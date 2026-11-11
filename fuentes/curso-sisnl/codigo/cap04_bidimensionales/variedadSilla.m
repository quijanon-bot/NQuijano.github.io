function ramas = variedadSilla(f, xs, cual, T, epsilon, caja)
% VARIEDADSILLA  Las dos ramas de la variedad estable o inestable de una silla
% de  x' = f(x)  en el plano (sección 4.7).
%   ramas = variedadSilla(f, xs, 'estable')    (o 'inestable')
%   ramas{1}, ramas{2}: matrices k x 2 con los puntos de cada rama.
%   Método: se parte de xs +- epsilon*v, con v el vector propio de la
%   jacobiana (numérica) asociado al valor propio negativo (W^s) o positivo
%   (W^u), y se integra HACIA ATRÁS en el tiempo para W^s y hacia adelante
%   para W^u. Hacia atrás, W^s atrae a los errores numéricos en lugar de
%   amplificarlos.
%   Opcionales: T (tiempo, 20), epsilon (1e-5), caja [x1min x1max x2min x2max].
if nargin < 4 || isempty(T), T = 20; end
if nargin < 5 || isempty(epsilon), epsilon = 1e-5; end
if nargin < 6 || isempty(caja), caja = [-1e3 1e3 -1e3 1e3]; end
A = jacobianoNumerico(@(x) f(x), xs(:));
[V, L] = eig(A);  l = real(diag(L));
if strcmp(cual, 'estable'), [~, k] = min(l); s = -1; else, [~, k] = max(l); s = 1; end
v = real(V(:, k));  v = v/norm(v);
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'Events', @(t, x) fuera(t, x, caja));
ramas = cell(1, 2);
for r = 1:2
    [~, X] = ode45(@(t, x) s*f(x)*dentro(x, caja), [0 T], xs(:) + (3 - 2*r)*epsilon*v, opc);
    ramas{r} = X;
end
end

function d = dentro(x, caja)
d = double(x(1) >= caja(1) && x(1) <= caja(2) && x(2) >= caja(3) && x(2) <= caja(4));
end

function [valor, terminal, direccion] = fuera(~, x, caja)
valor = min([x(1) - caja(1), caja(2) - x(1), x(2) - caja(3), caja(4) - x(2)]);
terminal = 1;  direccion = -1;
end
