function [h, dh] = diodoTunel()
% DIODOTUNEL  Característica corriente-voltaje del diodo túnel de Khalil (2002,
% ejemplo de la sección 1.2.2):  i = h(v), v en V, i en mA.
%   [h, dh] = diodoTunel()  devuelve h(v) y su derivada h'(v) como funciones.
%   Con C en pF, R en kOhm y t en ns, C v' = (E - v)/R - h(v) queda en V/ns.
h  = @(v) 17.76*v - 103.79*v.^2 + 229.62*v.^3 - 226.31*v.^4 + 83.72*v.^5;
dh = @(v) 17.76 - 2*103.79*v + 3*229.62*v.^2 - 4*226.31*v.^3 + 5*83.72*v.^4;
end
