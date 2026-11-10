%% C1_Ej2_Logistica -- Notas: sección 1.4 (crecimiento de poblaciones)
% QUÉ HACE   Itera el mapa logístico P[k+1] = R P[k] (1 - P[k]/K), K = 32, desde
%            P[0] = 1, para R = 1.6 (natalidad 2 menos mortandad 0.4) y para
%            R = 3.2, 3.5 y 3.9. Compara con la ecuación logística en tiempo
%            continuo P' = R P (1 - P/K) y su solución exacta.
% OBSERVE    Con R = 1.6 la población sube monótonamente a K(1 - 1/R) = 12. Con
%            R = 3.2 oscila entre dos valores, con R = 3.5 entre cuatro y con
%            R = 3.9 no se repite nunca. La ecuación continua, con el mismo R,
%            siempre sube monótonamente hasta K.
% ESPERADO   R = 1.6:  P[1] = 1.55,  P[21] = 12.0000.
%            R = 3.2:  ciclo {16.4174, 25.5826};  R = 3.5: ciclo de período 4.
%            Continua: error de ode45 contra la solución exacta < 1e-8.
% EXPLORE    Busque el valor de R en el que aparece el ciclo de período 2
%            (pista: R = 3). ¿Qué pasa si R > 4?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:discreta]
K = 32;  R = 1.6;  n = 50;
P = zeros(1, n + 1);  P(1) = 1;                 % P(1) es P[0]
for k = 1:n
    P(k+1) = R*P(k)*(1 - P(k)/K);
end
fprintf('R = %.1f:  P[1] = %.4f,  P[21] = %.4f,  K(1 - 1/R) = %.4f\n', R, P(2), P(22), K*(1 - 1/R));
% [fin:discreta]

% [ini:regimenes]
for R = [3.2 3.5 3.9]
    p = 1;
    for k = 1:2000, p = R*p*(1 - p/K); end      % se deja pasar el transitorio
    orbita = zeros(1, 8);
    for k = 1:8, p = R*p*(1 - p/K); orbita(k) = p; end
    fprintf('R = %.1f:  ', R); fprintf('%8.4f', orbita); fprintf('\n');
end
% [fin:regimenes]

% [ini:continua]
R = 1.6;  P0 = 1;
Pex = @(t) K*P0*exp(R*t)./(K + P0*(exp(R*t) - 1));
[t, Pn] = ode45(@(t, P) R*P*(1 - P/K), [0 10], P0, odeset('RelTol', 1e-11, 'AbsTol', 1e-12));
fprintf('Continua: error máximo de ode45 frente a la solución exacta = %.1e\n', max(abs(Pn - Pex(t))));
% [fin:continua]

fig = estiloFigura(1000, 420);
subplot(1, 2, 1); stem(0:n, P, 'filled'); grid on; xlabel('$k$'); ylabel('$P[k]$');
title('mapa log\''istico, $R=1.6$');
subplot(1, 2, 2); plot(t, Pn); grid on; xlabel('$t$'); ylabel('$P(t)$');
title('ecuaci\''on log\''istica continua, $R=1.6$');
