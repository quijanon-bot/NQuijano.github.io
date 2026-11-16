%% C8_Video_PenduloLaSalle -- Video V8_1: pasar por E no es quedarse en E
% QUÉ MUESTRA  El péndulo con fricción (a = 1, b = 0.3) desde (2, 0.8): a la izquierda la
%              trayectoria cruzando E (el segmento del eje x2 = 0 en Omega_c); a la derecha
%              V(x(t)) y Vdot(x(t)). En cada cruce Vdot = 0 y V sigue bajando.
% USO          Ejecute. Video en videos/V8_1_pendulo_lasalle.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

a = 1;  b = 0.3;  c = 1.8;  xE = acos(1 - c/a);
[t, X] = ode45(@(t, x) [x(2); -a*sin(x(1)) - b*x(2)], linspace(0, 25, 2501), [2; 0.8], odeset('RelTol', 1e-9, 'AbsTol', 1e-11));
V = a*(1 - cos(X(:, 1))) + X(:, 2).^2/2;  Vd = -b*X(:, 2).^2;
[X1, X2] = meshgrid(linspace(-3.2, 3.2, 300), linspace(-2.2, 2.2, 200));
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V8_1_pendulo_lasalle'), 24);
end
for j = round(linspace(1, numel(t), 180))
    clf(fig);
    subplot(1, 2, 1);  contour(X1, X2, a*(1 - cos(X1)) + X2.^2/2, [c c], 'b');  hold on;
    plot([-xE xE], [0 0], 'r', 'LineWidth', 4);  plot(X(1:j, 1), X(1:j, 2), 'k', 'LineWidth', 1);
    enE = abs(X(j, 2)) < 0.03;
    plot(X(j, 1), X(j, 2), 'o', 'MarkerSize', 11, 'MarkerFaceColor', [enE 0.6*(1 - enE) 0]);
    axis([-3.2 3.2 -2.2 2.2]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('$\Omega_c$ y $E$');
    subplot(1, 2, 2);  plot(t(1:j), V(1:j), t(1:j), Vd(1:j));  axis([0 25 -0.7 2]);  grid on;
    xlabel('$t$');  legend('$V$', '$\dot V$');  title('en $E$: $\dot V=0$, pero $V$ no se detiene');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
