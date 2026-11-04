function [V1, V2, vs, qs] = energiaAgua(X, c, Q, r, vm)
% ENERGIAAGUA  Almacenamientos del lazo tanques-replicador respecto al equilibrio vigente.
%   X: matriz con una fila por instante, [v q];  c: descargas.
%   V1 = r/(2 Q vm) sum (v_i - v*)^2          (tanques, OSP)
%   V2 = (1/Q) sum q*_i ln(q*_i / q_i)        (replicador, sin pérdidas; entropía relativa)
N = size(X, 2)/2;
c = c(:).';
vs = Q^2/sum(c)^2;              % v*  (todos los tanques al mismo nivel)
qs = c*Q/sum(c);                % q*_i proporcional a la demanda c_i
V1 = r/(2*Q*vm)*sum((X(:,1:N) - vs).^2, 2);
V2 = sum(qs.*log(qs./X(:,N+1:end)), 2)/Q;
end
