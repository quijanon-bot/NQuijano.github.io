%% C4_Ej7_Linealizacion -- Notas: sección 4.5 (linealización y Hartman-Grobman)
% QUÉ HACE   (1) Para x1' = x1 + x1 x2, x2' = -x2 + x2^2 + x1 x2 - x1^3 (diapositivas
%            2026) busca los tres equilibrios con fsolve, calcula la jacobiana
%            (analítica y numérica) y los clasifica. (2) Dibuja el retrato.
% OBSERVE    Los tres equilibrios son hiperbólicos: cerca de cada uno el retrato no
%            lineal es el de su linealización (Hartman-Grobman). Lejos, no.
% ESPERADO   (0,0) silla; (0,1) nodo inestable (lambda = 2, 1);
%            (1,-1) foco estable (lambda = -1 +- 1.732j).
% EXPLORE    Agregue al sistema el término +mu*x1 en la segunda ecuación. ¿Para qué mu
%            deja (1,-1) de ser un foco? ¿Y de ser estable?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:tres]
f = @(x) [x(1) + x(1)*x(2); -x(2) + x(2)^2 + x(1)*x(2) - x(1)^3];
J = @(x) [1 + x(2), x(1); x(2) - 3*x(1)^2, -1 + 2*x(2) + x(1)];   % jacobiana analítica
opc = optimset('TolFun', 1e-14, 'TolX', 1e-14, 'Display', 'off');
semillas = [[0.1; 0.1], [0.1; 0.9], [0.9; -0.9]];
Xe = zeros(2, 3);
for k = 1:3
    xe = fsolve(f, semillas(:, k), opc);  Xe(:, k) = xe;
    A = J(xe);
    fprintf('(%6.3f, %6.3f): %-16s lambda = %s   |J - J_num| = %.1e\n', xe, ...
            clasificarEquilibrio(A, 1e-8), num2str(eig(A).', '%.4f  '), norm(A - jacobianoNumerico(f, xe)));
end
% [fin:tres]

fig = estiloFigura(700, 620);
retratoFase(gca, f, [-2 2.5], [-3 2.5], 'T', 12, 'Equilibrios', Xe);
title('$\dot x_1=x_1+x_1x_2,\ \dot x_2=-x_2+x_2^2+x_1x_2-x_1^3$');
