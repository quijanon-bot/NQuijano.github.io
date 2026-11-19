%% C8_Video_GradienteBarrido -- Video V8_3: mover a11 y ver crecer (y colapsar) el estimado
% QUÉ MUESTRA  Gradiente variable para x1' = x2, x2' = -(x1 + x2) - sin(x1 + x2) con
%              V = a11 x1^2/2 + x1 x2 + x2^2/2. Al barrer a11 de 1.1 a 4: la región donde
%              Vdot > 0 (rojo), el mayor nivel que no la toca (azul) y su área.
% USO          Ejecute. Video en videos/V8_3_gradiente_barrido.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

[X1, X2] = meshgrid(linspace(-7, 7, 351));  Y = X1 + X2;
aa = [linspace(1.1, 4, 90), linspace(4, 1.48, 40)];  area = NaN(size(aa));
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V8_3_gradiente_barrido'), 24);
end
for i = 1:numel(aa)
    a = aa(i);  VV = a*X1.^2/2 + X1.*X2 + X2.^2/2;  Vd = (a - 2)*X1.*X2 - X1.^2 - Y.*sin(Y);
    cs = nivelCritico(@(x1, x2) a*x1.^2/2 + x1.*x2 + x2.^2/2, @(x1, x2) (a - 2)*x1.*x2 - x1.^2 - (x1 + x2).*sin(x1 + x2), [-12 12], [-12 12], 601);
    area(i) = pi*cs/sqrt(a/4 - 1/4);
    clf(fig);
    subplot(1, 2, 1);  contourf(X1, X2, double(Vd > 0), [0.5 0.5]);  colormap([1 1 1; 1 0.85 0.85]);  hold on;
    if cs > 1e-3, contour(X1, X2, VV, [cs cs], 'b', 'LineWidth', 2.5); end
    axis equal;  axis([-7 7 -7 7]);  grid on;  title(sprintf('$a_{11}=%.2f$', a));
    subplot(1, 2, 2);  plot(aa(1:i), area(1:i), 'b.-');  hold on;  plot(2, pi^3, 'ro');
    axis([1 4.2 0 42]);  grid on;  xlabel('$a_{11}$');  ylabel('\''area del estimado');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
