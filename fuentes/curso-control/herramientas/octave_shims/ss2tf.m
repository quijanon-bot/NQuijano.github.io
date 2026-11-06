function [num, den] = ss2tf(A, B, C, D, iu)
% Equivalente mínimo de ss2tf de MATLAB para probar en Octave (una entrada).
if nargin < 5, iu = 1; end
den = poly(A);  n = size(A, 1);  num = zeros(size(C, 1), n + 1);
for i = 1:size(C, 1)
    num(i,:) = poly(A - B(:,iu)*C(i,:)) - den + D(i,iu)*den;
end
end
