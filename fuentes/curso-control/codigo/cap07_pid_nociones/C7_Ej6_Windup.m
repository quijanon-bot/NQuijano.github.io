%% C7_Ej6_Windup -- Notas: sección 7.6 (wind-up y anti-windup)
% QUÉ HACE   PID ideal (Kc=3, Ti=8, Td=2, N=10) sobre e^{-4s}/(10s+1) con el
%            actuador saturado en [0, 1.5]: sin corrección, con back-calculation
%            (Tt = sqrt(Ti Td) = 4 y Tt = Ti = 8) y con integración condicional.
% OBSERVE    Sin anti-windup el término integral sigue creciendo mientras el
%            actuador está en el límite, y el actuador tarda en "despegarse".
% ESPERADO   Sin corrección: OS 38 %, ts 45 s, saturado 25 s.  Back-calculation
%            Tt=4: OS 3 %, ts 30 s.  Integración condicional: OS 4 %, ts 29 s.
% EXPLORE    Barra Tt entre 0.5 y 20 s y grafique OS, ts e IAE.
clear; close all; clc;
if ~exist('simularPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:windup]
s = tf('s');  G = 1/(10*s + 1);  L = 4;
op = {'tf', 100, 'dt', 0.005, 'L', L, 'N', 10, 'umin', 0, 'umax', 1.5};
[t, y1, u1, ~, I1] = simularPID(G, 3, 8, 2, op{:});                          % sin corrección
[~, y2, u2, ~, I2] = simularPID(G, 3, 8, 2, op{:}, 'aw', 'back', 'Tt', 4);   % back-calculation
[~, y3, u3, ~, I3] = simularPID(G, 3, 8, 2, op{:}, 'aw', 'clamp');           % condicional
subplot(1,2,1); plot(t, y1, t, y2, t, y3); grid on; title('y');
legend('sin anti-windup', 'back-calculation', 'condicional');
subplot(1,2,2); plot(t, u1, t, u2, t, u3); hold on; plot(t, I1, ':', t, I2, ':', t, I3, ':');
grid on; title('u y término integral');
OS = 100*([max(y1) max(y2) max(y3)] - 1)     % sobrepico (%) de los tres
% [fin:windup]
