%% C4_Ej2_Nulclinas -- Notas: secciones 4.2 y 4.5 (nulclinas, sistema de la clase del 19 de agosto)
% QUÉ HACE   Para x1' = -x1 + x1 x2, x2' = x1 + x2 - 2 x1 x2 dibuja las nulclinas
%            (de x1: x1 = 0 y x2 = 1; de x2: la hipérbola x2 = x1/(2 x1 - 1)),
%            busca los equilibrios con fsolve y los clasifica con la jacobiana.
% OBSERVE    El cruce (0,1) de las DOS ramas de la nulclina de x1 no es un
%            equilibrio: allí f2 = 1. Los equilibrios son cruces de colores distintos.
% ESPERADO   (0,0): silla (lambda = -1, 1).  (1,1): foco estable, -0.5 +- 0.866j, horario.
% EXPLORE    Cambie el término -2 x1 x2 por -c x1 x2. ¿Cómo se mueven las nulclinas y
%            el equilibrio de coexistencia? ¿Para qué c deja de existir?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:nulclinas]
f = @(x) [-x(1) + x(1)*x(2); x(1) + x(2) - 2*x(1)*x(2)];
fig = estiloFigura(700, 620);  ax = gca;
retratoFase(ax, f, [-2 3], [-2 3], 'T', 15);
plot(ax, [0 0], [-2 3], '--', 'Color', [209 73 91]/255, 'LineWidth', 2);      % f1 = 0
plot(ax, [-2 3], [1 1], '--', 'Color', [209 73 91]/255, 'LineWidth', 2);
x1 = linspace(-2, 3, 2001);  x2 = x1./(2*x1 - 1);  x2(abs(2*x1 - 1) < 0.02) = NaN;
plot(ax, x1, x2, '--', 'Color', [224 159 62]/255, 'LineWidth', 2);          % f2 = 0
opc = optimset('TolFun', 1e-14, 'TolX', 1e-14, 'Display', 'off');
for x0 = [[0.1; -0.1], [0.9; 1.2]]
    xe = fsolve(f, x0, opc);
    A = jacobianoNumerico(f, xe);
    [tipo, info] = clasificarEquilibrio(A, 1e-6);
    fprintf('equilibrio (%.4f, %.4f): %s, lambda = %s %s\n', xe, tipo, num2str(info.lambda.', '%.4f  '), info.giro);
    plot(ax, xe(1), xe(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'w');
end
fprintf('en (0,1): f = (%g, %g)  -> no es equilibrio\n', f([0; 1]));
title('Nulclinas: de $x_1$ en coral, de $x_2$ en \''ambar');
% [fin:nulclinas]
