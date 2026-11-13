%% crearModelo_InterruptorGenetico -- Construye "InterruptorGenetico.slx" (sección 6.5)
% Interruptor genético de Griffith con la tasa de degradación a variando lentamente:
%   x' = -a(t) x + y,    y' = x^2/(1 + x^2) - b y,
%   a(t) sube de a0 a a1 en Tr unidades de tiempo y vuelve a bajar (señal triangular).
% Solo bloques básicos (sin toolboxes).
% USO   1) ejecute el script: crea el modelo, lo simula y grafica x contra a;
%       2) cambie b, a0, a1 o Tr en el workspace y vuelva a simular.
%   OBSERVE: el gen se apaga un poco después de a_c = 1/(2b) (retardo, más corto cuanto
%   más lenta la rampa) y no se vuelve a encender al bajar a: histéresis.
clear; clc;
b = 0.35;  a0 = 1;  a1 = 1.8;  Tr = 6400;  x0 = [2.4; 2.4];
vars = {'b', 'a0', 'a1', 'Tr', 'x0'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'InterruptorGenetico';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');

blk('simulink/Sources/Clock', 'reloj', 'Position', [20 230 40 250]);
blk('simulink/User-Defined Functions/Fcn', 'a(t)', 'Expr', 'a0 + (a1 - a0)*(1 - abs(1 - u/Tr))', 'Position', [80 225 200 255]);
blk('simulink/Continuous/Integrator', 'x', 'InitialCondition', 'x0(1)', 'Position', [380 40 410 70]);
blk('simulink/Continuous/Integrator', 'y', 'InitialCondition', 'x0(2)', 'Position', [380 150 410 180]);
blk('simulink/User-Defined Functions/Fcn', 'dx', 'Expr', '-u(1)*u(2) + u(3)', 'Position', [240 40 320 70]);
blk('simulink/User-Defined Functions/Fcn', 'dy', 'Expr', 'u(1)^2/(1 + u(1)^2) - b*u(2)', 'Position', [240 150 320 180]);
blk('simulink/Signal Routing/Mux', 'mux1', 'Inputs', '3', 'Position', [200 30 205 80]);
blk('simulink/Signal Routing/Mux', 'mux2', 'Inputs', '2', 'Position', [200 145 205 185]);
blk('simulink/Signal Routing/Mux', 'salida', 'Inputs', '3', 'Position', [480 40 485 250]);
blk('simulink/Sinks/To Workspace', 'registro', 'VariableName', 'reg', 'SaveFormat', 'Array', 'Position', [540 130 610 160]);
blk('simulink/Sinks/XY Graph', 'x contra a', 'Position', [540 220 570 250]);

lin('reloj/1', 'a(t)/1');
lin('a(t)/1', 'mux1/1');  lin('x/1', 'mux1/2');  lin('y/1', 'mux1/3');  lin('mux1/1', 'dx/1');  lin('dx/1', 'x/1');
lin('x/1', 'mux2/1');  lin('y/1', 'mux2/2');  lin('mux2/1', 'dy/1');  lin('dy/1', 'y/1');
lin('a(t)/1', 'salida/1');  lin('x/1', 'salida/2');  lin('y/1', 'salida/3');  lin('salida/1', 'registro/1');
lin('a(t)/1', 'x contra a/1');  lin('x/1', 'x contra a/2');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '2*Tr', 'Solver', 'ode45', 'RelTol', '1e-9', 'MaxStep', '1');
save_system(mdl);
fprintf('Modelo %s.slx creado.\n', mdl);

salida = sim(mdl);  reg = salida.get('reg');
k = find(reg(:, 2) < 0.7, 1);
fprintf('a_c = %.4f; el gen se apaga en a = %.4f (subiendo); x final = %.4f (apagado)\n', 1/(2*b), reg(k, 1), reg(end, 2));
F = @(t, z) [-(a0 + (a1 - a0)*(1 - abs(1 - t/Tr)))*z(1) + z(2); z(1)^2/(1 + z(1)^2) - b*z(2)];
[~, Z] = ode45(F, [0 2*Tr], x0, odeset('RelTol', 1e-9, 'MaxStep', 1));
fprintf('ode45: x final = %.4f\n', Z(end, 1));
figure;  plot(reg(:, 1), reg(:, 2));  grid on;  xlabel('a');  ylabel('x');  title('Histéresis del interruptor genético');
