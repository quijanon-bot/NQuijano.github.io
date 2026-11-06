%% C8_Ej2_MallaAbierta -- Notas: sección 8.3 (reglas de malla abierta)
% QUÉ HACE   Sintoniza un PID ideal para Kp e^{-Ls}/(tau s+1), Kp = 2, L = 2, tau = 10,
%            con Ziegler-Nichols, Cohen-Coon y el coeficiente de ajustabilidad, y
%            simula referencia y perturbación a la entrada (estructura PI-D, c = 0).
% OBSERVE    ZN y CC son rápidas pero muy oscilatorias; la de ajustabilidad casi no
%            sobrepasa, pero rechaza la perturbación con más lentitud.
% ESPERADO   ZN 3/4/1: OS 64 %.  CC 3.46/4.55/0.70: OS 84 %.  Ajust. 1.375/11/0.91:
%            OS 2 %; pico ante perturbación 0.38 / 0.39 / 0.48.
% EXPLORE    Cambie L a 4 y a 1 (r_c = 0.4 y 0.1) y repita la comparación.
clear; close all; clc;
if ~exist('reglasPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:reglas]
Kp = 2;  L = 2;  tau = 10;
[K1, T1, D1] = reglasPID('ZN', 'PID', Kp, L, tau);
[K2, T2, D2] = reglasPID('CC', 'PID', Kp, L, tau);
[K3, T3, D3] = reglasPID('ajust', '', Kp, L, tau);
tabla = [K1 T1 D1; K2 T2 D2; K3 T3 D3]           % filas: ZN, CC, ajustabilidad
% [fin:reglas]

% [ini:simulacion]
s = tf('s');  G = Kp/(tau*s + 1);
op = {'tf', 60, 'dt', 0.005, 'L', L, 'N', 10, 'c', 0};
subplot(1,2,1); hold on; subplot(1,2,2); hold on;
for k = 1:3
    [t, y] = simularPID(G, tabla(k,1), tabla(k,2), tabla(k,3), op{:});
    [~, yd] = simularPID(G, tabla(k,1), tabla(k,2), tabla(k,3), op{:}, 'r', 0, 'd', 1);
    subplot(1,2,1); plot(t, y);  subplot(1,2,2); plot(t, yd);
    fprintf('%d: OS = %5.1f %%   pico perturbación = %.3f\n', k, 100*(max(y) - 1), max(yd));
end
subplot(1,2,1); grid on; title('referencia'); legend('ZN', 'CC', 'ajustabilidad');
subplot(1,2,2); grid on; title('perturbación a la entrada');
% [fin:simulacion]
