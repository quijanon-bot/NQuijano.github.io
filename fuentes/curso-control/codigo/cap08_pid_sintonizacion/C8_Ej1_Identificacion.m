%% C8_Ej1_Identificacion -- Notas: sección 8.2 (identificación a partir de la respuesta escalón)
% QUÉ HACE   (a) Ganancia normalizada del ejemplo 30 °C / 20 %.  (b) Identifica un
%            modelo de primer orden con retardo a partir de los datos del ejercicio
%            (CO de 30 a 45 %, transmisor 50-150 °C) con el método de la tangente,
%            y compara tau(63 %) con tau(100 %, Ziegler-Nichols).
% OBSERVE    La tangente "de 100 %" da una constante de tiempo mayor que la del 63 %.
% ESPERADO   Kp = 2.5 en el ejemplo.  Datos: Kp = 1.19, L = 3.9 s, tau63 = 19.9 s,
%            tauZN = 22.4 s; el modelo L = 4, tau = 20 ajusta con ECM = 0.0019 °C^2.
% EXPLORE    Agregue ruido a los datos (randn*0.2) y observe cuánto se mueve L.
clear; close all; clc;
if ~exist('reglasPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:ganancia]
dy = 60 - 30;  rangoPV = 70 - 10;      % °C
du = 40 - 20;  rangoCO = 100;          % %
Kp = (dy/rangoPV)/(du/rangoCO)         % ganancia normalizada (adimensional): 2.5
% [fin:ganancia]

% [ini:tangente]
t = [0 2 4 6 8 10 15 20 24 30 40 50 60 100];
y = [80 80 80.1 81.7 83.3 84.6 87.7 89.9 91.4 93.1 95.0 96.2 96.9 97.9];
duN = 15/100;  yN = (y - 80)/100;                % señales en fracción de rango
[Kp, L, tau63, tauZN] = identificarFOPDT(t, yN, duN)
modelo = @(tt) 80 + 18*(1 - exp(-max(tt - 4, 0)/20));   % Kp = 1.2, L = 4, tau = 20
ECM = mean((modelo(t) - y).^2)
tt = linspace(0, 100, 1001);
plot(t, y, 'o', tt, modelo(tt)); grid on;
xlabel('t (s)'); ylabel('PV (°C)'); legend('datos', 'modelo L = 4, \tau = 20');
% [fin:tangente]
