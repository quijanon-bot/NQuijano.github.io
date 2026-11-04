%% C2_Ej7_Termico -- Notas: sección 2.7 (proceso térmico)
% QUÉ HACE   Simula el tanque agitado tau dT/dt + T = T_i en variables
%            desviación y en variables físicas, ante un escalón de M grados.
% OBSERVE    La función de transferencia trabaja con DESVIACIONES: arranca en
%            cero. Para ver la temperatura real se suma el punto de equilibrio.
% ESPERADO   tau = 5 s, M = 2 °C, T* = 25 °C: T(5) = 26.26 °C, T(inf) = 27 °C
% EXPLORE    Duplique el caudal f: ¿qué le pasa a tau = V Cv/(f Cp)?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:termico]
tau = 5;  M = 2;  Teq = 25;            % s, °C, °C  (T* = Ti* = 25)
s = tf('s');
G = 1/(tau*s + 1);                     % That(s)/Tihat(s)
t = linspace(0, 40, 801);
eT  = M*step(G, t);                    % desviación: step es unitario -> por M
T   = Teq + eT;                        % variable física
fprintf('T(tau) = %.2f C  (63.2 %% del cambio)\n', interp1(t, T, tau));
% [fin:termico]
fig = estiloFigura(1100, 420);
subplot(1,2,1); plot(t, M*ones(size(t)), t, eT); grid on; ylim([-0.2 2.5]);
legend('$\hat T_i$', '$\hat T$', 'Location', 'southeast'); title('Variables desviaci\''on'); xlabel('$t$ (s)');
subplot(1,2,2); plot(t, Teq + M*ones(size(t)), t, T); grid on; ylim([24.8 27.5]);
legend('$T_i$', '$T$', 'Location', 'southeast'); title('Variables f\''isicas ($^\circ$C)'); xlabel('$t$ (s)');
exportgraphics(fig, 'C2_Ej7_termico.png', 'Resolution', 200);
