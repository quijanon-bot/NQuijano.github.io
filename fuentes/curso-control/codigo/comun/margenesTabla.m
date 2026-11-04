function T = margenesTabla(L, nombre)
% MARGENESTABLA  Imprime GM (dB), PM (grados) y sus frecuencias.
%   margenesTabla(L, nombre)    imprime una línea
%   T = margenesTabla(L, nombre) además devuelve una estructura.
%
%   ¡Cuidado con los nombres de MATLAB! En [Gm,Pm,Wcg,Wcp] = margin(L):
%     Wcg es la frecuencia donde se mide el GM (fase = -180°)  -> w_GM en las notas
%     Wcp es la frecuencia donde se mide el PM (|L| = 0 dB)    -> w_PM en las notas
%   y Gm sale en VECES, no en dB.
if nargin < 2, nombre = inputname(1); end
[Gm, Pm, Wcg, Wcp] = margin(L);
fprintf('%-22s GM = %6.2f dB (w_GM = %7.3f)   PM = %6.2f° (w_PM = %7.3f)\n', ...
        nombre, 20*log10(Gm), Wcg, Pm, Wcp);
if nargout > 0
    T = struct('GMdB', 20*log10(Gm), 'GM', Gm, 'wGM', Wcg, 'PM', Pm, 'wPM', Wcp);
end
end
