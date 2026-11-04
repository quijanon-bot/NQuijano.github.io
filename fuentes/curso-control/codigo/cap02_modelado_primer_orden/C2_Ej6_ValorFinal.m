%% C2_Ej6_ValorFinal -- Notas: sección 2.6 (teorema del valor final)
% QUÉ HACE   Aplica el teorema del valor final y lo compara con la respuesta
%            en el tiempo, incluyendo dos casos en los que NO se puede usar.
% OBSERVE    Antes de calcular lim s->0 sY(s), mire los polos de sY(s):
%            todos deben tener parte real negativa.
% ESPERADO   1/(s-2): lim = 0 pero h(t) = e^{2t} diverge (no aplica).
%            6(s^2-2)/(s^3+s^2-4s-4): polo en +2 (no aplica).
%            Térmico con M = 2: valor final 2.
% EXPLORE    Construya un caso con polos en ±j: ¿qué dice el teorema? ¿Qué
%            hace la señal?
clear; clc;

% [ini:tvf]
s = tf('s');
casos = {1/(s-2), 6*(s^2-2)/(s^3+s^2-4*s-4), 2/(s*(5*s+1))};
for k = 1:numel(casos)
    Y = casos{k};
    sY = minreal(s*Y);
    p  = pole(sY);
    if all(real(p) < 0)
        fprintf('caso %d: valor final = %g\n', k, dcgain(sY));
    else
        fprintf('caso %d: NO aplica (polo con Re >= 0 en %s)\n', k, mat2str(p(real(p) >= 0).', 3));
    end
end
% [fin:tvf]
