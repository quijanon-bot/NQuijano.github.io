%% crearModelo_PenduloLyapunov -- Construye "PenduloLyapunov.slx" (secciones 7.4 y 7.6)
% Péndulo con fricción  x1' = x2,  x2' = -a sin x1 - b x2,  con dos "medidores":
%   V_E = a(1 - cos x1) + x2^2/2                         (la energía)
%   V_P = (1/2)(b p12 x1^2 + 2 p12 x1 x2 + x2^2) + a(1 - cos x1)   (con término cruzado)
% y sus derivadas a lo largo de las soluciones, Vdot_E = -b x2^2 y
% Vdot_P = -a p12 x1 sin x1 - (b - p12) x2^2. Solo bloques básicos (sin toolboxes).
% USO   1) ejecute el script: crea el modelo, lo simula y compara con ode45;
%       2) cambie a, b, p12 o x0 en el workspace y vuelva a simular.
%   OBSERVE: Vdot_E se anula cada vez que x2 = 0 (el péndulo se detiene en un extremo);
%   Vdot_P es estrictamente negativa mientras |x1| < pi y x ~= 0.
clear; clc;
a = 1;  b = 0.5;  p12 = 0.25;  x0 = [2.5; 0];
vars = {'a', 'b', 'p12', 'x0'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'PenduloLyapunov';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');

% planta: dos integradores y la fuerza -a sin x1 - b x2
blk('simulink/Continuous/Integrator', 'x2', 'InitialCondition', 'x0(2)', 'Position', [260 50 290 80]);
blk('simulink/Continuous/Integrator', 'x1', 'InitialCondition', 'x0(1)', 'Position', [340 50 370 80]);
blk('simulink/Signal Routing/Mux', 'x', 'Inputs', '2', 'Position', [420 40 425 100]);
blk('simulink/User-Defined Functions/Fcn', 'aceleración', 'Expr', '-a*sin(u(1)) - b*u(2)', ...
    'Position', [130 50 210 80]);
% medidores
blk('simulink/User-Defined Functions/Fcn', 'V_E', 'Expr', 'a*(1 - cos(u(1))) + u(2)^2/2', 'Position', [500 20 600 45]);
blk('simulink/User-Defined Functions/Fcn', 'Vdot_E', 'Expr', '-b*u(2)^2', 'Position', [500 60 600 85]);
blk('simulink/User-Defined Functions/Fcn', 'V_P', 'Expr', ...
    '0.5*(b*p12*u(1)^2 + 2*p12*u(1)*u(2) + u(2)^2) + a*(1 - cos(u(1)))', 'Position', [500 100 600 125]);
blk('simulink/User-Defined Functions/Fcn', 'Vdot_P', 'Expr', '-a*p12*u(1)*sin(u(1)) - (b - p12)*u(2)^2', ...
    'Position', [500 140 600 165]);
blk('simulink/Signal Routing/Mux', 'medidores', 'Inputs', '4', 'Position', [650 20 655 170]);
blk('simulink/Sinks/Scope', 'V y Vdot', 'Position', [700 80 730 110]);
blk('simulink/Sinks/To Workspace', 'a workspace', 'VariableName', 'med', 'SaveFormat', 'Array', 'Position', [700 140 770 160]);
blk('simulink/Sinks/To Workspace', 'estado', 'VariableName', 'est', 'SaveFormat', 'Array', 'Position', [500 200 570 220]);

lin('aceleración/1', 'x2/1');  lin('x2/1', 'x1/1');
lin('x1/1', 'x/1');  lin('x2/1', 'x/2');  lin('x/1', 'aceleración/1');
for nombre = {'V_E', 'Vdot_E', 'V_P', 'Vdot_P'}, lin('x/1', [nombre{1} '/1']); end
lin('V_E/1', 'medidores/1');  lin('Vdot_E/1', 'medidores/2');  lin('V_P/1', 'medidores/3');  lin('Vdot_P/1', 'medidores/4');
lin('medidores/1', 'V y Vdot/1');  lin('medidores/1', 'a workspace/1');  lin('x/1', 'estado/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '20', 'Solver', 'ode45', 'RelTol', '1e-9', 'MaxStep', '1e-2');
save_system(mdl);
fprintf('Modelo %s.slx creado.\n', mdl);

salida = sim(mdl);  med = salida.get('med');  est = salida.get('est');
fprintf('Simulink: V_E: %.4f -> %.4f;  V_P: %.4f -> %.4f;  max Vdot_P = %.2e\n', ...
        med(1,1), med(end,1), med(1,3), med(end,3), max(med(2:end,4)));
[~, X] = ode45(@(t, x) [x(2); -a*sin(x(1)) - b*x(2)], [0 20], x0, odeset('RelTol', 1e-10));
fprintf('ode45:    x(20) = (%.5f, %.5f); diferencia con Simulink %.1e\n', X(end,:), norm(X(end,:) - est(end,:)));
