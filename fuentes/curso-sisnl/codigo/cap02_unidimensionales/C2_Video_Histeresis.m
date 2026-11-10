%% C2_Video_Histeresis -- Video V2_2: el diodo túnel recuerda
% QUÉ MUESTRA  El voltaje de la fuente E sube lentamente de 0 a 1.8 V y vuelve a
%              bajar. A la izquierda, la línea de fase del circuito para el E del
%              momento (cómo aparecen y desaparecen equilibrios); a la derecha,
%              el punto (E, v) sobre la curva de equilibrios: sube por una rama,
%              salta, baja por la otra y vuelve a saltar.
% USO          Ejecute. Video en videos/V2_2_histeresis.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

[h, ~] = diodoTunel();  R = 1.5;  C = 2;  Tm = 4000;  Emax = 1.8;
E = @(t) Emax*min(t, 2*Tm - t)/Tm;
t = linspace(0, 2*Tm, 481)';
[t, v] = ode45(@(t, v) ((E(t) - v)/R - h(v))/C, t, 0, odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 0.5));
vv = linspace(-0.05, 1.2, 600);
fig = estiloFigura(1280, 620);
ax1 = subplot(1, 2, 1);  ax2 = subplot(1, 2, 2); hold(ax2, 'on'); grid(ax2, 'on');
plot(ax2, vv + R*h(vv), vv, 'Color', [0.6 0.6 0.6], 'LineWidth', 4); xlim(ax2, [0 1.8]);
xlabel(ax2, '$E$ [V]'); ylabel(ax2, '$v$ [V]'); hr = plot(ax2, nan, nan); hp = plot(ax2, nan, nan, 'o', 'MarkerSize', 10);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V2_2_histeresis'), 30);
end
for k = 1:numel(t)
    Ek = E(t(k));  f = @(x) ((Ek - x)/R - h(x))/C;
    cla(ax1); lineaFase(ax1, f, [-0.05 1.2]); hold(ax1, 'on');
    plot(ax1, v(k), 0, 'o', 'MarkerSize', 12, 'MarkerFaceColor', [209 73 91]/255);
    title(ax1, sprintf('$E = %.2f$ V', Ek)); xlabel(ax1, '$v$ [V]'); ylabel(ax1, '$\dot v$');
    set(hr, 'XData', E(t(1:k)), 'YData', v(1:k)); set(hp, 'XData', Ek, 'YData', v(k)); drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
