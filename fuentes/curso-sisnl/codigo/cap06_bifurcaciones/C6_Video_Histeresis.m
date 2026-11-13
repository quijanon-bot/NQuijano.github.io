%% C6_Video_Histeresis -- Video V6_3: salto y regreso (histéresis de ciclos)
% QUÉ MUESTRA  r' = r(mu + r^2 - r^4), theta' = 1, con mu que sube lentamente de -0.4
%              a 0.1 y vuelve a bajar. A la izquierda, el estado en el plano; a la
%              derecha, (mu, r) sobre el diagrama de bifurcación.
% USO          Ejecute. Video en videos/V6_3_histeresis_ciclos.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

T = 3000;  ruido = 1e-6;  opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 1);
g = @(t, r, m0, m1) r*((m0 + (m1 - m0)*t/T) + r^2 - r^4) + ruido;
[t1, R1] = ode45(@(t, r) g(t, r, -0.4, 0.1), linspace(0, T, 160), 1e-3, opc);
[t2, R2] = ode45(@(t, r) g(t, r, 0.1, -0.4), linspace(0, T, 160), R1(end), opc);
m = [-0.4 + 0.5*t1/T; 0.1 - 0.5*t2/T];  R = [R1; R2];  th = (1:numel(m)).'*0.35;
rr = linspace(0, 1.3, 400);  mr = rr.^4 - rr.^2;  est = (2*rr - 4*rr.^3) < 0;
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V6_3_histeresis_ciclos'), 24);
end
for k = 1:numel(m)
    clf(fig);
    subplot(1, 2, 1);  k0 = max(1, k - 12);  cc = linspace(0, 2*pi, 200);
    plot(R(k)*cos(cc), R(k)*sin(cc), 'Color', [201 209 222]/255);  hold on;
    if k > k0
        ts = linspace(th(k0), th(k), 20*(k - k0) + 2);  rs = interp1(th(k0:k), R(k0:k), ts);
        plot(rs.*cos(ts), rs.*sin(ts), 'Color', [30 90 168]/255);
    end
    plot(R(k)*cos(th(k)), R(k)*sin(th(k)), 'o', 'MarkerSize', 10, 'MarkerFaceColor', [209 73 91]/255, 'MarkerEdgeColor', 'none');
    axis equal;  axis([-1.3 1.3 -1.3 1.3]);  grid on;  title(sprintf('$\\mu=%.3f$', m(k)));
    subplot(1, 2, 2);
    plot(mr(est), rr(est), '.', 'Color', [42 157 143]/255);  hold on;
    plot(mr(~est), rr(~est), '.', 'Color', [209 73 91]/255);  plot(m(1:k), R(1:k), 'Color', [30 90 168]/255);
    plot(m(k), R(k), 'o', 'MarkerFaceColor', [209 73 91]/255);
    axis([-0.45 0.15 -0.05 1.3]);  grid on;  xlabel('$\mu$');  ylabel('$r$');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
