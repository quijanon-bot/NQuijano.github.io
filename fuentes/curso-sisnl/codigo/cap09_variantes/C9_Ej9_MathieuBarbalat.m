%% C9_Ej9_MathieuBarbalat -- Notas: sección 9.6 (cuando Vdot es solo semidefinida)
% QUÉ HACE   Sigue los cinco pasos del ejemplo con la Mathieu amortiguada desde (1, 0):
%            W = x2^2 -> 0 (LaSalle--Yoshizawa), x2'' acotada, x2' -> 0 (Barbalat) y
%            x1 = -(x2' + x2)/(2 + sin t) -> 0.
% OBSERVE    La identidad del paso 5 se cumple en cada instante, no solo en el límite.
% ESPERADO   max |x2''| = 2.77; ||x(30)|| < 1e-5.
% EXPLORE    Repita con el sistema adaptativo de la sección 10.5 y omega = e^{-0.3t}.
%            ¿En qué paso falla el argumento?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-13);

% [ini:yoshizawa]
t = linspace(0, 30, 30001)';
[t, X] = ode45(@(t, x) [x(2); -x(2) - (2 + sin(t))*x(1)], t, [1; 0], opc);
x1 = X(:, 1);  x2 = X(:, 2);
x2d = -x2 - (2 + sin(t)).*x1;                             % x2'
x2dd = -x2d - cos(t).*x1 - (2 + sin(t)).*x2;              % x2'' (x1' = x2)
fprintf('paso 2: max |x2''''| = %.2f (acotada => x2'' uniformemente continua)\n', max(abs(x2dd)));
fprintf('paso 3: x2(30) - x2(0) = %.4f  (-> -x2(0) = 0)\n', x2(end) - x2(1));
fprintf('paso 4: max |x2''| en [25, 30] = %.1e\n', max(abs(x2d(t >= 25))));
fprintf('paso 5: max |x1 + (x2'' + x2)/(2 + sin t)| = %.1e;  ||x(30)|| = %.1e\n', ...
    max(abs(x1 + (x2d + x2)./(2 + sin(t)))), norm(X(end, :)));
% [fin:yoshizawa]

fig = estiloFigura(800, 360);
plot(t, x2.^2, 'r', t, x2d, 'Color', [0.5 0.3 0.7]);  hold on;  plot(t, x1, 'b', 'LineWidth', 2);
grid on;  xlim([0 20]);  xlabel('$t$');  legend('$x_2^2$', '$\dot x_2$', '$x_1$');
