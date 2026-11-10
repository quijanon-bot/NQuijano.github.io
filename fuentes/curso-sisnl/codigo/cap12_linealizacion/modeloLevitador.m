function dx = modeloLevitador(x, u, P, mReal)
% MODELOLEVITADOR  Dinámica del levitador.  x = [y; ydot; i] (y hacia abajo),  u = voltaje.
%   dx = modeloLevitador(x, u, P)          planta con la masa del modelo, P.m
%   dx = modeloLevitador(x, u, P, mReal)   planta con otra masa (error de modelo)
if nargin < 4, mReal = P.m; end
x1 = x(1);  x2 = x(2);  x3 = x(3);
dx = [ x2;
       P.g - P.k/mReal*x2 - P.L0*P.a*x3^2/(2*mReal*(P.a + x1)^2);
       (u - P.R*x3 + P.L0*P.a*x2*x3/(P.a + x1)^2)/P.L(x1) ];
end
