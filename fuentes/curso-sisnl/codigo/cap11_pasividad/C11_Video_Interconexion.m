%% C11_Video_Interconexion -- Video V11_4: la energía pasa de H1 a H2 y la suma solo baja
% QUÉ MUESTRA  Los dos osciladores de C11_Ej10 como dos masas. Toda la energía empieza
%              en H1. Las barras muestran V1, V2 y V = V1 + V2: cada una sube y baja,
%              la suma decrece con V' = -k y1^2 - y2^4.
% USO          Ejecute. Video en videos/V11_4_interconexion.mp4.
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

a = 1;  k = 0.5;  b = 2;
[t, X] = ode45(@(t, x) modeloOsciladores(t, x, a, k, b), linspace(0, 25, 751), [1.5; 0; 0; 0], ...
               odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
V1 = a*X(:,1).^4/4 + X(:,2).^2/2;  V2 = b*X(:,3).^2/2 + X(:,4).^2/2;
fig = estiloFigura(1280, 680);
ax1 = subplot(2,2,1); hold(ax1, 'on'); axis(ax1, [-2 2 -1 1]); axis(ax1, 'off');
m1 = fill(ax1, [-0.2 0.2 0.2 -0.2], 0.45 + [-0.2 -0.2 0.2 0.2], [0.12 0.35 0.66]);
m2 = fill(ax1, [-0.2 0.2 0.2 -0.2], -0.45 + [-0.2 -0.2 0.2 0.2], [0.82 0.29 0.36]);
text(ax1, -1.9, 0.45, '$H_1$'); text(ax1, -1.9, -0.45, '$H_2$');
ax2 = subplot(2,2,2); barras = bar(ax2, [0 0 0], 'FaceColor', 'flat');
barras.CData = [0.12 0.35 0.66; 0.82 0.29 0.36; 0.08 0.13 0.24];
set(ax2, 'XTickLabel', {'V_1', 'V_2', 'V_1+V_2'}); ylim(ax2, [0 1.35]); grid(ax2, 'on');
ax3 = subplot(2,1,2); hold(ax3, 'on'); grid(ax3, 'on'); xlim(ax3, [0 25]); ylim(ax3, [0 1.35]);
l1 = plot(ax3, nan, nan); l2 = plot(ax3, nan, nan); l3 = plot(ax3, nan, nan, 'k', 'LineWidth', 2.5);
legend(ax3, '$V_1$', '$V_2$', '$V$'); xlabel(ax3, '$t$');

if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V11_4_interconexion'), 30);
end
for j = 1:numel(t)
    set(m1, 'XData', X(j,1) + [-0.2 0.2 0.2 -0.2]);  set(m2, 'XData', X(j,3) + [-0.2 0.2 0.2 -0.2]);
    barras.YData = [V1(j) V2(j) V1(j) + V2(j)];
    set(l1, 'XData', t(1:j), 'YData', V1(1:j)); set(l2, 'XData', t(1:j), 'YData', V2(1:j));
    set(l3, 'XData', t(1:j), 'YData', V1(1:j) + V2(1:j));
    title(ax2, sprintf('$t=%.1f$', t(j)));
    drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
