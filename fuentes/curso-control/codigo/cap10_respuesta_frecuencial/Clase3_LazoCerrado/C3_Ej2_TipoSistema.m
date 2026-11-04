%% C3_Ej2_TipoSistema -- Notas: sección 10.9 (tipo y constantes estáticas desde el Bode)
% ESPERADO  kp = 0.01, kv = 1, ka = 100
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
% [ini:tipos]
s  = tf('s');
G0 = 0.01/(s/10+1);          % tipo 0: nivel de baja frecuencia -40 dB -> kp = 0.01
G1 = 1/(s*(s/10+1));         % tipo 1: la asíntota de -20 cruza 0 dB en w = kv = 1
G2 = 100/(s^2*(s/100+1));    % tipo 2: la asíntota de -40 cruza 0 dB en w = sqrt(ka) = 10
kp = dcgain(G0)
kv = dcgain(minreal(s*G1))
ka = dcgain(minreal(s^2*G2))
% [fin:tipos]
fig = estiloFigura(1200, 420);
subplot(1,3,1); bodemag(G0); grid on; title('Tipo 0');
subplot(1,3,2); bodemag(G1); grid on; title('Tipo 1');
subplot(1,3,3); bodemag(G2); grid on; title('Tipo 2');
