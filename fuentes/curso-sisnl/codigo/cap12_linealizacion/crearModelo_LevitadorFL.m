%% crearModelo_LevitadorFL -- Construye "LevitadorFL.slx" (sección 12.8)
% Levitador magnético con la linealización exacta en el lazo:
%   planta:      x1' = x2,  x2' = g - (k/m) x2 - L0 a x3^2/(2 m (a + x1)^2),
%                x3' = (u - R x3 + L0 a x2 x3/(a + x1)^2)/L(x1)
%   lazo interno: u = (v - L_f^3 h)/(L_g L_f^2 h)      (bloque MATLAB Function con
%                 leyExactaLevitador.m, que debe estar en el path)
%   lazo externo: v = y_d''' - K (xi - [y_d y_d' y_d''])  con K = [6000 1100 60]
% La referencia sale de un filtro p^4/(s + p)^4 (p = 6) que entrega y_d y sus tres
% derivadas: un escalón de 0.05 a 0.12 m se vuelve una maniobra que la planta puede
% hacer sin apagar la corriente. La masa de la planta (mPlanta) puede ser distinta
% de la del modelo (P.m): cámbiela a 0.12 para ver el error de modelo.
% USO   1) ejecute el script: crea, simula y compara con ode45;
%       2) cambie mPlanta, p o el escalón y vuelva a simular.
clear; clc;
P = parametrosLevitador();  KFL = [6000 1100 60];  p = 6;  y0 = 0.05;  yf = 0.12;  mPlanta = P.m;
x0 = equilibrioLevitador(y0, P);
vars = {'P', 'KFL', 'p', 'y0', 'yf', 'mPlanta', 'x0'};
for i = 1:numel(vars), assignin('base', vars{i}, eval(vars{i})); end

mdl = 'LevitadorFL';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
blk = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
lin = @(desde, hasta) add_line(mdl, desde, hasta, 'autorouting', 'on');

% referencia: escalón filtrado por p^4/(s+p)^4, en forma de estados -> [yd; yd'; yd''; yd''']
blk('simulink/Sources/Step', 'escalón', 'Time', '0', 'Before', 'y0', 'After', 'yf', 'Position', [20 40 50 70]);
cf = poly(-p*ones(1, 4));  Af = [zeros(3, 1) eye(3); -fliplr(cf(2:end))];  assignin('base', 'Af', Af);
blk('simulink/Continuous/State-Space', 'filtro', 'A', 'Af', 'B', '[0;0;0;p^4]', 'C', 'eye(4)', ...
    'D', 'zeros(4,1)', 'InitialCondition', '[y0;0;0;0]', 'Position', [90 30 190 80]);

% controlador: MATLAB Function que llama a leyExactaLevitador
blk('simulink/User-Defined Functions/MATLAB Function', 'ley exacta', 'Position', [250 40 370 110]);
cod = sprintf(['function u = ley(x, yd)\n' ...
               '%%#codegen\n' ...
               'coder.extrinsic(''leyExactaLevitador'', ''parametrosLevitador'');\n' ...
               'u = 0;\n' ...
               'u = leyExactaLevitador(x, yd, [6000 1100 60], parametrosLevitador());\n']);
rt = sfroot;  ch = rt.find('-isa', 'Stateflow.EMChart', 'Path', [mdl '/ley exacta']);  ch.Script = cod;

% planta: MATLAB Function con modeloLevitador e integrador vectorial
blk('simulink/User-Defined Functions/MATLAB Function', 'levitador', 'Position', [430 40 550 110]);
cod2 = sprintf(['function dx = planta(x, u, mPlanta)\n' ...
                '%%#codegen\n' ...
                'coder.extrinsic(''modeloLevitador'', ''parametrosLevitador'');\n' ...
                'dx = zeros(3,1);\n' ...
                'dx = modeloLevitador(x, u, parametrosLevitador(), mPlanta);\n']);
ch2 = rt.find('-isa', 'Stateflow.EMChart', 'Path', [mdl '/levitador']);  ch2.Script = cod2;
blk('simulink/Sources/Constant', 'masa real', 'Value', 'mPlanta', 'Position', [370 130 410 150]);
blk('simulink/Continuous/Integrator', 'x', 'InitialCondition', 'x0', 'Position', [600 60 630 90]);
blk('simulink/Signal Routing/Demux', 'demux', 'Outputs', '3', 'Position', [670 50 675 100]);
blk('simulink/Signal Routing/Demux', 'demux ref', 'Outputs', '4', 'Position', [230 140 235 200]);
blk('simulink/Signal Routing/Mux', 'mux y yd', 'Inputs', '2', 'Position', [720 130 725 170]);
blk('simulink/Sinks/Scope', 'y y yd', 'Position', [760 135 790 165]);
blk('simulink/Sinks/To Workspace', 'a workspace', 'VariableName', 'sal', 'SaveFormat', 'Array', 'Position', [760 190 830 210]);
blk('simulink/Sinks/To Workspace', 'corriente', 'VariableName', 'corr', 'SaveFormat', 'Array', 'Position', [760 230 830 250]);

lin('escalón/1', 'filtro/1');
lin('x/1', 'ley exacta/1');  lin('filtro/1', 'ley exacta/2');
lin('x/1', 'levitador/1');  lin('ley exacta/1', 'levitador/2');  lin('masa real/1', 'levitador/3');
lin('levitador/1', 'x/1');  lin('x/1', 'demux/1');
lin('filtro/1', 'demux ref/1');
lin('demux/1', 'mux y yd/1');  lin('demux ref/1', 'mux y yd/2');
lin('mux y yd/1', 'y y yd/1');  lin('mux y yd/1', 'a workspace/1');  lin('demux/3', 'corriente/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
set_param(mdl, 'StopTime', '2', 'Solver', 'ode45', 'RelTol', '1e-8', 'MaxStep', '1e-3');
save_system(mdl);
fprintf('Modelo %s.slx creado.\n', mdl);

salida = sim(mdl);  sal = salida.get('sal');  corr = salida.get('corr');
fprintf('Simulink: y(2) = %.5f m (y_d(2) = %.5f), corriente mínima %.3f A\n', sal(end,1), sal(end,2), min(corr));
% comparación con ode45 (misma maniobra)
lazo = @(t, z) [modeloLevitador(z(1:3), leyExactaLevitador(z(1:3), z(4:7), KFL, P), P, mPlanta); Af*z(4:7) + [0;0;0;p^4]*yf];
[~, Z] = ode45(lazo, [0 2], [x0; y0; 0; 0; 0], odeset('RelTol', 1e-9, 'MaxStep', 1e-3));
fprintf('ode45:    y(2) = %.5f m.  Diferencia: %.1e m\n', Z(end,1), abs(Z(end,1) - sal(end,1)));
