%% C2_Video_LineaFase -- Video V2_1: la partícula que se mueve sobre la recta
% QUÉ MUESTRA  Arriba, la gráfica de f(x) = sin x y, sobre el eje, cinco
%              partículas que se mueven con velocidad f(x). Abajo, sus x(t). Las
%              partículas nunca cruzan los equilibrios x = k pi y se detienen en
%              los impares.
% USO          Ejecute. Video en videos/V2_1_linea_fase.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

f = @(x) sin(x);  x0 = [-5.8 -2 0.3 2.6 4];  t = linspace(0, 6, 361);
X = zeros(numel(t), numel(x0));
for i = 1:numel(x0), [~, X(:,i)] = ode45(@(t, x) f(x), t, x0(i)); end
fig = estiloFigura(1280, 720);
ax1 = subplot(2, 1, 1); lineaFase(ax1, f, [-2*pi 2*pi], 'Equilibrios', (-2:2)*pi); hold(ax1, 'on');
hp = plot(ax1, X(1,:), 0*x0, 'o', 'MarkerSize', 12, 'MarkerFaceColor', [209 73 91]/255);
ax2 = subplot(2, 1, 2); hold(ax2, 'on'); grid(ax2, 'on'); xlim(ax2, [0 6]); ylim(ax2, [-2*pi 2*pi]);
for k = -2:2, plot(ax2, [0 6], k*pi*[1 1], 'k--', 'LineWidth', 0.6); end
hl = cell(1, numel(x0)); for i = 1:numel(x0), hl{i} = plot(ax2, nan, nan); end
xlabel(ax2, '$t$'); ylabel(ax2, '$x(t)$');
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V2_1_linea_fase'), 30);
end
for k = 1:numel(t)
    set(hp, 'XData', X(k,:));
    for i = 1:numel(x0), set(hl{i}, 'XData', t(1:k), 'YData', X(1:k,i)); end
    title(ax1, sprintf('$\\dot x=\\sin x$, $t = %.1f$', t(k))); drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
