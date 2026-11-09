%% C3_Video_NoUnicidad -- Video V3_2: x' = x^(1/3) desde x(0) = 0
% QUÉ MUESTRA  A la izquierda, el campo f(x) = x^(1/3) con la pendiente infinita
%              en el origen. A la derecha, una tras otra, soluciones que esperan
%              en x = 0 un tiempo c y luego despegan: todas parten de x(0) = 0.
% USO          Ejecute. Video en videos/V3_2_no_unicidad.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

xc = @(t, c) (t > c).*((2/3)*max(t - c, 0)).^(3/2);
t = linspace(0, 3, 301);  cs = [0 0.4 0.8 1.2 1.6 2.0];
fig = estiloFigura(1280, 620);
ax1 = subplot(1,2,1); s = linspace(-1, 1, 801); plot(ax1, s, nthroot(s, 3)); grid(ax1, 'on');
xlabel(ax1, '$x$'); ylabel(ax1, '$f(x)=x^{1/3}$'); title(ax1, 'pendiente infinita en $x=0$');
ax2 = subplot(1,2,2); hold(ax2, 'on'); grid(ax2, 'on'); xlim(ax2, [0 3]); ylim(ax2, [-0.1 3]);
plot(ax2, t, 0*t, 'k', 'LineWidth', 3); xlabel(ax2, '$t$'); ylabel(ax2, '$x(t)$');
title(ax2, 'todas parten de $x(0)=0$');
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V3_2_no_unicidad'), 30);
end
for c = cs
    h = plot(ax2, nan, nan, 'LineWidth', 2.2);  x = xc(t, c);
    for k = 1:4:numel(t)
        set(h, 'XData', t(1:k), 'YData', x(1:k)); drawnow;
        if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
    end
end
if HACER_VIDEO, close(vid); end
