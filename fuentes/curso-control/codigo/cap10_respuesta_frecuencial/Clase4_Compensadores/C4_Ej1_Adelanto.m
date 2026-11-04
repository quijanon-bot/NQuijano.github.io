%% C4_Ej1_Adelanto -- Notas: sección 10.11 (ejemplo de compensador en adelanto) + video V7
% Gp = K/(s(s+2)), e_ss(rampa) = 5 %  ->  kv = 20  ->  K = 40;  PM deseado 45°
% ESPERADO  PM0 = 18.0° (6.17 rad/s); phiM = 37.0°; alpha = 4.03; wM = 8.85;
%           wL = 4.41; wH = 17.76; PM = 49.8°;  %OS: 60 % -> 22 %
% NOTA      El handout anterior decía wM = 14 en el texto: era un error
%           tipográfico (su propio código usaba 8.84).
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

% [ini:adelanto]
ess = 0.05;  kv = 1/ess;  K = 2*kv                     % paso 1: kv = K/2 -> K = 40
Gp  = zpk([], [0 -2], K);
[Gc, info] = disenoAdelanto(Gp, 45, 10)                % pasos 2 a 7
margenesTabla(Gp, 'sin compensar');
margenesTabla(Gc*Gp, 'con adelanto');
% [fin:adelanto]
stepinfo(feedback(Gp, 1)), stepinfo(feedback(Gc*Gp, 1))
fig = estiloFigura(1200, 560);
subplot(1,2,1); bode(Gp, Gc, Gc*Gp); grid on; legend('G_p', 'G_c', 'G_cG_p');
subplot(1,2,2); step(feedback(Gp, 1), feedback(Gc*Gp, 1), 5); grid on; legend('sin compensar', 'adelanto');
exportgraphics(fig, 'C4_adelanto.png', 'Resolution', 200);

%% Video V7: alpha de 1 a 4.03 con wM fijo
w = logspace(-1, 3, 600);  t = linspace(0, 4, 600);  wM = info.wM;
als = [ones(1,20) linspace(1, info.alpha, 240) info.alpha*ones(1,50)];
fig = estiloFigura(1280, 720);
ax1 = subplot(2,2,1); hold on; grid on; set(ax1, 'XScale', 'log'); ylim([-70 55]); yline(0, 'k'); ylabel('dB');
[m0, f0] = bode(Gp, w);  plot(ax1, w, 20*log10(squeeze(m0)), 'Color', [.6 .6 .6]);  hM = plot(ax1, NaN, NaN, 'r');
ax2 = subplot(2,2,3); hold on; grid on; set(ax2, 'XScale', 'log'); ylim([-190 -80]); yline(-180, 'k'); ylabel('fase'); xlabel('$\omega$ (rad/s)');
plot(ax2, w, squeeze(f0), 'Color', [.6 .6 .6]);  hF = plot(ax2, NaN, NaN, 'r');
ax3 = subplot(2,2,[2 4]); hold on; grid on; axis([0 4 0 1.7]); xlabel('$t$ (s)');
plot(ax3, t, step(feedback(Gp, 1), t), 'Color', [.6 .6 .6]);  hY = plot(ax3, NaN, NaN, 'r');
v = abrirVideo('V7_adelanto_alpha', 30);
for k = 1:numel(als)
    a = als(k);  wL = wM/sqrt(a);  C = zpk(-wL, -a*wL, a);  L = C*Gp;
    [m, f] = bode(L, w);  set(hM, 'XData', w, 'YData', 20*log10(squeeze(m)));  set(hF, 'XData', w, 'YData', squeeze(f));
    set(hY, 'XData', t, 'YData', step(feedback(L, 1), t));  [~, Pm] = margin(L);
    sgtitle(sprintf('alpha = %4.2f   phi_M = %4.1f deg   PM = %4.1f deg   (kv = 20 fijo)', a, asind((a-1)/(a+1)), Pm));
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
