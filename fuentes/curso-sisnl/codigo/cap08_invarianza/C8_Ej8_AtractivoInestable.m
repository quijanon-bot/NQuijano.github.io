%% C8_Ej8_AtractivoInestable -- Notas: sección 8.4 (LaSalle da convergencia, no estabilidad)
% QUÉ HACE   r' = r(1 - r), theta' = 1 - cos(theta) en el anillo 1/2 <= r <= 3/2.
%            Con V = (1 - r)^2, LaSalle da convergencia al círculo; todas las soluciones
%            van a (1, 0), que es INESTABLE.
% OBSERVE    Desde distancia 0.15 de (1, 0) la solución da la vuelta y se aleja hasta 2.
% ESPERADO   Excursión máxima 2.000; distancia final < 0.01 en t = 400 (convergencia lenta).
% EXPLORE    Arranque en theta = -0.15. ¿Qué cambia? ¿Por qué?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:inestable]
f = @(t, x) [x(1)*(1 - norm(x)) - x(2)*(1 - x(1)/norm(x)); ...   % r' = r(1 - r), theta' = 1 - cos(theta)
             x(2)*(1 - norm(x)) + x(1)*(1 - x(1)/norm(x))];   %   (en cartesianas: r cos(theta) = x1)
x0 = [cos(0.15); sin(0.15)];
[t, X] = ode45(f, linspace(0, 400, 40001), x0, opc);
d = sqrt((X(:, 1) - 1).^2 + X(:, 2).^2);
fprintf('distancia inicial = %.3f, máxima = %.3f, final (t = 400) = %.4f\n', d(1), max(d), d(end));
% [fin:inestable]

fig = estiloFigura(900, 420);
subplot(1, 2, 1);  plot(X(:, 1), X(:, 2));  axis equal;  grid on;  title('$\Omega$ y la solución');
subplot(1, 2, 2);  plot(t, d);  xlim([0 60]);  grid on;  xlabel('$t$');  ylabel('distancia a $(1,0)$');
