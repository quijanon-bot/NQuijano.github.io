%% C8_Video_ZubovVanDerPol -- Video V8_4: los niveles de Zubov llenan la región hasta el ciclo
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ MUESTRA  Van der Pol en tiempo invertido. Calcula W en una malla (zubovMalla) y anima
%              el nivel {V <= c} con c de 0.05 a 0.999, junto al ciclo límite y a la mejor
%              elipse x'Px <= 2.30 del capítulo 7. (La malla tarda unos minutos.)
% USO          Ejecute. Video en videos/V8_4_zubov_vdp.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
addpath(raiz);  HACER_VIDEO = true;

f = @(t, x) [-x(2); x(1) + (x(1)^2 - 1)*x(2)];
g = linspace(-3, 3, 61);  W = zubovMalla(f, g, g, @(x) x(1)^2 + x(2)^2);
[X1, X2] = meshgrid(g);  VV = 1 - exp(-W);  VV(isinf(W)) = 1;
[~, C] = ode45(@(t, x) [x(2); -x(1) + (1 - x(1)^2)*x(2)], [0 40], [2; 0]);  C = C(end-400:end, :);
P = ecuacionLyapunov([0 -1; 1 -1], eye(2));  th = linspace(0, 2*pi, 300);  U = [cos(th); sin(th)];
R = sqrt(2.30./sum(U.*(P*U), 1));
fig = estiloFigura(900, 820);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V8_4_zubov_vdp'), 24);
end
for c = [linspace(0.05, 0.9, 60), 1 - logspace(-1, -3, 40)]
    clf(fig);  contourf(X1, X2, double(VV <= c), [0.5 0.5]);  colormap([1 1 1; 0.8 0.88 1]);  hold on;
    plot(C(:, 1), C(:, 2), 'r', 'LineWidth', 2);  plot(U(1, :).*R, U(2, :).*R, 'g', 'LineWidth', 2);
    axis equal;  axis([-3 3 -3 3]);  grid on;  title(sprintf('$\\{V\\leq %.3f\\}$', c));
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
