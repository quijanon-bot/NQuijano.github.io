%% C9_Video_Chetaev -- Video V9_4: la región de Chetaev
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ MUESTRA  x1' = x1^2 + x2^3, x2' = -x2 + x1^3 con V = x1 - x2^2/2. La región
%              U = {V > 0} dentro de B_{1/2} (sombreada) y soluciones que nacen en U cada
%              vez más cerca del origen: todas salen de la bola. A la derecha, V(x(t)).
% USO          Ejecute. Video en videos/V9_4_cetaev.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

f = @(t, x) [x(1)^2 + x(2)^3; -x(2) + x(1)^3];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, x) eventoODE(norm(x) - 0.6, 1, 0));
x0s = [0.05 0.02 0.01 0.005];  sol = cell(1, 4);
for k = 1:4
    [t, X] = ode45(f, linspace(0, 400, 40001), [x0s(k); 0.5*x0s(k)^0.5*0.3], opc);  sol{k} = [t X];
end
th = linspace(0, 2*pi, 300);  y = linspace(-0.5, 0.5, 200);  col = lines(4);
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V9_4_cetaev'), 24);
end
for q = linspace(0, 1, 160)
    clf(fig);
    subplot(1, 2, 1);  hold on;
    xb = sqrt(max(0.25 - y.^2, 0));  fill([y.^2/2, fliplr(xb)], [y, fliplr(y)], [0.75 0.9 0.85], 'EdgeColor', 'none');
    plot(0.5*cos(th), 0.5*sin(th), 'k:');
    for k = 1:4
        S = sol{k};  n = max(2, round(q*size(S, 1)));
        plot(S(1:n, 2), S(1:n, 3), 'Color', col(k, :), 'LineWidth', 1.5);
    end
    axis equal;  axis([-0.6 0.6 -0.6 0.6]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
    title('$U=\{x_1>x_2^2/2\}\cap B_{1/2}$');
    subplot(1, 2, 2);  hold on;
    for k = 1:4
        S = sol{k};  n = max(2, round(q*size(S, 1)));
        semilogy(S(1:n, 1), S(1:n, 2) - S(1:n, 3).^2/2, 'Color', col(k, :), 'LineWidth', 1.5);
    end
    set(gca, 'YScale', 'log');  grid on;  xlabel('$t$');  title('$V(x(t))$ solo puede crecer en $U$');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
