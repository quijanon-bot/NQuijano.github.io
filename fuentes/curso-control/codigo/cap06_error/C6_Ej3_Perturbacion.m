%% C6_Ej3_Perturbacion -- Notas: sección 6.5 (error por perturbaciones)
% QUÉ HACE   Perturbación escalón de 0.5 sobre Gp = 1/((s+1)(s+2)), con referencia
%            nula: controlador P (K = 1, 10, 100) y PI; perturbación a la entrada y
%            a la salida del proceso.
% OBSERVE    Subir K reduce el error pero no lo anula; el integrador del controlador sí.
% ESPERADO   Entrada: e = -0.5/(2 + K): -0.167, -0.042, -0.0049. Salida: el doble.
%            PI con K = 10: estable para 0 < Ki < 36, error nulo.
% EXPLORE    Ponga el integrador en la planta en lugar del controlador: ¿se anula?
clear; close all; clc;
if ~exist('constantesError', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
s = tf('s');  Gp = 1/((s+1)*(s+2));

% [ini:proporcional]
for K = [1 10 100]
    Ted = -feedback(Gp, K);                     % E/D con D a la entrada (R = 0)
    Tes = -feedback(1, K*Gp);                   % E/D con D a la salida
    fprintf('K = %3d: entrada %8.4f   salida %8.4f\n', K, 0.5*dcgain(Ted), 0.5*dcgain(Tes));
end
% [fin:proporcional]

% [ini:pi]
K = 10;  Ki = 18;                               % 0 < Ki < 36 (Routh de s^3+3s^2+12s+Ki)
Gc = K + Ki/s;
Ted = -feedback(Gp, Gc);
0.5*dcgain(Ted)                                 % 0: el integrador en Gc anula el error
step(0.5*Ted, 15); grid on;
% [fin:pi]
