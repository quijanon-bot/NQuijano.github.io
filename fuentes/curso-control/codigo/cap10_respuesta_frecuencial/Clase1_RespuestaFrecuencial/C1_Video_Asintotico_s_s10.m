%% C1_Video_Asintotico_s_s10 -- Video V10: Bode de s/(s+10) término a término (sección 10.5)
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
G = tf([1 0], [1 10]);
w = logspace(-1, 3, 900);
[m1,f1] = bodeAsintotico(w, 0.1, 0);            % ganancia 1/10
[m2,f2] = bodeAsintotico(w, 1, -1);             % cero en el origen
[m3,f3] = bodeAsintotico(w, 1, 0, [10 -1]);     % polo en -10
[mS,fS] = bodeAsintotico(w, 0.1, -1, [10 -1]);  % suma
[mR,fR] = bode(G, w);  mR = 20*log10(squeeze(mR));  fR = squeeze(fR);
M = {m1, m2, m3, mS, mR};  Fz = {f1, f2, f3, fS, fR};
col = {[30 90 168]/255, [209 73 91]/255, [108 74 182]/255, [20 33 61]/255, [42 157 143]/255};
txt = {'Paso 1: 1/10 -> -20 dB y 0 grados', 'Paso 2: s -> +20 dB/dec (0 dB en w = 1) y +90 grados', ...
       'Paso 3: 1/(s/10+1) -> -20 dB/dec desde w = 10', 'Paso 4: suma (pendientes +20 - 20 = 0 desde w = 10)', ...
       'Paso 5: curva real (bode)'};

fig = estiloFigura(1280, 720);
set(groot, 'defaultTextInterpreter', 'tex', 'defaultAxesTickLabelInterpreter', 'tex', 'defaultLegendInterpreter', 'tex');
ax1 = subplot(2,1,1); hold on; grid on; set(ax1, 'XScale', 'log'); xlim([0.1 1000]); ylim([-45 45]); ylabel('dB'); yline(0, 'k');
ax2 = subplot(2,1,2); hold on; grid on; set(ax2, 'XScale', 'log'); xlim([0.1 1000]); ylim([-100 110]); ylabel('fase (grados)'); xlabel('\omega (rad/s)'); yline(0, 'k');
v = abrirVideo('V10_asintotico_s_s10', 30);
P = 60;                                          % cuadros por paso
for st = 1:5
    lw = 1.8 + 1.4*(st == 4);  ls = '-';  if st == 5, ls = '--'; end
    h1 = plot(ax1, NaN, NaN, ls, 'Color', col{st}, 'LineWidth', lw);
    h2 = plot(ax2, NaN, NaN, ls, 'Color', col{st}, 'LineWidth', lw);
    sgtitle(txt{st});
    for k = 1:P
        n = max(2, round(numel(w)*min(1, k/40)));
        set(h1, 'XData', w(1:n), 'YData', M{st}(1:n));  set(h2, 'XData', w(1:n), 'YData', Fz{st}(1:n));
        drawnow;  writeVideo(v, getframe(fig));
    end
end
plot(ax1, 10, -3.01, 'ro', 'MarkerFaceColor', 'r');  text(ax1, 14, -14, '-3 dB en \omega = 10 (real)', 'Color', 'r');
plot(ax2, 10, 45, 'ro', 'MarkerFaceColor', 'r');     text(ax2, 14, 60, '45° en \omega = 10', 'Color', 'r');
sgtitle('En la esquina: -3 dB y 45°. Es un filtro pasa-altos.');
for k = 1:60, drawnow; writeVideo(v, getframe(fig)); end
close(v);
