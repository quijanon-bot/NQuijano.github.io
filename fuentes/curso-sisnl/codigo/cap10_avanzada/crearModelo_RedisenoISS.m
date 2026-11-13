%% crearModelo_RedisenoISS -- Construye "RedisenoISS.slx" (secciones 10.4 y 10.6)
% Lazo x' = x + (x^2 + 1)(u + w) con un selector entre tres leyes de control:
%   ley = 1: cancelación exacta       u = -2x/(x^2 + 1)
%   ley = 2: con amortiguamiento      u = -2x/(x^2 + 1) - x(x^2 + 1)      (- L_gV, V = x^2/2)
%   ley = 3: Sontag con kappa        u = leySontag(x^2, x(x^2 + 1), kappa)
% y un escalón de perturbación w (amplitud W en el instante Tw) en el actuador.
% Solo bloques básicos (sin toolboxes). La ley de Sontag va en un bloque MATLAB Fcn
% que llama a comun/leySontag.m (debe estar en el path).
% USO   1) ejecute el script: crea el modelo y lo simula con las tres leyes;
%       2) cambie W, Tw, kappa o x0 en el workspace y vuelva a simular.
%   OBSERVE: con W = 1 la cancelación escapa (la simulación se detiene cuando |x| > 1e3);
%   las otras dos leyes quedan acotadas.
clear; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('leySontag', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
W = 1;  Tw = 2;  kappa = 1;  x0 = 0.5;  ley = 1;
vars = {'W', 'Tw', 'kappa', 'x0', 'ley'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'RedisenoISS';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');

blk('simulink/Continuous/Integrator', 'x', 'InitialCondition', 'x0', 'Position', [520 100 550 130]);
blk('simulink/User-Defined Functions/Fcn', 'cancelacion', 'Expr', '-2*u/(u^2 + 1)', 'Position', [100 20 220 50]);
blk('simulink/User-Defined Functions/Fcn', 'amortiguada', 'Expr', '-2*u/(u^2 + 1) - u*(u^2 + 1)', 'Position', [100 80 220 110]);
blk('simulink/User-Defined Functions/MATLAB Function', 'sontag', 'Position', [100 140 220 170]);
blk('simulink/Signal Routing/Multiport Switch', 'selector', 'Inputs', '3', 'Position', [270 30 300 170]);
blk('simulink/Sources/Constant', 'ley', 'Value', 'ley', 'Position', [200 190 230 210]);
blk('simulink/Sources/Step', 'w', 'Time', 'Tw', 'After', 'W', 'Position', [270 210 300 240]);
blk('simulink/Math Operations/Sum', 'u+w', 'Inputs', '++', 'Position', [340 120 360 140]);
blk('simulink/Signal Routing/Mux', 'mux', 'Inputs', '2', 'Position', [390 100 395 140]);
blk('simulink/User-Defined Functions/Fcn', 'planta', 'Expr', 'u(1) + (u(1)^2 + 1)*u(2)', 'Position', [420 105 490 135]);
blk('simulink/Sinks/To Workspace', 'registro', 'VariableName', 'xr', 'SaveFormat', 'Array', 'Position', [600 170 660 200]);
blk('simulink/Sinks/Stop Simulation', 'parar', 'Position', [680 100 710 130]);
blk('simulink/Logic and Bit Operations/Compare To Constant', 'escape', 'relop', '>', 'const', '1e3', 'Position', [600 100 650 130]);
blk('simulink/Math Operations/Abs', 'abs', 'Position', [570 60 590 80]);
blk('simulink/Sources/Clock', 'reloj', 'Position', [540 230 560 250]);
blk('simulink/Signal Routing/Mux', 'mux2', 'Inputs', '2', 'Position', [580 175 585 215]);
try  % código del bloque MATLAB Function
    sf = sfroot;  ch = sf.find('-isa', 'Stateflow.EMChart', 'Path', [mdl '/sontag']);
    ch.Script = sprintf('function u = f(x, kappa)\nu = leySontag(x^2, x*(x^2 + 1), kappa);\n');
catch
    warning('No se pudo escribir el bloque sontag; use ley = 1 o 2.');
end
blk('simulink/Sources/Constant', 'kappa', 'Value', 'kappa', 'Position', [20 160 50 180]);

lin('x/1', 'cancelacion/1');  lin('x/1', 'amortiguada/1');  lin('x/1', 'sontag/1');  lin('kappa/1', 'sontag/2');
lin('ley/1', 'selector/1');  lin('cancelacion/1', 'selector/2');  lin('amortiguada/1', 'selector/3');  lin('sontag/1', 'selector/4');
lin('selector/1', 'u+w/1');  lin('w/1', 'u+w/2');
lin('x/1', 'mux/1');  lin('u+w/1', 'mux/2');  lin('mux/1', 'planta/1');  lin('planta/1', 'x/1');
lin('x/1', 'abs/1');  lin('abs/1', 'escape/1');  lin('escape/1', 'parar/1');
lin('reloj/1', 'mux2/1');  lin('x/1', 'mux2/2');  lin('mux2/1', 'registro/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '12', 'Solver', 'ode45', 'RelTol', '1e-9', 'MaxStep', '0.01');
save_system(mdl);
fprintf('Modelo %s.slx creado.\n', mdl);

nombres = {'cancelación', 'con -L_gV', 'Sontag kappa'};
figure;  hold on;
for ley = 1:3
    assignin('base', 'ley', ley);
    salida = sim(mdl);  xr = salida.get('xr');
    fprintf('ley %d (%s): t final = %.3f, x final = %.4f\n', ley, nombres{ley}, xr(end, 1), xr(end, 2));
    plot(xr(:, 1), xr(:, 2));
end
ylim([-1 10]);  grid on;  xlabel('t');  ylabel('x');  legend(nombres);  title('Error de actuador W = 1 desde t = 2');
