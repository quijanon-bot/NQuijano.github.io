function [tipo, info] = clasificarEquilibrio(A, tol)
% CLASIFICAREQUILIBRIO  Tipo del origen de  x' = A x,  A real de 2 x 2
% (teorema de traza y determinante, sección 4.4).
%   tipo = clasificarEquilibrio(A)   devuelve, por ejemplo, 'foco estable'.
%   [tipo, info] = ...   info tiene los campos traza, det, disc (= traza^2 - 4 det),
%   lambda (valores propios), hiperbolico (true si ningún Re(lambda) = 0) y
%   giro ('horario' o 'antihorario' si los valores propios son complejos; se lee
%   en el signo de A(2,1)).
%   tol (1e-10 por defecto) decide cuándo una cantidad se considera cero.
if nargin < 2, tol = 1e-10; end
tau = trace(A);  delta = det(A);  disc = tau^2 - 4*delta;
info = struct('traza', tau, 'det', delta, 'disc', disc, 'lambda', eig(A), ...
              'hiperbolico', all(abs(real(eig(A))) > tol), 'giro', '');
if tau < 0, est = 'estable'; else, est = 'inestable'; end
if abs(delta) <= tol
    tipo = 'no aislado (det A = 0)';
elseif delta < 0
    tipo = 'silla';
elseif abs(tau) <= tol
    tipo = 'centro';
elseif disc < -tol
    tipo = ['foco ' est];
elseif abs(disc) <= tol
    if norm(A - A(1,1)*eye(2)) <= tol, tipo = ['estrella ' est];
    else, tipo = ['nodo impropio ' est]; end
else
    tipo = ['nodo ' est];
end
if ~isempty(strfind(tipo, 'foco')) || strcmp(tipo, 'centro')
    if A(2,1) > 0, info.giro = 'antihorario'; else, info.giro = 'horario'; end
end
end
