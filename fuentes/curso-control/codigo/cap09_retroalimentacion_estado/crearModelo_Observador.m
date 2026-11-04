%% crearModelo_Observador -- Construye "Observador.slx" (secciones 9.6 y 9.7)
% Planta (State-Space, mide solo y) + observador de Luenberger
%   x~' = (A - L C) x~ + B u + L y
% + ley de control u = -K x~ + N r, con N = 1/dcgain para que el escalón
% llegue a 1. Un interruptor permite usar el estado real (u = -K x) para
% comparar. La planta arranca en x(0) = [1; -1]; el observador, en cero.
% USO   1) ejecute el script;  2) cambie los polos del observador (po);
%       3) sim('Observador') y compare x con x~ en el Scope.
clear; clc;
A = [0 1; -2 -3];  B = [0; 1];  C = [1 0];
K = acker(A, B, [-2+2j, -2-2j]);
po = [-10 -10];
L = acker(A.', C.', po).';
N = 1/dcgain(ss(A - B*K, B, C, 0));
vars = {'A','B','C','K','L','N'};
for k = 1:numel(vars), assignin('base', vars{k}, eval(vars{k})); end

mdl = 'Observador';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
b = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
l = @(a, c) add_line(mdl, a, c, 'autorouting', 'on');
b('simulink/Sources/Step', 'r', 'Time', '1', 'Position', [20 60 50 90]);
b('simulink/Math Operations/Gain', 'N', 'Gain', 'N', 'Position', [70 60 100 90]);
b('simulink/Math Operations/Sum', 'u', 'Inputs', '+-', 'Position', [130 65 150 85]);
b('simulink/Continuous/State-Space', 'Planta', 'A', 'A', 'B', 'B', 'C', 'eye(2)', 'D', 'zeros(2,1)', ...
  'X0', '[1; -1]', 'Position', [190 55 270 95]);
b('simulink/Math Operations/Gain', 'C', 'Gain', 'C', 'Multiplication', 'Matrix(K*u)', 'Position', [300 60 340 90]);
b('simulink/Continuous/State-Space', 'Observador', 'A', 'A - L*C', 'B', '[B L]', 'C', 'eye(2)', 'D', 'zeros(2,2)', ...
  'Position', [300 160 400 200]);
b('simulink/Signal Routing/Mux', 'MuxObs', 'Inputs', '2', 'Position', [260 160 265 200]);
b('simulink/Signal Routing/Manual Switch', 'estado', 'Position', [430 110 460 150]);
b('simulink/Math Operations/Gain', 'K', 'Gain', 'K', 'Multiplication', 'Matrix(K*u)', 'Position', [470 10 530 40], 'Orientation', 'left');
b('simulink/Signal Routing/Mux', 'MuxX', 'Inputs', '2', 'Position', [470 200 475 260]);
b('simulink/Sinks/Scope', 'x y x~', 'Position', [510 215 540 245]);
b('simulink/Sinks/Scope', 'y', 'Position', [380 60 410 90]);
l('r/1', 'N/1');  l('N/1', 'u/1');  l('u/1', 'Planta/1');  l('Planta/1', 'C/1');  l('C/1', 'y/1');
l('u/1', 'MuxObs/1');  l('C/1', 'MuxObs/2');  l('MuxObs/1', 'Observador/1');
l('Observador/1', 'estado/1');  l('Planta/1', 'estado/2');  l('estado/1', 'K/1');  l('K/1', 'u/2');
l('Planta/1', 'MuxX/1');  l('Observador/1', 'MuxX/2');  l('MuxX/1', 'x y x~/1');
set_param(mdl, 'StopTime', '6');
save_system(mdl);
fprintf('Modelo %s.slx creado (L = [%g; %g]). Ejecute sim(''%s'').\n', mdl, L, mdl);
