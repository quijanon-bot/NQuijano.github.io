%% C2_Ej1_Senales -- Notas: sección 2.1 (señales y sistemas)
% QUÉ HACE   Dibuja la señal T(t) = 20 - 3e^{-0.15t} y evalúa el sistema
%            ESTÁTICO de conversión de Fahrenheit a Celsius, numérica y
%            simbólicamente.
% OBSERVE    El sistema estático responde "al instante": y(t) solo depende de
%            u(t) en ese mismo instante. La señal T(t), en cambio, es la
%            salida de un sistema DINÁMICO (una ODE): depende de su historia.
% ESPERADO   T(0) = 17, T(60) ≈ 20;  90 °F -> 32.22 °C,  212 °F -> 100 °C
% EXPLORE    ¿Qué ODE de primer orden tiene a T(t) como solución? (pista: la
%            de la figura del bombillo, con V = 3 y T(0) = 17).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:senal]
t = 0:0.1:60;                    % vector de tiempo (s)
T = 20 - 3*exp(-0.15*t);         % la señal: un número por cada instante
fprintf('T(0) = %.2f, T(60) = %.2f\n', T(1), T(end));
% [fin:senal]
fig = estiloFigura(900, 420);
plot(t, T); grid on; xlabel('$t$ (s)'); ylabel('$T(t)$ ($^\circ$C)');
title('$T(t)=20-3e^{-0.15t}$');

% [ini:fc]
u = -5:0.5:100;                  % temperaturas de entrada en °F
y = 5/9*(u - 32);                % el sistema estático: y = (5/9)(u - 32)
fprintf('90 F = %.2f C\n', 5/9*(90 - 32));
% La misma transformación, simbólica (requiere Symbolic Math Toolbox):
syms uF
yC = 5/9*(uF - 32);
subs(yC, uF, 212)                % -> 100
% [fin:fc]
figure; plot(u, y); grid on; xlabel('$u$ ($^\circ$F)'); ylabel('$y$ ($^\circ$C)');
