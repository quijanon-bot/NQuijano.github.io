%% crearModelo_Bioreactor -- Construye "Bioreactor.slx" (sección 4.7)
% Bioreactor con inhibición por sustrato, con dos entradas (tasa de dilución u1,
% sustrato de alimentación u2) y los dos estados como salidas. Sirve para
% simular el modelo no lineal y para linealizarlo con trim y linmod:
%   [X, ~, U] = trim('Bioreactor', [0.99; 1.5], [0.3; 4], [], [], [1; 2], [])
%   [A, B, C, D] = linmod('Bioreactor', X, [0.3; 4])
% USO   1) ejecute este script;  2) los comandos de arriba, o sim('Bioreactor').
clear; clc;
mdl = 'Bioreactor';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
a = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
l = @(o, d) add_line(mdl, o, d, 'autorouting', 'on');
a('simulink/Sources/In1', 'u1', 'Position', [20 40 50 55]);
a('simulink/Sources/In1', 'u2', 'Port', '2', 'Position', [20 90 50 105]);
a('simulink/Signal Routing/Mux', 'mux', 'Inputs', '4', 'Position', [120 30 125 150]);
a('simulink/User-Defined Functions/Fcn', 'f1', 'Expr', ...
  '(0.53*u(4)/(0.12+u(4)+0.4545*u(4)^2) - u(1))*u(3)', 'Position', [170 40 330 70]);
a('simulink/User-Defined Functions/Fcn', 'f2', 'Expr', ...
  'u(1)*(u(2)-u(4)) - 0.53*u(4)/(0.12+u(4)+0.4545*u(4)^2)*u(3)/0.4', 'Position', [170 110 330 140]);
a('simulink/Continuous/Integrator', 'x1', 'InitialCondition', '1', 'Position', [370 40 400 70]);
a('simulink/Continuous/Integrator', 'x2', 'InitialCondition', '1', 'Position', [370 110 400 140]);
a('simulink/Sinks/Out1', 'y1', 'Position', [460 48 490 62]);
a('simulink/Sinks/Out1', 'y2', 'Port', '2', 'Position', [460 118 490 132]);
l('u1/1', 'mux/1');  l('u2/1', 'mux/2');  l('x1/1', 'mux/3');  l('x2/1', 'mux/4');
l('mux/1', 'f1/1');  l('mux/1', 'f2/1');  l('f1/1', 'x1/1');  l('f2/1', 'x2/1');
l('x1/1', 'y1/1');  l('x2/1', 'y2/1');
set_param(mdl, 'StopTime', '100');
save_system(mdl);
