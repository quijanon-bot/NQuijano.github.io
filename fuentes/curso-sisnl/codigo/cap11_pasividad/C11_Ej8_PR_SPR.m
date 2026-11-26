%% C11_Ej8_PR_SPR -- Notas: sección 11.7 (funciones reales positivas)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Familia G_z(s) = (s + z)/(s^2 + 3 s + 2), z = 1.5, 3, 5: Nyquist,
%            Re G_z(jw) y w^2 Re G_z(jw), y la prueba numérica esPR.
% OBSERVE    Las tres son Hurwitz. Con z = 3 la parte real es positiva en todo
%            el eje, pero w^2 Re G -> a - z = 0: PR y NO SPR. Con z = 5 la
%            curva cruza al semiplano izquierdo para w > sqrt(5).
% ESPERADO   z = 1.5: SPR;  z = 3: PR;  z = 5: no PR.
% EXPLORE    ¿Qué pasa con z = 1 y z = 2? (Pista: cancelaciones polo-cero; la
%            prueba supone una realización mínima.)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:familia]
a = 3;  b = 2;
w = logspace(-3, 3.5, 4000);
fig = estiloFigura(1100, 420);
for z = [1.5 3 5]
    G = respFrec([1 z], [1 a b], w);
    v = esPR([1 z], [1 a b]);
    fprintf('z = %3.1f:  min Re G = %+.4f   w^2 Re G(w = 3000) = %+.4f  (a - z = %+.1f)  -> %s\n', ...
            z, min(real(G)), 3000^2*real(respFrec([1 z], [1 a b], 3000)), a - z, v);
    subplot(1,2,1); plot(real(G), imag(G)); hold on;
    subplot(1,2,2); semilogx(w, w.^2.*real(G)); hold on;
end
% [fin:familia]
subplot(1,2,1); grid on; axis([-0.12 0.35 -0.25 0.08]); xlabel('Re'); ylabel('Im');
legend('$z=1.5$', '$z=3$', '$z=5$', 'Location', 'southeast');
subplot(1,2,2); grid on; ylim([-2.5 2.5]); xlabel('$\omega$'); title('$\omega^2\,\mathrm{Re}\,G_z(j\omega)$');

% [ini:trampa]
G3 = respFrec([1 3], [1 3 2], w);
fprintf('(s+3)/((s+1)(s+2)): Re G(j1) = %.4f (= 6/10);  ¿y con s -> s - 0.1?\n', ...
        real(respFrec([1 3], [1 3 2], 1)));
Gc = polyval([1 3], 1j*w - 0.1)./polyval([1 3 2], 1j*w - 0.1);
fprintf('  min Re G(jw - 0.1) = %.4f < 0: no es SPR\n', min(real(Gc)));
% [fin:trampa]

% ---- Figura de las notas (fig:pa-familia) ----------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
w = logspace(-3, 3.5, 6000);  a = 3;  b = 2;
clf(fig);                                     % reemplaza, en la misma ventana, la gráfica del bloque [familia]
zs = [1.5 3 5];  cs = [ve; am; co];  et = {'SPR', 'PR, no SPR', 'no PR'};  h = zeros(1, 3);
subplot(1, 2, 1);  hold on;
patch([-1 0 0 -1], [-1 -1 1 1], claro(co, 0.05), 'EdgeColor', 'none');
plot([-1 1], [0 0], 'Color', gr, 'LineWidth', 0.6);  plot([0 0], [-1 1], 'Color', gr, 'LineWidth', 0.6);
for j = 1:3
    G = (1j*w + zs(j))./((1j*w).^2 + a*1j*w + b);
    subplot(1, 2, 1);  h(j) = plot(real(G), imag(G), 'Color', cs(j,:));
    subplot(1, 2, 2);  semilogx(w, w.^2.*real(G), 'Color', cs(j,:));  hold on;
    semilogx(w([1 end]), (a - zs(j))*[1 1], ':', 'Color', cs(j,:), 'LineWidth', 0.8);
end
subplot(1, 2, 1);  axis([-0.12 0.35 -0.25 0.08]);  grid on;  box on;  xlabel('Re');  ylabel('Im');
title('cerca del origen ($\omega\to\infty$)');
legend(h, sprintf('$z=1.5$: %s', et{1}), sprintf('$z=3$: %s', et{2}), sprintf('$z=5$: %s', et{3}), 'Location', 'southeast');
subplot(1, 2, 2);  ylim([-2.5 2.5]);  grid on;  box on;  xlabel('$\omega$ (rad/s)');
title('$\omega^2\,\mathrm{Re}\,G_z(j\omega)\to a-z$');
