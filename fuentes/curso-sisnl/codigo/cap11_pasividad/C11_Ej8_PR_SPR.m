%% C11_Ej8_PR_SPR -- Notas: sección 11.7 (funciones reales positivas)
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
