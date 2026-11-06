%% C6_Ej2_NoUnitaria -- Notas: sección 6.4 (retroalimentación no unitaria)
% QUÉ HACE   Con G = 100/(s+1) y H = 1/(s+5), compara el error de actuación
%            (r - Hy, de la malla abierta GH) con el de seguimiento (r - y, del
%            lazo abierto G_OL = G/(1 + GH - G)).
% OBSERVE    La malla abierta promete un error de 0.048; la salida termina en 4.76.
% ESPERADO   kp de GH = 20, e_a = 1/21. G_OL = 100(s+5)/(s^2 - 94s - 395),
%            kp = -1.266, e = 1 - 100/21 = -3.762. Con H = 4.95/(s+5), e = 0.
% EXPLORE    ¿Qué H constante daría error de seguimiento nulo?
clear; close all; clc;
if ~exist('constantesError', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
s = tf('s');

% [ini:lazoabierto]
G = 100/(s+1);  H = 1/(s+5);
T = feedback(G, H);  pole(T)                    % estable: -3 +- 9.8j
ea = 1/(1 + dcgain(G*H))                        % error de actuación: 0.0476
Gol = minreal(G/(1 + G*H - G))                  % lazo abierto: polo en +98
e = 1/(1 + dcgain(Gol))                         % error de seguimiento: -3.762
1 - dcgain(T)                                   % lo mismo, directamente
% [fin:lazoabierto]

% [ini:simulacion]
t = 0:0.001:3;
y = step(T, t);  yH = step(T*H, t);
plot(t, ones(size(t)), '--', t, y, t, 1 - yH, t, 1 - y); grid on;
legend('r', 'y', 'e_a = r - Hy', 'e = r - y');
k = fzero(@(k) dcgain(feedback(G, k/(s+5))) - 1, 5)   % sensor recalibrado: 4.95
% [fin:simulacion]
