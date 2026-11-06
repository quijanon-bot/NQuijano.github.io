%% C6_Ej5_Atraso -- Notas: sección 6.7 (especificaciones en conflicto)
% QUÉ HACE   Para G = 1/(s(s+4)(s+8)): ningún K cumple a la vez ess <= 0.05 ante
%            rampa y %OS <= 20 %. Un atraso K(s+a)/(s+b) multiplica kv por a/b.
% OBSERVE    El par polo-cero cerca del origen casi no mueve los polos dominantes,
%            pero agrega una cola lenta.
% ESPERADO   ess <= 0.05 pide K >= 640 (inestable: K < 384); %OS = 17 % pide K = 67.8.
%            (simulado: 16.2 %). Atraso a = 0.0519, b = 0.005: ess = 0.0455, %OS = 19 %, ts = 4.8 s
%            (3.1 s sin atraso).
% EXPLORE    Use b = 0.0005: ¿mejora o empeora la cola?
clear; close all; clc;
if ~exist('constantesError', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
s = tf('s');  G = 1/(s*(s+4)*(s+8));

% [ini:conflicto]
Kerr = 32/0.05                                  % kv = K/32 >= 20
Kmax = 12*32                                    % Routh: s^3 + 12s^2 + 32s + K
zeta = -log(0.17)/sqrt(pi^2 + log(0.17)^2);     % sobrepico de diseño 17 %
K = fzero(@(K) polosDominantes(K) - zeta, [20 380])
% [fin:conflicto]

% [ini:atraso]
b = 0.005;  a = 1.1*(Kerr/K)*b                  % a/b con 10 % de margen
Gc = K*(s + a)/(s + b);
T0 = feedback(K*G, 1);  T1 = feedback(Gc*G, 1);
pole(T1)
S0 = stepinfo(T0), S1 = stepinfo(T1)
t = 0:0.05:400;  e = t' - lsim(T1, t, t);  e(end)   % 0.0455
% [fin:atraso]

function z = polosDominantes(K)
p = roots([1 12 32 K]);  p = p(imag(p) > 0);
z = -real(p)/abs(p);
end
