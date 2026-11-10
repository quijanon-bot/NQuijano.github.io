%% C2_Ej1_Seno -- Notas: sección 2.2 (el flujo sobre la recta)
% QUÉ HACE   Dibuja la línea de fase de x' = sin x, simula 15 condiciones
%            iniciales y compara la simulación desde x0 = pi/4 con la solución
%            exacta x(t) = 2 atan( tan(x0/2) e^t ).
% OBSERVE    Ninguna solución cruza las rectas x = k pi: los equilibrios son
%            barreras. La solución desde pi/4 se acerca a pi, no a infinito.
% ESPERADO   x(1) = 1.6891 desde x0 = pi/4;  error máximo frente a la solución
%            exacta < 1e-8;  f'(k pi) = (-1)^k: los pares inestables, los impares estables.
% EXPLORE    Cambie a x' = sin(x) - 0.5. ¿Dónde están ahora los equilibrios?
%            ¿Y con sin(x) - 1.2? (este es el adelanto de la silla-nodo del capítulo 6)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:exacta]
f = @(x) sin(x);  x0 = pi/4;
xex = @(t) 2*atan(tan(x0/2)*exp(t));
[t, x] = ode45(@(t, x) f(x), linspace(0, 6, 601), x0, odeset('RelTol', 1e-11, 'AbsTol', 1e-12));
fprintf('x(1) = %.4f (exacta %.4f);  error máximo = %.1e;  x(6) = %.4f -> pi\n', ...
        x(101), xex(1), max(abs(x - xex(t))), x(end));
% [fin:exacta]

fig = estiloFigura(1100, 420);
ax = subplot(1, 2, 1);
% [ini:linea]
eq = lineaFase(ax, f, [-2*pi 2*pi], 'Equilibrios', (-2:2)*pi);
for k = 1:numel(eq.x), fprintf('x* = %6.3f   f''(x*) = %+.0f   %s\n', eq.x(k), cos(eq.x(k)), eq.tipo{k}); end
% [fin:linea]
xlabel(ax, '$x$'); ylabel(ax, '$\dot x=\sin x$'); title(ax, 'l\''inea de fase');
subplot(1, 2, 2); hold on;
for x0i = linspace(-2*pi + 0.2, 2*pi - 0.2, 15)
    [ti, xi] = ode45(@(t, x) f(x), [0 6], x0i); plot(ti, xi);
end
for k = -2:2, plot([0 6], k*pi*[1 1], 'k--', 'LineWidth', 0.7); end
plot(t(1:50:end), xex(t(1:50:end)), 'ko'); grid on; xlabel('$t$'); ylabel('$x(t)$');
title('ninguna soluci\''on cruza un equilibrio');
