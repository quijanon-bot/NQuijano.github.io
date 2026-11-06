%% C6_Ej6_Sensibilidad -- Notas: sección 6.1 (sensitividad y error)
% QUÉ HACE   Con Gp = 1/((s+1)(s+10)) y Gc = K (10 y 200), tabula |S| y |T| y
%            calcula cuánto aportan al error una perturbación lenta y un ruido rápido.
% OBSERVE    S + T = 1: donde una es pequeña, la otra es casi 1.
% ESPERADO   K = 200: perturbación 0.0024, ruido 0.00085; K = 10: 0.0249 y 0.00004.
%            K = 10 es mejor si la amplitud del ruido supera 0.28.
% EXPLORE    Agregue un filtro 1/(0.02s+1) al sensor y repita.
clear; close all; clc;
if ~exist('constantesError', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
s = tf('s');  Gp = 1/((s+1)*(s+10));

% [ini:tabla]
w = [0.1 1 10 100];
for K = [10 200]
    L = K*Gp;  S = 1/(1 + L);  T = L/(1 + L);
    fprintf('K = %3d  |S| = %s\n         |T| = %s\n', K, ...
        mat2str(abs(squeeze(freqresp(S, w))).', 3), mat2str(abs(squeeze(freqresp(T, w))).', 3));
end
% [fin:tabla]

% [ini:aportes]
for K = [10 200]
    L = K*Gp;  S = 1/(1 + L);  T = L/(1 + L);
    ed = 0.5*abs(freqresp(S*Gp, 0.2));          % d = 0.5 sin(0.2 t)
    en = 0.01*abs(freqresp(T, 50));             % n = 0.01 sin(50 t)
    fprintf('K = %3d: perturbación %.5f   ruido %.5f\n', K, ed, en);
end
bodemag(1/(1 + 10*Gp), 10*Gp/(1 + 10*Gp), 1/(1 + 200*Gp), 200*Gp/(1 + 200*Gp)); grid on;
legend('S, K=10', 'T, K=10', 'S, K=200', 'T, K=200');
% [fin:aportes]
