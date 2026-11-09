%% C5_Video_Indice -- Video V5_2: el índice de una curva cerrada
% QUÉ MUESTRA  Un punto recorre una circunferencia en sentido antihorario; en
%              cada posición se dibuja el vector f(x) y, a la derecha, el mismo
%              vector trasladado al origen. Se cuentan las vueltas netas. Cuatro
%              casos: nodo (+1), silla (-1), z^2 (+2) y un círculo que rodea la
%              silla y el foco del ejemplo de las notas (0).
% USO          Ejecute. Video en videos/V5_2_indice.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

casos = { 'nodo: $I=+1$', @(x) -x, [0 0], 1;
          'silla: $I=-1$', @(x) [x(1); -x(2)], [0 0], 1;
          '$z^2$: $I=+2$', @(x) [x(1)^2 - x(2)^2; 2*x(1)*x(2)], [0 0], 1;
          'silla + foco: $I=0$', @(x) [-x(1) + x(1)*x(2); x(1) + x(2) - 2*x(1)*x(2)], [0.5 0.5], 2 };
fig = estiloFigura(1280, 620);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V5_2_indice'), 30);
end
for c = 1:size(casos, 1)
    f = casos{c,2};  x0 = casos{c,3};  R = casos{c,4};  clf(fig);
    ax1 = subplot(1,2,1); hold(ax1, 'on'); axis(ax1, 'equal'); grid(ax1, 'on');
    s = linspace(0, 2*pi, 300); plot(ax1, x0(1) + R*cos(s), x0(2) + R*sin(s), 'k');
    title(ax1, casos{c,1});
    ax2 = subplot(1,2,2); hold(ax2, 'on'); axis(ax2, 'equal'); axis(ax2, [-1.2 1.2 -1.2 1.2]); grid(ax2, 'on');
    plot(ax2, cos(s), sin(s), 'Color', [0.79 0.82 0.87]); title(ax2, '$f(x)/\|f(x)\|$ desde el origen');
    ang0 = 0;  vueltas = 0;  prev = [];
    for th = linspace(0, 2*pi, 181)
        x = x0(:) + R*[cos(th); sin(th)];  v = f(x);  u = v/norm(v);
        a = atan2(v(2), v(1));  if ~isempty(prev), d = mod(a - prev + pi, 2*pi) - pi; vueltas = vueltas + d/(2*pi); end
        prev = a;
        quiver(ax1, x(1), x(2), 0.35*R*u(1), 0.35*R*u(2), 0, 'Color', [0.12 0.35 0.66]);
        cla(ax2); plot(ax2, cos(s), sin(s), 'Color', [0.79 0.82 0.87]);
        quiver(ax2, 0, 0, u(1), u(2), 0, 'LineWidth', 3, 'Color', [0.82 0.29 0.36]);
        text(ax2, -1.1, -1.05, sprintf('vueltas = %+.2f', vueltas), 'FontSize', 14);
        drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
    end
    for r = 1:30, if HACER_VIDEO, writeVideo(vid, getframe(fig)); end, end
end
if HACER_VIDEO, close(vid); end
