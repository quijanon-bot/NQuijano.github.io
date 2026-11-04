%% C11_Video_LaSalle -- Video V11_2: OSP + ZSO, la trayectoria toca E y no se queda
% QUÉ MUESTRA  El RLC serie con u = 0 en el plano (x1, x2) con los círculos de nivel
%              de V y la recta E = {x2 = 0} (donde V' = 0) en rojo. A la derecha,
%              V(x(t)): cada vez que la trayectoria cruza E, la curva se aplana.
% USO          Ejecute. Video en videos/V11_2_lasalle.mp4.
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

[t, X] = ode45(@(t, x) [x(2); -x(1) - x(2)], linspace(0, 14, 701), [1.5; 0], ...
               odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
V = (X(:,1).^2 + X(:,2).^2)/2;
fig = estiloFigura(1280, 620);
ax1 = subplot(1,2,1); hold(ax1, 'on'); axis(ax1, 'equal'); axis(ax1, [-1.7 1.7 -1.7 1.7]); grid(ax1, 'on');
th = linspace(0, 2*pi, 200);
for c = 0.25:0.25:1.25, plot(ax1, sqrt(2*c)*cos(th), sqrt(2*c)*sin(th), 'Color', [0.79 0.82 0.87]); end
plot(ax1, [-1.7 1.7], [0 0], 'Color', [0.82 0.29 0.36], 'LineWidth', 2.5);
tray = plot(ax1, nan, nan, 'LineWidth', 2);  pto = plot(ax1, nan, nan, 'o', 'MarkerSize', 9, 'MarkerFaceColor', [0.88 0.62 0.24]);
xlabel(ax1, '$x_1$ (carga)'); ylabel(ax1, '$x_2=y$ (corriente)'); title(ax1, '$E=\{\dot V=0\}=\{x_2=0\}$ en rojo');
ax2 = subplot(1,2,2); hold(ax2, 'on'); grid(ax2, 'on'); xlim(ax2, [0 14]); ylim(ax2, [0 1.2]);
lV = plot(ax2, nan, nan, 'k', 'LineWidth', 2.5); xlabel(ax2, '$t$'); title(ax2, '$V(x(t))$, $\dot V=-x_2^2$');

if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V11_2_lasalle'), 30);
end
for k = 1:numel(t)
    set(tray, 'XData', X(1:k,1), 'YData', X(1:k,2)); set(pto, 'XData', X(k,1), 'YData', X(k,2));
    set(lV, 'XData', t(1:k), 'YData', V(1:k));
    if k > 1 && sign(X(k,2)) ~= sign(X(k-1,2))
        plot(ax2, [t(k) t(k)], [0 1.2], '--', 'Color', [0.82 0.29 0.36]);
        plot(ax1, X(k,1), 0, 'x', 'Color', [0.82 0.29 0.36], 'MarkerSize', 12, 'LineWidth', 2);
    end
    drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
