function dx = modeloAgua(x, c, Q, r, vm)
% MODELOAGUA  Tanques + dinámica del replicador (sección 11.10; Ramírez-Llanos y Quijano, 2010).
%   x = [v; q]  (N volúmenes y N caudales),  c: coeficientes de descarga (N x 1)
%   v_i' = q_i - c_i sqrt(v_i)                      (Torricelli)
%   q_i' = q_i (F_i - Fbar),  F_i = r (1 - v_i/vm),  Fbar = (1/Q) sum_j q_j F_j
%   Notación del artículo -> curso: x_i -> q_i, f_i -> F_i, Sigma_1,2 -> H_1,2.
N = numel(x)/2;
v = max(x(1:N), 0);            % sqrt no está definida para v < 0 (error numérico)
q = x(N+1:end);
F = r*(1 - v/vm);
Fbar = (q.'*F)/Q;
dx = [q - c(:).*sqrt(v); q.*(F - Fbar)];
end
