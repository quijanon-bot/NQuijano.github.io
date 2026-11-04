%% crearModelo_Termico -- Construye "Termico.slx" (secciones 2.7 y 2.8)
% Escalón (o rampa) en la temperatura de entrada -> 1/(tau s + 1) en
% variables DESVIACIÓN -> se le suma el equilibrio T* para ver la temperatura
% física. Un Scope muestra Ti y T; otro, las desviaciones.
% El modelo se CONSTRUYE por código: así no hay que versionar un .slx binario.
% USO   1) ejecute este script;  2) cambie tau, M o Teq en el workspace;
%       3) sim('Termico').  Cambie el interruptor 'Entrada' para usar la rampa.
% ACTIVIDAD (problema 2.x): identifique K1 y tau del proceso del problema de
%       identificación y verifique la respuesta a la rampa de 0.01 unidades/s.
clear; clc;
mdl = 'Termico';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);

add_block('simulink/Sources/Step', [mdl '/Escalon'], 'Time', '0', 'Before', '0', ...
    'After', 'M', 'Position', [30 40 60 70]);
add_block('simulink/Sources/Ramp', [mdl '/Rampa'], 'Slope', 'a', 'Start', '0', ...
    'Position', [30 110 60 140]);
add_block('simulink/Signal Routing/Manual Switch', [mdl '/Entrada'], 'Position', [100 70 130 110]);
add_block('simulink/Continuous/Transfer Fcn', [mdl '/Proceso'], ...
    'Numerator', 'K1', 'Denominator', '[tau 1]', 'Position', [190 70 270 110]);
add_block('simulink/Sources/Constant', [mdl '/Tieq'], 'Value', 'Teq', 'Position', [190 160 230 180]);
add_block('simulink/Math Operations/Sum', [mdl '/SumaTi'], 'Inputs', '++', 'Position', [300 140 320 160]);
add_block('simulink/Math Operations/Sum', [mdl '/SumaT'], 'Inputs', '++', 'Position', [300 80 320 100]);
add_block('simulink/Signal Routing/Mux', [mdl '/MuxF'], 'Inputs', '2', 'Position', [360 80 365 160]);
add_block('simulink/Signal Routing/Mux', [mdl '/MuxD'], 'Inputs', '2', 'Position', [360 10 365 60]);
add_block('simulink/Sinks/Scope', [mdl '/Fisicas'], 'Position', [400 105 430 135]);
add_block('simulink/Sinks/Scope', [mdl '/Desviaciones'], 'Position', [400 20 430 50]);

add_line(mdl, 'Escalon/1', 'Entrada/1');
add_line(mdl, 'Rampa/1', 'Entrada/2');
add_line(mdl, 'Entrada/1', 'Proceso/1');
add_line(mdl, 'Proceso/1', 'SumaT/1');
add_line(mdl, 'Tieq/1', 'SumaT/2', 'autorouting', 'on');
add_line(mdl, 'Entrada/1', 'SumaTi/1', 'autorouting', 'on');
add_line(mdl, 'Tieq/1', 'SumaTi/2', 'autorouting', 'on');
add_line(mdl, 'SumaTi/1', 'MuxF/1', 'autorouting', 'on');
add_line(mdl, 'SumaT/1', 'MuxF/2', 'autorouting', 'on');
add_line(mdl, 'MuxF/1', 'Fisicas/1');
add_line(mdl, 'Entrada/1', 'MuxD/1', 'autorouting', 'on');
add_line(mdl, 'Proceso/1', 'MuxD/2', 'autorouting', 'on');
set_param(mdl, 'StopTime', '40');

% Parámetros (en el workspace base)
assignin('base', 'K1', 1);   assignin('base', 'tau', 5);  assignin('base', 'M', 2);
assignin('base', 'a', 0.1);  assignin('base', 'Teq', 25);
save_system(mdl);
fprintf('Modelo %s.slx creado. Ejecute sim(''%s'') y abra los dos Scope.\n', mdl, mdl);
