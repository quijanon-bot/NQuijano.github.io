%% C4_Ej6_Linealizacion -- Notas: sección 4.7 (linealización en espacio de estado)
% QUÉ HACE   (a) Duffing x'' + delta x' + x^3 - x = 0: equilibrios y valores propios
%            de cada linealización.  (b) Levitador magnético: equilibrio, matrices
%            A y B, valores propios y comparación con el modelo no lineal.
% OBSERVE    La misma ecuación tiene un equilibrio silla y dos estables; el levitador
%            tiene un valor propio positivo (sqrt(g/y*)): inestable en lazo abierto.
% ESPERADO   Duffing delta = 0.3: origen 0.861 y -1.161; (+-1, 0): -0.15 +- 1.41j.
%            Levitador: i* = 2.215 A, u* = 22.15 V, a21 = g/y* = 981, valores
%            propios +-31.32 y -20; la predicción lineal falla después de ~0.1 s.
% EXPLORE    Cambie y_des a 0.02 m: ¿el levitador se vuelve más o menos inestable?
clear; close all; clc;
if ~exist('variablesFase', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:duffing]
delta = 0.3;
J = @(x1) [0 1; 1 - 3*x1^2, -delta];       % jacobiano
for x1 = [0 1 -1]
    fprintf('equilibrio (%2d, 0): valores propios %s\n', x1, mat2str(eig(J(x1)).', 4));
end
% [fin:duffing]

% [ini:levitador]
M = 0.05;  R = 10;  L = 0.5;  Cf = 1e-3;  g = 9.81;  ydes = 0.01;
f = @(t, x, u) [x(2); g - Cf/M*x(3)^2/x(1); -R/L*x(3) + u/L];
x3e = sqrt(M*g*ydes/Cf);  ue = R*x3e;      % equilibrio
A = [0 1 0; Cf*x3e^2/(M*ydes^2) 0 -2*Cf*x3e/(M*ydes); 0 0 -R/L];
B = [0; 0; 1/L];
eig(A)
G = zpk(ss(A, B, [1 0 0], 0))
[tn, xn] = ode45(@(t, x) f(t, x, ue), [0 0.2], [ydes + 1e-4; 0; x3e]);
[yl, tl] = initial(ss(A, B, [1 0 0], 0), [1e-4; 0; 0], 0.2);
plot(tn, 1e3*(xn(:,1) - ydes), tl, 1e3*yl, '--'); grid on;
xlabel('t (s)'); ylabel('desviación de y (mm)'); legend('no lineal', 'lineal'); ylim([0 20]);
% [fin:levitador]
