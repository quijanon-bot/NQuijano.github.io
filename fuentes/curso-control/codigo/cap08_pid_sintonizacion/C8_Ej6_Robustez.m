%% C8_Ej6_Robustez -- Notas: sección 8.7 (agresividad contra robustez)
% QUÉ HACE   Para Kp = 1.2, L = 4, tau = 20 compara ZN, CC, ajustabilidad e IMC
%            (lambda = 6.7): márgenes con el retardo exacto y fracción de plantas
%            estables en una malla Kp +-30 %, tau +-30 %, L +-50 % (5 x 5 x 5).
% OBSERVE    Las reglas más agresivas son también las más frágiles.
% ESPERADO   MG/MF: ZN 1.33/39°, CC 1.31/27°, ajust. 2.91/75°.
%            Estables: ZN 98/125, CC 90/125, ajust. 125/125, IMC 125/125.
% EXPLORE    Reduzca Kc de CC hasta que toda la malla sea estable (factor ~0.48).
clear; close all; clc;
if ~exist('reglasPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
s = tf('s');

% [ini:malla]
Kp = 1.2;  L = 4;  tau = 20;
P = zeros(4, 3);
[P(1,1), P(1,2), P(1,3)] = reglasPID('ZN', 'PID', Kp, L, tau);
[P(2,1), P(2,2), P(2,3)] = reglasPID('CC', 'PID', Kp, L, tau);
[P(3,1), P(3,2), P(3,3)] = reglasPID('ajust', '', Kp, L, tau);
P(4,:) = [22/(1.2*8.7), 22, 80/44];                         % IMC, lambda = 6.7
pid = @(p) p(1)*(1 + 1/(p(2)*s) + p(3)*s/(p(3)/10*s + 1));
v = linspace(-1, 1, 5);
for k = 1:4
    [MG, MF] = margin(pid(P(k,:))*Kp*exp(-L*s)/(tau*s + 1));
    n = 0;
    for a = v, for b = v, for c = v
        Gk = Kp*(1 + 0.3*a)*exp(-L*(1 + 0.5*c)*s)/(tau*(1 + 0.3*b)*s + 1);
        M = allmargin(pid(P(k,:))*Gk);
        n = n + M.Stable;                                   % ¿lazo cerrado estable?
    end, end, end
    fprintf('%d: MG = %.2f  MF = %4.1f°  estables %3d / 125\n', k, MG, MF, n);
end
% [fin:malla]
