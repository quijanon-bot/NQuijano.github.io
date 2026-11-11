%% C4_Video_TrazaDeterminante -- Video V4_1: un punto recorre el plano traza-determinante
% QUÉ MUESTRA  A la izquierda, un punto (tau, delta) recorre un camino que cruza todas
%              las fronteras (sillas, nodos, focos, centros, nodos degenerados). A la
%              derecha, el retrato de x' = A x con A = [tau/2 1; tau^2/4 - delta tau/2],
%              que tiene esa traza y ese determinante.
% USO          Ejecute. Video en videos/V4_1_traza_determinante.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

P = [-3 -1.5; -3 1.2; -3 3.5; -1 3.5; 0 3.5; 1 3.5; 3 3.5; 3 1.2; 3 -1.5; -3 -1.5];
camino = [];
for k = 1:size(P, 1) - 1
    s = linspace(0, 1, 37)';  s(end) = [];
    camino = [camino; (1 - s)*P(k, :) + s*P(k + 1, :)];             %#ok<AGROW>
end
th = linspace(0, 2*pi, 17);  th(end) = [];  X0 = 0.95*[cos(th); sin(th)];
fig = estiloFigura(1280, 620);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V4_1_traza_determinante'), 24);
end
tt = linspace(-4, 4, 200);
for k = 1:size(camino, 1)
    tau = camino(k, 1);  de = camino(k, 2);  A = [tau/2 1; tau^2/4 - de tau/2];
    clf(fig);
    subplot(1, 2, 1);  hold on;
    plot(tt, tt.^2/4, 'k');  plot([-4 4], [0 0], 'k');  plot([0 0], [0 5], 'Color', [42 157 143]/255, 'LineWidth', 2);
    plot(camino(1:k, 1), camino(1:k, 2), 'Color', [0.6 0.6 0.6]);
    plot(tau, de, 'o', 'MarkerSize', 10, 'MarkerFaceColor', [209 73 91]/255, 'MarkerEdgeColor', 'none');
    axis([-4 4 -2.5 5]);  grid on;  xlabel('$\tau$');  ylabel('$\delta$');
    title(sprintf('$\\tau=%.2f$, $\\delta=%.2f$: %s', tau, de, clasificarEquilibrio(A, 1e-6)));
    ax = subplot(1, 2, 2);
    retratoFase(ax, @(x) A*x, [-1 1], [-1 1], 'X0', X0, 'T', 8, 'Atras', true, 'N', 15);
    axis(ax, 'square');  title(ax, 'Retrato de $\dot x=Ax$');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
