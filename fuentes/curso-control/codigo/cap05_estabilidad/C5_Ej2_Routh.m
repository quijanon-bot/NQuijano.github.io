%% C5_Ej2_Routh -- Notas: sección 5.3 (criterio de Routh-Hurwitz)
% QUÉ HACE   Arma la tabla de Routh de varios polinomios con tablaRouth (carpeta
%            comun/) y compara el número de cambios de signo con roots.
% OBSERVE    Coeficientes todos positivos NO garantizan estabilidad si n >= 3.
% ESPERADO   s^4+2s^3+3s^2+4s+5: dos cambios de signo, raíces 0.288 +- j1.416;
%            s^3+s^2+2s+8: dos cambios (0.5 +- j1.936);  s^3+2s^2+3s+4: estable.
% EXPLORE    Para a0 s^3 + a1 s^2 + a2 s + a3, compruebe con varios números que
%            la condición es a1 a2 > a0 a3.
clear; clc;
if ~exist('tablaRouth', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:routh]
p = [1 2 3 4 5];             % s^4 + 2s^3 + 3s^2 + 4s + 5
tablaRouth(p)                % imprime la tabla y cuenta los cambios de signo
roots(p)                     % dos raíces con parte real positiva

q = [1 1 2 8];               % todos los coeficientes positivos...
[~, cambios] = tablaRouth(q) % ... y aun así dos raíces inestables
roots(q)
% [fin:routh]

% [ini:tercerorden]
a = [1 2 3 4];               % a1*a2 = 6 > a0*a3 = 4: estable
tablaRouth(a)
a(2)*a(3) > a(1)*a(4)
% [fin:tercerorden]
