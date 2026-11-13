function u = leySontag(lf, lg, kappa)
% LEYSONTAG  Fórmula universal de Sontag (1989) para x' = f(x) + g(x) u.
%   u = leySontag(lf, lg)          lf = L_f V(x) (escalar), lg = L_g V(x) (fila 1 x m)
%   u = leySontag(lf, lg, kappa)   agrega el amortiguamiento -kappa*lg' (kappa >= 0)
%   Devuelve la columna u = -(kappa + (lf + sqrt(lf^2 + |lg|^4))/|lg|^2) lg'
%   y u = 0 donde lg = 0. Con ella  Vdot = -sqrt(lf^2 + |lg|^4) - kappa |lg|^2.
%   Si V es CLF (lg = 0 => lf < 0), Vdot < 0 para x ~= 0. La ley es continua en el
%   origen si y solo si V tiene la propiedad de control pequeño (Artstein).
if nargin < 3, kappa = 0; end
lg = lg(:).';  n2 = lg*lg.';
if n2 < 1e-300
    u = zeros(numel(lg), 1);
else
    u = -(kappa + (lf + sqrt(lf^2 + n2^2))/n2)*lg.';
end
end
