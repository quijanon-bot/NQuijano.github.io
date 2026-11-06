%% crearModelo_TanqueLazos -- Construye "TanqueLazos.slx" (sección 1.2)
% El mismo tanque  Area dh/dt = u + d - h/R  en dos ramas:
%   (1) lazo abierto: u = Calibracion * hr   (usted ajusta Calibracion a mano)
%   (2) lazo cerrado: u = hr/Kn + Kc (hr - h)
% La lluvia es un escalón de 0.2 m^3/min en t = 5 min, multiplicado por la
% ganancia 'Lluvia' (0 = apagada, 1 = encendida).  Un Scope muestra hr y
% los dos niveles.  El modelo se CONSTRUYE por código (no se versiona el .slx).
% ACTIVIDAD  1) Con Lluvia = 0, ajuste Calibracion hasta que el nivel llegue
%            a 1 (respuesta: 1/K = 0.5).  2) Ponga Lluvia = 1 e intente
%            mantener el nivel cambiando Calibracion. ¿Pudo?  3) Compare con
%            la rama retroalimentada.  4) Cambie R a 2.4 (válvula obstruida).
clear; clc;
mdl = 'TanqueLazos';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);

% Fuentes
add_block('simulink/Sources/Step', [mdl '/Referencia'], 'Time', '1', 'Before', '0', ...
    'After', '1', 'Position', [30 100 60 130]);
add_block('simulink/Sources/Step', [mdl '/Escalon lluvia'], 'Time', '5', 'Before', '0', ...
    'After', '0.2', 'Position', [30 20 60 50]);
add_block('simulink/Math Operations/Gain', [mdl '/Lluvia'], 'Gain', '0', 'Position', [90 20 120 50]);
% Rama 1: lazo abierto
add_block('simulink/Math Operations/Gain', [mdl '/Calibracion'], 'Gain', '0.3', 'Position', [120 100 160 130]);
add_block('simulink/Math Operations/Sum', [mdl '/SumaA'], 'Inputs', '++', 'Position', [200 100 220 130]);
add_block('simulink/Continuous/Transfer Fcn', [mdl '/Tanque abierto'], ...
    'Numerator', 'R', 'Denominator', '[Area*R 1]', 'Position', [250 95 330 135]);
% Rama 2: lazo cerrado
add_block('simulink/Math Operations/Sum', [mdl '/Error'], 'Inputs', '+-', 'Position', [120 200 140 220]);
add_block('simulink/Math Operations/Gain', [mdl '/Kc'], 'Gain', 'Kc', 'Position', [160 195 200 225]);
add_block('simulink/Math Operations/Gain', [mdl '/Prealim'], 'Gain', '1/Kn', 'Position', [160 250 200 280]);
add_block('simulink/Math Operations/Sum', [mdl '/SumaU'], 'Inputs', '++', 'Position', [230 200 250 230]);
add_block('simulink/Math Operations/Sum', [mdl '/SumaC'], 'Inputs', '++', 'Position', [280 200 300 230]);
add_block('simulink/Continuous/Transfer Fcn', [mdl '/Tanque cerrado'], ...
    'Numerator', 'R', 'Denominator', '[Area*R 1]', 'Position', [330 195 410 235]);
% Salidas
add_block('simulink/Signal Routing/Mux', [mdl '/Mux'], 'Inputs', '3', 'Position', [470 90 475 240]);
add_block('simulink/Sinks/Scope', [mdl '/Niveles'], 'Position', [510 150 540 180]);

add_line(mdl, 'Escalon lluvia/1', 'Lluvia/1');
add_line(mdl, 'Referencia/1', 'Calibracion/1');
add_line(mdl, 'Calibracion/1', 'SumaA/1');
add_line(mdl, 'Lluvia/1', 'SumaA/2', 'autorouting', 'on');
add_line(mdl, 'SumaA/1', 'Tanque abierto/1');
add_line(mdl, 'Referencia/1', 'Error/1', 'autorouting', 'on');
add_line(mdl, 'Error/1', 'Kc/1');
add_line(mdl, 'Referencia/1', 'Prealim/1', 'autorouting', 'on');
add_line(mdl, 'Kc/1', 'SumaU/1');
add_line(mdl, 'Prealim/1', 'SumaU/2', 'autorouting', 'on');
add_line(mdl, 'SumaU/1', 'SumaC/1');
add_line(mdl, 'Lluvia/1', 'SumaC/2', 'autorouting', 'on');
add_line(mdl, 'SumaC/1', 'Tanque cerrado/1');
add_line(mdl, 'Tanque cerrado/1', 'Error/2', 'autorouting', 'on');
add_line(mdl, 'Referencia/1', 'Mux/1', 'autorouting', 'on');
add_line(mdl, 'Tanque abierto/1', 'Mux/2', 'autorouting', 'on');
add_line(mdl, 'Tanque cerrado/1', 'Mux/3', 'autorouting', 'on');
add_line(mdl, 'Mux/1', 'Niveles/1');
set_param(mdl, 'StopTime', '10');

% Parámetros (en el workspace base)
assignin('base', 'Area', 0.5);  assignin('base', 'R', 2);
assignin('base', 'Kn', 2);      assignin('base', 'Kc', 5);
save_system(mdl);
fprintf('Modelo %s.slx creado. Ajuste "Calibracion", luego ponga "Lluvia" = 1 y ejecute sim(''%s'').\n', mdl, mdl);
