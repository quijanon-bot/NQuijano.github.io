%% C12_Video_FaseNoMinima -- Video V12_2: la salida converge, el estado escapa
% QUÉ MUESTRA  x1' = x1 + x2, x2' = 3 x1^2 x2 + x1 + u, y = -x1^3 + x2, con la ley
%              u = -x1 + 3 x1^3 - 2 y. La trayectoria llega a Z* = {x2 = x1^3} y se
%              desliza por ella; y -> 0 mientras eta = x1 y el control explotan.
% USO          Ejecute. Video en videos/V12_2_fase_no_minima.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

k = 2;  lazo = @(t, x) [x(1) + x(2); 3*x(1)^2*x(2) + x(1) + (-x(1) + 3*x(1)^3 - k*(-x(1)^3 + x(2)))];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.005, 'Events', @(t, x) deal(abs(x(1)) - 2.2, 1, 0));
[ts, Xs] = ode45(lazo, [0 10], [0.05; 0.6], opc);
t = linspace(0, ts(end), 288);  X = interp1(ts, Xs, t);
y = -X(:,1).^3 + X(:,2);  u = -X(:,1) + 3*X(:,1).^3 - k*y;

fig = estiloFigura(1280, 720);
ax1 = subplot(2, 2, [1 3]); hold(ax1, 'on'); grid(ax1, 'on'); axis(ax1, [-0.3 2.4 -1 12]);
xx = linspace(-0.3, 2.4, 300);  plot(ax1, xx, xx.^3, 'Color', [42 157 143]/255, 'LineWidth', 4);
tr = plot(ax1, nan, nan, 'Color', [30 90 168]/255);  pto = plot(ax1, nan, nan, 'o', 'MarkerSize', 10, ...
     'MarkerFaceColor', [209 73 91]/255, 'MarkerEdgeColor', 'k');
xlabel(ax1, '$x_1=\eta$'); ylabel(ax1, '$x_2$'); title(ax1, 'Llega a $Z^*=\{x_2=x_1^3\}$... y se va por ella');
ax2 = subplot(2, 2, 2); hold(ax2, 'on'); grid(ax2, 'on'); xlim(ax2, [0 t(end)]); ylim(ax2, [-0.2 2.4]);
l1 = plot(ax2, nan, nan, 'Color', [30 90 168]/255);  l2 = plot(ax2, nan, nan, 'Color', [209 73 91]/255);
legend(ax2, '$y=\xi$', '$\eta=x_1$', 'Location', 'northwest'); title(ax2, 'La salida converge como se dise\~n\''o...');
ax3 = subplot(2, 2, 4); hold(ax3, 'on'); grid(ax3, 'on'); xlim(ax3, [0 t(end)]); ylim(ax3, [min(-1, min(u)) 1.05*max(u)]);
l3 = plot(ax3, nan, nan, 'Color', [108 74 182]/255);  xlabel(ax3, '$t$'); ylabel(ax3, '$u$');
title(ax3, '...pero el estado interno y el control explotan');
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V12_2_fase_no_minima'), 24);
end
for i = 1:numel(t)
    set(tr, 'XData', X(1:i,1), 'YData', X(1:i,2));  set(pto, 'XData', X(i,1), 'YData', X(i,2));
    set(l1, 'XData', t(1:i), 'YData', y(1:i));  set(l2, 'XData', t(1:i), 'YData', X(1:i,1));
    set(l3, 'XData', t(1:i), 'YData', u(1:i));
    drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
