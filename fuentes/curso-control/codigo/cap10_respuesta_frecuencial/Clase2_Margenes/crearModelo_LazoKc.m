%% crearModelo_LazoKc -- Construye "LazoKc.slx" (sección 10.7)
% Escalón -> suma -> Kc -> Gp(s) -> Scope, retroalimentación unitaria.
% Pruebe Kc = 1000, 50 000, 122 210 (marginal) y 150 000 (inestable).
% Para otra planta cambie 'Poles' del bloque Gp (p. ej. [0 -5 -50]).
clear; clc;
mdl = 'LazoKc';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
add_block('simulink/Sources/Step', [mdl '/r'], 'Time', '0', 'Position', [30 80 60 110]);
add_block('simulink/Math Operations/Sum', [mdl '/Suma'], 'Inputs', '|+-', 'Position', [110 85 130 105]);
add_block('simulink/Math Operations/Gain', [mdl '/Kc'], 'Gain', 'Kc', 'Position', [170 80 220 110]);
add_block('simulink/Continuous/Zero-Pole', [mdl '/Gp'], 'Zeros', '[]', 'Poles', '[-1 -10 -100]', 'Gain', '1', 'Position', [260 75 360 115]);
add_block('simulink/Sinks/Scope', [mdl '/Scope'], 'Position', [430 80 460 110]);
add_line(mdl, 'r/1', 'Suma/1');  add_line(mdl, 'Suma/1', 'Kc/1');  add_line(mdl, 'Kc/1', 'Gp/1');
add_line(mdl, 'Gp/1', 'Scope/1');  add_line(mdl, 'Gp/1', 'Suma/2', 'autorouting', 'on');
set_param(mdl, 'StopTime', '2');
assignin('base', 'Kc', 1000);
save_system(mdl);
fprintf('Modelo %s.slx creado. Cambie Kc en el workspace y simule.\n', mdl);
