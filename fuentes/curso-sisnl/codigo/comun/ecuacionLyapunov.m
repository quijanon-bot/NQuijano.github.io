function P = ecuacionLyapunov(A, Q)
% ECUACIONLYAPUNOV  Resuelve A'P + PA = -Q (la convención del curso y de Khalil).
%   P = ecuacionLyapunov(A, Q)   no requiere toolboxes.
%   Usa la vectorización (I kron A' + A' kron I) vec(P) = -vec(Q), cuyos valores propios
%   son lambda_i + lambda_j. La solución es única si y solo si lambda_i + lambda_j ~= 0
%   para todo i, j; si no, devuelve NaN y avisa.
%   OJO: lyap(A, Q) de la Control System Toolbox resuelve A X + X A' + Q = 0.
%   La P del curso es lyap(A', Q), NO lyap(A, Q).
n = size(A, 1);
lam = eig(A);
S = repmat(lam, 1, n) + repmat(lam.', n, 1);
M = kron(eye(n), A.') + kron(A.', eye(n));
if min(abs(S(:))) < 1e-9 || rcond(M) < 1e-14
    warning('ecuacionLyapunov:singular', 'lambda_i + lambda_j = 0 para algún par: no hay solución única.');
    P = NaN(n);
    return
end
P = reshape(-M \ Q(:), n, n);
P = (P + P.')/2;
end
