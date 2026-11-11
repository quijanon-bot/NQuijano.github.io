%% C4_Video_CuencasDuffing -- Video V4_2: la variedad estable dibuja las cuencas
% QUÉ MUESTRA  Duffing amortiguado (delta = 0.5). Las dos ramas de W^s de la silla
%              (negro, calculadas hacia atrás en el tiempo) y de W^u (verde) crecen
%              desde el origen; al final aparecen las cuencas de (1,0) (azul) y
%              (-1,0) (coral), cuya frontera es W^s.
% USO          Ejecute. Video en videos/V4_2_cuencas_duffing.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
addpath(raiz);
HACER_VIDEO = true;

delta = 0.5;  L = 3;  f = @(x) [x(2); x(1) - x(1)^3 - delta*x(2)];
Ws = variedadSilla(f, [0; 0], 'estable', 40, 1e-6, [-L L -L L]);
Wu = variedadSilla(f, [0; 0], 'inestable', 30, 1e-6);
[X1, X2] = meshgrid(linspace(-L, L, 201));  x = X1;  y = X2;  h = 0.01;
for k = 1:6000                                         % pozo final, RK4 vectorizado
    k1x = y;  k1y = x - x.^3 - delta*y;
    k2x = y + h/2*k1y;  k2y = (x + h/2*k1x) - (x + h/2*k1x).^3 - delta*(y + h/2*k1y);
    k3x = y + h/2*k2y;  k3y = (x + h/2*k2x) - (x + h/2*k2x).^3 - delta*(y + h/2*k2y);
    k4x = y + h*k3y;    k4y = (x + h*k3x) - (x + h*k3x).^3 - delta*(y + h*k3y);
    x = x + h/6*(k1x + 2*k2x + 2*k3x + k4x);  y = y + h/6*(k1y + 2*k2y + 2*k3y + k4y);
end
S = sign(x);
fig = estiloFigura(720, 680);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V4_2_cuencas_duffing'), 24);
end
n = 150;
for k = 1:n
    clf(fig);  hold on;  fr = k/n;
    if k > 0.6*n, contourf(X1, X2, S, [0 0]);  colormap([1 0.85 0.87; 0.85 0.9 1]); end
    for r = 1:2
        m = max(2, round(fr*size(Ws{r}, 1)));  plot(Ws{r}(1:m, 1), Ws{r}(1:m, 2), 'k', 'LineWidth', 2);
        m = max(2, round(fr*size(Wu{r}, 1)));  plot(Wu{r}(1:m, 1), Wu{r}(1:m, 2), 'Color', [42 157 143]/255, 'LineWidth', 2);
    end
    plot([-1 1], [0 0], 'ko', 'MarkerFaceColor', [20 33 61]/255);  plot(0, 0, 'ko', 'MarkerFaceColor', 'w');
    axis equal;  axis([-L L -L L]);  xlabel('$x_1$');  ylabel('$x_2$');
    title('Duffing, $\delta=0.5$: $W^s$ (negro) y $W^u$ (verde) de la silla');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
