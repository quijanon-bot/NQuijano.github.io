%% C10_Video_BandaUUB -- Video V10_1: afinar la cota última cuesta tiempo
% QUÉ MUESTRA  x' = -x + sin t desde x(0) = 4, -4 y 2. La cota pedida b baja de 3 a 1.05
%              y la banda |x| <= b se dibuja desde T(4, b) = ln(3/(b - 1)). A la derecha,
%              T(4, b) crece sin cota cuando b -> delta = 1.
% USO          Ejecute. Video en videos/V10_1_banda_uub.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

d = 1;  a = 4;  t = linspace(0, 12, 1200);  opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11);
X = zeros(3, numel(t));  x0s = [4 -4 2];
for i = 1:3, [~, x] = ode45(@(t, x) -x + d*sin(t), t, x0s(i), opc);  X(i, :) = x'; end
env = exp(-t)*a + d*(1 - exp(-t));  bs = [linspace(3, 1.05, 70) 1.05*ones(1, 20)];  bb = linspace(1.01, 3.2, 300);
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V10_1_banda_uub'), 24);
end
for k = 1:numel(bs)
    b = bs(k);  T = log((a - d)/(b - d));  clf(fig);
    subplot(1, 2, 1);  hold on;  fill([T 12 12 T], [-b -b b b], [0.85 0.95 0.93], 'EdgeColor', 'none');
    plot(t, X);  plot(t, env, 'r--', t, -env, 'r--');  plot([T T], [-4.3 4.3], 'k:');
    axis([0 12 -4.3 4.3]);  grid on;  xlabel('$t$');  ylabel('$x$');  title(sprintf('cota $b=%.2f$ desde $T=%.2f$', b, T));
    subplot(1, 2, 2);  plot(bb, log((a - d)./(bb - d)), 'k', b, T, 'ro', 'MarkerFaceColor', 'r');
    axis([0.9 3.2 0 6]);  grid on;  xlabel('$b$');  ylabel('$T(4,b)$');  title('Afinar la cota cuesta tiempo');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
