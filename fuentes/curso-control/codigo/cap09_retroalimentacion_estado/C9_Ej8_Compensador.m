%% C9_Ej8_Compensador -- Notas: sección 9.7 (principio de separación)
% QUÉ HACE   Une u = -K x~ con el observador para A = [0 1; -2 -3], C = [1 0]:
%            K pone los polos en -2 ± 2j y L los del observador en -10 (doble).
%            Verifica que los polos del conjunto son la unión de ambos y
%            obtiene la función de transferencia del compensador.
% OBSERVE    El compensador U/Y es una función de transferencia de segundo
%            orden: un "controlador clásico" diseñado en el espacio de estado.
% ESPERADO   K = [6 1], L = [17; 47]; polos {-2±2j, -10, -10};
%            U/Y = -(149 s + 554)/(s^2 + 21 s + 123)
% EXPLORE    Mueva los polos del observador a -4: ¿cuánto se deteriora la
%            respuesta con un error inicial de estimación?
clear; clc;

% [ini:separacion]
A = [0 1; -2 -3];   B = [0; 1];   C = [1 0];
K = acker(A, B, [-2+2j, -2-2j])                % [6 1]
L = acker(A.', C.', [-10 -10]).'               % [17; 47]
Aa = [A - B*K, B*K; zeros(2), A - L*C];        % coordenadas (x, e = x - x~)
eig(Aa)                                        % unión de eig(A-BK) y eig(A-LC)
Gc = tf(ss(A - B*K - L*C, L, -K, 0))           % compensador U(s)/Y(s)
zpk(Gc)
% [fin:separacion]
