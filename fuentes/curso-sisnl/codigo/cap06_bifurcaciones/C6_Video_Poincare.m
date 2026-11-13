%% C6_Video_Poincare -- Video V6_4: la sucesión de Poincaré de van der Pol
% QUÉ MUESTRA  Van der Pol (mu = 1) desde (0.2, 0): la trayectoria se dibuja vuelta por
%              vuelta y cada cruce con Sigma = {x2 = 0, x1 > 0} se marca; a la derecha,
%              la misma sucesión en la telaraña del mapa P.
% USO          Ejecute. Video en videos/V6_4_poincare.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

f = @(x) [x(2) - (x(1)^3 - x(1)); -x(1)];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) f(x), linspace(0, 26, 400), [0.2; 0], opc);
q = 0.2;  for k = 1:4, xr = mapaPoincare(f, [q(end); 0], @(x) x(2), -1);  q(end+1) = xr(1); end %#ok<SAGROW>
qq = linspace(0.05, 2.5, 30);  PP = arrayfun(@(s) [1 0]*mapaPoincare(f, [s; 0], @(x) x(2), -1), qq);
fig = estiloFigura(1280, 720);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V6_4_poincare'), 24);
end
for k = 2:numel(t)
    clf(fig);
    subplot(1, 2, 1);  plot(X(1:k, 1), X(1:k, 2), 'Color', [30 90 168]/255);  hold on;
    plot([0 2.5], [0 0], 'Color', [224 159 62]/255, 'LineWidth', 3);
    cruces = find(X(1:k-1, 2) > 0 & X(2:k, 2) <= 0 & X(2:k, 1) > 0);
    plot(X(cruces, 1), 0*cruces, 'o', 'MarkerFaceColor', [209 73 91]/255);
    axis([-2.5 2.5 -2.5 2.5]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('Secci\''on $\Sigma$ (\''ambar)');
    subplot(1, 2, 2);  plot(qq, PP, 'k', qq, qq, ':');  hold on;  n = min(numel(cruces), numel(q) - 1);
    for i = 1:n, plot([q(i) q(i) q(i+1)], [q(i)*(i > 1) q(i+1) q(i+1)], 'Color', [209 73 91]/255); end
    axis([0 2.5 0 2.5]);  grid on;  xlabel('$q_k$');  ylabel('$q_{k+1}$');  title('Telara\~na');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
