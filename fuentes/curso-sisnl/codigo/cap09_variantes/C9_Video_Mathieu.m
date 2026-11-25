%% C9_Video_Mathieu -- Video V9_2: los niveles de V(t,x) respiran y la solución entra
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ MUESTRA  Mathieu amortiguada desde (1.5, 0). A la izquierda, la solución y el nivel
%              V(t, x) = V(t, x(t)) en el instante actual: la elipse cambia de forma con t
%              y la solución siempre está sobre ella. A la derecha, V(t, x(t)).
% USO          Ejecute. Video en videos/V9_2_mathieu.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
t = linspace(0, 12, 1201);
[t, X] = ode45(@(t, x) [x(2); -x(2) - (2 + sin(t))*x(1)], t, [1.5; 0], opc);
Vt = X(:, 1).^2 + X(:, 2).^2./(2 + sin(t));  th = linspace(0, 2*pi, 300);
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V9_2_mathieu'), 24);
end
for j = round(linspace(1, numel(t), 180))
    clf(fig);
    subplot(1, 2, 1);  hold on;  c = sqrt(Vt(j));
    plot(c*cos(th), c*sqrt(2 + sin(t(j)))*sin(th), 'b--', 'LineWidth', 1.5);
    plot(X(1:j, 1), X(1:j, 2), 'k');  plot(X(j, 1), X(j, 2), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 9);
    axis equal;  axis([-1.7 1.7 -2.7 2.7]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
    title(sprintf('$t=%.1f$: nivel $V(t,x)=%.3f$', t(j), Vt(j)));
    subplot(1, 2, 2);  semilogy(t(1:j), Vt(1:j), 'b', 'LineWidth', 2);  hold on;
    semilogy(t, 2.25*exp(-t), 'k--');  axis([0 12 1e-6 4]);  grid on;  xlabel('$t$');
    title('$V(t,x(t))$: mesetas donde $x_2=0$');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
