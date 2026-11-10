%% C12_Video_DinamicaCero -- Video V12_3: después de Z*, solo manda la dinámica cero
% QUÉ MUESTRA  Sistema con n = 3 y r = 1 construido en forma normal:
%                xi' = -3 xi  (después de la linealización entrada/salida),
%                eta' = [s -2; 2 s] eta + [xi; 0],
%              con x = (eta1, eta2, xi + 0.3 (eta1^2 - eta2^2)): Z* = {xi = 0} es una
%              silla de montar. Con s = -0.25 (fase mínima) la trayectoria cae a Z* y
%              gira hacia el origen; con s = +0.12 (fase no mínima), cae a Z* y se aleja.
% USO          Ejecute. Video en videos/V12_3_dinamica_cero.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

c = @(e1, e2) 0.3*(e1.^2 - e2.^2);  ss = [-0.25 0.12];  t = linspace(0, 14, 14*24);  Z = cell(1, 2);
for j = 1:2
    M = [ss(j) -2; 2 ss(j)];
    [~, Z{j}] = ode45(@(t, z) [-3*z(1); M*z(2:3) + [z(1); 0]], t, [1.2; 1.0; 0.3], odeset('RelTol', 1e-10));
end
fig = estiloFigura(1280, 640);  [g1, g2] = meshgrid(linspace(-2.2, 2.2, 25));
tit = {'Fase m\''inima ($s=-0.25$)', 'Fase no m\''inima ($s=+0.12$)'};  cs = [42 157 143; 209 73 91]/255;
ax = zeros(1, 2);  tr = ax;  pt = ax;
for j = 1:2
    ax(j) = subplot(1, 2, j); hold(ax(j), 'on'); grid(ax(j), 'on');
    surf(ax(j), g1, g2, c(g1, g2), 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'FaceColor', [.6 .7 .85]);
    tr(j) = plot3(ax(j), nan, nan, nan, 'Color', cs(j,:), 'LineWidth', 2.2);
    pt(j) = plot3(ax(j), nan, nan, nan, 'o', 'MarkerFaceColor', cs(j,:), 'MarkerEdgeColor', 'k');
    view(ax(j), -35, 25); axis(ax(j), [-2.2 2.2 -2.2 2.2 -1.6 1.8]);
    xlabel(ax(j), '$x_1$'); ylabel(ax(j), '$x_2$'); zlabel(ax(j), '$x_3$'); title(ax(j), tit{j});
end
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V12_3_dinamica_cero'), 24);
end
for i = 1:numel(t)
    for j = 1:2
        z = Z{j}(1:i,:);  x3 = z(:,1) + c(z(:,2), z(:,3));  m = all(abs(z(:,2:3)) < 2.2, 2);
        set(tr(j), 'XData', z(m,2), 'YData', z(m,3), 'ZData', x3(m));
        if m(end), set(pt(j), 'XData', z(end,2), 'YData', z(end,3), 'ZData', x3(end)); end
    end
    drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
