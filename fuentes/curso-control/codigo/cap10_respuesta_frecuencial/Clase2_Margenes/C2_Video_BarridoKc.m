%% C2_Video_BarridoKc -- Video V4: subir Kc hasta perder la estabilidad (sección 10.7)
% OBSERVE  La fase no cambia: la ganancia solo sube la magnitud. Cuando el
%          GM llega a 0 dB (Kc = 122 210) la respuesta oscila sin amortiguarse.
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
G0 = zpk([], [-1 -10 -100], 1);
Ks = [1000*ones(1,20) logspace(3, log10(1.6e5), 330) 1.6e5*ones(1,40)];
w = logspace(-1, 3, 600);  t = linspace(0, 1.5, 600);
[~, f0] = bode(G0, w);  f0 = squeeze(f0);
fig = estiloFigura(1280, 720);
ax1 = subplot(2,2,1); hold on; grid on; set(ax1, 'XScale', 'log'); ylim([-80 50]); ylabel('dB'); xline(33.3, 'r:'); yline(0, 'k');
hM = plot(ax1, NaN, NaN);  hG = plot(ax1, NaN, NaN, 'r', 'LineWidth', 3);
ax2 = subplot(2,2,3); semilogx(w, f0); grid on; hold on; yline(-180, 'k'); xline(33.3, 'r:'); ylabel('fase ($^\circ$)'); xlabel('$\omega$ (rad/s)');
ax3 = subplot(2,2,[2 4]); hold on; grid on; axis([0 1.5 -0.5 2.5]); xlabel('$t$ (s)'); title('lazo cerrado: escal\''on');
hY = plot(ax3, NaN, NaN, 'r');
v = abrirVideo('V4_barrido_Kc', 30);
for k = 1:numel(Ks)
    K = Ks(k);  [m, ~] = bode(K*G0, w);  m = 20*log10(squeeze(m));
    m33 = 20*log10(abs(evalfr(K*G0, 1j*33.317)));
    set(hM, 'XData', w, 'YData', m);  set(hG, 'XData', [33.317 33.317], 'YData', [m33 0]);
    y = step(feedback(K*G0, 1), t);  set(hY, 'XData', t, 'YData', max(min(y, 3), -1));
    if K < 122210, est = 'ESTABLE'; else, est = 'INESTABLE'; end
    sgtitle(sprintf('K_c = %9.0f    GM = %+5.1f dB  ->  %s', K, -m33, est));
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
