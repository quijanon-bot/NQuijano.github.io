%% C12_Video_Difeomorfismo -- Video V12_4: local en todo punto no es global
% QUÉ MUESTRA  Izquierda: la rejilla se deforma continuamente bajo el difeomorfismo
%              global Phi(x) = (x1, x2 + x1^3/2). Derecha: Psi(x) = e^x1 (cos x2, sin x2)
%              barre la franja x2 en [0, 4 pi]; tiene jacobiano no singular en todo punto,
%              pero cubre el anillo DOS veces: no es uno a uno.
% USO          Ejecute. Video en videos/V12_4_difeomorfismo.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

N = 12*24;  rej = linspace(-2, 2, 11);  s = linspace(-2, 2, 200);  c1 = linspace(-0.8, 0.5, 8);  th = linspace(0, 4*pi, 800);
fig = estiloFigura(1280, 640);
ax1 = subplot(1, 2, 1); hold(ax1, 'on'); axis(ax1, [-2.2 2.2 -4.5 4.5]); grid(ax1, 'on');
title(ax1, '$\Phi(x)=(x_1,\ x_2+x_1^3/2)$: global');
hv = zeros(1, numel(rej));  hh = hv;
for k = 1:numel(rej)
    hv(k) = plot(ax1, nan, nan, 'Color', [30 90 168]/255, 'LineWidth', 1.2);
    hh(k) = plot(ax1, nan, nan, 'Color', [209 73 91]/255, 'LineWidth', 1.2);
end
ax2 = subplot(1, 2, 2); hold(ax2, 'on'); axis(ax2, 'equal'); axis(ax2, [-1.8 1.8 -1.8 1.8]); grid(ax2, 'on');
title(ax2, '$e^{x_1}(\cos x_2,\ \sin x_2)$: $\det\neq0$, pero dos vueltas');
ha = zeros(1, numel(c1));  for k = 1:numel(c1), ha(k) = plot(ax2, nan, nan, 'LineWidth', 1.4); end
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V12_4_difeomorfismo'), 24);
end
for i = 1:N
    a = min(1, (i - 1)/(0.6*N));  a = 0.5 - 0.5*cos(pi*a);
    for k = 1:numel(rej)
        set(hv(k), 'XData', rej(k)*ones(size(s)), 'YData', s + a*rej(k)^3/2);
        set(hh(k), 'XData', s, 'YData', rej(k) + a*s.^3/2);
    end
    m = th <= 4*pi*min(1, (i - 1)/(0.85*N));
    if any(th(m) > 2*pi), col = [209 73 91]/255; else, col = [30 90 168]/255; end
    for k = 1:numel(c1), set(ha(k), 'XData', exp(c1(k))*cos(th(m)), 'YData', exp(c1(k))*sin(th(m)), 'Color', col); end
    drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
