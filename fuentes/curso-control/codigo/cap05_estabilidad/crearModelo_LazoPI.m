%% crearModelo_LazoPI -- Construye "LazoPI.slx" (sección 5.5)
% Lazo con controlador PI en forma paralela, Gc = Kc + Ki/s, y planta
% 2/(s^3 + 4s^2 + 5s + 2) con retroalimentación unitaria. Sirve para
% recorrer la región de estabilidad del plano (Kc, Ki).
% USO   1) ejecute este script;  2) cambie Kc y Ki en el espacio de trabajo;
%       3) sim('LazoPI').  Pruebe (5, 1), (5, 3) y (5, 4).
clear; clc;
Kc = 5;  Ki = 1;
assignin('base', 'Kc', Kc);  assignin('base', 'Ki', Ki);
mdl = 'LazoPI';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
b = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
b('simulink/Sources/Step', 'r', 'Time', '0', 'Position', [20 80 50 110]);
b('simulink/Math Operations/Sum', 'e', 'Inputs', '+-', 'Position', [90 85 110 105]);
b('simulink/Math Operations/Gain', 'Kc', 'Gain', 'Kc', 'Position', [160 110 200 140]);
b('simulink/Math Operations/Gain', 'Ki', 'Gain', 'Ki', 'Position', [160 40 200 70]);
b('simulink/Continuous/Integrator', 'int', 'Position', [230 40 260 70]);
b('simulink/Math Operations/Sum', 'u', 'Inputs', '++', 'Position', [300 85 320 105]);
b('simulink/Continuous/Transfer Fcn', 'Gp', 'Numerator', '2', 'Denominator', '[1 4 5 2]', 'Position', [360 75 440 115]);
b('simulink/Sinks/Scope', 'y', 'Position', [490 80 520 110]);
l = @(a, c) add_line(mdl, a, c, 'autorouting', 'on');
l('r/1', 'e/1');  l('e/1', 'Kc/1');  l('e/1', 'Ki/1');  l('Ki/1', 'int/1');
l('int/1', 'u/1');  l('Kc/1', 'u/2');  l('u/1', 'Gp/1');  l('Gp/1', 'y/1');  l('Gp/1', 'e/2');
set_param(mdl, 'StopTime', '40');
save_system(mdl);
fprintf('Modelo %s.slx creado (Kc = %g, Ki = %g). Ejecute sim(''%s'').\n', mdl, Kc, Ki, mdl);
