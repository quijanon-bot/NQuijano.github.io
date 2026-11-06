%% crearModelo_IMC -- Construye "LazoIMC.slx" (sección 8.6)
% Estructura de control por modelo interno: Q(s) = (5s+1)/(2(lambda s+1)), proceso
% real 1.5(1-s)/((s+1)(4s+1)) y modelo nominal 2/(5s+1) (ejemplo de Bequette).
% La realimentación lleva solo la diferencia entre la planta y el modelo.
% Referencia escalón en t = 1 y perturbación escalón de 0.5 a la salida en t = 25.
% USO   1) ejecute este script;  2) sim('LazoIMC');  3) mire el Scope.
%       Cambie lambda en el espacio de trabajo (0.85, 1.5, 3) y vuelva a simular:
%       por debajo de 0.887 el lazo es inestable.
clear; clc;
lambda = 1.5;  assignin('base', 'lambda', lambda);
mdl = 'LazoIMC';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
b = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
l = @(a, c) add_line(mdl, a, c, 'autorouting', 'on');
b('simulink/Sources/Step', 'r', 'Time', '1', 'Position', [20 60 50 90]);
b('simulink/Math Operations/Sum', 'e', 'Inputs', '+-', 'Position', [90 65 110 85]);
b('simulink/Continuous/Transfer Fcn', 'Q', 'Numerator', '[5 1]', 'Denominator', '[2*lambda 2]', 'Position', [150 55 230 95]);
b('simulink/Continuous/Transfer Fcn', 'Gp', 'Numerator', '1.5*[-1 1]', 'Denominator', 'conv([1 1],[4 1])', 'Position', [290 55 380 95]);
b('simulink/Continuous/Transfer Fcn', 'Gm', 'Numerator', '2', 'Denominator', '[5 1]', 'Position', [290 145 380 185]);
b('simulink/Sources/Step', 'd', 'Time', '25', 'After', '0.5', 'Position', [400 0 430 30]);
b('simulink/Math Operations/Sum', 'yd', 'Inputs', '++', 'Position', [440 65 460 85]);
b('simulink/Math Operations/Sum', 'dif', 'Inputs', '+-', 'Position', [440 155 460 175]);
b('simulink/Sinks/Scope', 'Scope', 'NumInputPorts', '2', 'Position', [540 60 570 110]);
l('r/1', 'e/1');  l('e/1', 'Q/1');  l('Q/1', 'Gp/1');  l('Q/1', 'Gm/1');
l('Gp/1', 'yd/1');  l('d/1', 'yd/2');  l('yd/1', 'dif/1');  l('Gm/1', 'dif/2');
l('dif/1', 'e/2');  l('yd/1', 'Scope/1');  l('Q/1', 'Scope/2');
set_param(mdl, 'StopTime', '50');
save_system(mdl);
