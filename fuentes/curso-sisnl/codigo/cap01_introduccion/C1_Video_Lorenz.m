%% C1_Video_Lorenz -- Video V1_1: determinismo no es predictibilidad
% QUÉ MUESTRA  Dos trayectorias del sistema de Lorenz (sigma = 10, rho = 28,
%              beta = 8/3) que empiezan a 1e-9 una de la otra. Durante unos 25
%              segundos son indistinguibles; después cada una va por su lado.
%              Abajo, la distancia entre las dos en escala logarítmica.
% USO          Ejecute. Video en videos/V1_1_lorenz.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

lor = @(t, x) [10*(x(2) - x(1)); x(1)*(28 - x(3)) - x(2); x(1)*x(2) - 8/3*x(3)];
o = odeset('RelTol', 1e-12, 'AbsTol', 1e-12);
t = linspace(0, 40, 1201);
[~, A] = ode45(lor, t, [1; 1; 1], o);  [~, B] = ode45(lor, t, [1 + 1e-9; 1; 1], o);
d = sqrt(sum((A - B).^2, 2)) + 1e-16;
fig = estiloFigura(1280, 720);
ax1 = subplot(3, 1, [1 2]); hold(ax1, 'on'); grid(ax1, 'on'); view(ax1, 25, 18);
axis(ax1, [-25 25 -30 30 0 50]);
ha = plot3(ax1, nan, nan, nan, 'LineWidth', 1.2);  hb = plot3(ax1, nan, nan, nan, 'LineWidth', 1.2);
pa = plot3(ax1, nan, nan, nan, 'o', 'MarkerFaceColor', [30 90 168]/255, 'MarkerSize', 8);
pb = plot3(ax1, nan, nan, nan, 'o', 'MarkerFaceColor', [209 73 91]/255, 'MarkerSize', 8);
ax2 = subplot(3, 1, 3); hd = semilogy(ax2, nan, nan); grid(ax2, 'on');
xlim(ax2, [0 40]); ylim(ax2, [1e-10 1e2]); xlabel(ax2, '$t$'); ylabel(ax2, '$\|\Delta x\|$');
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V1_1_lorenz'), 30);
end
for k = 2:numel(t)
    i0 = max(1, k - 150);
    set(ha, 'XData', A(i0:k,1), 'YData', A(i0:k,2), 'ZData', A(i0:k,3));
    set(hb, 'XData', B(i0:k,1), 'YData', B(i0:k,2), 'ZData', B(i0:k,3));
    set(pa, 'XData', A(k,1), 'YData', A(k,2), 'ZData', A(k,3));
    set(pb, 'XData', B(k,1), 'YData', B(k,2), 'ZData', B(k,3));
    set(hd, 'XData', t(1:k), 'YData', d(1:k));
    title(ax1, sprintf('$t = %.1f$', t(k))); drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
