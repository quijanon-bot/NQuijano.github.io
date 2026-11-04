%% C9_Ej3_Controlabilidad -- Notas: sección 9.3 (¿se pueden mover todos los polos?)
% QUÉ HACE   Calcula la matriz de controlabilidad y su rango, aplica el test
%            PBH para saber QUÉ modo falla, y mide "cuánta" controlabilidad hay
%            con el número de condición.
% OBSERVE    rank dice sí o no; el número de condición de ctrb y el tamaño de
%            K dicen qué tan caro es mover los polos.
% ESPERADO   diag(-1,-3), B = [1;1]: controlable, K = [0.5 -0.5] para {-2,-2}.
%            A = [-1 a; 3 -2]: det(ctrb) = -a.
% EXPLORE    a = 0.01: ¿qué le pasa a K y a max|u|?
clear; clc;

% [ini:rango]
A = [-1 0; 0 -3];   B = [1; 1];
Cc = ctrb(A, B)                 % [B, AB]
rank(Cc)                        % 2 = n: controlable
K = acker(A, B, [-2 -2])        % -> [0.5 -0.5]
eig(A - B*K)
% [fin:rango]

% [ini:pbh]
a = 0;
A = [-1 a; 3 -2];   B = [0; 1];
for lambda = eig(A).'
    r = rank([A - lambda*eye(2), B]);
    fprintf('lambda = %5.1f: rank[A-lambda I, B] = %d\n', lambda, r);
end
% el modo con rango < n es el que la entrada no puede mover
% [fin:pbh]

% [ini:condicion]
for a = [2 1 0.1 0.01]
    A = [-1 a; 3 -2];
    K = place(A, B, [-2 -3]);
    fprintf('a = %5.2f: K = [%7.2f %5.2f], cond(ctrb) = %7.1f\n', a, K, cond(ctrb(A, B)));
end
% [fin:condicion]
