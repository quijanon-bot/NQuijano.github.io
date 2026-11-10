%% C7_Video_TerminoCruzado -- Video V7_2: inclinar la energía del péndulo
% QUÉ MUESTRA  Péndulo con fricción (a = 1, b = 0.5). El término cruzado p12 de
%              V = (1/2) x'[b p12  p12; p12 1] x + a(1 - cos x1) crece de 0 a 0.95 b:
%              el nivel certificado Omega_c* (grueso) se inclina y crece hasta p12 = b/2.
%              Al final, la trayectoria desde (1.5, 3): arranca en D = {|x1| < pi}, sale
%              de D y termina en (2 pi, 0).
% USO          Ejecute. Video en videos/V7_2_termino_cruzado.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

a = 1;  b = 0.5;
V = @(q, X1, X2) 0.5*(b*q*X1.^2 + 2*q*X1.*X2 + X2.^2) + a*(1 - cos(X1));
cEst = @(q) 2*a + pi^2/2*q.*(b - q);
[X1, X2] = meshgrid(linspace(-4.5, 8, 251), linspace(-3.6, 3.6, 201));
[~, Y] = ode45(@(t, x) [x(2); -a*sin(x(1)) - b*x(2)], linspace(0, 30, 120), [1.5; 3], odeset('RelTol', 1e-9));
q = [linspace(0, 0.95*b, 150) b/2*ones(1, 120)];
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V7_2_termino_cruzado'), 24);
end
for k = 1:numel(q)
    clf(fig);  hold on;
    contour(X1, X2, V(q(k), X1, X2), [0.5 1 1.5 2 3 4], 'LineColor', [201 209 222]/255);
    contour(X1, X2, V(q(k), X1, X2), cEst(q(k))*[1 1], 'LineColor', [42 157 143]/255, 'LineWidth', 3);
    plot([-pi -pi], [-3.6 3.6], 'k:', [pi pi], [-3.6 3.6], 'k:');
    if k > 150
        j = k - 150;  plot(Y(1:j, 1), Y(1:j, 2), 'Color', [209 73 91]/255, 'LineWidth', 2.5);
        plot(Y(j, 1), Y(j, 2), 'ko', 'MarkerFaceColor', [209 73 91]/255, 'MarkerSize', 9);
    end
    axis([-4.5 8 -3.6 3.6]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
    title(sprintf('$p_{12}=%.3f$: $c^*=%.3f$', q(k), cEst(q(k))));
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
