%% C10_Ej15_PequenaGanancia -- Notas: sección 10.7 (retroalimentación y pequeña ganancia)
% QUÉ HACE   Para x1' = -x1 + a x2, x2' = -x2 + b sin x1, con a = 1:
%            b = 0.8 (|ab| < 1), b = 1.2 (ab > 1) y b = -3 (|ab| > 1 pero GAS).
%            Calcula equilibrios y valores propios, y simula desde varios puntos.
% OBSERVE    Con b = 1.2 el origen es una silla y aparecen dos nodos estables. Con b = -3
%            la pequeña ganancia falla y aun así todas las trayectorias van al origen.
% ESPERADO   b = 1.2: x* = 1.027, ab cos x* = 0.62. b = -3: valores propios -1 +- j sqrt3.
% EXPLORE    Con b = -3, calcule la divergencia del campo. ¿Por qué no hay órbitas cerradas?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:ganancia]
a = 1;  opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
xs = fzero(@(x) x - 1.2*sin(x), [0.5 2]);
fprintf('b = 1.2: x* = %.4f, ab cos x* = %.4f, origen: %s\n', xs, 1.2*cos(xs), mat2str(eig([-1 1; 1.2 -1]).', 4));
fprintf('b = -3: valores propios en el origen %s\n', mat2str(eig([-1 1; -3 -1]).', 4));
fig = estiloFigura(1300, 420);  bs = [0.8 1.2 -3];
for i = 1:3
    b = bs(i);  f = @(t, x) [-x(1) + a*x(2); -x(2) + b*sin(x(1))];
    subplot(1, 3, i);  hold on;
    for x0 = [-2.8 2.5; 2.8 -2.5; 2.8 2.5; -2.8 -2.5; 0.3 0.05; -0.3 -0.05]'
        [~, X] = ode45(f, [0 20], x0, opc);  plot(X(:, 1), X(:, 2));
    end
    fprintf('b = %+.1f: desde (-0.3, -0.05) termina en (%.3f, %.3f)\n', b, X(end, 1), X(end, 2));
    axis equal;  axis([-3 3 -3 3]);  grid on;  title(sprintf('$ab=%g$', a*b));
end
% [fin:ganancia]
