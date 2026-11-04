%% C9_Ej9_Integral -- Notas: sección 9.8 (acción integral)
% QUÉ HACE   Para A = [0 1; -3 -5], diseña u = r - Kx (%OS = 10 %, ts = 0.5 s)
%            y mide el error; luego agrega el estado z' = r - y y rediseña con
%            un tercer polo en -100.
% OBSERVE    Sin integrador el valor final es 1/183 (¡error de 99.5 %!); con
%            integrador el error se anula, a cambio de un pico de u mayor.
% ESPERADO   K = [180.1 11]; con integrador K = [1780.1 111], Ke = 18 314
% EXPLORE    Ponga el tercer polo en -40 y compare el pico de u.
clear; close all; clc;
if ~exist('polosDeseados', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:sinintegrador]
A = [0 1; -3 -5];   B = [0; 1];   C = [1 0];
p  = polosDeseados(0.10, 'ts', 0.5)            % -8 ± 10.91j
K  = acker(A, B, p)                            % [180.1 11]
T0 = ss(A - B*K, B, C, 0);
ess0 = 1 - dcgain(T0)                          % 0.9945
% [fin:sinintegrador]

% [ini:integrador]
Aa = [A, zeros(2,1); -C, 0];   Ba = [B; 0];    % estado aumentado [x; z]
Ka = acker(Aa, Ba, [p; -100]);                 % Ka = [K, -Ke]
K  = Ka(1:2),  Ke = -Ka(3)                     % [1780.1 111], 18 314
Ti = ss(Aa - Ba*Ka, [0; 0; 1], [C 0], 0);      % r entra por z
essI = 1 - dcgain(Ti)                          % 0
% [fin:integrador]
fig = estiloFigura(900, 420);
step(T0, Ti, 1.5); grid on; legend('sin integrador', 'con integrador');
