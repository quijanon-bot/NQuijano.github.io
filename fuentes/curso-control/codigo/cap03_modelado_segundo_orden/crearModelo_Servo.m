%% crearModelo_Servo -- Construye "Servo.slx" (sección 3.7)
% Servo de posición K/s · 1/(s+1) con retroalimentación de posición y de
% velocidad (tacómetro, ganancia Kh). Sirve para comprobar el diseño de K y
% Kh y para ver qué hace cada uno por separado.
% La planta se arma como K -> 1/(s+1) -> 1/s (en SISO el orden de los
% bloques en serie no importa): así la VELOCIDAD v = sY queda disponible a la
% salida del motor y el tacómetro no necesita un bloque derivador.
% e = r - y - Kh v = r - (1 + Kh s) Y, igual que en la figura de las notas.
% USO   1) ejecute este script;  2) cambie K y Kh;  3) sim('Servo').
clear; clc;
OS = 0.2;  tp = 1;
zeta = -log(OS)/sqrt(pi^2 + log(OS)^2);  wn = pi/(tp*sqrt(1 - zeta^2));
K = wn^2;  Kh = (2*zeta*wn - 1)/K;
assignin('base', 'K', K);  assignin('base', 'Kh', Kh);

mdl = 'Servo';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
b = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
b('simulink/Sources/Step', 'r', 'Time', '0', 'Position', [20 60 50 90]);
b('simulink/Math Operations/Sum', 'e', 'Inputs', '+--', 'Position', [90 65 110 85]);
b('simulink/Math Operations/Gain', 'K', 'Gain', 'K', 'Position', [140 60 180 90]);
b('simulink/Continuous/Transfer Fcn', 'motor', 'Numerator', '1', 'Denominator', '[1 1]', 'Position', [210 55 270 95]);
b('simulink/Continuous/Integrator', 'posicion', 'Position', [310 60 340 90]);
b('simulink/Math Operations/Gain', 'Kh', 'Gain', 'Kh', 'Position', [210 140 250 170]);
b('simulink/Sinks/Scope', 'y', 'Position', [390 60 420 90]);
l = @(a, c) add_line(mdl, a, c, 'autorouting', 'on');
l('r/1', 'e/1');  l('e/1', 'K/1');  l('K/1', 'motor/1');  l('motor/1', 'posicion/1');
l('posicion/1', 'y/1');  l('posicion/1', 'e/2');  l('motor/1', 'Kh/1');  l('Kh/1', 'e/3');
set_param(mdl, 'StopTime', '5');
save_system(mdl);
fprintf('Modelo %s.slx creado (K = %.2f, Kh = %.3f). Ejecute sim(''%s'').\n', mdl, K, Kh, mdl);
