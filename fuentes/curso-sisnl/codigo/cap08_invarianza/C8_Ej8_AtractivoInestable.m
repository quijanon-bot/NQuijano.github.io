%% C8_Ej8_AtractivoInestable -- Notas: sección 8.4 (LaSalle da convergencia, no estabilidad)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% ---- Figura de las notas (fig:iv-inestable) -------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
th = linspace(0, 2*pi, 300);
x0s = [[cos(0.15); sin(0.15)], 1.4*[cos(2); sin(2)], 0.6*[cos(-1); sin(-1)]];  col = [no; vi; ve];
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;
fill([1.5*cos(th) 0.5*cos(fliplr(th))], [1.5*sin(th) 0.5*sin(fliplr(th))], 1 - 0.15*(1 - az), 'EdgeColor', 'none');
plot(cos(th), sin(th), 'Color', co, 'LineWidth', 2);
for j = 1:3
    [ts, Xs] = ode45(f, linspace(0, 60, 6000), x0s(:, j), opc);
    plot(Xs(:, 1), Xs(:, 2), 'Color', col(j, :), 'LineWidth', 1);
    plot(x0s(1, j), x0s(2, j), 'o', 'Color', col(j, :), 'MarkerFaceColor', col(j, :), 'MarkerSize', 3);
    dist{j} = hypot(Xs(:, 1) - 1, Xs(:, 2));
end
plot(1, 0, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
axis equal;  axis([-1.6 1.6 -1.6 1.6]);  box on;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
title('$\Omega=\{\frac12\le r\le\frac32\}$, $E=M$');
subplot(1, 2, 2);  hold on;  grid on;
for j = 1:3, plot(ts, dist{j}, 'Color', col(j, :), 'LineWidth', 1.3);  end
axis([0 60 0 2.2]);  xlabel('$t$');  ylabel('distancia a $(1,0)$');  title('converge, pero no es estable');
