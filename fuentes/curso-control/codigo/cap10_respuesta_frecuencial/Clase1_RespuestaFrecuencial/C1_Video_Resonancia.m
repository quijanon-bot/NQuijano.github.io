%% C1_Video_Resonancia -- Video V2: polos complejos y pico de resonancia (sección 10.4)
% wn = 1 y zeta decrece de 1 a 0.05. Tres vistas del mismo zeta:
% polos en el plano s, |G(jw)| y respuesta al escalón.
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

zs = [ones(1,20) logspace(0, log10(0.05), 300) 0.05*ones(1,45)];
w  = logspace(-1, 1, 600);  t = linspace(0, 25, 800);
[ma, ~] = bodeAsintotico(w, 1, 0, [1 -2]);

fig = estiloFigura(1280, 720);
subplot(1,3,1); hold on; grid on; axis equal; axis([-1.2 0.3 -1.2 1.2]); title('plano $s$');
th = linspace(pi/2, 3*pi/2, 100);  plot(cos(th), sin(th), ':', 'Color', [.5 .5 .5]);
hP = plot(NaN, NaN, 'x', 'MarkerSize', 14, 'LineWidth', 2.5);
subplot(1,3,2); semilogx(w, ma, 'k--'); hold on; grid on; ylim([-40 22]); title('$|G(j\omega)|$ (dB)'); xlabel('$\omega/\omega_n$');
hM = semilogx(NaN, NaN, 'LineWidth', 2.3);
subplot(1,3,3); hold on; grid on; axis([0 25 0 2]); title('escal\''on'); xlabel('$t$ (s)');
hY = plot(NaN, NaN, 'LineWidth', 2.2);

v = abrirVideo('V2_resonancia_zeta', 30);
for k = 1:numel(zs)
    z = zs(k);  G = tf(1, [1 2*z 1]);  p = pole(G);
    set(hP, 'XData', real(p), 'YData', imag(p));
    [m, ~] = bode(G, w);  set(hM, 'XData', w, 'YData', 20*log10(squeeze(m)));
    set(hY, 'XData', t, 'YData', step(G, t));
    sgtitle(sprintf('$\\zeta$ = %.3f   pico en $\\omega_n$: %+.1f dB', z, 20*log10(1/(2*z))), 'Interpreter', 'latex');
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
