%% C3_Ej7_Picard -- Notas: sección 3.9 (aproximaciones sucesivas)
% QUÉ HACE   Aplica el operador de Picard (P x)(t) = x0 + int_0^t f(x(s)) ds a
%            x' = x, x(0) = 1, en [0, 1], empezando en x_0(t) = 1. Luego calcula
%            el intervalo que garantiza el teorema local para x' = x^2, x(0) = 1.
% OBSERVE    Las iteraciones son los polinomios de Taylor de e^t y el error en
%            la norma del máximo cae como 1/(k+1)!. Para x' = x^2 el teorema
%            garantiza [0, 0.207], aunque la solución vive en [0, 1).
% ESPERADO   Error de la iteración 5 en [0,1]: 1.6152e-03 (= e - sum_{j<=5} 1/j!).
%            x' = x^2: delta = max_r min(r/(L r + h), 1/L) con L = 2(1 + r), h = 1:
%            r* = 1/sqrt(2), delta* = 0.2071.
% EXPLORE    Itere también x' = x^2: ¿converge en [0, 0.2]? ¿Y en [0, 0.9]?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:picard]
t = linspace(0, 1, 10001);  f = @(x) x;  x0 = 1;
x = ones(size(t));                               % x_0(t) = x0
for k = 1:6
    x = x0 + cumtrapz(t, f(x));                  % (P x)(t)
    fprintf('iteración %d: error ||x_k - e^t||_C = %.4e\n', k, max(abs(x - exp(t))));
end
% [fin:picard]

% [ini:delta]
r = linspace(1e-3, 5, 50001);  L = 2*(1 + r);  h = 1;
delta = min(r./(L.*r + h), 1./L);               % con rho -> 1
[dmax, k] = max(delta);
fprintf('x'' = x^2, x(0) = 1: el teorema garantiza [0, %.4f] (r = %.4f); la solución vive en [0, 1)\n', ...
        dmax, r(k));
% [fin:delta]

fig = estiloFigura(700, 420); hold on;
x = ones(size(t));
for k = 1:4, x = x0 + cumtrapz(t, f(x)); plot(t, x); end
plot(t, exp(t), 'k--'); grid on; xlabel('$t$'); legend('$x_1$', '$x_2$', '$x_3$', '$x_4$', '$e^t$', 'Location', 'northwest');
