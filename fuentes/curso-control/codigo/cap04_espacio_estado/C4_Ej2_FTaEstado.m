%% C4_Ej2_FTaEstado -- Notas: sección 4.4 (de la función de transferencia al estado)
% QUÉ HACE   Pasa 24/(s^3+9s^2+26s+24) y (s^2+7s+2)/(s^3+9s^2+26s+24) a variables
%            de fase y compara con tf2ss, que numera los estados al revés.
% OBSERVE    Representaciones distintas, misma función de transferencia.
% ESPERADO   A = [0 1 0; 0 0 1; -24 -26 -9]; con numerador s^2+7s+2, C = [2 7 1].
% EXPLORE    Pruebe un numerador del mismo grado que el denominador: ¿qué pasa con D?
clear; close all; clc;
if ~exist('variablesFase', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:fase]
den = [1 9 26 24];
A = [0 1 0; 0 0 1; -fliplr(den(2:end))]     % última fila: -a0 -a1 -a2
B = [0; 0; 24];  C = [1 0 0];  D = 0;       % x1 = y, x2 = y', x3 = y''
tf(ss(A, B, C, D))
% [fin:fase]

% [ini:numerador]
num = [1 7 2];                              % Y = (s^2 + 7s + 2) Z,  Z = U/den
[Af, Bf, Cf, Df] = variablesFase(num, den)  % C = [2 7 1]: coeficientes del numerador
tf(ss(Af, Bf, Cf, Df))
% [fin:numerador]

% [ini:matlab]
[A1, B1, C1, D1] = tf2ss(num, den)          % primera fila -9 -26 -24
P = fliplr(eye(3));                         % invertir el orden de los estados
A2 = P*A1*P,  B2 = P*B1,  C2 = C1*P         % = variables de fase
tf(ss(A1, B1, C1, D1)) - tf(ss(A2, B2, C2, D1))   % diferencia nula
% [fin:matlab]
