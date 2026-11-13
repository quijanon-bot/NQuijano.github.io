%% C6_Ej11_MapaPoincare -- Notas: sección 6.8 (mapas de Poincaré)
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

fig = estiloFigura(600, 560);  q = linspace(0, 0.35, 200);  hold on;
plot(q, P(q), 'k', q, q, 'Color', [0.6 0.6 0.6]);
for i = 1:2
    s = seq(i, :);  xs = reshape([s(1:end-1); s(1:end-1)], 1, []);  ys = reshape([s(1:end-1); s(2:end)], 1, []);
    plot([s(1) xs(2:end) s(end)], [0 ys(2:end) s(end)]);
end
grid on;  axis([0 0.35 0 0.35]);  axis square;  xlabel('$r_k$');  ylabel('$r_{k+1}=P(r_k)$');
title('Telara\~na: $\mu=0.2$');
