%% C1_Video_PasaAltos_s_s10 -- Video V11: s/(s+10) como filtro pasa-altos (sección 10.5)
% Parte 1: barrido de frecuencia (entrada y salida en estado estacionario + Bode).
% Parte 2: entrada compuesta sin(t) + 0.3 sin(20t): solo pasa la componente rápida.
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
G = tf([1 0], [1 10]);
wg = logspace(-1, 3, 800);  [mg, fg] = bode(G, wg);  mg = 20*log10(squeeze(mg));  fg = squeeze(fg);
ws = [0.1*ones(1,15) logspace(-1, 3, 300) 1000*ones(1,30)];
tau = linspace(0, 4*pi, 400);

fig = estiloFigura(1280, 720);
set(groot, 'defaultTextInterpreter', 'tex', 'defaultAxesTickLabelInterpreter', 'tex', 'defaultLegendInterpreter', 'tex');
ax1 = subplot(2,2,[1 3]); hold on; grid on;
hIn = plot(ax1, NaN, NaN, '--', 'Color', [.5 .5 .5], 'LineWidth', 2);  hOut = plot(ax1, NaN, NaN, 'LineWidth', 2.4);
legend(ax1, 'entrada', 'salida', 'Location', 'southwest');
ax2 = subplot(2,2,2); semilogx(wg, mg, 'Color', [.85 .85 .85]); hold on; grid on; ylim([-45 5]); ylabel('dB');
hM = semilogx(ax2, NaN, NaN, 'LineWidth', 2.2);  pM = plot(ax2, NaN, NaN, 'o', 'MarkerFaceColor', 'auto');
ax3 = subplot(2,2,4); semilogx(wg, fg, 'Color', [.85 .85 .85]); hold on; grid on; ylim([-5 95]); ylabel('fase (grados)'); xlabel('\omega (rad/s)');
hF = semilogx(ax3, NaN, NaN, 'LineWidth', 2.2);  pF = plot(ax3, NaN, NaN, 'o', 'MarkerFaceColor', 'auto');

v = abrirVideo('V11_pasaaltos_s_s10', 30);
axis(ax1, [0 4*pi -1.6 1.6]);  xlabel(ax1, '\omega t (dos periodos)');
for k = 1:numel(ws)
    w = ws(k);  g = evalfr(G, 1j*w);  Mg = abs(g);  ph = angle(g);
    set(hIn, 'XData', tau, 'YData', sin(tau));  set(hOut, 'XData', tau, 'YData', Mg*sin(tau + ph));
    idx = wg <= w;
    set(hM, 'XData', wg(idx), 'YData', mg(idx));  set(pM, 'XData', w, 'YData', 20*log10(Mg));
    set(hF, 'XData', wg(idx), 'YData', fg(idx));  set(pF, 'XData', w, 'YData', rad2deg(ph));
    sgtitle(sprintf('\\omega = %6.1f rad/s   |G| = %5.3f (%+5.1f dB)   fase = +%4.1f° (salida adelantada)', w, Mg, 20*log10(Mg), rad2deg(ph)));
    drawnow;  writeVideo(v, getframe(fig));
end
% Parte 2: señal compuesta
% [ini:pasaaltos]
t = linspace(0, 6.3, 3000);
x = sin(t) + 0.3*sin(20*t);          % componente lenta + componente rápida
y = lsim(G, x, t);                   % la lenta sale x0.0995, la rápida x0.894
% [fin:pasaaltos]
axis(ax1, [0 6.3 -1.6 1.6]);  xlabel(ax1, 't (s)');
set(hM, 'XData', wg, 'YData', mg);  set(hF, 'XData', wg, 'YData', fg);
set(pM, 'XData', [1 20], 'YData', 20*log10(abs(evalfr(G, 1j*[1 20]))));
set(pF, 'XData', [1 20], 'YData', rad2deg(angle(evalfr(G, 1j*[1 20]))));
sgtitle('Entrada sin(t) + 0.3 sin(20t): la lenta se atenúa 20 dB, la rápida pasa casi intacta');
for k = 1:150
    n = round(numel(t)*min(1, k/110));
    set(hIn, 'XData', t(1:n), 'YData', x(1:n));  set(hOut, 'XData', t(1:n), 'YData', y(1:n));
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
