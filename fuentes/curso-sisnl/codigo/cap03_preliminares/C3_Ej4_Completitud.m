%% C3_Ej4_Completitud -- Notas: sección 3.5 (espacios completos)
% QUÉ HACE   Construye las rampas continuas f_k en [0,1] (0 hasta t = 1/2, suben
%            con pendiente k, valen 1 después) y mide ||f_k - f_m|| en la norma
%            L2 y en la norma del máximo.
% OBSERVE    En L2 la sucesión es de Cauchy y se acerca al escalón, que NO es
%            continuo: (C[0,1], ||.||_L2) no es completo. En la norma del
%            máximo no es de Cauchy: ||f_k - f_2k||_inf = 1/2 para todo k.
% ESPERADO   ||f_k - escalón||_L2 = 1/sqrt(3k):  k = 10 -> 0.1826, k = 100 -> 0.0577.
%            ||f_10 - f_20||_L2 = 0.0913,  ||f_10 - f_20||_inf = 0.5.
% EXPLORE    Repita con f_k(t) = t^k en [0,1]. ¿Es de Cauchy en L2? ¿En la norma
%            del máximo? ¿A qué converge?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:rampas]
t = linspace(0, 1, 400001);
rampa = @(k) min(1, max(0, k*(t - 0.5)));      % continua para todo k
escalon = double(t > 0.5);                      % el "límite": no es continuo
nL2  = @(h) sqrt(trapz(t, h.^2));
nInf = @(h) max(abs(h));
for k = [10 100 1000]
    fprintf('k = %4d:  ||f_k - escalón||_L2 = %.4f  (1/sqrt(3k) = %.4f)\n', ...
            k, nL2(rampa(k) - escalon), 1/sqrt(3*k));
end
fprintf('||f_10 - f_20||_L2 = %.4f,   ||f_10 - f_20||_inf = %.4f\n', ...
        nL2(rampa(10) - rampa(20)), nInf(rampa(10) - rampa(20)));
% [fin:rampas]

fig = estiloFigura(700, 420); hold on;
for k = [4 10 40], plot(t, rampa(k)); end
plot(t, escalon, 'k--'); grid on; xlabel('$t$'); legend('$k=4$', '$k=10$', '$k=40$', 'escalón', 'Location', 'northwest');
