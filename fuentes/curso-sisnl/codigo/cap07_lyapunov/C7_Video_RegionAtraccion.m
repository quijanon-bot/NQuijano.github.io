%% C7_Video_RegionAtraccion -- Video V7_4: el nivel más grande que se puede certificar
% QUÉ MUESTRA  Van der Pol en tiempo invertido con V = x'Px, P = [1.5 -0.5; -0.5 1]. El
%              nivel Omega_c crece hasta tocar la curva {Vdot = 0} (c* = 2.30); detrás,
%              el ciclo límite inestable, frontera de la región de atracción real. Al
%              final, soluciones desde la frontera de Omega_c* convergen al origen.
% USO          Ejecute. Video en videos/V7_4_region_atraccion.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

f = @(t, x) [-x(2); x(1) + (x(1)^2 - 1)*x(2)];
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11);
[~, Cic] = ode45(@(t, x) -f(t, x), [0 30], [2; 0], opc);  Cic = Cic(round(end/2):end, :);
[X1, X2] = meshgrid(linspace(-3, 3, 241));
V = 1.5*X1.^2 - X1.*X2 + X2.^2;  W = -X1.^2 - X2.^2 - X1.^3.*X2 + 2*X1.^2.*X2.^2;
cEst = 2.3045;  cs = [linspace(0.05, cEst, 120) cEst*ones(1, 96)];
ang = linspace(0, 2*pi, 9);  ang(end) = [];  L = chol([1.5 -0.5; -0.5 1]);
Y = cell(1, numel(ang));
for i = 1:numel(ang)
    [~, Y{i}] = ode45(f, linspace(0, 12, 96), 0.99*sqrt(cEst)*(L \ [cos(ang(i)); sin(ang(i))]), opc);
end
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V7_4_region_atraccion'), 24);
end
for k = 1:numel(cs)
    clf(fig);  hold on;
    plot(Cic(:,1), Cic(:,2), 'Color', [92 103 125]/255, 'LineWidth', 1.5);
    contour(X1, X2, W, [0 0], 'LineColor', [209 73 91]/255, 'LineWidth', 1.5);
    contour(X1, X2, V, cs(k)*[1 1], 'LineColor', [42 157 143]/255, 'LineWidth', 3);
    if k > 120
        j = k - 120;
        for i = 1:numel(ang), plot(Y{i}(1:j, 1), Y{i}(1:j, 2), 'Color', [30 90 168]/255); end
    end
    axis equal;  axis([-3 3 -3 3]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
    title(sprintf('$\\Omega_c=\\{x^TPx\\le c\\}$, $c=%.2f$', cs(k)));
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
