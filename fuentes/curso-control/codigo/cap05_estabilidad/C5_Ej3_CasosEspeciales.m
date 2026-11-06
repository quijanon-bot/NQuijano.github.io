%% C5_Ej3_CasosEspeciales -- Notas: sección 5.4 (casos especiales)
% QUÉ HACE   Construye la tabla en los dos casos especiales: un cero solo en la
%            primera columna (epsilon) y una fila completa de ceros (polinomio
%            auxiliar). Factoriza el auxiliar para ver las raíces simétricas.
% OBSERVE    La fila de ceros aparece justo debajo del polinomio auxiliar, y sus
%            raíces son raíces del polinomio original.
% ESPERADO   s^5+2s^4+4s^3+8s^2+10s+6: 2 cambios (inestable);
%            s^5+7s^4+6s^3+42s^2+8s+56: auxiliar 7(s^2+2)(s^2+4), sin cambios:
%            marginalmente estable (raíces +-j1.414, +-j2 y -7).
% EXPLORE    Repita con s^4+4 (sin término s^3, s^2, s): ¿por qué ya sabía
%            antes de la tabla que era inestable?
clear; clc;
if ~exist('tablaRouth', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:caso1]
p1 = [1 2 4 8 10 6];
tablaRouth(p1)               % el 0 de la fila s^3 se reemplaza por epsilon
roots(p1)
% [fin:caso1]

% [ini:caso2]
p2 = [1 7 6 42 8 56];
tablaRouth(p2)               % la fila s^3 se anula: derivada del auxiliar
aux = [7 0 42 0 56];         % fila s^4: 7s^4 + 42s^2 + 56
roots(aux)                   % +-j1.414 y +-j2: también son raíces de p2
roots(p2)
% [fin:caso2]
