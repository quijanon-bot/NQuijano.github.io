%% C4_Ej7_Bioreactor -- Notas: sección 4.7 (bioreactor con inhibición por sustrato)
% QUÉ HACE   Halla los tres equilibrios, linealiza alrededor de los dos no triviales
%            con el jacobiano analítico y obtiene las cuatro funciones de transferencia.
%            Opcional (MATLAB): trim y linmod sobre el modelo de crearModelo_Bioreactor.
% OBSERVE    El equilibrio de operación (0.995, 1.512) es inestable: allí la tasa de
%            crecimiento DISMINUYE con el sustrato (inhibición).
% ESPERADO   x2* = 0.1746 y 1.5122. En (0.9951, 1.5122): A = [0 -0.0679; -0.75 -0.1302],
%            valores propios 0.1698 y -0.3. En (1.5302, 0.1746): -0.3 y -2.262.
% EXPLORE    Arranque cerca del equilibrio inestable, por encima y por debajo.
clear; close all; clc;
if ~exist('variablesFase', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:equilibrios]
mumax = 0.53;  km = 0.12;  k1 = 0.4545;  Y = 0.4;  u1 = 0.3;  u2 = 4;
x2e = sort(roots([u1*k1, u1 - mumax, u1*km]))  % mu(x2) = u1: dos soluciones
x1e = Y*(u2 - x2e)                          % y el lavado: (0, u2)
% [fin:equilibrios]

% [ini:jacobiano]
mu  = @(x2) mumax*x2/(km + x2 + k1*x2^2);
dmu = @(x2) mumax*(km - k1*x2^2)/(km + x2 + k1*x2^2)^2;
for i = 1:2
    a = x1e(i);  c = x2e(i);
    A = [mu(c) - u1, a*dmu(c); -mu(c)/Y, -u1 - a*dmu(c)/Y];
    B = [-a, 0; u2 - c, u1];
    fprintf('\nequilibrio (%.4f, %.4f):\n', a, c);  disp(A);  disp(eig(A).');
end
G = tf(ss(A, B, eye(2), 0))                 % 2 x 2, en el punto de operación (0.995, 1.512)
% [fin:jacobiano]

% [ini:linmod]
% Solo en MATLAB con Simulink:
% crearModelo_Bioreactor;
% [X, ~, U] = trim('Bioreactor', [0.99; 1.5], [u1; u2], [], [], [1; 2], [])
% [A, B, C, D] = linmod('Bioreactor', X, [u1; u2])
% [fin:linmod]
