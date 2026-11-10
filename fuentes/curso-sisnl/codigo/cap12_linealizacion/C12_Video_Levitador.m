%% C12_Video_Levitador -- Video V12_1: seguimiento exacto contra jacobiano
% QUÉ MUESTRA  Dos levitadores siguen y_d = 0.08 + 0.03 sin(2 pi t). Izquierda: la ley
%              jacobiana con ganancia fija (diseñada en 0.05 m); derecha: la
%              linealización exacta. Abajo, posición y voltaje. Cámara lenta x4.
% USO          Ejecute. Video en videos/V12_1_levitador.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

P = parametrosLevitador();  [A, B] = jacobianoLevitador(0.05, P);  K = ubicarPolos(A, B, [-20 -25 -30]);
KFL = [6000 1100 60];  Am = 0.03;  w = 2*pi;  c3 = sqrt(2*P.g*P.m/(P.L0*P.a));
yd = @(t) [0.08 + Am*sin(w*t), Am*w*cos(w*t), -Am*w^2*sin(w*t), -Am*w^3*cos(w*t)];
xsRef = @(t) [0.08 + Am*sin(w*t); 0; c3*(P.a + 0.08 + Am*sin(w*t))];
uJac = @(t, x) P.R*[0 0 1]*xsRef(t) - K*(x - xsRef(t));
T = 3;  t = linspace(0, T, 4*24*T);  opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 1e-3);
x0 = equilibrioLevitador(0.08, P);
[~, X1] = ode45(@(t, x) modeloLevitador(x, uJac(t, x), P), t, x0, opc);
[~, X2] = ode45(@(t, x) modeloLevitador(x, leyExactaLevitador(x, yd(t), KFL, P), P), t, x0, opc);
Yd = 0.08 + Am*sin(w*t(:));
U1 = arrayfun(@(i) uJac(t(i), X1(i,:).'), 1:numel(t));
U2 = arrayfun(@(i) leyExactaLevitador(X2(i,:).', yd(t(i)), KFL, P), 1:numel(t));

fig = estiloFigura(1280, 720);  cl = [209 73 91; 30 90 168]/255;
ax1 = subplot(2, 3, [1 4]); hold(ax1, 'on'); axis(ax1, 'equal'); axis(ax1, [-0.03 0.17 -0.045 0.2]);
set(ax1, 'YDir', 'reverse'); axis(ax1, 'off');
xc = [0.02 0.11];  bola = zeros(1, 2);  ref = bola;
for j = 1:2
    rectangle(ax1, 'Position', [xc(j)-0.025 -0.03 0.05 0.025], 'FaceColor', [.6 .66 .79]);
    ref(j) = plot(ax1, xc(j) + [-0.02 0.02], [0.08 0.08], 'k', 'LineWidth', 2);
    bola(j) = plot(ax1, xc(j), 0.08, 'o', 'MarkerSize', 22, 'MarkerFaceColor', cl(j,:), 'MarkerEdgeColor', 'k');
end
text(ax1, 0.02, 0.17, 'jacobiana', 'HorizontalAlignment', 'center', 'Color', cl(1,:));
text(ax1, 0.11, 0.17, 'exacta', 'HorizontalAlignment', 'center', 'Color', cl(2,:));
ax2 = subplot(2, 3, [2 3]); hold(ax2, 'on'); grid(ax2, 'on'); set(ax2, 'YDir', 'reverse');
plot(ax2, t, Yd, 'k--'); l1 = plot(ax2, nan, nan, 'Color', cl(1,:)); l2 = plot(ax2, nan, nan, 'Color', cl(2,:));
xlim(ax2, [0 T]); ylim(ax2, [0.03 0.13]); ylabel(ax2, '$y$ [m]');
ax3 = subplot(2, 3, [5 6]); hold(ax3, 'on'); grid(ax3, 'on');
m1 = plot(ax3, nan, nan, 'Color', cl(1,:)); m2 = plot(ax3, nan, nan, 'Color', cl(2,:));
xlim(ax3, [0 T]); ylim(ax3, [min([U1 U2]) - 1, max([U1 U2]) + 1]); xlabel(ax3, '$t$ [s]'); ylabel(ax3, '$u$ [V]');
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V12_1_levitador'), 24);
end
for i = 1:numel(t)
    set(bola(1), 'YData', X1(i,1));  set(bola(2), 'YData', X2(i,1));
    set(ref, 'YData', Yd(i)*[1 1]);
    set(l1, 'XData', t(1:i), 'YData', X1(1:i,1));  set(l2, 'XData', t(1:i), 'YData', X2(1:i,1));
    set(m1, 'XData', t(1:i), 'YData', U1(1:i));    set(m2, 'XData', t(1:i), 'YData', U2(1:i));
    title(ax2, sprintf('$t = %.2f$ s (cuatro veces m\\''as lento)', t(i)));
    drawnow; if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
