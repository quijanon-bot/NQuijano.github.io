%% C1_Ej2_Asintotico_s_s10 -- Notas: sección 10.5 (ejemplo resuelto s/(s+10))
% QUÉ HACE   Dibuja los tres factores de G'(s) = (1/10)*s*1/(s/10+1), su suma
%            asintótica y la curva real de bode.
% ESPERADO   En la esquina w = 10: -3.01 dB y +45°.  En w = 1: -20.04 dB, 84.3°.
% EXPLORE    Cambie el polo a -100 (y la ganancia de Bode a 1/100): ¿dónde
%            queda ahora la meseta de 0 dB?
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

% [ini:factores]
G = tf([1 0], [1 10]);                         % G'(s) = s/(s+10)
w = logspace(-1, 3, 600);
[m1, f1] = bodeAsintotico(w, 0.1, 0);          % factor 1: ganancia 1/10
[m2, f2] = bodeAsintotico(w, 1, -1);           % factor 2: cero en el origen (N = -1)
[m3, f3] = bodeAsintotico(w, 1, 0, [10 -1]);   % factor 3: polo en -10
[mA, fA] = bodeAsintotico(w, 0.1, -1, [10 -1]);% la suma: todo junto
[mR, fR] = bode(G, w);  mR = 20*log10(squeeze(mR));  fR = squeeze(fR);
% [fin:factores]

fig = estiloFigura(1100, 650);
subplot(2,1,1); semilogx(w, m1, w, m2, w, m3, 'LineWidth', 1.2); hold on
semilogx(w, mA, 'k', 'LineWidth', 3); semilogx(w, mR, '--', 'Color', [.16 .62 .56]); grid on
ylabel('dB'); legend('$1/10$', '$s$', '$1/(s/10+1)$', 'suma asint\''otica', 'real', 'Location', 'southeast');
title('$G''(s)=\frac{s}{s+10}$: suma de factores');
subplot(2,1,2); semilogx(w, f1, w, f2, w, f3, 'LineWidth', 1.2); hold on
semilogx(w, fA, 'k', 'LineWidth', 3); semilogx(w, fR, '--', 'Color', [.16 .62 .56]); grid on
ylabel('fase ($^\circ$)'); xlabel('$\omega$ (rad/s)'); yticks(-90:45:90);
exportgraphics(fig, 'C1_Ej2_asintotico.png', 'Resolution', 200);

%% Comprobación en tres frecuencias
for wi = [1 10 20]
    [mi, fi] = bode(G, wi);
    fprintf('w = %4g: %7.2f dB, %6.1f grados\n', wi, 20*log10(mi), fi);
end
