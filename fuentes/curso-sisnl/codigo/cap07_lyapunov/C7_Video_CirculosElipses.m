%% C7_Video_CirculosElipses -- Video V7_3: la métrica en la que el sistema se contrae
% QUÉ MUESTRA  x' = Ax con A = [-1 10; 0 -2] (Hurwitz) desde x0 = (0, 1). Izquierda: el
%              círculo por x(t) (norma euclidiana) y la elipse {x'Px = V(x(t))}, con P de
%              A'P + PA = -I. Derecha: |x(t)| y sqrt(V). El círculo crece (de 1 a 2.5)
%              mientras la elipse solo se encoge.
% USO          Ejecute. Video en videos/V7_3_circulos_elipses.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

A = [-1 10; 0 -2];  P = ecuacionLyapunov(A, eye(2));
t = linspace(0, 5, 200);  X = zeros(2, numel(t));
for k = 1:numel(t), X(:, k) = expm(A*t(k))*[0; 1]; end
nx = sqrt(sum(X.^2));  Vx = sum(X.*(P*X));
ang = linspace(0, 2*pi, 300);  U = [cos(ang); sin(ang)];  L = chol(P);   % P = L'L
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V7_3_circulos_elipses'), 24);
end
for k = 1:numel(t)
    clf(fig);
    subplot(1, 2, 1);  hold on;
    plot(nx(k)*U(1,:), nx(k)*U(2,:), 'Color', [209 73 91]/255);
    E = L \ (sqrt(Vx(k))*U);  plot(E(1,:), E(2,:), 'Color', [42 157 143]/255, 'LineWidth', 2.5);
    plot(X(1, 1:k), X(2, 1:k), 'Color', [30 90 168]/255);
    plot(X(1, k), X(2, k), 'ko', 'MarkerFaceColor', 'k');
    axis equal;  axis([-3.2 3.2 -3.2 3.2]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
    title('C\''irculo por $x(t)$ (rojo) y elipse de $P$ (verde)');
    subplot(1, 2, 2);  hold on;
    plot(t(1:k), nx(1:k), 'Color', [209 73 91]/255);  plot(t(1:k), sqrt(Vx(1:k)/Vx(1)), 'Color', [42 157 143]/255);
    xlim([0 5]);  ylim([0 2.8]);  grid on;  xlabel('$t$');
    legend('$|x(t)|$', '$\sqrt{V(x(t))/V(x_0)}$');  title('La norma crece; $V$ no');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
