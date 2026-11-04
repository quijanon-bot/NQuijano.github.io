%% C1_Ej3_SegundoOrden -- Notas: sección 10.4, factor 4 y profundización (*)
% QUÉ HACE   (1) tabla de corrección del factor de segundo orden; (2) lee wn y
%            zeta de un Bode "medido"; (3) el ejemplo en que la asíntota dice
%            "estable" y la realidad es inestable; (4) un filtro notch de 60 Hz.
% ESPERADO   (1) |G(jwn)| = 1/(2 zeta); (2) wn = 10, zeta = 0.20;
%            (3) PM = -45.5°, GM = -7.5 dB (INESTABLE); Routh: 5*104 < 1100
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

%% 1) Tres hechos exactos en w = wn
wn = 1;  zetas = [0.05 0.1 0.2 0.3 0.5 0.707 1];
fprintf(' zeta   |G(jwn)| (dB)   Mr (dB)   wr/wn   %%OS\n');
for z = zetas
    G   = tf(wn^2, [1 2*z*wn wn^2]);
    Mwn = 20*log10(abs(evalfr(G, 1j*wn)));
    if z < 1/sqrt(2)
        Mr = 20*log10(1/(2*z*sqrt(1-z^2)));  wr = sqrt(1-2*z^2);
    else
        Mr = 0; wr = NaN;                     % no hay pico
    end
    OS = 100*exp(-z*pi/sqrt(1-min(z,0.9999)^2));
    fprintf(' %5.3f   %+8.2f      %+6.2f    %5.3f   %5.1f\n', z, Mwn, Mr, wr, OS);
end
z = 0.2; d = 1e-4; G = tf(1, [1 2*z 1]);
pendiente = (faseEn(G, 1+d) - faseEn(G, 1-d))/(log10(1+d) - log10(1-d))   % ~ -132/zeta = -660 °/dec

%% 2) Leer wn y zeta en un Bode "medido"
% [ini:leerzeta]
Gm = tf(100, [1 4 100]);                       % "la planta desconocida"
w  = logspace(0, 2, 5000);
[m, f] = bode(Gm, w);  m = 20*log10(squeeze(m));  f = squeeze(f);
wn_est   = interp1(f, w, -90)                  % la fase cruza -90° en wn -> 10
[MrdB, i] = max(m);  wr = w(i)                 % 8.14 dB en 9.59 rad/s
Mr       = 10^(MrdB/20);
zeta_est = fzero(@(z) 1/(2*z*sqrt(1-z^2)) - Mr, [0.01 0.7])   % 0.20
% [fin:leerzeta]

%% 3) La asíntota dice "estable por poco"; la curva real dice inestable
% [ini:sorpresa]
G2 = tf(1000, conv([1 1], [1 4 100]));         % = 10/((s+1)(s^2/100 + 0.04 s + 1))
margenesTabla(G2, 'real');                     % PM = -45.5°, GM = -7.5 dB
T2 = feedback(G2, 1);  pole(T2)                % dos polos con parte real > 0
% [fin:sorpresa]
wa = logspace(-1, 3, 800);
[ma, ~]  = bodeAsintotico(wa, 10, 0, [1 -1; 10 -2]);
[mr, fr] = bode(G2, wa);
fig = estiloFigura(1000, 650);
subplot(2,1,1); semilogx(wa, ma, 'k', wa, 20*log10(squeeze(mr)), '--'); grid on; ylabel('dB'); yline(0, 'k');
legend('as\''intotas', 'real'); title('$1000/((s+1)(s^2+4s+100))$: +7.96 dB en $\omega_n=10$');
subplot(2,1,2); semilogx(wa, squeeze(fr), '--'); grid on; yline(-180, 'k'); ylabel('fase'); xlabel('$\omega$ (rad/s)');
exportgraphics(fig, 'C1_Ej3_sorpresa.png', 'Resolution', 200);

%% 4) Filtro notch de 60 Hz (ceros complejos sobre el eje imaginario)
w0 = 2*pi*60;  Q = 5;
N = tf([1 0 w0^2], [1 w0/Q w0^2]);
figure('Color', 'w'); bode(N, {10^1.5, 10^3.5}); grid on; title('Notch en 60 Hz (377 rad/s)');
