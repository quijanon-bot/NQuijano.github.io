%% C9_Ej4_Ackermann -- Notas: sección 9.4 (la fórmula de Ackermann)
% QUÉ HACE   Implementa la fórmula K = [0 ... 0 1] ctrb^{-1} q(A) paso a paso
%            y la compara con acker y place.
% OBSERVE    q(A) es el polinomio deseado evaluado en la MATRIZ A (polyvalm).
% ESPERADO   1/s^2 con polos -1 ± j: K = [2 2]
% EXPLORE    Pruebe con 1/(s(s+3)) y polos -4 ± 4j (problema del capítulo).
clear; clc;

% [ini:ackermann]
A = [0 1; 0 0];   B = [0; 1];          % 1/s^2 en variables de fase
q  = poly([-1+1j, -1-1j])              % [1 2 2]: lambda^2 + 2 lambda + 2
qA = polyvalm(q, A)                    % A^2 + 2A + 2I
Cc = ctrb(A, B);
n  = size(A, 1);
K  = [zeros(1, n-1) 1] / Cc * qA       % fórmula de Ackermann -> [2 2]
acker(A, B, [-1+1j, -1-1j])            % lo mismo
place(A, B, [-1+1j, -1-1j])            % place: más robusto numéricamente
% [fin:ackermann]
