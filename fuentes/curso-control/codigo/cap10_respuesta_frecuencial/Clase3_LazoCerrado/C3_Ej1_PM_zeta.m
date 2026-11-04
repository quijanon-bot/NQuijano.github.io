%% C3_Ej1_PM_zeta -- Notas: sección 10.8 (del PM de malla abierta al transitorio del lazo cerrado)
% G'(s) = 100/(s(s+10))
% ESPERADO  PM = 51.8° en 7.86 rad/s -> zeta = 0.50, wn = 10 -> %OS = 16.3 %,
%           tp = 0.363 s, ts = 0.8 s;  Mr = 1.25 dB en wr = 7.07;  w_BW = 12.7 rad/s
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

% [ini:receta]
G = zpk([], [0 -10], 100);
[~, PM, ~, wPM] = margin(G)                          % 51.83° en 7.86 rad/s
zeta = zetaDePM(PM)                                  % 0.50  (inversa de pmDeZeta)
wn   = wPM/sqrt(-2*zeta^2 + sqrt(1 + 4*zeta^4))      % 10
OS   = 100*exp(-zeta*pi/sqrt(1 - zeta^2))            % 16.3 %
tp   = pi/(wn*sqrt(1 - zeta^2))                      % 0.363 s
ts   = 4/(zeta*wn)                                   % 0.8 s (criterio del 2 %)
stepinfo(feedback(G, 1))                             % comprobación
% [fin:receta]

% Curva PM(zeta) y la aproximación PM ~ 100 zeta
z = linspace(0.01, 1, 300);
fig = estiloFigura(900, 520);  plot(z, pmDeZeta(z), z, 100*z, '--');  grid on;  ylim([0 90]);
xlabel('$\zeta$');  ylabel('PM ($^\circ$)');  legend('exacto', '$100\zeta$', 'Location', 'northwest');
exportgraphics(fig, 'C3_PM_zeta.png', 'Resolution', 200);

%% Pico de resonancia y ancho de banda del LAZO CERRADO
% [ini:resonancia]
T    = feedback(G, 1);
MrdB = 20*log10(1/(2*zeta*sqrt(1-zeta^2)))           % 1.25 dB  (pico de resonancia Mr)
wr   = wn*sqrt(1 - 2*zeta^2)                         % 7.07 rad/s
wBW  = wn*sqrt((1-2*zeta^2) + sqrt(4*zeta^4 - 4*zeta^2 + 2))   % 12.7 rad/s
bandwidth(T)                                         % comprobación
% [fin:resonancia]
