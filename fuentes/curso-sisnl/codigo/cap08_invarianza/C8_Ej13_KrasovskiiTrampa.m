%% C8_Ej13_KrasovskiiTrampa -- Notas: sección 8.7 (||f||^2 se anula en todos los equilibrios)
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
salir = odeset(opc, 'Events', @(t, x) deal(x(1) - 10, 1, 0));
[te, ~] = ode45(f, [0 10], [1.05; 0], salir);
fprintf('desde (1.05, 0): x1 = 10 en t = %.2f\n', te(end));
% [fin:k2]
