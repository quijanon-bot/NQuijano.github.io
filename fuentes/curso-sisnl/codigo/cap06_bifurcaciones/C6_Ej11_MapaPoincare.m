%% C6_Ej11_MapaPoincare -- Notas: sección 6.8 (mapas de Poincaré)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Para x1' = mu x1 + x2 - x1 r, x2' = -x1 + mu x2 - x2 r (r = |x|), mu = 0.2,
%            con Sigma = {x2 = 0, x1 > 0}:
%            (1) compara la fórmula P(r0) = mu r0/(r0 + (mu - r0) e^{-2 pi mu}) con el
%            retorno simulado (mapaPoincare, en comun/);
%            (2) itera el mapa desde r0 = 0.1 y 0.3 (telaraña) y estima P'(mu).
% OBSERVE    Las dos sucesiones se acercan a r = mu de forma monótona, cada una desde su
%            lado; la distancia se multiplica por P'(mu) en cada vuelta.
% ESPERADO   P'(mu) = e^{-2 pi mu} = 0.2846. Tiempo de retorno 2 pi para todo r0.
% EXPLORE    Repita con mu = 0.02. ¿Qué pasa con P'(mu)? ¿Por qué el ciclo que nace en
%            una Hopf es "apenas" atractor?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:mapa]
mu = 0.2;
f = @(x) [mu*x(1) + x(2) - x(1)*norm(x);  -x(1) + mu*x(2) - x(2)*norm(x)];
P = @(r0) mu*r0./(r0 + (mu - r0)*exp(-2*pi*mu));
for r0 = [0.05 0.1 0.3]
    [xr, tau] = mapaPoincare(f, [r0; 0], @(x) x(2), -1);
    fprintf('r0 = %.2f: P simulado = %.8f, fórmula = %.8f, tiempo de retorno = %.6f\n', r0, xr(1), P(r0), tau);
end
dP = (P(mu + 1e-6) - P(mu - 1e-6))/2e-6;
fprintf("P'(mu) = %.6f, e^{-2 pi mu} = %.6f\n", dP, exp(-2*pi*mu));
seq = zeros(2, 8);  seq(:, 1) = [0.1; 0.3];
for k = 2:8, seq(:, k) = P(seq(:, k - 1)); end
disp('sucesiones de Poincaré:');  disp(seq);
% [fin:mapa]

fig = estiloFigura(1100, 480);
subplot(1, 2, 1);  hold on;                      % el circuito con mu = 0.1: la sucesión A_k
fc = @(x) [x(2) - (x(1)^3 - 0.1*x(1));  -x(1)];  oc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, Y] = ode45(@(t, x) fc(x), [0 4*6.29], [0.12; 0], oc);  plot(Y(:, 1), Y(:, 2), 'LineWidth', 0.9);
Ak = 0.12;  for k = 1:3, xr = mapaPoincare(fc, [Ak(end); 0], @(x) x(2), -1);  Ak(end + 1) = xr(1); end
Bq = fzero(@(s) [1 0]*mapaPoincare(fc, [s; 0], @(x) x(2), -1) - s, [0.2 0.6]);
[~, Y] = ode45(@(t, x) fc(x), [0 6.29], [Bq; 0], oc);  plot(Y(:, 1), Y(:, 2), 'Color', [42 157 143]/255);
plot([0 0.52], [0 0], 'Color', [224 159 62]/255, 'LineWidth', 3);
plot(Ak, 0*Ak, 'o', 'MarkerFaceColor', [209 73 91]/255, 'MarkerEdgeColor', 'none');  plot(Bq, 0, 'ks', 'MarkerFaceColor', 'k');
fprintf('circuito mu = 0.1: A_0..A_3 = %s; B = %.4f\n', mat2str(Ak, 4), Bq);
axis equal;  axis([-0.5 0.55 -0.5 0.5]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('Circuito, $\mu=0.1$: $A_k\to B$');
subplot(1, 2, 2);  q = linspace(0, 0.35, 200);  hold on;
plot(q, P(q), 'k', q, q, 'Color', [0.6 0.6 0.6]);
for i = 1:2
    s = seq(i, :);  xs = reshape([s(1:end-1); s(1:end-1)], 1, []);  ys = reshape([s(1:end-1); s(2:end)], 1, []);
    plot([s(1) xs(2:end) s(end)], [0 ys(2:end) s(end)]);
end
grid on;  axis([0 0.35 0 0.35]);  axis square;  xlabel('$r_k$');  ylabel('$r_{k+1}=P(r_k)$');
title('Telara\~na: $\mu=0.2$');
