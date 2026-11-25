%% C8_Ej13_KrasovskiiTrampa -- Notas: sección 8.7 (||f||^2 se anula en todos los equilibrios)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   x1' = -x1 + x1^3, x2' = -x2 con P = I. Calcula el límite r < 1/sqrt3 de la
%            condición de Krasovskii, el nivel 4/27 y simula desde un punto cerca de la silla.
% OBSERVE    (1.05, 0) tiene V = ||f||^2 = 0.0116 < 0.12 y escapa: V no distingue
%            equilibrios estables de inestables.
% ESPERADO   (r - r^3)^2 -> 4/27 = 0.148 en r = 1/sqrt3. Escape (x1 = 10) en t = 1.18.
% EXPLORE    Arranque en (0.95, 0). ¿Está en el estimado? ¿Converge?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:k2]
f = @(t, x) [-x(1) + x(1)^3; -x(2)];
V = @(x) (x(1) - x(1)^3)^2 + x(2)^2;
r = 1/sqrt(3);
fprintf('la condición vale en |x1| < 1/sqrt3 = %.3f; (r - r^3)^2 = %.4f = 4/27\n', r, (r - r^3)^2);
fprintf('V(1, 0) = %g (silla), V(1.05, 0) = %.4f\n', V([1; 0]), V([1.05; 0]));
salir = odeset(opc, 'Events', @(t, x) eventoODE(x(1) - 10, 1, 0));
[te, ~] = ode45(f, [0 10], [1.05; 0], salir);
fprintf('desde (1.05, 0): x1 = 10 en t = %.2f\n', te(end));
% [fin:k2]

% ---- Figura de las notas (fig:iv-krasovskii-trampa) -----------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(800, 480);  hold on;
x1 = linspace(-1.6, 1.6, 600);  x2 = linspace(-0.6, 0.6, 300);  [X1, X2] = meshgrid(x1, x2);
VV = (X1 - X1.^3).^2 + X2.^2;  cc = 0.12;
pintarZonas(x1, x2, {VV <= cc & abs(X1) < r, VV <= cc & abs(X1) >= r}, [az; gr], [0.25 0.25]);
plot([r r], [-0.6 0.6], ':', 'Color', no, 'LineWidth', 0.9);  plot(-[r r], [-0.6 0.6], ':', 'Color', no, 'LineWidth', 0.9);
plot([1 1], [-0.6 0.6], 'Color', co, 'LineWidth', 1.2);  plot(-[1 1], [-0.6 0.6], 'Color', co, 'LineWidth', 1.2);
[~, X] = ode45(f, [0 12], [0.85; 0.5], opc);  plot(X(:, 1), X(:, 2), 'Color', ve, 'LineWidth', 1.2);
sal16 = odeset(opc, 'Events', @(t, x) eventoODE(abs(x(1)) - 1.6, 1, 0));
[~, X] = ode45(f, [0 10], [1.05; 0.1], sal16);  plot(X(:, 1), X(:, 2), 'Color', co, 'LineWidth', 1.3);
plot(0, 0, 'o', 'MarkerFaceColor', no, 'MarkerEdgeColor', no);
plot([-1 1], [0 0], 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
axis([-1.6 1.6 -0.6 0.6]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');
title('$V=\|f\|^2$ se anula en las tres ra\''ices');
