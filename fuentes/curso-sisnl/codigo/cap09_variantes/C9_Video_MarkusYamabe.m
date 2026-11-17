%% C9_Video_MarkusYamabe -- Video V9_3: los campos congelados atraen; la solución real se escapa
% QUÉ MUESTRA  A la izquierda, el campo congelado A(t) (flechas) que cambia con t, la
%              solución real desde (1, 0) y la solución del campo congelado en ese instante.
%              A la derecha, ||x(t)|| contra e^{t/2} y e^{-t/4}.
% USO          Ejecute. Video en videos/V9_3_markus_yamabe.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

A = @(t) [-1 + 1.5*cos(t)^2, 1 - 1.5*sin(t)*cos(t); -1 - 1.5*sin(t)*cos(t), -1 + 1.5*sin(t)^2];
t = linspace(0, 6, 601);  X = [exp(t/2).*cos(t); -exp(t/2).*sin(t)]';   % solución exacta
[G1, G2] = meshgrid(linspace(-20, 20, 15));
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V9_3_markus_yamabe'), 24);
end
for j = round(linspace(1, numel(t), 160))
    clf(fig);  Aj = A(t(j));
    subplot(1, 2, 1);  hold on;
    U = Aj(1, 1)*G1 + Aj(1, 2)*G2;  W = Aj(2, 1)*G1 + Aj(2, 2)*G2;  L = sqrt(U.^2 + W.^2) + eps;
    quiver(G1, G2, U./L, W./L, 0.5, 'Color', [0.6 0.6 0.6]);
    s = linspace(0, 10, 400);  Z = zeros(2, numel(s));
    for i = 1:numel(s), Z(:, i) = expm(Aj*s(i))*X(j, :)'; end    % congelado desde x(t)
    plot(Z(1, :), Z(2, :), 'b--');  plot(X(1:j, 1), X(1:j, 2), 'r', 'LineWidth', 2);
    plot(X(j, 1), X(j, 2), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 9);
    axis equal;  axis([-20 20 -20 20]);  grid on;  title(sprintf('campo congelado $A(%.1f)$', t(j)));
    subplot(1, 2, 2);  semilogy(t(1:j), exp(t(1:j)/2), 'r', 'LineWidth', 2);  hold on;
    semilogy(t, exp(t/2), 'k--', t, exp(-t/4), 'b:');  axis([0 6 0.2 25]);  grid on;  xlabel('$t$');
    title('$\|x(t)\|=e^{t/2}$; los valores propios dicen $e^{-t/4}$');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
