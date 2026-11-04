function [Gc, info] = disenoAtraso(Gp, PMdes, holgura)
% DISENOATRASO  Compensador en atraso por respuesta en frecuencia (notas, sección 10.11).
%   [Gc, info] = disenoAtraso(Gp, PMdes, holgura)
%   Gp       planta YA con la ganancia que cumple el error
%   PMdes    margen de fase deseado (grados)
%   holgura  grados extra por la fase que roba el atraso (por defecto 5°)
%   Gc = (1/alpha) (s + wH)/(s + wL),   Gc(0) = 1
%
%   Ejemplo (notas): Gp = zpk([], [0 -2], 40); [Gc, info] = disenoAtraso(Gp, 45)
%     -> wdes = 1.68, alpha = 9.13, wH = 0.168, wL = 0.0184, PM = 44.8°
if nargin < 3, holgura = 5; end
fobj = -180 + PMdes + holgura;                           % paso 1: fase objetivo
ww = logspace(-3, 3, 20000);  fw = faseEn(Gp, ww);
i = find(diff(sign(fw - fobj)), 1);                      % primer cruce de la fase objetivo
if isempty(i), error('disenoAtraso:fase', 'La fase de Gp nunca vale %.1f°.', fobj); end
wdes  = fzero(@(w) faseEn(Gp, w) - fobj, ww([i i+1]));
wH    = wdes/10;                                         % paso 2: cero una década abajo
alpha = abs(evalfr(Gp, 1j*wdes));                        % paso 3: 20 log|Gp(j wdes)| = 20 log(alpha)
wL    = wH/alpha;
Gc = zpk(-wH, -wL, 1/alpha);
[~, PMn, ~, wPMn] = margin(Gc*Gp);
info = struct('wdes', wdes, 'alpha', alpha, 'wH', wH, 'wL', wL, 'PM', PMn, 'wPM', wPMn);
end
