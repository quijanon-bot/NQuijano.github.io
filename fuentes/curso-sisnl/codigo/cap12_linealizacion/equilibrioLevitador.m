function [xs, us] = equilibrioLevitador(yb, P)
% EQUILIBRIOLEVITADOR  Equilibrio con la esfera en y = yb > 0:
%   x* = (yb, 0, sqrt(2 g m/(L0 a)) (a + yb)),   u* = R x3*.
x3 = sqrt(2*P.g*P.m/(P.L0*P.a))*(P.a + yb);
xs = [yb; 0; x3];  us = P.R*x3;
end
