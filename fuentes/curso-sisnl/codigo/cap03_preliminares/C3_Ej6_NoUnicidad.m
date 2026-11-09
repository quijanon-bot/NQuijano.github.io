%% C3_Ej6_NoUnicidad -- Notas: sección 3.9 (continuidad no basta)
% QUÉ HACE   Resuelve x' = x^(1/3), x(0) = 0. Muestra la familia de soluciones
%            x_c(t) = 0 para t <= c y ((2/3)(t - c))^(3/2) para t >= c, y lo que
%            hace ode45 desde 0 y desde un número muy pequeño.
% OBSERVE    Desde x0 = 0, ode45 devuelve la solución nula: el integrador "elige"
%            una de infinitas soluciones sin avisar. Desde x0 = 1e-12 sigue a la
%            rama que despega en c = 0.
% ESPERADO   x_0(3) = 2^(3/2) = 2.8284;  ode45 desde 1e-12 llega a 2.8284 en t = 3.
%            Residuo numérico de x' - x^(1/3) en cada x_c: < 1e-3 (derivada por diferencias).
% EXPLORE    ¿Qué pasa con x' = |x|^(1/2)? ¿Y con x' = x^(1/3) desde x0 = -1e-12?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:familia]
xc = @(t, c) (t > c).*((2/3)*max(t - c, 0)).^(3/2);
t  = linspace(0, 3, 3001);
for c = [0 1 2]
    x  = xc(t, c);  dx = gradient(x, t);
    res = max(abs(dx(t > c + 0.05) - nthroot(x(t > c + 0.05), 3)));
    fprintf('c = %g: x(3) = %.4f,  residuo de x'' - x^(1/3) = %.1e\n', c, x(end), res);
end
% [fin:familia]

% [ini:ode45]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-14);
[~, X0] = ode45(@(t, x) nthroot(x, 3), [0 3], 0, opc);
[~, Xe] = ode45(@(t, x) nthroot(x, 3), [0 3], 1e-12, opc);
fprintf('ode45 desde 0: x(3) = %g;   desde 1e-12: x(3) = %.4f\n', X0(end), Xe(end));
% [fin:ode45]

fig = estiloFigura(700, 420); hold on;
for c = [0 0.5 1 1.5 2], plot(t, xc(t, c)); end
plot(t, 0*t, 'k', 'LineWidth', 3); grid on; xlabel('$t$'); ylabel('$x$');
title('$\dot x=x^{1/3}$, $x(0)=0$: infinitas soluciones');
