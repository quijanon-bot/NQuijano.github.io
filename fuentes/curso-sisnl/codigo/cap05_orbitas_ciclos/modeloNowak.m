function dx = modeloNowak(~, x, B, Q)
% MODELONOWAK  Dinámica replicador-mutador del lenguaje (Mitchener y Nowak, 2004).
%   F = B x (aptitud de cada gramática),  Fbar = x' B x (aptitud media),
%   dx_j = sum_i F_i x_i Q_ij - Fbar x_j,   es decir   dx = Q' (F .* x) - Fbar x.
%   Q es estocástica por filas: Q(i,j) = prob. de que el hijo de un hablante
%   de G_i aprenda G_j.
F    = B*x(:);
Fbar = x(:).'*F;
dx   = Q.'*(F.*x(:)) - Fbar*x(:);
end
