%% C2_Video_SensorMargenFase -- El PM como presupuesto de fase (sección 10.7) + video V12
% G'(s) = 10000/((s+1)(s+10)(s+100)): PM = 54.9° en 7.80 rad/s.
% Un sensor de primer orden a/(s+a) en la retroalimentación "gasta" fase:
%     PM_nuevo ~ PM - atan(w_PM/a)     (buena estimación si a >> w_PM)
% ESPERADO (PM con margin, sobrepico):
%     a = 50: 46.5° (28 %),  a = 20: 36.4° (44 %),  a = 10: 26.3° (68 %),  a = 5: 18.7° (104 %)
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
% [ini:sensor]
G = zpk([], [-1 -10 -100], 1e4);
[~, Pm, ~, Wcp] = margin(G)                      % 54.9°, 7.80 rad/s
fprintf('\n   a     PM estimado   PM (margin)   GM (dB)   sobrepico\n');
for a = [50 20 10 5]
    H = tf(a, [1 a]);                            % sensor de primer orden
    [Gm, PmH] = margin(G*H);                     % malla abierta: G'(s) = G(s) H(s)
    S = stepinfo(feedback(G, H));                % lazo cerrado: Y/R = G/(1+GH)
    fprintf('%5g     %6.1f°       %6.1f°      %6.2f    %6.1f %%\n', ...
            a, Pm - atand(Wcp/a), PmH, 20*log10(Gm), S.Overshoot);
end
% [fin:sensor]
t = linspace(0, 2.5, 3000);
figure('Color', 'w'); hold on; grid on;
plot(t, step(feedback(G, 1), t), 'DisplayName', 'sin sensor');
for a = [50 20 10 5]
    H = tf(a, [1 a]);  [~, PmH] = margin(G*H);
    plot(t, step(feedback(G, H), t), 'DisplayName', sprintf('a = %g: PM = %.1f°', a, PmH));
end
legend show; xlabel('t (s)'); title('Escalón en lazo cerrado con un sensor a/(s+a)');

%% Video V12: barrido de a de 300 a 5 rad/s
w = logspace(-1, 3, 600);  [mg, fg] = bode(G, w);  mg = 20*log10(squeeze(mg));  fg = squeeze(fg);
aa = [300*ones(1,45) logspace(log10(300), log10(5), 330) 5*ones(1,75)];
fig = estiloFigura(1280, 720);
set(groot, 'defaultTextInterpreter', 'tex', 'defaultAxesTickLabelInterpreter', 'tex', 'defaultLegendInterpreter', 'tex');
ax1 = subplot(2,2,1); semilogx(w, mg, 'Color', [.6 .6 .6]); grid on; hold on; yline(0, 'k'); ylabel('dB'); ylim([-80 30]);
hM = semilogx(ax1, NaN, NaN, 'b', 'LineWidth', 2);
ax2 = subplot(2,2,3); semilogx(w, fg, 'Color', [.6 .6 .6]); grid on; hold on; yline(-180, 'k'); ylim([-360 0]); ylabel('fase (grados)'); xlabel('\omega (rad/s)');
hF = semilogx(ax2, NaN, NaN, 'r', 'LineWidth', 2);  hB = plot(ax2, NaN, NaN, 'g', 'LineWidth', 5);
ax3 = subplot(2,2,[2 4]); hold on; grid on; axis([0 2.5 0 2.1]); xlabel('t (s)'); title('lazo cerrado: escalón');
plot(ax3, t, step(feedback(G, 1), t), 'Color', [.6 .6 .6]);  hY = plot(ax3, NaN, NaN, 'r', 'LineWidth', 2);
v = abrirVideo('V12_sensor_margen_fase', 30);
for k = 1:numel(aa)
    a = aa(k);  H = tf(a, [1 a]);  L = G*H;
    [m, f] = bode(L, w);  set(hM, 'XData', w, 'YData', 20*log10(squeeze(m)));  set(hF, 'XData', w, 'YData', squeeze(f));
    [~, PmH, ~, WcpH] = margin(L);  set(hB, 'XData', [WcpH WcpH], 'YData', [-180 -180+PmH]);
    y = step(feedback(G, H), t);  set(hY, 'XData', t, 'YData', y);
    os = (max(y) - y(end))/y(end)*100;
    sgtitle(sprintf('a = %6.1f rad/s     PM = %5.1f°     sobrepico = %5.1f %%', a, PmH, os));
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
