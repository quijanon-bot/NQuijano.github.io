%% C3_Ej4_DisenoKKh -- Notas: sección 3.7 (diseño con especificaciones)
% QUÉ HACE   Calcula K y Kh del servo con tacómetro para %OS = 20 % y
%            tp = 1 s, arma el lazo con series/feedback y verifica.
% OBSERVE    Las especificaciones fijan zeta y wn; la ecuación característica
%            s^2 + (1 + K Kh) s + K se iguala término a término.
% ESPERADO   zeta = 0.4559, wn = 3.5299, K = 12.46, Kh = 0.178,
%            T(s) = 12.46/(s^2 + 3.219 s + 12.46)
% EXPLORE    Pida %OS = 10 % con el mismo tp. ¿Crece o decrece K?
clear; close all; clc;
if ~exist('zetaDeOS', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:diseno]
OS = 0.20;  tp = 1;                       % especificaciones
zeta = zetaDeOS(OS)                       % = -ln(OS)/sqrt(pi^2 + ln(OS)^2)
wn   = pi/(tp*sqrt(1 - zeta^2))
K    = wn^2                               % término independiente
Kh   = (2*zeta*wn - 1)/K                  % término en s: 1 + K Kh = 2 zeta wn
s = tf('s');
G = series(K/s, 1/(s + 1));               % camino directo
H = 1 + Kh*s;                             % sensor de posición + tacómetro
T = feedback(G, H)                        % lazo cerrado
S = stepinfo(T)                           % Overshoot ~ 20, PeakTime ~ 1
% [fin:diseno]
fig = estiloFigura(900, 420);
step(feedback(G, 1), '--', T, 4); grid on;
legend('sin tac\''ometro', 'con $K_h$', 'Location', 'southeast');
