%% C11_Video_Balance -- Video V11_1: la energía que entra, la que se guarda y la que se pierde
% QUÉ MUESTRA  La masa con resorte duro de C11_Ej1 moviéndose, y tres barras que
%              crecen: energía suministrada int u y, disipada int delta y^2 y
%              almacenada V. En todo instante  almacenada = V(0) + suministrada - disipada.
% USO          Ejecute. El video queda en videos/V11_1_balance.mp4 (en Linux, .avi).
%              Con HACER_VIDEO = false solo se anima en pantalla.
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

delta = 0.3;  F = @(x1) x1 + x1.^3;  u = @(t) 0.8*sin(1.2*t).*(t < 12);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.01);
[t, X] = ode45(@(t, x) [x(2); -F(x(1)) - delta*x(2) + u(t)], linspace(0, 30, 901), [0; 0], opc);
y = X(:,2);  V = X(:,1).^2/2 + X(:,1).^4/4 + y.^2/2;
[S, D] = balanceEnergia(t, V, u(t).*y, delta*y.^2);

fig = estiloFigura(1280, 720);
ax1 = subplot(2,2,1); hold(ax1, 'on'); axis(ax1, [-2 2 -0.6 0.6]); axis(ax1, 'off');
title(ax1, 'masa con resorte duro, $F(x_1)=x_1+x_1^3$');
plot(ax1, [-2 -1.9], [-0.4 0.4], 'k', 'LineWidth', 4);
resorte = plot(ax1, 0, 0, 'Color', [0.36 0.40 0.49]);
masa = fill(ax1, [-0.2 0.2 0.2 -0.2], [-0.25 -0.25 0.25 0.25], [0.12 0.35 0.66]);
flecha = quiver(ax1, 0, 0, 0, 0, 0, 'Color', [0.82 0.29 0.36], 'LineWidth', 2, 'MaxHeadSize', 2);
ax2 = subplot(2,2,2); barras = bar(ax2, [0 0 0], 'FaceColor', 'flat');
barras.CData = [0.16 0.62 0.56; 0.42 0.29 0.71; 0.08 0.13 0.24];
set(ax2, 'XTickLabel', {'suministrada', 'disipada', 'almacenada'}); ylim(ax2, [0 5.5]); grid(ax2, 'on');
ax3 = subplot(2,1,2); hold(ax3, 'on'); grid(ax3, 'on'); xlim(ax3, [0 30]); ylim(ax3, [0 5.5]);
lS = plot(ax3, nan, nan); lD = plot(ax3, nan, nan); lV = plot(ax3, nan, nan, 'k', 'LineWidth', 2.5);
legend(ax3, '$\int u\,y$', '$\int\delta y^2$', '$V$', 'Location', 'northwest'); xlabel(ax3, '$t$ (s)');
patch(ax3, [0 12 12 0], [0 0 5.5 5.5], [0.88 0.62 0.24], 'FaceAlpha', 0.08, 'EdgeColor', 'none');

if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V11_1_balance'), 30);
end
for k = 1:numel(t)
    xm = X(k,1)*0.8;                       % posición de la masa (escala de dibujo)
    xs = linspace(-1.9, xm - 0.2, 200);
    set(resorte, 'XData', xs, 'YData', 0.12*sin(linspace(0, 16*pi, 200)));
    set(masa, 'XData', xm + [-0.2 0.2 0.2 -0.2]);
    set(flecha, 'XData', xm, 'YData', 0.4, 'UData', 0.5*u(t(k)), 'VData', 0);
    barras.YData = [S(k) D(k) V(k)];
    set(lS, 'XData', t(1:k), 'YData', S(1:k)); set(lD, 'XData', t(1:k), 'YData', D(1:k));
    set(lV, 'XData', t(1:k), 'YData', V(1:k));
    title(ax2, sprintf('$t=%.1f$ s:  $V=%.3f=%.3f-%.3f$', t(k), V(k), S(k), D(k)));
    drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
