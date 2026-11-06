%% C8_Ej3_MallaCerrada -- Notas: sección 8.4 (Ziegler-Nichols de malla cerrada y Tyreus-Luyben)
% QUÉ HACE   Para Gp = 1/((3s+1)(2s+1)(s+1)) obtiene Kcr y Pcr por sustitución s = jw,
%            lo comprueba con Routh (tablaRouth) y compara un PID ideal sintonizado
%            por ZN y por Tyreus-Luyben.
% OBSERVE    ZN da una relación de decaimiento cercana a 1/4... pero por debajo; TL
%            casi no oscila: es más conservador, no es de "un cuarto".
% ESPERADO   Kcr = 10, wcr = 1 rad/s, Pcr = 6.28 s.  ZN 6/3.14/0.785: OS 47 %,
%            decaimiento 0.17.  TL 4.55/13.8/1.0: OS 9 %.
% EXPLORE    Multiplique la planta por 1.5 y compare cuánto empeora cada sintonía.
clear; close all; clc;
if ~exist('reglasPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:critico]
den = conv(conv([3 1], [2 1]), [1 1]);           % 6s^3 + 11s^2 + 6s + 1
% s = jw:  imaginaria  -6w^3 + 6w = 0  ->  w = 1;   real  -11w^2 + 1 + Kc = 0
wcr = sqrt(den(3)/den(1));  Kcr = den(2)*wcr^2 - den(4);  Pcr = 2*pi/wcr
tablaRouth([den(1:3) den(4) + 9.9])              % sin cambios de signo: estable
tablaRouth([den(1:3) den(4) + Kcr])              % fila s^1 nula: raíces en +-j wcr
% [fin:critico]

% [ini:zntl]
s = tf('s');  Gp = tf(1, den);
[K1, T1, D1] = reglasPID('ZNcr', 'PID', Kcr, Pcr);
[K2, T2, D2] = reglasPID('TL', 'PID', Kcr, Pcr);
[t, y1] = simularPID(Gp, K1, T1, D1, 'tf', 60, 'dt', 0.002, 'N', 10);
[~, y2] = simularPID(Gp, K2, T2, D2, 'tf', 60, 'dt', 0.002, 'N', 10);
plot(t, y1, t, y2); grid on; legend('Ziegler-Nichols', 'Tyreus-Luyben');
OS = 100*([max(y1) max(y2)] - 1)
e = y1 - 1;  pk = find(e(2:end-1) > e(1:end-2) & e(2:end-1) >= e(3:end) & e(2:end-1) > 0);
decaimiento = e(pk(2)+1)/e(pk(1)+1)              % segundo pico / primer pico (ZN)
% [fin:zntl]
