function [GL, d] = reduccionMomentos(GH)
% REDUCCIONMOMENTOS  Aproxima GH(s) por K/(1 + d1 s + d2 s^2) igualando
% los "momentos" M_{2q} = Delta_{2q}, q = 1, 2 (sección 3.10 de las notas).
%   [GL, d] = reduccionMomentos(GH)     d = [d1 d2]
% GH debe ser estable y con GH(0) finito y distinto de cero.
[num, den] = tfdata(tf(GH), 'v');
K  = dcgain(GH);
% normalizar: GH = K * N(s)/D(s) con N(0) = D(0) = 1, coeficientes en potencias crecientes
N = fliplr(num(find(num, 1):end));  N = N/N(1);
D = fliplr(den(find(den, 1):end));  D = D/D(1);
% G_H/G_L = N(s) (1 + d1 s + d2 s^2) / D(s):  M = N*(1 + d1 s + d2 s^2), Delta = D
mom = @(c, q) sum(arrayfun(@(k) (-1)^(k+q)*coef(c, k)*coef(c, 2*q-k), 0:2*q));
residuo = @(v) [mom(conv(N, [1 v(1) v(2)]), 1) - mom(D, 1);
                mom(conv(N, [1 v(1) v(2)]), 2) - mom(D, 2)];
% valor inicial: el caso sin ceros tiene solución cerrada
d2 = sqrt(mom(D, 2));  d1 = sqrt(mom(D, 1) + 2*d2);
if numel(N) > 1
    d = fsolve(residuo, [d1 d2], optimset('Display', 'off', 'TolFun', 1e-12));
    d1 = d(1);  d2 = d(2);
end
d  = [d1 d2];
GL = tf(K, [d2 d1 1]);
end

function a = coef(c, k)
% coeficiente de s^k (c en potencias crecientes); cero fuera de rango
if k >= 0 && k < numel(c), a = c(k+1); else, a = 0; end
end
