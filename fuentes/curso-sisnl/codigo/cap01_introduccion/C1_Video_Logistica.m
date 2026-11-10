%% C1_Video_Logistica -- Video V1_2: el mapa logístico, de la calma al caos
% QUÉ MUESTRA  A la izquierda, el diagrama de telaraña de P[k+1] = R P[k](1 - P[k]/K)
%              (K = 32) mientras R crece de 1.6 a 3.95. A la derecha se va
%              dibujando el diagrama de bifurcación: los valores que visita la
%              población después del transitorio. Un punto, dos, cuatro... caos.
% USO          Ejecute. Video en videos/V1_2_logistica.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

K = 32;  Rs = linspace(1.6, 3.95, 360);  P = linspace(0, K, 400);
fig = estiloFigura(1280, 620);
ax1 = subplot(1, 2, 1); ax2 = subplot(1, 2, 2); hold(ax2, 'on'); grid(ax2, 'on');
xlim(ax2, [1.6 4]); ylim(ax2, [0 K]); xlabel(ax2, '$R$'); ylabel(ax2, 'valores visitados');
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V1_2_logistica'), 30);
end
for R = Rs
    F = @(p) R*p.*(1 - p/K);
    p = 1;  for k = 1:600, p = F(p); end
    orb = zeros(1, 60);  for k = 1:60, p = F(p); orb(k) = p; end
    cla(ax1); hold(ax1, 'on'); plot(ax1, P, F(P)); plot(ax1, [0 K], [0 K], 'k');
    q = 1;  xs = q;  ys = 0;
    for k = 1:40, xs = [xs q F(q)]; ys = [ys F(q) F(q)]; q = F(q); end           %#ok<AGROW>
    plot(ax1, xs, ys, 'LineWidth', 1);  axis(ax1, [0 K 0 K]); grid(ax1, 'on');
    title(ax1, sprintf('telara\\~na, $R = %.3f$', R)); xlabel(ax1, '$P[k]$'); ylabel(ax1, '$P[k+1]$');
    plot(ax2, R*ones(size(orb)), orb, '.', 'Color', [20 33 61]/255, 'MarkerSize', 4);
    drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
