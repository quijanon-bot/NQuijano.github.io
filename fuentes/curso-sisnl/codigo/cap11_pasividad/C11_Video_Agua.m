%% C11_Video_Agua -- Video V11_5: tres tanques, un caudal y un replicador
% QUÉ MUESTRA  Los niveles de los tres tanques, el reparto del caudal q_i y la
%              función V = V1 + V2. En t = 40 s sube la demanda del tanque 3
%              (c3: 1.4 -> 2.0): V salta (cambió el equilibrio) y vuelve a decrecer.
% USO          Ejecute. Video en videos/V11_5_agua.mp4.
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

Q = 2;  r = 2;  vm = 2;  c1 = [0.6; 1.0; 1.4];  c2 = [0.6; 1.0; 2.0];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t1, X1] = ode45(@(t, x) modeloAgua(x, c1, Q, r, vm), linspace(0, 40, 481), [0.1; 0.8; 0.3; 0.9; 0.6; 0.5], opc);
[t2, X2] = ode45(@(t, x) modeloAgua(x, c2, Q, r, vm), linspace(40, 80, 481), X1(end,:).', opc);
[a1, b1] = energiaAgua(X1, c1, Q, r, vm);  [a2, b2] = energiaAgua(X2, c2, Q, r, vm);
t = [t1; t2(2:end)];  X = [X1; X2(2:end,:)];  V = [a1 + b1; a2(2:end) + b2(2:end)];

fig = estiloFigura(1280, 680);
ax1 = subplot(2,2,1); hold(ax1, 'on'); axis(ax1, [0.3 3.7 0 1]); title(ax1, 'vol\''umenes $v_i$');
niv = bar(ax1, [0 0 0], 0.6, 'FaceColor', [0.55 0.71 0.90]); grid(ax1, 'on');
ref = plot(ax1, [0.5 3.5], [1 1]*4/9, 'k--');
ax2 = subplot(2,2,2); cau = bar(ax2, [0 0 0], 0.6, 'FaceColor', 'flat'); ylim(ax2, [0 1.3]); grid(ax2, 'on');
cau.CData = [0.12 0.35 0.66; 0.82 0.29 0.36; 0.42 0.29 0.71]; title(ax2, 'caudales $q_i$ ($\sum q_i=Q=2$)');
ax3 = subplot(2,1,2); grid(ax3, 'on'); hold(ax3, 'on'); set(ax3, 'YScale', 'log'); xlim(ax3, [0 80]); ylim(ax3, [1e-8 10]);
lV = plot(ax3, nan, nan, 'k', 'LineWidth', 2.5); plot(ax3, [40 40], [1e-8 10], 'Color', [0.88 0.62 0.24], 'LineWidth', 2);
xlabel(ax3, '$t$ (s)'); title(ax3, '$V=V_1+V_2$ respecto al equilibrio vigente');

if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V11_5_agua'), 30);
end
for k = 1:numel(t)
    niv.YData = X(k,1:3);  cau.YData = X(k,4:6);
    if t(k) >= 40, set(ref, 'YData', [1 1]*4/12.96); end
    set(lV, 'XData', t(1:k), 'YData', V(1:k));
    title(ax1, sprintf('vol\\''umenes, $t=%.1f$ s, $c_3=%.1f$', t(k), 1.4 + 0.6*(t(k) >= 40)));
    drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
