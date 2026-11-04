%% C9_Ej1_Kalman -- Notas: sección 9.1 (lo que la función de transferencia esconde)
% QUÉ HACE   Toma el sistema de cuarto orden de Friedland, calcula su función
%            de transferencia, la simplifica y revisa los rangos de las
%            matrices de controlabilidad y observabilidad.
% OBSERVE    De cuatro modos, solo uno llega a la función de transferencia:
%            el que es a la vez controlable y observable.
% ESPERADO   H(s) = (s+2)(s+3)(s+4)/((s+1)(s+2)(s+3)(s+4)) = 1/(s+1);
%            rank(ctrb) = 2, rank(obsv) = 2
% EXPLORE    Cambie la última fila de A para que un modo sea inestable y
%            vuelva a calcular H(s): ¿se nota en la función de transferencia?
clear; clc;

% [ini:kalman]
A = [ 2  3  2  1;  -2 -3  0  0;  -2 -2 -4  0;  -2 -2 -2 -5];
B = [1; -2; 2; -1];
C = [7 6 4 2];   D = 0;
H = tf(ss(A, B, C, D))          % cuarto orden "en apariencia"
zpk(H)                          % ceros en -2, -3, -4 cancelan tres polos
Hmin = minreal(H)               % -> 1/(s+1)
rank(ctrb(A, B))                % 2 < 4: dos modos no controlables
rank(obsv(A, C))                % 2 < 4: dos modos no observables
% [fin:kalman]

% [ini:modal]
[V, Lam] = eig(A);              % forma modal: z = V^{-1} x
Bz = V\B, Cz = C*V              % ceros en Bz: modos que la entrada no mueve;
                                % ceros en Cz: modos que la salida no ve
% [fin:modal]
