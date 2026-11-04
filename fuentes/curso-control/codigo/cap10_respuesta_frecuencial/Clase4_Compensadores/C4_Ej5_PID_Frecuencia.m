%% C4_Ej5_PID_Frecuencia -- Notas: sección 10.12 (PID desde la frecuencia)
% Planta de la sección 10.7: Gp = 1/((s+1)(s+10)(s+100))
% ESPERADO  ZN: Kcr = 122 210, Pcr = 0.189 s; punto ZN en w_cr: -0.6 - 0.28j; PM ~ 20°
%           Moldeo del lazo (wc = 20, PM = 50°): Td = 0.0465, Kc = 33 427, GM = 24.4 dB
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
Gp = zpk([], [-1 -10 -100], 1);
s  = tf('s');

%% Ziegler-Nichols (oscilación sostenida) leído en el Bode
% [ini:zn]
[Gm, ~, wcr] = margin(Gp);  Kcr = Gm               % 122 210 en w_cr = 33.3 rad/s
Pcr = 2*pi/wcr                                      % 0.189 s
Kc = 0.6*Kcr;  Ti = Pcr/2;  Td = Pcr/8;             % tabla de ZN (PID)
Czn = Kc*(1 + 1/(Ti*s) + Td*s);                     % PID ideal (forma estándar)
punto = evalfr(Czn*Gp, 1j*wcr)                      % -0.6 - 0.28j: ZN "mueve" el punto -1
margenesTabla(Czn*Gp, 'Ziegler-Nichols');           % PM ~ 20°: agresivo
% [fin:zn]

%% Moldeo del lazo: cruce en wc = 20 rad/s con PM = 50°, PID serie con filtro N = 10
% [ini:moldeo]
wc = 20;  PMdes = 50;  N = 10;
Ti2 = 10/wc;                                        % cero del PI una década abajo de wc
PI  = 1 + 1/(Ti2*s);
falta = -180 + PMdes - (faseEn(Gp, wc) + faseEn(PI, wc))     % 37.6° que debe dar el PD
Td2 = fzero(@(Td) atand(wc*Td) - atand(wc*Td/N) - falta, [1e-4 5/wc])   % 0.0465
C0  = PI*(1 + Td2*s)/(1 + Td2*s/N);
Kc2 = 1/abs(evalfr(C0*Gp, 1j*wc))                   % 33 427: |L(j wc)| = 1
Cls = Kc2*C0;
margenesTabla(Cls*Gp, 'moldeo del lazo');           % PM = 50°, GM = 24.4 dB
% [fin:moldeo]

%% Comparación
fig = estiloFigura(1200, 520);
subplot(1,2,1); bode(Czn*Gp, Cls*Gp); grid on; legend('ZN', 'moldeo');
subplot(1,2,2); step(feedback(Czn*Gp, 1), feedback(Cls*Gp, 1), 1.2); grid on; legend('ZN', 'moldeo');
stepinfo(feedback(Czn*Gp, 1)), stepinfo(feedback(Cls*Gp, 1))
exportgraphics(fig, 'C4_PID_ZN_vs_moldeo.png', 'Resolution', 200);

%% Lo mismo con pidtune (moldeo automático)
op  = pidtuneOptions('PhaseMargin', 50);
Cpt = pidtune(Gp, 'PIDF', wc, op)
margenesTabla(Cpt*Gp, 'pidtune');

%% Relé (Åström-Hägglund): estimar Kcr sin llevar la planta al borde
d = 1;                                              % amplitud del relé
a = 4*d/(pi*Kcr);                                   % amplitud esperada de la oscilación
fprintf('Relé de amplitud %g: la salida oscila con amplitud %.2e y periodo %.3f s\n', d, a, Pcr);
