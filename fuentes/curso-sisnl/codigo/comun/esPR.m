function [veredicto, info] = esPR(num, den, wmax)
% ESPR  Prueba numérica (escalar) de real positiva / estrictamente real positiva.
%   [veredicto, info] = esPR(num, den)  aplica las condiciones en frecuencia
%   de Khalil (2002), Lema 6.1, a G(s) = num(s)/den(s), con realización mínima
%   (sin factores comunes). veredicto: 'SPR', 'PR' o 'no PR'.
%
%   PR : polos en Re s <= 0; los del eje jw simples con residuo real > 0;
%        Re G(jw) >= 0 para todo w que no sea polo.
%   SPR: G Hurwitz; Re G(jw) > 0 para todo w; y G(inf) > 0, o bien
%        G(inf) = 0 y lim w^2 Re G(jw) > 0.
%
%   ¡OJO! Es una prueba en una MALLA de frecuencias (hasta wmax, por defecto
%   1e4 veces el polo más rápido): sirve para explorar y verificar, no
%   reemplaza el análisis. El límite w -> inf se estima con w = wmax.
%   Ejemplo (notas, trampa de la sección 11.7):
%       esPR([1 3], [1 3 2])    % -> 'PR' (no SPR: w^2 Re G -> 0)
tol = 1e-9;
p = roots(den);
if nargin < 3, wmax = 1e4*max([1; abs(p); abs(roots(num))]); end
info.polos = p;
info.gradoRelativo = (numel(den) - 1) - (numel(num) - find(num ~= 0, 1));
w = [0, logspace(-4, log10(wmax), 20000)];
eje = abs(real(p)) < 1e-9;
for k = find(eje).'
    w(abs(w - abs(imag(p(k)))) < 1e-6*max(1, abs(imag(p(k))))) = [];   % no evaluar en polos
end
G = respFrec(num, den, w);
info.minReG = min(real(G));
veredicto = 'no PR';
if any(real(p) > 1e-9) || info.minReG < -tol, info.motivo = 'polo inestable o Re G(jw) < 0'; return; end
% polos en el eje: simples y con residuo real positivo
for k = find(eje).'
    if sum(abs(p - p(k)) < 1e-6) > 1, info.motivo = 'polo múltiple en el eje jw'; return; end
    otros = p; otros(k) = [];
    res = polyval(num, p(k))/(den(1)*prod(p(k) - otros));
    if abs(imag(res)) > 1e-6*abs(res) || real(res) <= 0
        info.motivo = 'residuo no real positivo en un polo del eje jw'; return;
    end
end
veredicto = 'PR';
if any(eje) || any(real(G) <= 0), info.motivo = 'Re G(jw) se anula en algún w o hay polos en el eje'; return; end
% comportamiento en w -> inf: G(inf) > 0, o G(inf) = 0 y w^2 Re G -> límite > 0
Ginf = real(respFrec(num, den, 1e3*wmax));  info.Ginf = Ginf;
r1 = wmax^2*real(respFrec(num, den, wmax));  r2 = (10*wmax)^2*real(respFrec(num, den, 10*wmax));
info.w2ReG = r2;
if Ginf > 1e-6 || (r2 > 1e-6 && r2 > 0.5*r1)
    veredicto = 'SPR'; info.motivo = 'cumple las tres condiciones';
else
    info.motivo = 'G(inf) = 0 y w^2 Re G(jw) -> 0 cuando w -> inf';
end
end
