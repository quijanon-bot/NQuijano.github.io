%% C4_Video_VariedadCentral -- Video V4_3: caer rápido, moverse despacio
% QUÉ MUESTRA  y' = y z, z' = -z + a y^2 con a = -1. Doce soluciones caen en menos de
%              tres unidades de tiempo sobre la variedad central z ~ a y^2 - 2 a^2 y^4
%              (verde) y después se deslizan despacio hacia el origen. La recta z = 0
%              (E^c, punteada) no es invariante.
% USO          Ejecute. Video en videos/V4_3_variedad_central.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

a = -1;  f = @(t, x) [x(1)*x(2); -x(2) + a*x(1)^2];
tt = [linspace(0, 3, 72), linspace(3, 30, 96)];  tt(73) = [];
y0 = [-0.8 -0.5 -0.3 0.3 0.5 0.8];  ics = [kron(y0, [1 1]); repmat([-0.7 0.7], 1, 6)];
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11);
Y = cell(1, size(ics, 2));
for i = 1:size(ics, 2), [~, Y{i}] = ode45(f, tt, ics(:, i), opc); end
ys = linspace(-0.62, 0.62, 200);
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V4_3_variedad_central'), 24);
end
for k = 1:numel(tt)
    clf(fig);  hold on;
    plot(ys, a*ys.^2 - 2*a^2*ys.^4, 'Color', [42 157 143]/255, 'LineWidth', 3);
    plot([-1 1], [0 0], ':', 'Color', [0.4 0.4 0.4]);
    for i = 1:numel(Y)
        plot(Y{i}(1:k, 1), Y{i}(1:k, 2), 'Color', [30 90 168]/255);
        plot(Y{i}(k, 1), Y{i}(k, 2), 'o', 'MarkerFaceColor', [209 73 91]/255, 'MarkerEdgeColor', 'none');
    end
    axis([-1 1 -0.8 0.8]);  grid on;  xlabel('$y$');  ylabel('$z$');
    title(sprintf('$\\dot y=yz,\\ \\dot z=-z+ay^2$, $a=%g$: $t=%.1f$', a, tt(k)));
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
