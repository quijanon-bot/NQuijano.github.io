function [A, B, C, D] = tf2ss(num, den)
% Equivalente mínimo de tf2ss de MATLAB (SISO) para probar en Octave.
den = den(find(den, 1):end);  a = den/den(1);  n = numel(a) - 1;
num = [zeros(1, n + 1 - numel(num)), num]/den(1);
D = num(1);  b = num(2:end) - D*a(2:end);
A = [-a(2:end); eye(n-1), zeros(n-1, 1)];  B = [1; zeros(n-1, 1)];  C = b;
end
