%% C5_Ej6_EspacioEstado -- Notas: sección 5.7 (estabilidad en el espacio de estado)
% QUÉ HACE   (1) Valores propios de A y polinomio característico.
%            (2) Un modo inestable que NO aparece en la función de transferencia.
%            (3) Estabilidad local de los dos equilibrios del péndulo linealizado.
% OBSERVE    La estabilidad del equilibrio la decide eig(A), no pole(tf(...)).
% ESPERADO   A = [0 1 0;0 0 1;2 1 -2]: valores propios 1, -1, -2, pero con
%            C = [-1 0 1] la función de transferencia es 1/(s+2).
%            Péndulo (g/l = 9.81, b = 0.5): abajo -0.25 +- j3.12 (estable),
%            arriba 2.89 y -3.39 (inestable).
% EXPLORE    Simule el sistema (2) desde x0 = [1 1 1]' sin entrada: ¿qué le
%            pasa a la salida? ¿y a los estados?
clear; clc;
if ~exist('tablaRouth', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:eig]
A = [0 1 0; 0 0 1; -6 -11 -6];
eig(A)                       % -1, -2, -3: A es Hurwitz
poly(A)                      % s^3 + 6s^2 + 11s + 6
tablaRouth(poly(A))          % lo mismo, sin calcular las raíces
% [fin:eig]

% [ini:escondido]
Au = [0 1 0; 0 0 1; 2 1 -2];  B = [0; 0; 1];  C = [-1 0 1];
eig(Au)                      % 1, -1, -2: el equilibrio es INESTABLE
G = minreal(tf(ss(Au, B, C, 0)))   % 1/(s+2): ¡parece estable!
% [fin:escondido]

% [ini:pendulo]
gl = 9.81;  b = 0.5;         % theta'' = -(g/l) sin(theta) - b theta'
for th = [0 pi]
    J = [0 1; -gl*cos(th) -b];          % jacobiano evaluado en el equilibrio
    fprintf('theta* = %4.2f  ->  valores propios:', th);  disp(eig(J).');
end
% [fin:pendulo]
