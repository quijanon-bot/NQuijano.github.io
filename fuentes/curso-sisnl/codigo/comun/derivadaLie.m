function L = derivadaLie(f, lambda, x, h)
% DERIVADALIE  Derivada de Lie numérica  L_f lambda(x) = (d lambda/dx)(x) f(x).
%   L = derivadaLie(f, lambda, x)      f: R^n -> R^n,  lambda: R^n -> R
%   Gradiente por diferencias centradas (paso h, por defecto 1e-6).
%   Para derivadas sucesivas, anide:  Lf2 = @(x) derivadaLie(f, @(z) derivadaLie(f, lambda, z), x)
%   (cada anidamiento pierde precisión; para n > 2 conviene la fórmula cerrada).
if nargin < 4, h = 1e-6; end
x = x(:);  n = numel(x);  grad = zeros(1, n);
for i = 1:n
    e = zeros(n, 1);  e(i) = h*max(1, abs(x(i)));
    grad(i) = (lambda(x + e) - lambda(x - e))/(2*e(i));
end
L = grad*f(x);
end
