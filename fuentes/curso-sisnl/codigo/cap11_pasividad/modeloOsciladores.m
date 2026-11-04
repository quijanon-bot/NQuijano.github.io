function dx = modeloOsciladores(t, x, a, k, b, u1, u2)
% MODELOOSCILADORES  Dos osciladores no lineales en la conexión estándar (sección 11.8).
%   H1: x1' = x2,  x2' = -a x1^3 - k x2 + e1,   y1 = x2
%   H2: x3' = x4,  x4' = -b x3 - x4^3 + e2,     y2 = x4
%   e1 = u1 - y2,  e2 = u2 + y1   (retroalimentación negativa en e1)
%   u1, u2: escalares o funciones de t (por defecto, cero).
if nargin < 6, u1 = 0; end
if nargin < 7, u2 = 0; end
if isa(u1, 'function_handle'), u1 = u1(t); end
if isa(u2, 'function_handle'), u2 = u2(t); end
y1 = x(2);  y2 = x(4);
e1 = u1 - y2;  e2 = u2 + y1;
dx = [x(2); -a*x(1)^3 - k*x(2) + e1; x(4); -b*x(3) - x(4)^3 + e2];
end
