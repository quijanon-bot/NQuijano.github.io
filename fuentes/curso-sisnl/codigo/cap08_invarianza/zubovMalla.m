function W = zubovMalla(f, x1, x2, hfun, T)
% ZUBOVMALLA  W(x0) = int_0^T h(phi_t(x0)) dt en una malla (método de las características).
%   W = zubovMalla(f, x1, x2, hfun, T)   f = @(t, x) ..., hfun = @(x) ... (h(x) > 0 si x ~= 0)
%   x1, x2: vectores de la malla. W(i, j) corresponde a (x1(j), x2(i)).
%   Se pone W = Inf si la solución sale de ||x|| <= 10 o no llega a ||x|| < 1e-3 en T.
%   V = 1 - exp(-W) es la función de Zubov; {V < 1} = {W < Inf} es la región de atracción.
if nargin < 5, T = 40; end
opc = odeset('RelTol', 1e-7, 'AbsTol', 1e-9, 'Events', @(t, z) eventoODE(z(1)^2 + z(2)^2 - 100, 1, 0));
g = @(t, z) [f(t, z(1:2)); hfun(z(1:2))];
W = Inf(numel(x2), numel(x1));
for i = 1:numel(x2)
    for j = 1:numel(x1)
        [t, Z] = ode45(g, [0 T], [x1(j); x2(i); 0], opc);
        if t(end) >= T && norm(Z(end, 1:2)) < 1e-3
            W(i, j) = Z(end, 3);
        end
    end
end
end
