%% C3_Video_PM_zeta -- Video V5: subir K baja el PM y sube el sobrepico (sección 10.8)
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
Ks = [20*ones(1,20) logspace(log10(20), log10(2000), 300) 2000*ones(1,40)];
w = logspace(-1, 3, 600);  t = linspace(0, 1.6, 600);  z = linspace(0.01, 1, 200);
fig = estiloFigura(1280, 720);
ax1 = subplot(2,2,1); hold on; grid on; set(ax1, 'XScale', 'log'); ylim([-60 60]); yline(0, 'k'); ylabel('dB');
hM = plot(ax1, NaN, NaN);  hC = plot(ax1, NaN, NaN, 'go', 'MarkerFaceColor', 'g');
subplot(2,2,3); plot(z, pmDeZeta(z)); hold on; grid on; xlabel('$\zeta$'); ylabel('PM');
hZ = plot(NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 9);
ax3 = subplot(2,2,[2 4]); hold on; grid on; axis([0 1.6 0 1.8]); xlabel('$t$ (s)');  hY = plot(NaN, NaN, 'r');
v = abrirVideo('V5_PM_zeta', 30);
for k = 1:numel(Ks)
    G = zpk([], [0 -10], Ks(k));  [~, Pm, ~, Wcp] = margin(G);
    zz = zetaDePM(Pm);  [m, ~] = bode(G, w);
    set(hM, 'XData', w, 'YData', 20*log10(squeeze(m)));  set(hC, 'XData', Wcp, 'YData', 0);
    set(hZ, 'XData', zz, 'YData', Pm);  set(hY, 'XData', t, 'YData', step(feedback(G, 1), t));
    sgtitle(sprintf('K = %6.0f   PM = %4.1f deg  ->  zeta = %.2f  ->  %%OS = %4.1f', ...
            Ks(k), Pm, zz, 100*exp(-zz*pi/sqrt(1 - min(zz, 0.999)^2))));
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
