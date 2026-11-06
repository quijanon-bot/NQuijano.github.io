%% C8_Ej4_SintesisDirecta -- Notas: sección 8.5 (síntesis directa)
% QUÉ HACE   Aplica la ecuación de síntesis Gc = T/(Gp(1 - T)) a tres procesos:
%            2/(5s+1), 3/((2s+1)(10s+1)) y el de fase no mínima (1-9s)/((15s+1)(3s+1)).
% OBSERVE    lambda es la constante de tiempo deseada del lazo cerrado: más pequeña,
%            respuesta más rápida y acción de control más grande.
% ESPERADO   PI: Kc = 5/(2 lambda), Ti = 5.  PID: Kc = 4/lambda, Ti = 12, Td = 5/3;
%            ts = 3.9 / 12.1 / 19.8 s para lambda = 1 / 3 / 5.  Fase no mínima,
%            lambda = 5: Kc = 0.947, Ti = 18, Td = 2.5, tau_f = 1.316.
% EXPLORE    Pruebe T(s) = 1/(lambda s + 1) en el proceso de fase no mínima y mire
%            el polo del controlador.
clear; close all; clc;
if ~exist('reglasPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
s = tf('s');

% [ini:pi]
lambda = 2;  Gp = 2/(5*s + 1);  T = 1/(lambda*s + 1);
Gc = minreal(T/(Gp*(1 - T)))                      % (5s + 1)/(2 lambda s): PI, Ti = 5
% [fin:pi]

% [ini:pid]
Gp = 3/((2*s + 1)*(10*s + 1));
for lambda = [1 3 5]
    Kc = 4/lambda;  Ti = 12;  Td = 20/12;          % (2s+1)(10s+1)/(3 lambda s)
    [t, y, u] = simularPID(Gp, Kc, Ti, Td, 'tf', 40, 'dt', 1e-3, 'N', 10);
    ts = t(find(abs(y - 1) > 0.02, 1, 'last') + 1);       % tiempo de establecimiento (2 %)
    fprintf('lambda = %d: ts = %5.2f s   |u|max = %5.2f\n', lambda, ts, max(abs(u)));
end
% [fin:pid]

% [ini:nomin]
Gp = (1 - 9*s)/((15*s + 1)*(3*s + 1));  lambda = 5;
Gc1 = minreal((1/(lambda*s + 1))/(Gp*(1 - 1/(lambda*s + 1))));
pole(Gc1)                                         % polo en +1/9: no implementable
T = (1 - 9*s)/(lambda*s + 1)^2;
Gc = minreal(T/(Gp*(1 - T)))                      % (45s^2 + 18s + 1)/(s(lambda^2 s + 2 lambda + 9))
Kc = 18/(2*lambda + 9),  Ti = 18,  Td = 2.5,  tauf = lambda^2/(2*lambda + 9)
step(feedback(Gc*Gp, 1), 80); grid on;
% [fin:nomin]
