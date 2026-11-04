%% C9_Ej5_Especificaciones -- Notas: sección 9.5 (diseño con %OS y tp)
% QUÉ HACE   Diseña K para 10/((s+10)(s^2+0.5s+1)) con %OS = 10 % y tp = 1 s,
%            con el tercer polo diez veces más a la izquierda; compara la forma
%            de tf2ss con la de variables de fase.
% OBSERVE    Las ganancias dependen de la representación; los polos no.
%            El valor final queda lejos de 1: falta la acción integral (9.8).
% ESPERADO   K (tf2ss) = [17.131 115.21 339.34]; K (variables de fase) al revés;
%            %OS = 9.8 %, tp = 1.05 s, valor final 0.029
% EXPLORE    Ponga el tercer polo 5 y 50 veces más lejos: compare max|u|.
clear; close all; clc;
if ~exist('polosDeseados', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:tercerorden]
num = 10;   den = conv([1 10], [1 0.5 1]);
p = polosDeseados(0.10, 'tp', 1, 'extra', 10)   % dominantes + polo 10x
[A, B, C, D] = tf2ss(num, den);                  % forma de MATLAB
K  = place(A, B, p)                              % [17.131 115.21 339.34]
[Af, Bf, Cf] = variablesFase(num, den);          % forma del curso
Kf = place(Af, Bf, p)                            % mismas cifras, otro orden
T  = ss(A - B*K, B, C, D);                       % u = r - Kx
stepinfo(T)                                      % %OS ~ 9.8, tp ~ 1.05
dcgain(T)                                        % 0.029: ¡no sigue la referencia!
% [fin:tercerorden]
fig = estiloFigura(900, 420);
step(tf(num, den), T, 12); grid on; legend('original', '$u=r-\mathbb{K}x$');
