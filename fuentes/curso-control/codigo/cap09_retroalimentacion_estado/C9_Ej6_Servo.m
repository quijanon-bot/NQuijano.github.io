%% C9_Ej6_Servo -- Notas: sección 9.5 (servo: la referencia entra por K1)
% QUÉ HACE   Para 1/(s(s+1)(s+2)) con u = K1(r - x1) - K2 x2 - K3 x3, ubica los
%            polos en -2 ± j3.464 y -10 y verifica que el valor final es 1.
% OBSERVE    Como la planta tiene un integrador y la referencia se compara con
%            x1 = y, el lazo es tipo 1: error nulo ante el escalón.
% ESPERADO   K = [160 54 11]; valor final 1; %OS ≈ 14.8 %
% EXPLORE    ¿Qué pasa si la referencia entra sumada a u (u = r - Kx)?
clear; clc;
if ~exist('polosDeseados', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:servo]
[A, B, C] = variablesFase(1, conv([1 0], conv([1 1], [1 2])));
rank(ctrb(A, B))                                 % 3: controlable
K = acker(A, B, [-2+3.464j, -2-3.464j, -10])     % [160 54 11]
T = ss(A - B*K, B*K(1), C, 0);                   % r entra multiplicada por K1
dcgain(T)                                        % 1
stepinfo(T)
% [fin:servo]
