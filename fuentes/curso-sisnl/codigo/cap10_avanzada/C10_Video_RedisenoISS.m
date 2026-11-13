%% C10_Video_RedisenoISS -- Video V10_4: estabilizar no es robustecer
% QUÉ MUESTRA  x' = x + (x^2 + 1)(u + w) con el error de actuador w subiendo de 0.05 a 1.
%              Cancelación exacta, k = -2x/(x^2+1): para w > 1/2 el campo no tiene ceros y
%              x escapa desde 0. Con -L_gV (k1 = k - x(x^2+1)) siempre hay un equilibrio.
% USO          Ejecute. Video en videos/V10_4_rediseno_iss.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

k = @(x) -2*x/(x^2 + 1);  k1 = @(x) k(x) - x*(x^2 + 1);  xx = linspace(-1, 12, 600);
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 0.02, 'Events', @(t, x) deal(x - 30, 1, 1));
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V10_4_rediseno_iss'), 24);
end
for w = [linspace(0.05, 1, 60) ones(1, 15)]
    clf(fig);
    subplot(1, 2, 1);  plot(xx, -xx + (xx.^2 + 1)*w, xx, -xx - xx.*(xx.^2 + 1).^2 + (xx.^2 + 1)*w, [-1 12], [0 0], 'k');
    axis([-1 12 -4 8]);  grid on;  xlabel('$x$');  ylabel('$\dot x$');  legend('cancelaci\''on', 'con $-L_gV$', 'Location', 'northwest');
    title(sprintf('error del actuador $w=%.2f$', w));
    subplot(1, 2, 2);  hold on;
    [t1, X1] = ode45(@(t, x) x + (x^2 + 1)*(k(x) + w), [0 8], 0, opc);
    [t2, X2] = ode45(@(t, x) x + (x^2 + 1)*(k1(x) + w), [0 8], 0, opc);
    plot(t1, X1, t2, X2);  axis([0 8 -0.5 12]);  grid on;  xlabel('$t$');  ylabel('$x$');  title('desde $x(0)=0$');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
