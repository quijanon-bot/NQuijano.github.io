%% C2_Ej1_Identificacion -- Notas: sección 10.6 (leer un Bode al revés)
% Pendientes del asintótico de magnitud, de izquierda a derecha:
%   -20 dB/dec       -> un polo en el origen
%   0 desde w = 1    -> un cero en -1   (-20 + 20 = 0)
%   -40 desde w = 10 -> un polo DOBLE en -10  (0 - 40 = -40)
%   meseta en 36 dB  -> Kb = 10^(36/20) = 63.1
% ESPERADO  G'(s) = 63.1 (s+1)/(s (s/10+1)^2);  PM = 13.7° en 78.8 rad/s
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

% [ini:identificacion]
Kb = 10^(36/20)                                  % 63.0957
s  = tf('s');
G  = Kb*(s+1)/(s*(s/10+1)^2);                    % forma de Bode
zpk(G)                                           % = 6309.6 (s+1)/(s (s+10)^2)
% [fin:identificacion]
w = logspace(-1, 3, 600);
[mA, fA] = bodeAsintotico(w, Kb, 1, [1 1; 10 -2]);
[m, f]   = bode(G, w);
fig = estiloFigura(1000, 650);
subplot(2,1,1); semilogx(w, mA, 'k', w, 20*log10(squeeze(m)), '--'); grid on; ylabel('dB');
legend('asint\''otico', 'real'); title('$G''(s)=63.1\,(s+1)/[s(s/10+1)^2]$');
subplot(2,1,2); semilogx(w, fA, 'k', w, squeeze(f), '--'); grid on; ylabel('fase ($^\circ$)'); xlabel('$\omega$ (rad/s)');
exportgraphics(fig, 'C2_Ej1_identificacion.png', 'Resolution', 200);
margenesTabla(G, 'identificada');

%% Fase mínima vs. fase no mínima: misma magnitud, distinta fase
% [ini:nominima]
G1 = (1+s)/(1+2*s);                              % cero en -1  (fase mínima)
G2 = (1-s)/(1+2*s);                              % cero en +1  (fase NO mínima)
figure('Color', 'w'); bode(G1, G2); grid on
legend('fase m\''inima', 'fase no m\''inima', 'Interpreter', 'latex');
% [fin:nominima]
