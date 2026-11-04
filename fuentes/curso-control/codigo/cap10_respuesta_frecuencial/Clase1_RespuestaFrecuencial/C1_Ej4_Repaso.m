%% C1_Ej4_Repaso -- Notas: sección 10.13, soluciones de R1 y R2
% ESPERADO   R1: kv = 2; +-2.97 dB en las esquinas; fase -50.7°
%            R2: z_ss = 1.897 sin(5t - 71.57°); |G| = 0.1 en w = 20.95 rad/s
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

%% R1: G'(s) = 20(s+2)/(s(s+20)) = 2(s/2+1)/(s(s/20+1))
G1 = tf(20*[1 2], [1 20 0]);
w  = logspace(-2, 3, 800);
[mA, fA] = bodeAsintotico(w, 2, 1, [2 1; 20 -1]);
[m, f]   = bode(G1, w);
fig = estiloFigura(1000, 650);
subplot(2,1,1); semilogx(w, mA, 'k', w, 20*log10(squeeze(m)), '--'); grid on; ylabel('dB'); legend('asint\''otico', 'real');
subplot(2,1,2); semilogx(w, fA, 'k', w, squeeze(f), '--'); grid on; ylabel('fase'); xlabel('$\omega$ (rad/s)');
for wi = [2 20]
    g = evalfr(G1, 1j*wi);
    fprintf('w = %4.0f: |G| = %.3f (%.2f dB), fase = %.1f grados\n', wi, abs(g), 20*log10(abs(g)), rad2deg(angle(g)));
end
kv = dcgain(minreal(tf('s')*G1))                % 2

%% R2: G(s) = 50/((s+5)(s+10)), x(t) = 3 sin(5t)
G2 = tf(50, conv([1 5], [1 10]));
g  = evalfr(G2, 5j);  A = 3*abs(g), phi = rad2deg(angle(g))     % 1.897, -71.57
t  = linspace(0, 3, 3000);  x = 3*sin(5*t);  z = lsim(G2, x, t);
figure('Color', 'w'); plot(t, x, '--', t, z, t, A*sin(5*t + deg2rad(phi)), ':'); grid on
legend('$x(t)$', '$z(t)$ (lsim)', '$z_{ss}(t)$', 'Interpreter', 'latex'); xlabel('t (s)');
w10 = fzero(@(w) abs(evalfr(G2, 1j*w)) - 0.1, [5 50])          % 20.95 rad/s (asintótico: 22.4)
