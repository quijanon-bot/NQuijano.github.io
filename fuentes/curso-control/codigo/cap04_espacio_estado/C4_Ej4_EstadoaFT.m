%% C4_Ej4_EstadoaFT -- Notas: sección 4.6 (del estado a la función de transferencia)
% QUÉ HACE   Calcula G(s) = C(sI-A)^-1 B + D, compara polos con valores propios y
%            muestra un caso en que la función de transferencia esconde modos.
% OBSERVE    Con Cb = [2 3 1] el numerador s^2+3s+2 cancela dos polos: G tiene un
%            polo, A tiene tres valores propios.
% ESPERADO   (i) 1/((s+2)(s+3)), ganancia DC 1/6. Ca: 1/((s+1)(s+2)(s+3)); Cb: 1/(s+3).
% EXPLORE    Cambie Cb a [2 3 1.01]: ¿qué pasa con la cancelación?
clear; close all; clc;
if ~exist('variablesFase', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:ss2tf]
A = [0 1; -6 -5];  B = [0; 1];  C = [1 0];  D = 0;
[num, den] = ss2tf(A, B, C, D)              % 1/(s^2 + 5s + 6)
eig(A), roots(den)                          % los mismos: -2 y -3
dcgain(ss(A, B, C, D))                      % 1/6
% [fin:ss2tf]

% [ini:cancelacion]
A = [0 1 0; 0 0 1; -6 -11 -6];  B = [0; 0; 1];
Ga = zpk(minreal(tf(ss(A, B, [1 0 0], 0))))
Gb = zpk(minreal(tf(ss(A, B, [2 3 1], 0)))) % solo queda el polo en -3
eig(A)
% [fin:cancelacion]

% [ini:similitud]
[T, L] = eig(A);                            % columnas de T: vectores propios
Ad = T\A*T                                  % diagonal
Bd = T\B;  Cd = [1 0 0]*T;
tf(ss(Ad, Bd, Cd, 0)) - Ga                  % la función de transferencia no cambia
norm(T*expm(L*1)/T - expm(A*1))             % Phi(t) = T diag(e^{lambda t}) T^-1
% [fin:similitud]
