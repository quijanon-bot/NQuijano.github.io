%% C8_Ej11_GradientePendulo -- Notas: sección 8.6 (el gradiente variable deduce la V del cap. 7)
% QUÉ HACE   Péndulo x1' = x2, x2' = -sin x1 - b x2 (b = 0.5). Con g = (sin x1 + k b x1 + k x2,
%            k x1 + x2): V = 1 - cos x1 + (k b x1^2 + 2 k x1 x2 + x2^2)/2 y
%            Vdot = -k x1 sin x1 - (b - k) x2^2. Compara la energía con V a lo largo de una solución
%            y calcula c*(k) = 2 + pi^2 k (b - k)/2.
% OBSERVE    La energía baja con escalones (Vdot = 0 en x2 = 0); V baja estrictamente.
% ESPERADO   Máximo de c*(k) en k = b/2 = 0.25 con c* = 2.308.
% EXPLORE    Tome k = b. ¿Qué pasa con Vdot y con la definición positiva de V?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:pendulo]
b = 0.5;  k = b/2;
f = @(t, x) [x(2); -sin(x(1)) - b*x(2)];
E = @(x) 1 - cos(x(:, 1)) + x(:, 2).^2/2;
V = @(x) 1 - cos(x(:, 1)) + (k*b*x(:, 1).^2 + 2*k*x(:, 1).*x(:, 2) + x(:, 2).^2)/2;
[t, X] = ode45(f, linspace(0, 20, 4001), [2; 0.8], opc);
fprintf('mayor subida de la energía = %.1e, de V = %.1e (debe ser < 0)\n', max(diff(E(X))), max(diff(V(X))));
kk = linspace(0, b, 101);  cs = 2 + pi^2*kk.*(b - kk)/2;
[cmax, i] = max(cs);
fprintf('c*(k) máximo en k = %.3f: c* = %.3f\n', kk(i), cmax);
% [fin:pendulo]

fig = estiloFigura(800, 420);  plot(t, E(X), '--', t, V(X));  grid on;  xlabel('$t$');  legend('energía', '$V$');
