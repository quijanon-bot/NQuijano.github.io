%% C11_Video_Nyquist -- Video V11_3: de SPR a no PR moviendo un cero
% QUÉ MUESTRA  G_z(s) = (s+z)/(s^2+3s+2) con z barriendo de 1.2 a 5. Izquierda:
%              Nyquist cerca del origen (por dónde llega la curva cuando w -> inf).
%              Derecha: w^2 Re G_z(jw), que tiende a a - z = 3 - z.
%              El título da el veredicto de esPR en cada cuadro.
% USO          Ejecute. Video en videos/V11_3_nyquist.mp4.
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

w = logspace(-3, 3.5, 3000);
fig = estiloFigura(1280, 560);
ax1 = subplot(1,2,1); hold(ax1, 'on'); grid(ax1, 'on'); axis(ax1, [-0.12 0.4 -0.3 0.08]);
patch(ax1, [-0.12 0 0 -0.12], [-0.3 -0.3 0.08 0.08], [0.82 0.29 0.36], 'FaceAlpha', 0.06, 'EdgeColor', 'none');
plot(ax1, [-0.12 0.4], [0 0], 'k', [0 0], [-0.3 0.08], 'k');
cN = plot(ax1, nan, nan, 'LineWidth', 2.5); xlabel(ax1, 'Re'); ylabel(ax1, 'Im');
ax2 = subplot(1,2,2); hold(ax2, 'on'); grid(ax2, 'on'); set(ax2, 'XScale', 'log'); ylim(ax2, [-2.5 2.5]);
cW = semilogx(ax2, nan, nan, 'LineWidth', 2.5); lim = plot(ax2, [1e-3 3e3], [0 0], ':', 'LineWidth', 1.5);
xlabel(ax2, '$\omega$'); title(ax2, '$\omega^2\,\mathrm{Re}\,G_z(j\omega)\to 3-z$');

if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V11_3_nyquist'), 30);
end
zs = [linspace(1.2, 3, 120), 3*ones(1, 45), linspace(3, 5, 120), 5*ones(1, 30)];
for z = zs
    G = respFrec([1 z], [1 3 2], w);
    v = esPR([1 z], [1 3 2]);
    col = struct('SPR', [0.16 0.62 0.56], 'PR', [0.88 0.62 0.24]);
    if strcmp(v, 'no PR'), c = [0.82 0.29 0.36]; else, c = col.(v); end
    set(cN, 'XData', real(G), 'YData', imag(G), 'Color', c);
    set(cW, 'XData', w, 'YData', w.^2.*real(G), 'Color', c); set(lim, 'YData', [3 - z, 3 - z], 'Color', c);
    title(ax1, sprintf('$z=%.2f$: %s', z, v));
    drawnow;
    if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
