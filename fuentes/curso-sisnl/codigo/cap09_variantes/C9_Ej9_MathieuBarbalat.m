%% C9_Ej9_MathieuBarbalat -- Notas: sección 9.6 (cuando Vdot es solo semidefinida)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% ---- Figura de las notas (fig:vt-yoshizawa) -------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(800, 420);  hold on;  grid on;
plot(t, x2.^2, 'Color', co);  plot(t, x2d, 'Color', vi, 'LineWidth', 1);  plot(t, x1, 'Color', az);
plot([0 20], [0 0], 'Color', no, 'LineWidth', 0.6);  xlim([0 20]);  xlabel('$t$');
legend('$W=x_2^2$ (LaSalle--Yoshizawa: $\to0$)', '$\dot x_2$ (Barbalat: $\to0$)', '$x_1=-(\dot x_2+x_2)/(2+\sin t)\to0$');
title('Mathieu amortiguada: de $x_2\to0$ a $x_1\to0$');
