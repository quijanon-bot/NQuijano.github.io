function J = jacobianoNumerico(g, y, h)
% JACOBIANONUMERICO  Jacobiano de g en y por diferencias centradas.
%   J = jacobianoNumerico(@(y) ..., y0)     (paso h = 1e-7 por defecto)
if nargin < 3, h = 1e-7; end
n = numel(y);  m = numel(g(y));  J = zeros(m, n);
for j = 1:n
    e = zeros(n, 1);  e(j) = h;
    J(:, j) = (g(y(:) + e) - g(y(:) - e))/(2*h);
end
end
