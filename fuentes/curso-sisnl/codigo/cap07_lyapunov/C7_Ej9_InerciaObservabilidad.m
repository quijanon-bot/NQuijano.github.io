%% C7_Ej9_InerciaObservabilidad -- Notas: sección 7.7 (lo que la ecuación detecta)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) A(mu) = [-1 2; 0 mu], Q = I: resuelve A'P + PA = -Q para varios mu y
%            cuenta los valores propios negativos de P.
%            (2) Dos masas unidas por un resorte kappa, con amortiguador b solo en la
%            masa 1: V = energía cumple A'P + PA = -C'C con C = [0 sqrt(b) 0 0].
%            Compara kappa = 0 y kappa = 0.4.
% OBSERVE    (1) Para mu > 0 la ecuación SÍ tiene solución, pero P es indefinida (tantos
%            valores propios negativos como valores propios inestables de A). En mu = 0
%            y mu = 1 no hay solución única.  (2) Con Q = C'C >= 0 y P > 0, A es Hurwitz
%            solo si (A, C) es observable.
% ESPERADO   (1) mu = -0.5: P > 0; mu = 0.5: un valor propio negativo.
%            (2) kappa = 0: rango 2, max Re lambda = 0; kappa = 0.4: rango 4, Hurwitz.
% EXPLORE    En (2), ¿qué pasa si el amortiguador se pone en la masa 2 y kappa = 0?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:inercia]
warning('off', 'ecuacionLyapunov:singular');
for mu = [-0.5 -0.01 0 0.5 1 1.5]
    P = ecuacionLyapunov([-1 2; 0 mu], eye(2));
    if any(isnan(P(:)))
        fprintf('mu = %5.2f: sin solución única (lambda_i + lambda_j = 0)\n', mu);
    else
        fprintf('mu = %5.2f: eig(P) = (%9.3f, %9.3f) -> %d negativo(s)\n', mu, eig(P), sum(eig(P) < 0));
    end
end
warning('on', 'ecuacionLyapunov:singular');
% [fin:inercia]

% [ini:masas]
k1 = 1;  k2 = 1;  b = 0.3;  C = [0 sqrt(b) 0 0];
for ka = [0 0.4]
    A = [0 1 0 0; -(k1 + ka) -b ka 0; 0 0 0 1; ka 0 -(k2 + ka) 0];
    P = 0.5*[k1 + ka 0 -ka 0; 0 1 0 0; -ka 0 k2 + ka 0; 0 0 0 1];
    Ob = [C; C*A; C*A^2; C*A^3];
    fprintf('kappa = %.1f: |A''P + PA + C''C| = %.1e, rango(O) = %d, max Re eig(A) = %.4f\n', ...
            ka, norm(A'*P + P*A + C'*C), rank(Ob), max(real(eig(A))));
end
% [fin:masas]

% ---- Figuras de las notas ----------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;

% Figura 7.x (fig:ly-inercia): valores propios de P(mu), escala logarítmica con signo
mus = linspace(-1.5, 1.8, 3301);  lam = nan(2, numel(mus));
warning('off', 'ecuacionLyapunov:singular');
for k = 1:numel(mus)
    if abs(mus(k)) > 2e-3 && abs(mus(k) - 1) > 2e-3
        lam(:, k) = sort(eig(ecuacionLyapunov([-1 2; 0 mus(k)], eye(2))));
    end
end
warning('on', 'ecuacionLyapunov:singular');
sl = @(z) sign(z).*log10(1 + abs(z));
fig1 = estiloFigura(1000, 420);  hold on;
fill([-1.5 0 0 -1.5], [-3 -3 3 3], [0.94 0.95 0.97], 'EdgeColor', 'none');
plot(mus, sl(lam(1, :)), 'Color', co);  plot(mus, sl(lam(2, :)), 'Color', az);
plot([-1.5 1.8], [0 0], 'Color', [0.6 0.6 0.6], 'LineWidth', 0.7);
plot([0 0], [-3 3], 'k:', [1 1], [-3 3], 'k:', 'LineWidth', 0.8);
text(-1.4, 2.2, '$A$ Hurwitz: $P>0$');  text(0.12, -0.5, '$A$ inestable: $P$ indefinida', 'Color', co);
axis([-1.5 1.8 -3 3]);  grid on;  xlabel('$\mu$');  ylabel('$\mathrm{sgn}(\lambda)\log_{10}(1+|\lambda|)$');
title('Valores propios de $P$ para $A(\mu)=[-1\ 2;\ 0\ \mu]$');

% Figura 7.x (fig:ly-masas): dos masas desde q1 = q2 = 1
tm = linspace(0, 80, 1601);  kas = [0 0.4];
tit = {'$\kappa=0$: $(A,C)$ no observable', '$\kappa=0.4$: observable, Hurwitz'};
fig2 = estiloFigura(1100, 400);
for j = 1:2
    ka = kas(j);  A = [0 1 0 0; -(k1 + ka) -b ka 0; 0 0 0 1; ka 0 -(k2 + ka) 0];
    Xm = zeros(4, numel(tm));
    for k = 1:numel(tm), Xm(:, k) = expm(A*tm(k))*[1; 0; 1; 0]; end
    ax(j) = subplot(1, 2, j);  hold on;
    plot(tm, Xm(1, :), 'Color', az, 'LineWidth', 1);  plot(tm, Xm(3, :), 'Color', co, 'LineWidth', 1);
    ylim([-1.1 1.1]);  grid on;  xlabel('$t$');  title(tit{j});
end
legend(ax(1), '$q_1$ (con amortiguador)', '$q_2$', 'Location', 'southeast');
