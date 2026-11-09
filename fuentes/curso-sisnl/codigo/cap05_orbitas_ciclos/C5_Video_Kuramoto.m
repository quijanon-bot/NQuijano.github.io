%% C5_Video_Kuramoto -- Video V5_1: sincronización de Kuramoto
% QUÉ MUESTRA  N = 60 osciladores (puntos sobre el círculo) con frecuencias de
%              Lorentz (gamma = 0.5) y K = 2 > Kc = 1. La flecha es el parámetro
%              de orden r e^{j Psi}; a la derecha, r(t). Las fases se agrupan,
%              pero algunos osciladores rápidos siguen dando vueltas: r < 1.
% USO          Ejecute. Video en videos/V5_1_kuramoto.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

N = 60;  gam = 0.5;  K = 2;  i = (1:N).';
w = gam*tan(pi*(i - 0.5)/N - pi/2);
th0 = 2*pi*mod(i*0.6180339887, 1);
t = linspace(0, 40, 801);
[~, TH] = ode45(@(t, th) modeloKuramoto(t, th, w, K), t, th0, odeset('RelTol', 1e-8));
z = mean(exp(1j*TH), 2);
fig = estiloFigura(1280, 620);
ax1 = subplot(1,2,1); hold(ax1, 'on'); axis(ax1, 'equal'); axis(ax1, [-1.2 1.2 -1.2 1.2]); axis(ax1, 'off');
s = linspace(0, 2*pi, 200); plot(ax1, cos(s), sin(s), 'Color', [0.79 0.82 0.87], 'LineWidth', 2);
pts = scatter(ax1, cos(th0), sin(th0), 60, w, 'filled');  flecha = plot(ax1, [0 0], [0 0], 'k', 'LineWidth', 3);
title(ax1, sprintf('$K=%g$, $K_c=%g$', K, 2*gam));
ax2 = subplot(1,2,2); hold(ax2, 'on'); grid(ax2, 'on'); xlim(ax2, [0 40]); ylim(ax2, [0 1]);
lr = plot(ax2, nan, nan, 'LineWidth', 2.5); plot(ax2, [0 40], sqrt(1 - 2*gam/K)*[1 1], 'k--');
xlabel(ax2, '$t$'); title(ax2, '$r(t)$ y la predicci\''on $\sqrt{1-K_c/K}$');
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V5_1_kuramoto'), 30);
end
for k = 1:numel(t)
    set(pts, 'XData', cos(TH(k,:)), 'YData', sin(TH(k,:)));
    set(flecha, 'XData', [0 real(z(k))], 'YData', [0 imag(z(k))]);
    set(lr, 'XData', t(1:k), 'YData', abs(z(1:k)));
    drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
