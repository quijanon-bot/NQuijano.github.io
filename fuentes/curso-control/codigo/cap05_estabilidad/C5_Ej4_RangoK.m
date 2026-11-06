%% C5_Ej4_RangoK -- Notas: sección 5.5 (diseño: rango de ganancia)
% QUÉ HACE   (1) Rango de Kc del lazo con tres retardos de primer orden, la
%            ganancia crítica y la frecuencia de oscilación; compara con margin.
%            (2) Rango de K para estabilizar una planta inestable con un
%            compensador K(s+2)/(s+3).
% OBSERVE    En Kc = Kcr el lazo oscila con la frecuencia que da el polinomio
%            auxiliar; GM de margin es exactamente Kcr.
% ESPERADO   -1.25 < Kc < 23.83; wcr = 0.2186 rad/s (Pcr = 28.7 s).
%            Planta inestable: 3 < K < 3.4891 (¡un rango muy estrecho!).
% EXPLORE    Con Kc = 0.5 Kcr, Kcr y 1.2 Kcr mida el periodo en la gráfica.
clear; close all; clc;
if ~exist('tablaRouth', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:rangokc]
s = tf('s');
G = 0.016/(3*s + 1) * 50/(30*s + 1);       % camino directo (sin Kc)
H = 1/(10*s + 1);                          % sensor
den = conv(conv([3 1], [30 1]), [10 1]);   % 900s^3 + 420s^2 + 43s + 1
% ecuación característica: 900s^3 + 420s^2 + 43s + (1 + 0.8 Kc) = 0
Kcr = (420*43/900 - 1)/0.8                 % fila s^1 = 0  ->  23.83
wcr = sqrt((1 + 0.8*Kcr)/420)              % auxiliar 420s^2 + (1+0.8Kcr) = 0
Pcr = 2*pi/wcr
[GM, PM, wgm] = margin(G*H)                % GM = Kcr, wgm = wcr
% [fin:rangokc]
fig = estiloFigura(1000, 420);  t = linspace(0, 300, 3001);
hold on;
for f = [0.5 1 1.2]
    y = step(feedback(f*Kcr*G, H), t);  plot(t, y);
end
grid on;  xlabel('t (s)');  legend('0.5 K_{cr}', 'K_{cr}', '1.2 K_{cr}');

% [ini:inestable]
P = 1/((s - 1)*(s^2 + 2*s + 2));           % planta inestable
for K = [2.9 3.2 3.48 3.6]
    T = feedback(K*(s + 2)/(s + 3)*P, 1);
    fprintf('K = %4.2f   max Re(polos) = %+.4f\n', K, max(real(pole(T))));
end
% Routh: K > 3 (fila s^0) y K^2 + 16K - 68 < 0 (fila s^1) -> 3 < K < 3.4891
Kmax = -8 + 2*sqrt(33)
% [fin:inestable]
