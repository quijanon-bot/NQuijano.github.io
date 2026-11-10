function [u, xi, b] = leyExactaLevitador(x, yd, K, P)
% LEYEXACTALEVITADOR  Linealización exacta del levitador (grado relativo r = n = 3).
%   [u, xi, b] = leyExactaLevitador(x, yd, K, P)
%   yd = [y_d, y_d', y_d'', y_d''']  (referencia y sus tres derivadas),  K = [k1 k2 k3].
%   xi = Phi(x) = [h; L_f h; L_f^2 h] = [posición; velocidad; aceleración]
%   u  = (v - L_f^3 h)/(L_g L_f^2 h),   v = y_d''' - K (xi - yd(1:3))
%   b  = L_g L_f^2 h = -L0 a i/(m (a + y)^2 L(y)): se anula con la corriente.
x1 = x(1);  x2 = x(2);  x3 = x(3);  c = P.L0*P.a/(2*P.m);
xi3 = P.g - P.k/P.m*x2 - c*x3^2/(P.a + x1)^2;
f3  = (-P.R*x3 + P.L0*P.a*x2*x3/(P.a + x1)^2)/P.L(x1);
Lf3 = 2*c*x3^2/(P.a + x1)^3*x2 - P.k/P.m*xi3 - 2*c*x3/(P.a + x1)^2*f3;
b   = -P.L0*P.a*x3/(P.m*(P.a + x1)^2*P.L(x1));
yd  = yd(:);  xi = [x1; x2; xi3];
v   = yd(4) - K(:).'*(xi - yd(1:3));
u   = (v - Lf3)/b;
end
