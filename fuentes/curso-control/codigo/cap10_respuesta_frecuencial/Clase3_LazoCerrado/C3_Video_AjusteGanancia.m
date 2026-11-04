%% C3_Video_AjusteGanancia -- Video V6: subir la curva hasta cruzar en 13.56 rad/s (sección 10.10)
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
G0 = zpk([], [0 -20 -100], 1);
Ks = [logspace(log10(2000), log10(33056), 240) 33056*ones(1,60)];
w = logspace(-1, 3, 600);  t = linspace(0, 0.8, 600);
[~, f0] = bode(G0, w);  f0 = squeeze(f0);
fig = estiloFigura(1280, 720);
ax1 = subplot(2,2,1); hold on; grid on; set(ax1, 'XScale', 'log'); ylim([-110 60]); yline(0, 'k'); xline(13.56, 'g:'); ylabel('dB');
hM = plot(ax1, NaN, NaN);  hC = plot(ax1, NaN, NaN, 'ro', 'MarkerFaceColor', 'r');
subplot(2,2,3); semilogx(w, f0); hold on; grid on; yline(-131.85, 'g--'); xline(13.56, 'g:'); ylabel('fase'); xlabel('$\omega$ (rad/s)');
subplot(2,2,[2 4]); hold on; grid on; axis([0 0.8 0 1.5]); yline(1.2, '--'); xlabel('$t$ (s)');  hY = plot(NaN, NaN, 'r');
v = abrirVideo('V6_ajuste_ganancia', 30);
for k = 1:numel(Ks)
    G = Ks(k)*G0;  [~, Pm, ~, Wcp] = margin(G);  [m, ~] = bode(G, w);
    set(hM, 'XData', w, 'YData', 20*log10(squeeze(m)));  set(hC, 'XData', Wcp, 'YData', 0);
    set(hY, 'XData', t, 'YData', step(feedback(G, 1), t));
    sgtitle(sprintf('K_c = %8.0f   cruce = %5.2f rad/s   PM = %4.1f deg', Ks(k), Wcp, Pm));
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
