%% crearModelo_DiodoTunel2D -- Construye "DiodoTunel2D.slx" (sección 4.6)
% Diodo túnel con inductancia (Khalil, sec. 1.2.2), con t en ns, v en V, i en mA:
%   C vC' = -h(vC) + iL,     L iL' = -vC - R iL + E.
% Dos integradores y bloques Fcn; solo bloques básicos (sin toolboxes).
% USO   1) ejecute el script: crea el modelo, lo simula desde x0 = (0.4, 0) y
%          (0.4, 0.3) y compara con ode45;
%       2) cambie E, R, L, C o x0 en el workspace y vuelva a simular.
%   OBSERVE: con el mismo voltaje inicial el circuito termina en Q1 o en Q3 según la
%   corriente inicial del inductor: la frontera es la variedad estable de Q2.
clear; clc;
E = 1.2;  R = 1.5;  C = 2;  L = 5;  x0 = [0.4; 0];
vars = {'E', 'R', 'C', 'L', 'x0'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end
hstr = '17.76*u - 103.79*u^2 + 229.62*u^3 - 226.31*u^4 + 83.72*u^5';

mdl = 'DiodoTunel2D';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');

blk('simulink/Continuous/Integrator', 'vC', 'InitialCondition', 'x0(1)', 'Position', [330 40 360 70]);
blk('simulink/Continuous/Integrator', 'iL', 'InitialCondition', 'x0(2)', 'Position', [330 150 360 180]);
blk('simulink/User-Defined Functions/Fcn', 'h(vC)', 'Expr', hstr, 'Position', [420 100 560 125]);
blk('simulink/User-Defined Functions/Fcn', 'dvC', 'Expr', '(-u(1) + u(2))/C', 'Position', [180 40 260 70]);
blk('simulink/User-Defined Functions/Fcn', 'diL', 'Expr', '(-u(1) - R*u(2) + E)/L', 'Position', [180 150 260 180]);
blk('simulink/Signal Routing/Mux', 'mux1', 'Inputs', '2', 'Position', [140 35 145 75]);
blk('simulink/Signal Routing/Mux', 'mux2', 'Inputs', '2', 'Position', [140 145 145 185]);
blk('simulink/Signal Routing/Mux', 'x', 'Inputs', '2', 'Position', [420 40 425 180]);
blk('simulink/Sinks/XY Graph', 'plano de fase', 'Position', [480 150 510 180]);
blk('simulink/Sinks/To Workspace', 'estado', 'VariableName', 'est', 'SaveFormat', 'Array', 'Position', [480 40 550 60]);

lin('dvC/1', 'vC/1');  lin('diL/1', 'iL/1');
lin('vC/1', 'h(vC)/1');  lin('h(vC)/1', 'mux1/1');  lin('iL/1', 'mux1/2');  lin('mux1/1', 'dvC/1');
lin('vC/1', 'mux2/1');  lin('iL/1', 'mux2/2');  lin('mux2/1', 'diL/1');
lin('vC/1', 'x/1');  lin('iL/1', 'x/2');  lin('x/1', 'estado/1');
lin('vC/1', 'plano de fase/1');  lin('iL/1', 'plano de fase/2');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '300', 'Solver', 'ode45', 'RelTol', '1e-9', 'MaxStep', '0.5');
save_system(mdl);
fprintf('Modelo %s.slx creado.\n', mdl);

h = @(v) 17.76*v - 103.79*v.^2 + 229.62*v.^3 - 226.31*v.^4 + 83.72*v.^5;
for i0 = [0 0.3]
    x0 = [0.4; i0];  assignin('base', 'x0', x0);
    salida = sim(mdl);  est = salida.get('est');
    [~, X] = ode45(@(t, x) [(-h(x(1)) + x(2))/C; (-x(1) - R*x(2) + E)/L], [0 300], x0, odeset('RelTol', 1e-10));
    fprintf('x0 = (0.4, %.1f): Simulink termina en (%.4f, %.4f); ode45 en (%.4f, %.4f)\n', i0, est(end, :), X(end, :));
end
