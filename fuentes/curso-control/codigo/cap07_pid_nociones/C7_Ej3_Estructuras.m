%% C7_Ej3_Estructuras -- Notas: sección 7.4 (formas ideal, paralelo y serie)
% QUÉ HACE   Convierte parámetros entre las tres formas con convertirPID y lo
%            comprueba comparando las funciones de transferencia.
% OBSERVE    La forma serie siempre tiene equivalente ideal; la ideal solo tiene
%            equivalente serie si Ti >= 4 Td (ceros reales).
% ESPERADO   Serie (2, 8, 2) -> ideal (2.5, 10, 1.6).  Ideal (5, 4, 2): ceros
%            -0.25 +- 0.25j, sin forma serie.  Paralelo (350, 300, 50) -> ideal
%            (350, 1.167, 0.143) -> serie (300, 1, 0.167).
% EXPLORE    ¿Qué pasa con la conversión cuando Ti = 4 Td exactamente?
clear; clc;
if ~exist('simularPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:conversion]
s = tf('s');
[K, Ti, Td] = convertirPID(2, 8, 2, 'serie', 'ideal')
Cs = 2*(1 + 1/(8*s))*(1 + 2*s);
Ci = K*(1 + 1/(Ti*s) + Td*s);
norm(minreal(Cs - Ci))                    % ~0: son el mismo controlador
[K, Ti, Td] = convertirPID(K, Ti, Td, 'ideal', 'serie')   % de vuelta: 2, 8, 2
% [fin:conversion]

% [ini:complejos]
roots([5*4*2, 5*4, 5])                    % ceros de 5(1 + 1/(4s) + 2s): complejos
try
    convertirPID(5, 4, 2, 'ideal', 'serie');
catch err
    disp(err.message)
end
% [fin:complejos]

% [ini:paralelo]
[Kc, Ti, Td] = convertirPID(350, 300, 50, 'paralelo', 'ideal')
[Ks, Tis, Tds] = convertirPID(Kc, Ti, Td, 'ideal', 'serie')
% [fin:paralelo]
