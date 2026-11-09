%% C3_Video_Picard -- Video V3_1: las aproximaciones sucesivas de Picard
% QUÉ MUESTRA  x' = x, x(0) = 1 en [0, 1]: cada fotograma aplica una vez el
%              operador (P x)(t) = 1 + int_0^t x(s) ds. Las iteraciones (polinomios
%              de Taylor de e^t) se pegan a la solución; abajo, el error en la
%              norma del máximo cae como 1/(k+1)!.
% USO          Ejecute. Video en videos/V3_1_picard.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

t = linspace(0, 1, 2001);  x = ones(size(t));  K = 8;  err = zeros(1, K);
fig = estiloFigura(1280, 620);
ax1 = subplot(1,2,1); hold(ax1, 'on'); grid(ax1, 'on'); xlim(ax1, [0 1]); ylim(ax1, [0.9 2.8]);
plot(ax1, t, exp(t), 'k--', 'LineWidth', 2.5); xlabel(ax1, '$t$'); title(ax1, 'iteraciones de Picard y $e^t$');
ax2 = subplot(1,2,2); grid(ax2, 'on'); hold(ax2, 'on'); xlim(ax2, [0.5 K + 0.5]); ylim(ax2, [1e-6 1]);
set(ax2, 'YScale', 'log'); xlabel(ax2, 'iteraci\''on $k$'); title(ax2, '$\|x_k-e^t\|_C$');
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V3_1_picard'), 30);
end
for k = 1:K
    xn = 1 + cumtrapz(t, x);
    for a = linspace(0, 1, 30)                  % transición suave de x_{k-1} a x_k
        if exist('hl', 'var') && ishandle(hl), delete(hl); end
        hl = plot(ax1, t, (1 - a)*x + a*xn, 'LineWidth', 2.5, 'Color', [0.12 0.35 0.66]);
        drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
    end
    plot(ax1, t, xn, 'Color', [0.79 0.82 0.87]);  x = xn;
    err(k) = max(abs(x - exp(t)));
    semilogy(ax2, 1:k, err(1:k), 'o-', 'Color', [0.82 0.29 0.36]);
    for r = 1:15, drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end, end
end
if HACER_VIDEO, close(vid); end
