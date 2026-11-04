function [A, B, C, D] = variablesFase(num, den)
% VARIABLESFASE  Representación de estado en variables de fase (la del curso):
%   x1 = y/b0-escalada, x2 = x1', ...,  A = [0 1 0 ...; ...; -a0 -a1 ... -a(n-1)],
%   B = [0; ...; 0; 1],  C = [b0 b1 ... ] (coeficientes del numerador en
%   potencias CRECIENTES de s).   Requiere grado(num) < grado(den).
%   [A,B,C,D] = variablesFase([10], conv([1 10],[1 0.5 1]))
% OJO: tf2ss de MATLAB devuelve otra forma (la "canónica controlable" con la
% primera fila -a(n-1) ... -a0); las ganancias K dependen de la forma.
den = den(find(den, 1):end);  num = num(find(num, 1):end);
a = den/den(1);  b = num/den(1);  n = numel(a) - 1;
A = [zeros(n-1, 1), eye(n-1); -fliplr(a(2:end))];
B = [zeros(n-1, 1); 1];
C = zeros(1, n);  C(1:numel(b)) = fliplr(b);
D = 0;
end
