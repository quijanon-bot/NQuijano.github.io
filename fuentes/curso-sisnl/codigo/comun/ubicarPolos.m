function K = ubicarPolos(A, B, polos)
% UBICARPOLOS  Ganancia K (fila) tal que eig(A - B K) = polos.  Una entrada.
%   K = ubicarPolos(A, B, polos)
%   Fórmula de Ackermann: K = [0 ... 0 1] C^{-1} p(A), con C = [B AB ... A^{n-1}B]
%   y p el polinomio característico deseado. No requiere Control System Toolbox
%   (equivale a place/acker para una entrada). Avisa si (A, B) no es controlable.
n = size(A, 1);
Cc = zeros(n);  Cc(:, 1) = B;
for i = 2:n, Cc(:, i) = A*Cc(:, i-1); end
if rank(Cc) < n, error('ubicarPolos: (A, B) no es controlable'); end
p = real(poly(polos));
pA = zeros(n);
for i = 1:n+1, pA = pA + p(i)*A^(n+1-i); end
K = [zeros(1, n-1) 1]/Cc*pA;
end
