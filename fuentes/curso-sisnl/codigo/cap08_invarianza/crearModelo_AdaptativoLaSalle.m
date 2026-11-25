%% crearModelo_AdaptativoLaSalle -- Construye "AdaptativoLaSalle.slx" (sección 8.4)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% Planta y' = a y + u con a desconocido para el controlador, ley u = -k y y adaptación
% k' = gamma y^2. Un "medidor" calcula V_b = y^2/2 + (k - b)^2/(2 gamma) con una constante
% b > a que solo existe en el análisis, y su derivada Vdot_b = -(b - a) y^2.
% Solo bloques básicos (sin toolboxes).
% USO   1) ejecute el script: crea el modelo, lo simula y compara k(T) con
%          k_inf = a + sqrt((k0 - a)^2 + gamma y0^2) y con ode45;
%       2) cambie b: la simulación (y, k) NO cambia; solo cambia el medidor V_b.
%   OBSERVE: y -> 0 y k -> k_inf, que depende de (y0, k0) y no de b.
clear; clc;
a = 1;  gamma = 1;  b = 2;  y0 = 2;  k0 = -1;
vars = {'a', 'gamma', 'b', 'y0', 'k0'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'AdaptativoLaSalle';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');

% planta: y' = a y + u
blk('simulink/Continuous/Integrator', 'y', 'InitialCondition', 'y0', 'Position', [300 50 330 80]);
blk('simulink/Math Operations/Gain', 'a', 'Gain', 'a', 'Position', [300 120 330 150], 'Orientation', 'left');
blk('simulink/Math Operations/Sum', 'suma', 'Inputs', '++', 'Position', [230 55 250 75]);
% controlador adaptativo: u = -k y, k' = gamma y^2
blk('simulink/Math Operations/Product', 'k y', 'Position', [140 50 170 80]);
blk('simulink/Math Operations/Gain', 'menos', 'Gain', '-1', 'Position', [185 55 210 75]);
blk('simulink/Math Operations/Product', 'y^2', 'Position', [380 180 410 210]);
blk('simulink/Math Operations/Gain', 'gamma', 'Gain', 'gamma', 'Position', [430 180 460 210]);
blk('simulink/Continuous/Integrator', 'k', 'InitialCondition', 'k0', 'Position', [480 180 510 210]);
% medidor de la V del análisis (con la constante ficticia b)
blk('simulink/Signal Routing/Mux', 'yk', 'Inputs', '2', 'Position', [560 40 565 220]);
blk('simulink/User-Defined Functions/Fcn', 'V_b', 'Expr', 'u(1)^2/2 + (u(2) - b)^2/(2*gamma)', 'Position', [610 60 720 85]);
blk('simulink/User-Defined Functions/Fcn', 'Vdot_b', 'Expr', '-(b - a)*u(1)^2', 'Position', [610 110 720 135]);
blk('simulink/Signal Routing/Mux', 'medidor', 'Inputs', '2', 'Position', [760 60 765 140]);
blk('simulink/Sinks/Scope', 'V_b y Vdot_b', 'Position', [800 85 830 115]);
blk('simulink/Sinks/To Workspace', 'estado', 'VariableName', 'est', 'SaveFormat', 'Array', 'Position', [610 180 680 200]);

lin('y/1', 'a/1');  lin('a/1', 'suma/2');  lin('suma/1', 'y/1');
lin('k/1', 'k y/1');  lin('y/1', 'k y/2');  lin('k y/1', 'menos/1');  lin('menos/1', 'suma/1');
lin('y/1', 'y^2/1');  lin('y/1', 'y^2/2');  lin('y^2/1', 'gamma/1');  lin('gamma/1', 'k/1');
lin('y/1', 'yk/1');  lin('k/1', 'yk/2');  lin('yk/1', 'V_b/1');  lin('yk/1', 'Vdot_b/1');  lin('yk/1', 'estado/1');
lin('V_b/1', 'medidor/1');  lin('Vdot_b/1', 'medidor/2');  lin('medidor/1', 'V_b y Vdot_b/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '30', 'Solver', 'ode45', 'RelTol', '1e-9', 'MaxStep', '1e-2');
carpeta = fileparts(mfilename('fullpath'));
save_system(mdl, fullfile(carpeta, [mdl '.slx']));
fprintf('Modelo %s.slx creado.\n', mdl);

salida = sim(mdl);  est = salida.get('est');
kinf = a + sqrt((k0 - a)^2 + gamma*y0^2);
fprintf('Simulink: y(30) = %.1e, k(30) = %.5f;  fórmula k_inf = %.5f;  b = %g no aparece\n', est(end, 1), est(end, 2), kinf, b);
[~, Z] = ode45(@(t, z) [-(z(2) - a)*z(1); gamma*z(1)^2], [0 30], [y0; k0], odeset('RelTol', 1e-10));
fprintf('ode45:    (y, k)(30) = (%.1e, %.5f); diferencia con Simulink %.1e\n', Z(end, :), norm(Z(end, :) - est(end, :)));
