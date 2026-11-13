%% C10_Ej6_SontagLineal -- Notas: sección 10.4 (planta lineal escalar)
% QUÉ HACE   Aplica la fórmula de Sontag (leySontag, en comun/) a x' = f0 x + g0 u con
%            V = x^2/2 y compara la ganancia con -(f0 + sqrt(f0^2 + g0^4))/g0.
% OBSERVE    Si f0 < 0 (planta estable), la ganancia tiende a cero: Sontag no se molesta.
%            Si g0 -> 0 con f0 > 0, la ganancia crece como -2 f0/g0.
% ESPERADO   f0 = g0 = 1: k = -2.414 x; u(0) = -4.83 desde x(0) = 2.
% EXPLORE    Barra f0 de -5 a 5 con g0 = 1 y grafique la ganancia. ¿Dónde vale -1?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:lineal]
f0 = 1;  g0 = 1;  x0 = 2;
u0 = leySontag(f0*x0^2, g0*x0);
fprintf('u(0) = %.4f;  ganancia = %.4f  (fórmula: %.4f)\n', u0, u0/x0, -(f0 + sqrt(f0^2 + g0^4))/g0);
for f0 = [-5 -1 1 5]
    fprintf('f0 = %+d, g0 = 1: ganancia %.4f\n', f0, leySontag(f0, 1));
end
fprintf('sin control (u = 1): x(10) = %.3g\n', 3*exp(10) - 1);
% [fin:lineal]

ff = linspace(-5, 5, 200);  fig = estiloFigura(700, 420);
plot(ff, arrayfun(@(a) leySontag(a, 1), ff), ff, -(ff + 1), '--');  grid on;
xlabel('$f_0$');  ylabel('ganancia');  legend('Sontag', 'cancelar y poner $-1$');
