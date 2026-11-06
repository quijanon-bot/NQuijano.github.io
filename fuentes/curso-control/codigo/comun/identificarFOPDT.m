function [Kp, L, tau63, tauZN] = identificarFOPDT(t, y, du)
% IDENTIFICARFOPDT  Modelo Kp e^{-Ls}/(tau s+1) a partir de una respuesta escalón.
%   [Kp, L, tau63, tauZN] = identificarFOPDT(t, y, du)
%   t, y : respuesta medida (y en desviación o absoluta; se resta y(1))
%   du   : tamaño del escalón aplicado a la salida del controlador
%   Método de la tangente: se traza la recta de máxima pendiente; su corte con
%   el valor inicial da L.  tau63: desde L hasta el 63.2 % del cambio final.
%   tauZN: desde L hasta el corte de la tangente con el valor final (Ziegler-Nichols).
%   Con datos muestreados, la pendiente se estima con diferencias hacia adelante.
t = t(:); dy = y(:) - y(1);  Dy = dy(end);
m = diff(dy)./diff(t);  [mmax, i] = max(m);
L = t(i) - dy(i)/mmax;
Kp = Dy/du;
tauZN = Dy/mmax;
j = find(dy >= 0.632*Dy, 1);                    % interpolación lineal del 63.2 %
t63 = t(j-1) + (0.632*Dy - dy(j-1))*(t(j) - t(j-1))/(dy(j) - dy(j-1));
tau63 = t63 - L;
end
