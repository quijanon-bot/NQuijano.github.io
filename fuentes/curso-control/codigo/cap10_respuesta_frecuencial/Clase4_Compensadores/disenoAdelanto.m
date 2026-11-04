function [Gc, info] = disenoAdelanto(Gp, PMdes, phiSeg, estricto)
% DISENOADELANTO  Compensador en adelanto por respuesta en frecuencia (notas, sección 10.11).
%   [Gc, info] = disenoAdelanto(Gp, PMdes, phiSeg, estricto)
%   Gp       planta YA con la ganancia que cumple el error (paso 1 del procedimiento)
%   PMdes    margen de fase deseado (grados)
%   phiSeg   ángulo de seguridad inicial (5°-10°)
%   estricto (opcional) true: aumenta phiSeg de 5° en 5° hasta que
%            phiSeg >= fase(Gp, w_PM) - fase(Gp, w_M)  (verificación estricta)
%   Gc = alpha (s + wL)/(s + wH),   Gc(0) = 1  (no cambia el error)
%
%   Ejemplo (notas): Gp = zpk([], [0 -2], 40); [Gc, info] = disenoAdelanto(Gp, 45, 10)
%     -> alpha = 4.03, wM = 8.85, wL = 4.41, wH = 17.76, PM = 49.8°
if nargin < 4, estricto = false; end
[~, PM, ~, wPM] = margin(Gp);                            % paso 2
while true
    phiM = PMdes - PM + phiSeg;                          % paso 3
    if phiM >= 90
        error('disenoAdelanto:phiM', 'phi_M = %.1f° >= 90°: use dos etapas o atraso-adelanto.', phiM);
    end
    alpha    = (1 + sind(phiM))/(1 - sind(phiM));        % paso 4
    objetivo = -10*log10(alpha);                         % paso 5: |Gp(j wM)| = -10 log(alpha) dB
    wM = fzero(@(w) 20*log10(abs(evalfr(Gp, 1j*w))) - objetivo, [wPM, 100*wPM]);
    perdida = faseEn(Gp, wPM) - faseEn(Gp, wM);          % fase que la planta pierde al correr el cruce
    if ~estricto || phiSeg >= perdida, break; end
    phiSeg = phiSeg + 5;
end
wL = wM/sqrt(alpha);  wH = alpha*wL;                     % paso 6
Gc = zpk(-wL, -wH, alpha);
[~, PMn, ~, wPMn] = margin(Gc*Gp);                       % paso 7: verificar
info = struct('PM0', PM, 'wPM0', wPM, 'phiSeg', phiSeg, 'phiM', phiM, 'alpha', alpha, ...
              'wM', wM, 'wL', wL, 'wH', wH, 'PM', PMn, 'wPM', wPMn, 'perdidaFase', perdida);
end
