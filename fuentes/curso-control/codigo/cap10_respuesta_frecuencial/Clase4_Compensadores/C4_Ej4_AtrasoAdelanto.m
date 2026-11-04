%% C4_Ej4_AtrasoAdelanto -- Notas: sección 10.11 (compensador atraso-adelanto)
% Gp = K/(s(s+1)(s+2)), kv = 10 -> K = 20: el lazo cerrado es INESTABLE (PM = -28.1°)
% Meta: PM >= 50°, GM >= 10 dB, sin perder kv = 10.
% ESPERADO  PM = 58.2°, GM = 13.2 dB, kv = 10
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
% [ini:atrasoadelanto]
Gp = zpk([], [0 -1 -2], 20);  margenesTabla(Gp, 'sin compensar');
wc = 1.2;                                          % nuevo cruce elegido (fase de Gp = -171.2°)
fase_wc = faseEn(Gp, wc)
% 1) Adelanto centrado en wc con alpha = 10 (aporta 54.9°)
alpha = 10;  phiM = asind((alpha-1)/(alpha+1))
wL = wc/sqrt(alpha);  wH = wc*sqrt(alpha);         % 0.38 y 3.79
Clead = zpk(-wL, -wH, alpha);
% 2) Atraso que baja la magnitud en wc lo que sobra para que wc sea el cruce
MdB  = 20*log10(abs(evalfr(Clead*Gp, 1j*wc)))      % 23.2 dB que debe quitar el atraso
beta = 10^(MdB/20);  zl = wc/10;  pl = zl/beta;    % 14.5, 0.12, 0.0083
Clag = zpk(-zl, -pl, 1/beta);
Gc = minreal(Clead*Clag)
margenesTabla(Gc*Gp, 'atraso-adelanto');           % PM = 58.2°, GM = 13.2 dB
kv = dcgain(minreal(tf('s')*Gc*Gp))                % 10: el error no cambió
% [fin:atrasoadelanto]
stepinfo(feedback(Gc*Gp, 1))
figure('Color', 'w'); subplot(1,2,1); margin(Gc*Gp); grid on;
subplot(1,2,2); step(feedback(Gc*Gp, 1), 30); grid on;
