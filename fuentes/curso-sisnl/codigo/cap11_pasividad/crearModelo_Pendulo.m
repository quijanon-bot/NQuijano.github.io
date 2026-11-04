%% crearModelo_Pendulo -- Construye "PenduloPD.slx" (sección 11.9)
% Péndulo  m l^2 q'' + b q' + m g l sin q = u  con la ley
%   u = compensa * m g l sin q - Kp (q - qr) - Kd q'
% (PD + compensación de gravedad si compensa = 1; PD solo si compensa = 0).
% Calcula en línea el almacenamiento del lazo con compensación,
%   V = m l^2 q'^2/2 + Kp (q - qr)^2/2,
% que no crece cuando compensa = 1 (Takegaki y Arimoto, 1981).
% USO   1) ejecute el script: simula los dos casos y los compara;
%       2) cambie Kp y Kd y observe el error de estado estacionario del PD solo.
clear; clc;
m = 1;  l = 1;  g = 9.81;  bf = 0.5;  Kp = 20;  Kd = 5;  qr = pi/3;  compensa = 1;
vars = {'m', 'l', 'g', 'bf', 'Kp', 'Kd', 'qr', 'compensa'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'PenduloPD';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');
blk('simulink/Signal Routing/Mux', 'mux q dq', 'Inputs', '2', 'Position', [60 60 65 120]);
blk('simulink/User-Defined Functions/Fcn', 'controlador', ...
    'Expr', 'compensa*m*g*l*sin(u(1)) - Kp*(u(1) - qr) - Kd*u(2)', 'Position', [100 75 260 105]);
blk('simulink/Signal Routing/Mux', 'mux planta', 'Inputs', '2', 'Position', [290 60 295 140]);
blk('simulink/User-Defined Functions/Fcn', 'péndulo', ...
    'Expr', '(u(3) - bf*u(2) - m*g*l*sin(u(1)))/(m*l^2)', 'Position', [330 85 470 115]);
blk('simulink/Continuous/Integrator', 'dq', 'InitialCondition', '0', 'Position', [500 85 530 115]);
blk('simulink/Continuous/Integrator', 'q', 'InitialCondition', '0', 'Position', [560 85 590 115]);
blk('simulink/User-Defined Functions/Fcn', 'V', 'Expr', 'm*l^2*u(2)^2/2 + Kp*(u(1) - qr)^2/2', 'Position', [100 160 260 190]);
blk('simulink/Sinks/Scope', 'q y V', 'Position', [640 150 670 180]);
blk('simulink/Signal Routing/Mux', 'mux salida', 'Inputs', '2', 'Position', [600 140 605 200]);
blk('simulink/Sinks/To Workspace', 'a workspace', 'VariableName', 'qV', 'SaveFormat', 'Array', 'Position', [640 210 710 230]);
lin('q/1', 'mux q dq/1');  lin('dq/1', 'mux q dq/2');
lin('mux q dq/1', 'controlador/1');
lin('mux q dq/1', 'mux planta/1');  lin('controlador/1', 'mux planta/2');
lin('mux planta/1', 'péndulo/1');  lin('péndulo/1', 'dq/1');  lin('dq/1', 'q/1');
lin('mux q dq/1', 'V/1');  lin('q/1', 'mux salida/1');  lin('V/1', 'mux salida/2');
lin('mux salida/1', 'q y V/1');  lin('mux salida/1', 'a workspace/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '10', 'Solver', 'ode45', 'RelTol', '1e-8', 'MaxStep', '0.01');
save_system(mdl);
fprintf('Modelo %s.slx creado.\n', mdl);

for c = [1 0]
    assignin('base', 'compensa', c);
    salida = sim(mdl);  qV = salida.get('qV');
    fprintf('compensa = %d:  q(10) = %.4f rad (%.2f°)', c, qV(end,1), rad2deg(qV(end,1)));
    if c == 1, fprintf('   ¿V no creciente? %d\n', all(diff(qV(:,2)) <= 1e-8)); else, fprintf('\n'); end
end
assignin('base', 'compensa', 1);
