function G = respFrec(num, den, w)
% RESPFREC  Respuesta en frecuencia G(jw) de num(s)/den(s) sin toolboxes.
%   G = respFrec(num, den, w)   num, den: coeficientes (potencias decrecientes)
%   Ejemplo: G = respFrec([1 3], [1 3 2], logspace(-2, 2, 400));
%   Equivale a squeeze(freqresp(tf(num, den), w)) del Control System Toolbox.
s = 1j*w(:).';
G = polyval(num, s)./polyval(den, s);
end
