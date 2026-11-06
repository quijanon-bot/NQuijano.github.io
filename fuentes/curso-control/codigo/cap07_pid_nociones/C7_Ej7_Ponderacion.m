%% C7_Ej7_Ponderacion -- Notas: sección 7.6 (ponderación de la referencia)
% QUÉ HACE   PI agresivo (Kc=20, Ti=0.3) sobre 1/((s+1)(s+5)), sintonizado para
%            rechazar perturbaciones. Varía beta (peso de la referencia en P).
% OBSERVE    beta cambia la respuesta a la referencia, pero NO la respuesta a la
%            perturbación: dos grados de libertad.
% ESPERADO   OS = 51 % (beta=1), 33 % (0.5), 29 % (0.3), 27 % (0).
%            Perturbación: pico 0.032, igual para todo beta.
% EXPLORE    ¿Por qué el sobrepico no baja de ~27 % ni con beta = 0? (mire los
%            polos del lazo cerrado).
clear; close all; clc;
if ~exist('simularPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:beta]
s = tf('s');  Gp = 1/((s + 1)*(s + 5));
for beta = [1 0.5 0.3 0]
    [t, y] = simularPID(Gp, 20, 0.3, 0, 'tf', 6, 'dt', 1e-3, 'b', beta);
    fprintf('beta = %.1f: OS = %.1f %%\n', beta, 100*(max(y) - 1));
    plot(t, y); hold on;
end
grid on; legend('\beta = 1', '0.5', '0.3', '0');
[t, yd] = simularPID(Gp, 20, 0.3, 0, 'tf', 6, 'dt', 1e-3, 'r', 0, 'd', 1);
max(yd)                                   % la misma para cualquier beta
% [fin:beta]
