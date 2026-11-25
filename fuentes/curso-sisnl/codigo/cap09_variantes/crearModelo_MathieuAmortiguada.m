%% crearModelo_MathieuAmortiguada -- Construye "MathieuAmortiguada.slx" (secciones 9.5 y 9.6)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% Resorte con rigidez periódica: y'' + b y' + (k0 + k1 sin t) y = 0, con un "medidor"
% de la función de Lyapunov variante V(t,x) = x1^2 + x2^2/(k0 + k1 sin t) y de su
% derivada Vdot = -x2^2 (2b(k0 + k1 sin t) + k1 cos t)/(k0 + k1 sin t)^2.
% Solo bloques básicos (sin toolboxes).
% USO   1) ejecute el script: crea el modelo, lo simula y compara con ode45;
%       2) aumente k1 o baje b: mire en el visor cuándo Vdot deja de ser <= 0.
%   OBSERVE: con b = 1, k0 = 2, k1 = 1 (el ejemplo), V baja con mesetas y Vdot <= 0.
clear; clc;
b = 1;  k0 = 2;  k1 = 1;  x10 = 1.5;  x20 = 0;
vars = {'b', 'k0', 'k1', 'x10', 'x20'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'MathieuAmortiguada';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');

blk('simulink/Sources/Clock', 'reloj', 'Position', [40 200 60 220]);
blk('simulink/Continuous/Integrator', 'x2', 'InitialCondition', 'x20', 'Position', [300 50 330 80]);
blk('simulink/Continuous/Integrator', 'x1', 'InitialCondition', 'x10', 'Position', [380 50 410 80]);
blk('simulink/Signal Routing/Mux', 'tx', 'Inputs', '3', 'Position', [460 120 465 230]);
blk('simulink/User-Defined Functions/Fcn', 'aceleracion', 'Expr', '-b*u(3) - (k0 + k1*sin(u(1)))*u(2)', ...
    'Position', [160 50 270 80]);
blk('simulink/User-Defined Functions/Fcn', 'V', 'Expr', 'u(2)^2 + u(3)^2/(k0 + k1*sin(u(1)))', 'Position', [520 120 640 145]);
blk('simulink/User-Defined Functions/Fcn', 'Vdot', 'Expr', ...
    '-u(3)^2*(2*b*(k0 + k1*sin(u(1))) + k1*cos(u(1)))/(k0 + k1*sin(u(1)))^2', 'Position', [520 190 640 215]);
blk('simulink/Signal Routing/Mux', 'medidor', 'Inputs', '2', 'Position', [690 120 695 215]);
blk('simulink/Sinks/Scope', 'V y Vdot', 'Position', [730 150 760 180]);
blk('simulink/Sinks/To Workspace', 'estado', 'VariableName', 'est', 'SaveFormat', 'Array', 'Position', [520 260 590 280]);

lin('aceleracion/1', 'x2/1');  lin('x2/1', 'x1/1');
lin('reloj/1', 'tx/1');  lin('x1/1', 'tx/2');  lin('x2/1', 'tx/3');  lin('tx/1', 'aceleracion/1');
lin('tx/1', 'V/1');  lin('tx/1', 'Vdot/1');  lin('tx/1', 'estado/1');
lin('V/1', 'medidor/1');  lin('Vdot/1', 'medidor/2');  lin('medidor/1', 'V y Vdot/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '20', 'Solver', 'ode45', 'RelTol', '1e-9', 'MaxStep', '1e-2');
carpeta = fileparts(mfilename('fullpath'));
save_system(mdl, fullfile(carpeta, [mdl '.slx']));
fprintf('Modelo %s.slx creado.\n', mdl);

salida = sim(mdl);  est = salida.get('est');               % columnas: t, x1, x2
[~, Z] = ode45(@(t, x) [x(2); -b*x(2) - (k0 + k1*sin(t))*x(1)], [0 20], [x10; x20], odeset('RelTol', 1e-10));
fprintf('Simulink: x(20) = (%.2e, %.2e);  ode45: (%.2e, %.2e)\n', est(end, 2:3), Z(end, :));
Vd = -est(:, 3).^2.*(2*b*(k0 + k1*sin(est(:, 1))) + k1*cos(est(:, 1)))./(k0 + k1*sin(est(:, 1))).^2;
fprintf('max Vdot a lo largo de la simulación = %.2e (<= 0)\n', max(Vd));
