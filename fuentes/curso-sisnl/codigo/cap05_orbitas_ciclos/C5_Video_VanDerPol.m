%% C5_Video_VanDerPol -- Video V5_3: todas las trayectorias llegan al mismo ciclo
% QUÉ MUESTRA  Van der Pol con mu = 1: ocho condiciones iniciales (cerca del
%              origen y lejos) se mueven a la vez en el plano de fase; todas
%              terminan en el mismo ciclo límite, con la misma amplitud (~2).
%              A la derecha, x(t) de dos de ellas.
% USO          Ejecute. Video en videos/V5_3_vanderpol.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

mu = 1;  f = @(t, x) [x(2); -x(1) - mu*(x(1)^2 - 1)*x(2)];
X0 = [0.05 0; -0.05 0; 0 0.1; 3.5 3; -3.5 -3; 0 4; 0 -4; 4 0].';
t = linspace(0, 25, 751);  Xs = cell(1, size(X0, 2));
for k = 1:size(X0, 2), [~, Xs{k}] = ode45(f, t, X0(:,k), odeset('RelTol', 1e-9)); end
fig = estiloFigura(1280, 620);
ax1 = subplot(1,2,1); hold(ax1, 'on'); grid(ax1, 'on'); axis(ax1, [-4.5 4.5 -4.5 4.5]); axis(ax1, 'equal');
xlabel(ax1, '$x$'); ylabel(ax1, '$\dot x$'); title(ax1, 'van der Pol, $\mu=1$');
ax2 = subplot(1,2,2); hold(ax2, 'on'); grid(ax2, 'on'); xlim(ax2, [0 25]); ylim(ax2, [-4.5 4.5]);
xlabel(ax2, '$t$'); title(ax2, '$x(t)$ desde $(0.05,0)$ y desde $(4,0)$');
h = zeros(1, numel(Xs));  for k = 1:numel(Xs), h(k) = plot(ax1, nan, nan, 'LineWidth', 1.8); end
l1 = plot(ax2, nan, nan, 'LineWidth', 2); l2 = plot(ax2, nan, nan, 'LineWidth', 2);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V5_3_vanderpol'), 30);
end
for i = 1:numel(t)
    for k = 1:numel(Xs), set(h(k), 'XData', Xs{k}(1:i,1), 'YData', Xs{k}(1:i,2)); end
    set(l1, 'XData', t(1:i), 'YData', Xs{1}(1:i,1));  set(l2, 'XData', t(1:i), 'YData', Xs{8}(1:i,1));
    drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
