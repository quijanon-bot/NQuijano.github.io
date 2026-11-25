%% C9_Video_TiempoInicial -- Video V9_1: misma condición inicial, distinta hora de arranque
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ MUESTRA  x' = -x/(1 + t) desde x0 = 1 con t0 = 0, 10, 40 y 100, todas contra el
%              tiempo transcurrido s = t - t0. Un cronómetro marca cuándo cada una baja de 0.1.
% USO          Ejecute. Video en videos/V9_1_tiempo_inicial.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

t0s = [0 10 40 100];  s = linspace(0, 1000, 2001);  col = lines(4);
fig = estiloFigura(1100, 520);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V9_1_tiempo_inicial'), 24);
end
for j = round(linspace(2, numel(s), 160))
    clf(fig);  hold on;
    for k = 1:4
        x = (1 + t0s(k))./(1 + t0s(k) + s(1:j));  plot(s(1:j), x, 'Color', col(k, :), 'LineWidth', 2);
        T = 9*(1 + t0s(k));
        if s(j) >= T, plot(T, 0.1, 'o', 'Color', col(k, :), 'MarkerFaceColor', col(k, :)); end
    end
    plot([0 1000], [0.1 0.1], 'k--');  axis([0 1000 0 1.05]);  grid on;
    xlabel('$s=t-t_0$');  ylabel('$x$');
    legend(arrayfun(@(a) sprintf('$t_0=%d$', a), t0s, 'UniformOutput', false));
    title(sprintf('$s=%.0f$: tiempos de asentamiento $9(1+t_0)$ = 9, 99, 369, 909', s(j)));
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
