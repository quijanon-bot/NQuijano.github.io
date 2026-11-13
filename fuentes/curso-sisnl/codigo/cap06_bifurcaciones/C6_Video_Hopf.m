%% C6_Video_Hopf -- Video V6_2: nace un ciclo límite
% QUÉ MUESTRA  El circuito x1' = x2 - (x1^3 - mu x1), x2' = -x1 con mu barriendo de -0.4
%              a 1. A la izquierda, una trayectoria desde (0.6, 0) y el ciclo cuando
%              existe; a la derecha, los valores propios cruzando el eje imaginario.
% USO          Ejecute. Video en videos/V6_2_hopf.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

mus = linspace(-0.4, 1, 120);
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V6_2_hopf'), 24);
end
opc = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);
for k = 1:numel(mus)
    mu = mus(k);  f = @(t, x) [x(2) - (x(1)^3 - mu*x(1)); -x(1)];
    [~, X] = ode45(f, [0 60], [0.6; 0], opc);
    clf(fig);
    subplot(1, 2, 1);  plot(X(:, 1), X(:, 2), 'Color', [30 90 168]/255);  hold on;
    if mu > 0
        [~, Y] = ode45(f, [0 300], [0.1; 0], opc);  [~, C] = ode45(f, [0 7], Y(end, :), opc);
        plot(C(:, 1), C(:, 2), 'Color', [42 157 143]/255, 'LineWidth', 3);
    end
    plot(0, 0, 'ko', 'MarkerFaceColor', (mu < 0)*[0.08 0.13 0.24] + (mu >= 0)*[1 1 1]);
    axis equal;  axis([-1.8 1.8 -1.8 1.8]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
    title(sprintf('$\\mu=%.2f$', mu));
    subplot(1, 2, 2);  lam = eig([mu 1; -1 0]);
    plot(real(lam), imag(lam), 'x', 'MarkerSize', 14, 'LineWidth', 3, 'Color', [209 73 91]/255);  hold on;
    plot([0 0], [-1.5 1.5], 'k', [-0.6 0.6], [0 0], 'k:');  axis([-0.6 0.6 -1.5 1.5]);  grid on;
    xlabel('Re $\lambda$');  ylabel('Im $\lambda$');  title('Valores propios del origen');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
