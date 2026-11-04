%% crearModelo_LazoPasivo -- Construye "LazoPasivo.slx" (sección 11.8)
% Dos osciladores no lineales en la conexión estándar de Khalil (Fig. 6.11):
%   H1: x1' = x2,  x2' = -a x1^3 - k x2 + e1,  y1 = x2      (OSP y ZSO)
%   H2: x3' = x4,  x4' = -b x3 - x4^3 + e2,    y2 = x4      (OSP y ZSO)
%   e1 = u1 - y2,  e2 = u2 + y1.
% Calcula en línea V1, V2 y V = V1 + V2, los muestra en un Scope y los guarda
% en el workspace; al final compara con ode45 (modeloOsciladores.m).
% USO   1) ejecute el script (crea, simula y compara);
%       2) abra el Scope "energias": V1 y V2 suben y bajan, V solo baja;
%       3) cambie el signo del sumador e1 a '++' y vuelva a simular (trampa del signo).
clear; clc;
a = 1;  k = 0.5;  b = 2;  x0 = [1.5 0 0 0];
vars = {'a', 'k', 'b', 'x0'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'LazoPasivo';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');

% --- entradas externas (cero: el lazo evoluciona solo) y conexión estándar
blk('simulink/Sources/Constant', 'u1', 'Value', '0', 'Position', [20 40 50 60]);
blk('simulink/Sources/Constant', 'u2', 'Value', '0', 'Position', [520 260 550 280]);
blk('simulink/Math Operations/Sum', 'e1 = u1 - y2', 'Inputs', '+-', 'Position', [90 40 110 60]);
blk('simulink/Math Operations/Sum', 'e2 = u2 + y1', 'Inputs', '++', 'Position', [460 250 480 270]);
% --- H1
blk('simulink/Signal Routing/Mux', 'mux H1', 'Inputs', '3', 'Position', [150 20 155 90]);
blk('simulink/User-Defined Functions/Fcn', 'x2'' (H1)', 'Expr', '-a*u(1)^3 - k*u(2) + u(3)', 'Position', [180 40 300 70]);
blk('simulink/Continuous/Integrator', 'x2', 'InitialCondition', 'x0(2)', 'Position', [330 40 360 70]);
blk('simulink/Continuous/Integrator', 'x1', 'InitialCondition', 'x0(1)', 'Position', [400 100 430 130]);
% --- H2
blk('simulink/Signal Routing/Mux', 'mux H2', 'Inputs', '3', 'Position', [420 200 425 270], 'Orientation', 'left');
blk('simulink/User-Defined Functions/Fcn', 'x4'' (H2)', 'Expr', '-b*u(1) - u(2)^3 + u(3)', 'Position', [270 220 390 250], 'Orientation', 'left');
blk('simulink/Continuous/Integrator', 'x4', 'InitialCondition', 'x0(4)', 'Position', [200 220 230 250], 'Orientation', 'left');
blk('simulink/Continuous/Integrator', 'x3', 'InitialCondition', 'x0(3)', 'Position', [130 290 160 320], 'Orientation', 'left');
% --- energías
blk('simulink/Signal Routing/Mux', 'mux x', 'Inputs', '4', 'Position', [560 330 565 410]);
blk('simulink/User-Defined Functions/Fcn', 'V1', 'Expr', 'a*u(1)^4/4 + u(2)^2/2', 'Position', [600 330 700 355]);
blk('simulink/User-Defined Functions/Fcn', 'V2', 'Expr', 'b*u(3)^2/2 + u(4)^2/2', 'Position', [600 385 700 410]);
blk('simulink/Math Operations/Sum', 'V', 'Inputs', '++', 'Position', [740 360 760 380]);
blk('simulink/Signal Routing/Mux', 'mux V', 'Inputs', '3', 'Position', [790 330 795 410]);
blk('simulink/Sinks/Scope', 'energias', 'Position', [830 355 860 385]);
blk('simulink/Sinks/To Workspace', 'a workspace', 'VariableName', 'Vsim', 'SaveFormat', 'Array', 'Position', [830 420 900 440]);

lin('u1/1', 'e1 = u1 - y2/1');   lin('e1 = u1 - y2/1', 'mux H1/3');
lin('x1/1', 'mux H1/1');         lin('x2/1', 'mux H1/2');
lin('mux H1/1', 'x2'' (H1)/1');  lin('x2'' (H1)/1', 'x2/1');   lin('x2/1', 'x1/1');
lin('x2/1', 'e2 = u2 + y1/2');   lin('u2/1', 'e2 = u2 + y1/1');  lin('e2 = u2 + y1/1', 'mux H2/3');
lin('x3/1', 'mux H2/1');         lin('x4/1', 'mux H2/2');
lin('mux H2/1', 'x4'' (H2)/1');  lin('x4'' (H2)/1', 'x4/1');   lin('x4/1', 'x3/1');
lin('x4/1', 'e1 = u1 - y2/2');
lin('x1/1', 'mux x/1');  lin('x2/1', 'mux x/2');  lin('x3/1', 'mux x/3');  lin('x4/1', 'mux x/4');
lin('mux x/1', 'V1/1');  lin('mux x/1', 'V2/1');  lin('V1/1', 'V/1');  lin('V2/1', 'V/2');
lin('V1/1', 'mux V/1');  lin('V2/1', 'mux V/2');  lin('V/1', 'mux V/3');
lin('mux V/1', 'energias/1');  lin('mux V/1', 'a workspace/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end   % (R2018b o posterior)
set_param(mdl, 'StopTime', '40', 'Solver', 'ode45', 'RelTol', '1e-8', 'AbsTol', '1e-10', 'MaxStep', '0.01');
save_system(mdl);
fprintf('Modelo %s.slx creado. Simulando...\n', mdl);

% --- simular y comparar con ode45
salida = sim(mdl);
tS = salida.tout;   VS = salida.get('Vsim');
[tO, XO] = ode45(@(t, x) modeloOsciladores(t, x, a, k, b), tS, x0(:), odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
VO = a*XO(:,1).^4/4 + XO(:,2).^2/2 + b*XO(:,3).^2/2 + XO(:,4).^2/2;
fprintf('max |V(Simulink) - V(ode45)| = %.1e   (esperado < 1e-5)\n', max(abs(VS(:,3) - VO)));
fprintf('¿V no creciente en Simulink? %d\n', all(diff(VS(:,3)) <= 1e-8));
