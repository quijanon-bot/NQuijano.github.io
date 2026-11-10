%% C1_Ej1_Superposicion -- Notas: sección 1.1 (el todo no es la suma de las partes)
% QUÉ HACE   Compara dos modelos de una población de conejos: el lineal
%            P[k+1] = 2 P[k] (cada pareja tiene cuatro crías y muere) y el
%            logístico P[k+1] = R P[k] (1 - P[k]/K), R = 1.6, K = 32. Pone 20
%            conejos en una isla, o 10 en cada una de dos islas iguales.
% OBSERVE    En el modelo lineal da lo mismo una isla o dos (superposición). En
%            el logístico, una isla con 20 da 12 conejos al año siguiente y dos
%            islas con 10 dan 11 + 11 = 22.
% ESPERADO   Lineal: 40 = 20 + 20.  Logístico: F(20) = 12,  2 F(10) = 22.
% EXPLORE    ¿Con qué reparto de los 20 conejos entre las dos islas se obtiene
%            el máximo al año siguiente? ¿Por qué es K/2 por isla?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:islas]
R = 1.6;  K = 32;
Flin = @(P) 2*P;                    % modelo lineal
Flog = @(P) R*P.*(1 - P/K);         % modelo logístico
fprintf('Lineal:     una isla F(20) = %g;   dos islas F(10) + F(10) = %g\n', Flin(20), 2*Flin(10));
fprintf('Logístico:  una isla F(20) = %g;   dos islas F(10) + F(10) = %g\n', Flog(20), 2*Flog(10));
% [fin:islas]

% [ini:reparto]
a = linspace(0, 20, 2001);           % conejos en la isla 1; 20 - a en la isla 2
total = Flog(a) + Flog(20 - a);
[mx, i] = max(total);
fprintf('Mejor reparto: %.1f y %.1f conejos  ->  %.2f al año siguiente\n', a(i), 20 - a(i), mx);
% [fin:reparto]

fig = estiloFigura(900, 380);
subplot(1, 2, 1); P = linspace(0, K, 400);
plot(P, Flin(P), P, Flog(P)); hold on; plot([10 20], Flog([10 20]), 'ko', 'MarkerFaceColor', 'k');
grid on; xlabel('$P[k]$'); ylabel('$P[k+1]$'); legend('lineal', 'log\''istico', 'Location', 'northwest');
title('el mapa de un a\~no');
subplot(1, 2, 2); plot(a, total); grid on; xlabel('conejos en la isla 1');
ylabel('total al a\~no siguiente'); title('repartir 20 conejos en dos islas');
