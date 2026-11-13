%% C10_Video_EnergiaFutura -- Video V10_3: la energía futura se gasta en el presente
% QUÉ MUESTRA  x' = A x, A = [0 1; -1 -1], desde (1, 0.5). A la izquierda, el área bajo
%              ||x(s)||^2 desde s = t (la energía futura V(x(t))); a la derecha, V(x(t)) y
%              su recta tangente de pendiente -||x(t)||^2.
% USO          Ejecute. Video en videos/V10_3_energia_futura.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

A = [0 1; -1 -1];  P = ecuacionLyapunov(A, eye(2));  x0 = [1; 0.5];
s = linspace(0, 14, 1400);  X = zeros(2, numel(s));
for i = 1:numel(s), X(:, i) = expm(A*s(i))*x0; end
n2 = sum(X.^2, 1);  Vt = sum((P*X).*X, 1);
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V10_3_energia_futura'), 24);
end
for tc = linspace(0, 6, 120)
    j = find(s >= tc, 1);  clf(fig);
    subplot(1, 2, 1);  hold on;  area(s(j:end), n2(j:end), 'FaceAlpha', 0.3);  plot(s, n2, 'Color', [0.7 0.7 0.7]);
    plot([tc tc], [0 1.3], 'r');  axis([0 12 0 1.3]);  grid on;  xlabel('$s$');  ylabel('$\|x(s)\|^2$');
    title(sprintf('$V(x(t))=%.3f$', Vt(j)));
    subplot(1, 2, 2);  plot(s(1:j), Vt(1:j), 'k', tc, Vt(j), 'ro', [tc - 1 tc + 1], Vt(j) + n2(j)*[1 -1], 'r--');
    axis([0 7 0 2.4]);  grid on;  xlabel('$t$');  ylabel('$x^\top Px$');  title(sprintf('pendiente $-%.3f$', n2(j)));
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
