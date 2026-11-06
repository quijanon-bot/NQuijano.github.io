%% C1_Ej2_Ascensor -- Notas: sección 1.3 (desempeño)
% QUÉ HACE   Respuesta de un ascensor (modelo de segundo orden, valores
%            exagerados) al botón del piso 4, con sus medidas de desempeño.
% OBSERVE    La respuesta transitoria (sobrepaso, tiempo de establecimiento)
%            y el error en estado estacionario son cosas distintas: se
%            pueden mejorar por separado.
% ESPERADO   zeta = 0.6, wn = 0.8: sobrepaso 9.48 %, tp = 4.91 s,
%            ts (2 %) = 7.43 s, valor final 3.90 (error 0.1 piso).
% EXPLORE    zeta = 1 y zeta = 0.3 (problema 1.7). ¿Qué ascensor prefiere?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:ascensor]
zeta = 0.6;  wn = 0.8;  kg = 0.975;    % kg < 1 produce el error final
piso = 4;
T = piso*kg*tf(wn^2, [1 2*zeta*wn wn^2]);
S = stepinfo(T);   % criterio por defecto: 2 %
fprintf('Sobrepaso %.2f %%, tp = %.2f s, ts = %.2f s\n', S.Overshoot, S.PeakTime, S.SettlingTime);
fprintf('Valor final %.2f pisos -> error %.2f piso\n', dcgain(T), piso - dcgain(T));
% [fin:ascensor]

fig = estiloFigura(800, 400);
t = linspace(0, 14, 1400);
plot(t, piso*ones(size(t)), ':', t, step(T, t), 'LineWidth', 1.8); grid on;
xlabel('t (s)'); ylabel('piso'); legend('botón del piso 4', 'posición', 'Location', 'southeast');
