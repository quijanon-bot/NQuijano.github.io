%% C8_Video_CicloSombrero -- Video V8_2: rodar por el sombrero hasta el ciclo
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ MUESTRA  r' = r(1 - r^2), theta' = 1 con V = (r^2 - 1)^2/4. A la izquierda, dos
%              soluciones en el anillo Omega_0.2; a la derecha, el perfil V(r) con las dos
%              soluciones bajando al fondo (r = 1). V(0) = 1/4 es un máximo.
% USO          Ejecute. Video en videos/V8_2_ciclo_sombrero.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

f = @(t, x) [x(1)*(1 - x(1)^2 - x(2)^2) - x(2); x(2)*(1 - x(1)^2 - x(2)^2) + x(1)];
t = linspace(0, 12, 1201);  opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11);
[~, A] = ode45(f, t, [1.3; 0.3], opc);  [~, B] = ode45(f, t, [0; -0.4], opc);
rA = sqrt(sum(A.^2, 2));  rB = sqrt(sum(B.^2, 2));  Vr = @(r) (r.^2 - 1).^2/4;
th = linspace(0, 2*pi, 300);  r1 = sqrt(1 - 2*sqrt(0.2));  r2 = sqrt(1 + 2*sqrt(0.2));  rr = linspace(0, 1.6, 300);
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V8_2_ciclo_sombrero'), 24);
end
for j = round(linspace(1, numel(t), 160))
    clf(fig);
    subplot(1, 2, 1);  hold on;  plot(r1*cos(th), r1*sin(th), 'b--', r2*cos(th), r2*sin(th), 'b--');
    plot(cos(th), sin(th), 'r', 'LineWidth', 2.5);  plot(A(1:j, 1), A(1:j, 2), 'k', B(1:j, 1), B(1:j, 2), 'k');
    plot(A(j, 1), A(j, 2), 'ko', B(j, 1), B(j, 2), 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 9);
    axis equal;  axis([-1.6 1.6 -1.6 1.6]);  grid on;  title('anillo $\Omega_{0.2}$ y $E=M$');
    subplot(1, 2, 2);  plot(rr, Vr(rr), 'k');  hold on;
    plot(rA(j), Vr(rA(j)), 'ko', rB(j), Vr(rB(j)), 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 10);
    axis([0 1.6 0 0.6]);  grid on;  xlabel('$r$');  ylabel('$V$');  title('$V(0)=1/4$ es un m\''aximo');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
