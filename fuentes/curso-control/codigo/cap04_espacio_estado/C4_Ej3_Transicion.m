%% C4_Ej3_Transicion -- Notas: sección 4.5 (solución de la ecuación de estado)
% QUÉ HACE   Calcula Phi(t) = e^{At} para A = [0 1; -2 -3] con la resolvente y con
%            expm, verifica sus propiedades y compara la solución forzada con lsim.
% OBSERVE    Phi(t1 + t2) = Phi(t1) Phi(t2): el estado "se transporta" por tramos.
% ESPERADO   Phi(t) = [2e^-t - e^-2t, e^-t - e^-2t; -2e^-t + 2e^-2t, -e^-t + 2e^-2t];
%            Phi(0.5) = [0.8452 0.2387; -0.4773 0.1292].  Con escalón y x(0) = 0,
%            x1(t) = 1/2 - e^-t + e^-2t/2.
% EXPLORE    Con x(0) = [1; -1] la respuesta tiene un solo modo. ¿Por qué?
clear; close all; clc;
if ~exist('variablesFase', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
A = [0 1; -2 -3];  B = [0; 1];

% [ini:simbolico]
syms s t
Phi_s = inv(s*eye(2) - A)                   % resolvente (sI - A)^-1
Phi_t = simplify(ilaplace(Phi_s, s, t))     % matriz de transición
% [fin:simbolico]

% [ini:numerico]
t1 = 0.5;  t2 = 1.2;
P1 = expm(A*t1)
norm(expm(A*(t1 + t2)) - expm(A*t1)*expm(A*t2))   % ~ 0
norm(inv(expm(A*t1)) - expm(-A*t1))                % ~ 0
% [fin:numerico]

% [ini:forzada]
tt = 0:0.01:6;
[~, ~, x] = lsim(ss(A, B, eye(2), 0), ones(size(tt)), tt);
x1 = 1/2 - exp(-tt) + exp(-2*tt)/2;         % de x(t) = int_0^t e^{A(t-tau)} B dtau
max(abs(x(:,1)' - x1))                      % ~ 0
xl = expm(A*2)*[1; -1]                      % respuesta libre: = e^-2 [1; -1]
% [fin:forzada]
