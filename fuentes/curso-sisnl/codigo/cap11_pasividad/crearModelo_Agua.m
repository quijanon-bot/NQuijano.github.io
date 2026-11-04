%% crearModelo_Agua -- Construye "AguaReplicador.slx" (sección 11.10)
% Tres tanques con descarga de Torricelli y reparto del caudal Q por la
% dinámica del replicador (modeloAgua.m, el MISMO modelo de C11_Ej13).
% Un escalón sube la demanda del tanque 3 (c3: 1.4 -> 2.0) en t = 40 s.
% La función V = V1 + V2 (energiaAguaSL.m) se calcula en línea respecto al
% equilibrio vigente: debe decrecer, saltar en t = 40 s y volver a decrecer.
% USO   1) ejecute el script (crea, simula y compara con ode45);
%       2) en los Scopes, observe que sum q_i = Q todo el tiempo;
%       3) cambie la condición inicial a q3(0) = 0 (x0(6) = 0) y explique (trampa de las caras).
clear; clc;
Q = 2;  r = 2;  vm = 2;  c12 = [0.6; 1.0];
x0 = [0.1; 0.8; 0.3; 0.9; 0.6; 0.5];               % [v; q], sum q = Q
vars = {'Q', 'r', 'vm', 'c12', 'x0'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'AguaReplicador';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');
fcn = 'simulink/User-Defined Functions/Interpreted MATLAB Function';

blk('simulink/Sources/Constant', 'c1 c2', 'Value', 'c12', 'Position', [20 120 60 140]);
blk('simulink/Sources/Step', 'c3', 'Time', '40', 'Before', '1.4', 'After', '2.0', 'Position', [20 170 50 200]);
blk('simulink/Signal Routing/Mux', 'mux [x; c]', 'Inputs', '3', 'Position', [120 60 125 210]);
blk(fcn, 'tanques + replicador', 'MATLABFcn', 'modeloAgua(u(1:6), u(7:9), Q, r, vm)', ...
    'OutputDimensions', '6', 'Position', [160 115 300 155]);
blk('simulink/Continuous/Integrator', 'x = [v; q]', 'InitialCondition', 'x0', 'Position', [340 120 380 150]);
blk('simulink/Signal Routing/Demux', 'demux', 'Outputs', '[3 3]', 'Position', [430 110 435 160]);
blk('simulink/Sinks/Scope', 'volumenes v', 'Position', [480 90 510 120]);
blk('simulink/Sinks/Scope', 'caudales q', 'Position', [480 150 510 180]);
blk('simulink/Math Operations/Sum of Elements', 'sum q', 'Position', [480 210 510 240]);
blk('simulink/Sinks/Display', 'sum q = Q', 'Position', [540 210 620 240]);
blk(fcn, 'V = V1 + V2', 'MATLABFcn', 'energiaAguaSL(u, Q, r, vm)', 'OutputDimensions', '1', ...
    'Position', [160 260 300 290]);
blk('simulink/Sinks/Scope', 'V', 'Position', [340 260 370 290]);
blk('simulink/Sinks/To Workspace', 'x a workspace', 'VariableName', 'Xsim', 'SaveFormat', 'Array', 'Position', [430 30 500 50]);
blk('simulink/Sinks/To Workspace', 'V a workspace', 'VariableName', 'Vsim', 'SaveFormat', 'Array', 'Position', [340 320 410 340]);

lin('x = [v; q]/1', 'mux [x; c]/1');  lin('c1 c2/1', 'mux [x; c]/2');  lin('c3/1', 'mux [x; c]/3');
lin('mux [x; c]/1', 'tanques + replicador/1');  lin('tanques + replicador/1', 'x = [v; q]/1');
lin('x = [v; q]/1', 'demux/1');  lin('demux/1', 'volumenes v/1');  lin('demux/2', 'caudales q/1');
lin('demux/2', 'sum q/1');  lin('sum q/1', 'sum q = Q/1');
lin('mux [x; c]/1', 'V = V1 + V2/1');  lin('V = V1 + V2/1', 'V/1');  lin('V = V1 + V2/1', 'V a workspace/1');
lin('x = [v; q]/1', 'x a workspace/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '80', 'Solver', 'ode45', 'RelTol', '1e-8', 'AbsTol', '1e-10', 'MaxStep', '0.05');
save_system(mdl);
fprintf('Modelo %s.slx creado. Simulando...\n', mdl);

salida = sim(mdl);
tS = salida.tout;  XS = salida.get('Xsim');  VS = salida.get('Vsim');
fprintf('Simulink: v(80) = %s   q(80) = %s\n', mat2str(XS(end,1:3), 4), mat2str(XS(end,4:6), 4));
fprintf('esperado: v* = %.4f   q* = %s\n', 4/12.96, mat2str([0.6 1 2]*2/3.6, 4));
fprintf('max |sum q - Q| = %.1e;  ¿V no creciente antes de t = 40? %d\n', ...
        max(abs(sum(XS(:,4:6), 2) - Q)), all(diff(VS(tS < 40)) <= 1e-8));
