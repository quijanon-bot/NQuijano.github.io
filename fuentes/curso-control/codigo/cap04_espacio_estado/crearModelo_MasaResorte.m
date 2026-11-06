%% crearModelo_MasaResorte -- Construye "MasaResorte.slx" (sección 4.3)
% La masa-resorte-amortiguador armada como en un computador analógico: dos
% integradores en cascada, una suma y dos ganancias. Los estados son las salidas
% de los integradores (posición y velocidad); sus condiciones iniciales van en
% los bloques Integrator. Entrada: pulso de 5 N durante 20 s.
% USO   1) ejecute este script;  2) sim('MasaResorte');  3) mire el Scope.
%       Cambie b en el espacio de trabajo (2, 4, 8, 16) y vuelva a simular.
clear; clc;
M = 2;  k = 16;  b = 2;
assignin('base', 'M', M); assignin('base', 'k', k); assignin('base', 'b', b);
mdl = 'MasaResorte';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
a = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
l = @(o, d) add_line(mdl, o, d, 'autorouting', 'on');
a('simulink/Sources/Pulse Generator', 'u', 'Amplitude', '5', 'Period', '40', 'PulseWidth', '50', 'Position', [20 60 50 90]);
a('simulink/Math Operations/Gain', '1/M', 'Gain', '1/M', 'Position', [90 60 120 90]);
a('simulink/Math Operations/Sum', 'suma', 'Inputs', '+--', 'Position', [160 55 180 95]);
a('simulink/Continuous/Integrator', 'int_x2', 'InitialCondition', '0', 'Position', [220 60 250 90]);
a('simulink/Continuous/Integrator', 'int_x1', 'InitialCondition', '0', 'Position', [310 60 340 90]);
a('simulink/Math Operations/Gain', 'b/M', 'Gain', 'b/M', 'Orientation', 'left', 'Position', [220 130 250 160]);
a('simulink/Math Operations/Gain', 'k/M', 'Gain', 'k/M', 'Orientation', 'left', 'Position', [220 190 250 220]);
a('simulink/Sinks/Scope', 'Scope', 'NumInputPorts', '2', 'Position', [420 55 450 105]);
l('u/1', '1/M/1');  l('1/M/1', 'suma/1');  l('suma/1', 'int_x2/1');  l('int_x2/1', 'int_x1/1');
l('int_x2/1', 'b/M/1');  l('int_x1/1', 'k/M/1');  l('b/M/1', 'suma/2');  l('k/M/1', 'suma/3');
l('int_x1/1', 'Scope/1');  l('int_x2/1', 'Scope/2');
set_param(mdl, 'StopTime', '40');
save_system(mdl);
