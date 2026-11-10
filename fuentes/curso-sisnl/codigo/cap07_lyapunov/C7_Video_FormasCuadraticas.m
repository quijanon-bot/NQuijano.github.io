%% C7_Video_FormasCuadraticas -- Video V7_1: de elipses a hipérbolas
% QUÉ MUESTRA  V(x) = x'Px con P = R diag(2, lambda2) R' (ejes girados 30 grados) mientras
%              lambda2 baja de 1.5 a -1.5. Las elipses (P > 0) se estiran, se abren en
%              franjas paralelas justo en lambda2 = 0 (P >= 0 singular) y se vuelven
%              hipérbolas (P indefinida). Arriba, los menores líderes Delta1 y Delta2.
% USO          Ejecute. Video en videos/V7_1_formas_cuadraticas.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

th = pi/6;  R = [cos(th) -sin(th); sin(th) cos(th)];
lam2 = [linspace(1.5, 0, 120) zeros(1, 36) linspace(0, -1.5, 120)];
[X1, X2] = meshgrid(linspace(-2, 2, 161));
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V7_1_formas_cuadraticas'), 24);
end
for k = 1:numel(lam2)
    P = R*diag([2 lam2(k)])*R';
    V = P(1,1)*X1.^2 + 2*P(1,2)*X1.*X2 + P(2,2)*X2.^2;
    clf(fig);
    subplot(1, 2, 1);  surf(X1, X2, V, 'EdgeColor', 'none');  view(-35, 30);
    zlim([-6 10]);  xlabel('$x_1$');  ylabel('$x_2$');  title('$V(x)=x^TPx$');
    subplot(1, 2, 2);  hold on;
    contour(X1, X2, V, [0.25 0.5 1 2 3], 'LineColor', [30 90 168]/255);
    if lam2(k) < 0, contour(X1, X2, V, -[0.25 0.5 1 2 3], 'LineColor', [209 73 91]/255); end
    axis equal;  axis([-2 2 -2 2]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
    title(sprintf('$\\lambda_2=%.2f$: $\\Delta_1=%.2f$, $\\Delta_2=%.2f$', lam2(k), P(1,1), det(P)));
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
