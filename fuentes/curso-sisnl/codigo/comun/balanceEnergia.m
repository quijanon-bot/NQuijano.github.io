function [S, D, residuo] = balanceEnergia(t, V, s, d)
% BALANCEENERGIA  Comprueba V(t) - V(0) = int s - int d a lo largo de una simulación.
%   [S, D, residuo] = balanceEnergia(t, V, s, d)
%   t : tiempos (vector);  V : almacenamiento evaluado en la solución, V(x(t))
%   s : tasa de suministro evaluada en la solución, s(u(t), y(t))
%   d : tasa de disipación evaluada en la solución, d(x(t), u(t)) >= 0
%   S, D : integrales acumuladas (regla del trapecio)
%   residuo : V - V(0) - S + D   (debe ser del orden del error numérico)
t = t(:);  V = V(:);  s = s(:);  d = d(:);
S = [0; cumsum(0.5*(s(2:end) + s(1:end-1)).*diff(t))];
D = [0; cumsum(0.5*(d(2:end) + d(1:end-1)).*diff(t))];
residuo = V - V(1) - S + D;
end
