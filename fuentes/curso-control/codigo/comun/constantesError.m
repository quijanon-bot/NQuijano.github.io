function [tipo, kp, kv, ka] = constantesError(G)
% CONSTANTESERROR  Tipo y constantes estáticas de error de un lazo abierto G(s).
%   [tipo, kp, kv, ka] = constantesError(G)
%   tipo = número de polos en el origen de G (el lazo abierto, con
%   retroalimentación unitaria). kp = lim G, kv = lim sG, ka = lim s^2 G.
%   OJO: solo tiene sentido si el lazo cerrado es estable (verifíquelo antes).
[z, p, k] = zpkdata(minreal(tf(G)), 'v');
enCero = abs(p) < 1e-9;  tipo = sum(enCero);
p0 = p(~enCero);  z0 = z(abs(z) > 1e-9);  nz0 = sum(abs(z) <= 1e-9);
base = real(k*prod(-z0)/prod(-p0));              % ganancia "de Bode" sin los s^N
c = Inf(1, 3);
for i = 0:2
    e = tipo - nz0 - i;                          % potencia de s que queda en el denominador
    if e > 0, c(i+1) = Inf; elseif e == 0, c(i+1) = base; else, c(i+1) = 0; end
end
kp = c(1);  kv = c(2);  ka = c(3);
end
