%% C4_Ej2_Atraso -- Notas: sección 10.11 (compensador en atraso, misma planta y especificaciones)
% ESPERADO  wdes = 1.68, alpha = 9.13, wH = 0.168, wL = 0.0184, PM = 44.8°
% NOTA      Sin los 5° de holgura (wdes = 2, como en el handout anterior) el PM queda en ~40°.
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
% [ini:atraso]
Gp = zpk([], [0 -2], 40);
[Gc, info] = disenoAtraso(Gp, 45, 5)
margenesTabla(Gc*Gp, 'atraso con +5°');
% [fin:atraso]
Gc_sinHolgura = zpk(-0.2, -0.02825, 0.14125);
margenesTabla(Gc_sinHolgura*Gp, 'sin holgura (w = 2)');
stepinfo(feedback(Gc*Gp, 1))
