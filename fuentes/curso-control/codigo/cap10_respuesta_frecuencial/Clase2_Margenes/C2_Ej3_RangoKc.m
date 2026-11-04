%% C2_Ej3_RangoKc -- Notas: sección 10.7 (¿cuánta ganancia aguanta? Routh-Hurwitz contra Bode)
% Gp(s) = 1/((s+1)(s+10)(s+100)), Gc = Kc.
% Polinomio característico: s^3 + 111 s^2 + 1110 s + (1000 + Kc)
% ESPERADO  Kcr = 122 210, w_cr = 33.32 rad/s, P_cr = 0.189 s
%           Bode asintótico con Kc = 1000: GM ~ 40 dB -> Kcr ~ 100 000 (conservador)
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

%% Routh-Hurwitz (sin Symbolic Toolbox)
% [ini:routh]
a2 = 111;  a1 = 1110;                      % s^3 + a2 s^2 + a1 s + (1000 + Kc)
% Fila s^1: (a2*a1 - (1000+Kc))/a2 > 0   y   fila s^0: 1000 + Kc > 0
Kcr = a2*a1 - 1000                         % 122 210  ->  -1000 < Kc < 122 210
wcr = sqrt(a1)                             % 33.32 rad/s (polinomio auxiliar a2 s^2 + 1000 + Kcr)
Pcr = 2*pi/wcr                             % 0.189 s  (periodo crítico, Ziegler-Nichols)
% [fin:routh]

%% Bode: con Kc = 1000 la ganancia DC es 0 dB
% [ini:bodekc]
G1000 = zpk([], [-1 -10 -100], 1000);
[Gm, ~, Wcg] = margin(G1000);
fprintf('GM = %.2f dB = x%.2f  ->  Kcr = 1000*GM = %.0f  (w_GM = %.2f)\n', ...
        20*log10(Gm), Gm, 1000*Gm, Wcg);
% [fin:bodekc]

%% Verificación: con Kc = Kcr el lazo cerrado oscila a w_cr
T = feedback(Kcr*zpk([], [-1 -10 -100], 1), 1);
figure('Color', 'w'); step(T, 2); grid on; title('K_c = K_{cr}: oscilación sostenida');
damp(T)

%% (Opcional) el mismo Routh con Symbolic Math Toolbox
if license('test', 'Symbolic_Toolbox')
    syms Kc s
    p = expand((s+1)*(s+10)*(s+100)) + Kc  %#ok<NOPTS>
end
