%% crearModelo_Perturbacion -- Construye "LazoPerturbacion.slx" (sección 6.5)
% Lazo con retroalimentación unitaria, controlador PI (Kc + Ki/s) y proceso
% 1/((s+1)(s+2)). La referencia es nula y en t = 5 s entra una perturbación
% escalón de 0.5. Con alEntrada = 1 entra a la entrada del proceso; con
% alEntrada = 0, a su salida.
% USO   1) ejecute este script;  2) sim('LazoPerturbacion');  3) mire el Scope.
%       Ki = 0 da un controlador proporcional: el error no se anula.
clear; clc;
Kc = 10;  Ki = 18;  alEntrada = 1;
assignin('base', 'Kc', Kc);  assignin('base', 'Ki', Ki);  assignin('base', 'alEntrada', alEntrada);
mdl = 'LazoPerturbacion';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
a = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
l = @(o, d) add_line(mdl, o, d, 'autorouting', 'on');
a('simulink/Sources/Constant', 'r', 'Value', '0', 'Position', [20 60 50 90]);
a('simulink/Math Operations/Sum', 'e', 'Inputs', '+-', 'Position', [90 65 110 85]);
a('simulink/Continuous/Transfer Fcn', 'Gc', 'Numerator', '[Kc Ki]', 'Denominator', '[1 0]', 'Position', [150 55 220 95]);
a('simulink/Sources/Step', 'd', 'Time', '5', 'After', '0.5', 'Position', [150 150 180 180]);
a('simulink/Math Operations/Gain', 'entrada', 'Gain', 'alEntrada', 'Position', [220 150 250 180]);
a('simulink/Math Operations/Gain', 'salida', 'Gain', '1 - alEntrada', 'Position', [340 150 370 180]);
a('simulink/Math Operations/Sum', 'du', 'Inputs', '++', 'Position', [260 65 280 85]);
a('simulink/Continuous/Transfer Fcn', 'Gp', 'Numerator', '1', 'Denominator', '[1 3 2]', 'Position', [310 55 380 95]);
a('simulink/Math Operations/Sum', 'dy', 'Inputs', '++', 'Position', [410 65 430 85]);
a('simulink/Sinks/Scope', 'Scope', 'Position', [480 60 510 90]);
l('r/1', 'e/1');  l('e/1', 'Gc/1');  l('Gc/1', 'du/1');  l('du/1', 'Gp/1');  l('Gp/1', 'dy/1');
l('d/1', 'entrada/1');  l('entrada/1', 'du/2');  l('d/1', 'salida/1');  l('salida/1', 'dy/2');
l('dy/1', 'e/2');  l('dy/1', 'Scope/1');
set_param(mdl, 'StopTime', '20');
save_system(mdl);
