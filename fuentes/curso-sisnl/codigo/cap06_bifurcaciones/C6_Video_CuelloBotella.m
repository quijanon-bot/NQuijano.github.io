%% C6_Video_CuelloBotella -- Video V6_1: el fantasma de la silla-nodo
% QUÉ MUESTRA  x' = mu - x^2 con mu < 0 acercándose a 0. A la izquierda, la parábola
%              f(x) y un punto que recorre la línea de fase; a la derecha, x(t). Cuanto
%              más cerca de mu = 0, más se demora el punto donde estaba el equilibrio.
% USO          Ejecute. Video en videos/V6_1_cuello_botella.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

mus = [-0.5 -0.1 -0.02];  nt = 120;
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V6_1_cuello_botella'), 24);
end
xx = linspace(-3, 3, 300);
for mu = mus
    opc = odeset('RelTol', 1e-9, 'Events', @(t, x) deal(x + 3, 1, -1));
    [t, X] = ode45(@(t, x) mu - x^2, [0 40], 3, opc);
    tk = linspace(0, t(end), nt);  xk = interp1(t, X, tk);
    for k = 1:nt
        clf(fig);
        subplot(1, 2, 1);  plot(xx, mu - xx.^2, 'k', [-3 3], [0 0], 'k:');  hold on;
        plot(xk(k), 0, 'o', 'MarkerSize', 12, 'MarkerFaceColor', [209 73 91]/255, 'MarkerEdgeColor', 'none');
        axis([-3 3 -6 1]);  grid on;  xlabel('$x$');  ylabel('$\dot x$');  title(sprintf('$\\mu=%g$', mu));
        subplot(1, 2, 2);  plot(tk(1:k), xk(1:k), 'Color', [30 90 168]/255);
        axis([0 26 -3 3]);  grid on;  xlabel('$t$');  ylabel('$x$');
        title(sprintf('tiempo de tr\\''ansito $\\approx\\pi/\\sqrt{|\\mu|}=%.1f$', pi/sqrt(-mu)));
        drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
    end
end
if HACER_VIDEO, close(vid); end
