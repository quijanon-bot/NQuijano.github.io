function I = indiceCurva(f, c, r, n)
% INDICECURVA  Índice de una circunferencia respecto al campo f (Poincaré).
%   I = indiceCurva(f, c, r) recorre la circunferencia de centro c y radio r
%   en sentido antihorario, sigue el ángulo de f(x) sin saltos (unwrap) y
%   devuelve el número neto de vueltas que dio el vector.  f: R^2 -> R^2.
%   La curva no debe pasar por equilibrios (f ~= 0 sobre ella).
if nargin < 4, n = 4000; end
th  = linspace(0, 2*pi, n + 1);
ang = zeros(1, n + 1);
for k = 1:n + 1
    v = f(c(:) + r*[cos(th(k)); sin(th(k))]);
    ang(k) = atan2(v(2), v(1));
end
I = (sum(diff(unwrap(ang))))/(2*pi);   % cambio neto del ángulo / 2 pi
end
