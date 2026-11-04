%% C1_Video_MaquinaBode -- Video V1 "La máquina de Bode" (notas, sección 10.2)
% Barre la frecuencia de una senoide de entrada y va dibujando, punto a
% punto, el Bode de G'(s) = 100/(s^2+4s+100)   (wn = 10, zeta = 0.2).
% OBSERVE  Cerca de w = 10 la salida es MÁS GRANDE que la entrada (resonancia)
%          y la fase pasa por -90°.
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

G  = tf(100, [1 4 100]);
wg = logspace(0, 2, 800);
[mg, fg] = bode(G, wg);  mg = 20*log10(squeeze(mg));  fg = squeeze(fg);
ws  = [ones(1,20) logspace(0,2,330) 100*ones(1,45)];    % frecuencias del barrido
tau = linspace(0, 4*pi, 400);                           % dos periodos

fig = estiloFigura(1280, 720);
ax1 = subplot(2,2,[1 3]); hold on; grid on; axis([0 4*pi -2.8 2.8]);
xlabel('$\omega t$ (dos periodos)');
plot(ax1, tau, sin(tau), '--', 'Color', [.5 .5 .5]);
hOut = plot(ax1, NaN, NaN, 'LineWidth', 2.5);
hTxt = text(ax1, 0.3, 2.3, '', 'FontSize', 13);
ax2 = subplot(2,2,2); semilogx(wg, mg, 'Color', [.8 .8 .8]); hold on; grid on; ylabel('dB'); ylim([-45 12]);
hM = semilogx(ax2, NaN, NaN, 'LineWidth', 2.2); pM = plot(ax2, NaN, NaN, 'o', 'MarkerFaceColor', 'auto');
ax3 = subplot(2,2,4); semilogx(wg, fg, 'Color', [.8 .8 .8]); hold on; grid on; ylabel('fase ($^\circ$)'); xlabel('$\omega$ (rad/s)'); ylim([-190 10]);
hF = semilogx(ax3, NaN, NaN, 'LineWidth', 2.2); pF = plot(ax3, NaN, NaN, 'o', 'MarkerFaceColor', 'auto');

v = abrirVideo('V1_maquina_bode', 30);
for k = 1:numel(ws)
    w = ws(k);  g = evalfr(G, 1j*w);  M = abs(g);  ph = angle(g);
    set(hOut, 'XData', tau, 'YData', M*sin(tau + ph));
    idx = wg <= w;
    set(hM, 'XData', wg(idx), 'YData', mg(idx));  set(pM, 'XData', w, 'YData', 20*log10(M));
    set(hF, 'XData', wg(idx), 'YData', fg(idx));  set(pF, 'XData', w, 'YData', rad2deg(ph));
    set(hTxt, 'String', sprintf('$\\omega$ = %5.1f   $|G|$ = %4.2f   $\\phi$ = %6.1f$^\\circ$', w, M, rad2deg(ph)));
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
