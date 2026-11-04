%% crearModelo_RetroEstado -- Construye "RetroEstado.slx" (secciones 9.2 a 9.8)
% Planta en espacio de estado con u = r - K x (bloque State-Space con C = I
% para tener todos los estados), y una segunda copia con acción integral
% u = -K x + Ke z, z' = r - y. Un Scope compara las dos salidas y otro los
% esfuerzos de control.
% El modelo se CONSTRUYE por código: así no hay que versionar un .slx binario.
% USO   1) ejecute este script (diseña K y [K Ke] para A = [0 1; -3 -5]);
%       2) cambie A, B, C, K, Ka en el workspace;  3) sim('RetroEstado').
clear; clc;
if ~exist('polosDeseados', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
A = [0 1; -3 -5];  B = [0; 1];  C = [1 0];
p = polosDeseados(0.10, 'ts', 0.5);
K = acker(A, B, p);
Ka = acker([A zeros(2,1); -C 0], [B; 0], [p; -100]);   Ke = -Ka(3);   K2 = Ka(1:2);
vars = {'A','B','C','K','K2','Ke'};
for k = 1:numel(vars), assignin('base', vars{k}, eval(vars{k})); end

mdl = 'RetroEstado';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
b = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
l = @(a, c) add_line(mdl, a, c, 'autorouting', 'on');
b('simulink/Sources/Step', 'r', 'Time', '0', 'Position', [20 100 50 130]);
% --- sin integrador: u = r - K x
b('simulink/Math Operations/Sum', 'u1', 'Inputs', '+-', 'Position', [100 60 120 80]);
b('simulink/Continuous/State-Space', 'Planta1', 'A', 'A', 'B', 'B', 'C', 'eye(2)', 'D', 'zeros(2,1)', 'Position', [160 50 240 90]);
b('simulink/Math Operations/Gain', 'K', 'Gain', 'K', 'Multiplication', 'Matrix(K*u)', 'Position', [160 0 220 30], 'Orientation', 'left');
b('simulink/Math Operations/Gain', 'C1', 'Gain', 'C', 'Multiplication', 'Matrix(K*u)', 'Position', [280 55 320 85]);
% --- con integrador: u = -K2 x + Ke z,  z' = r - y
b('simulink/Math Operations/Sum', 'e', 'Inputs', '+-', 'Position', [100 180 120 200]);
b('simulink/Continuous/Integrator', 'z', 'Position', [150 175 180 205]);
b('simulink/Math Operations/Gain', 'Ke', 'Gain', 'Ke', 'Position', [200 175 240 205]);
b('simulink/Math Operations/Sum', 'u2', 'Inputs', '+-', 'Position', [260 180 280 200]);
b('simulink/Continuous/State-Space', 'Planta2', 'A', 'A', 'B', 'B', 'C', 'eye(2)', 'D', 'zeros(2,1)', 'Position', [310 170 390 210]);
b('simulink/Math Operations/Gain', 'K2', 'Gain', 'K2', 'Multiplication', 'Matrix(K*u)', 'Position', [310 240 370 270], 'Orientation', 'left');
b('simulink/Math Operations/Gain', 'C2', 'Gain', 'C', 'Multiplication', 'Matrix(K*u)', 'Position', [420 175 460 205]);
b('simulink/Signal Routing/Mux', 'MuxY', 'Inputs', '2', 'Position', [500 60 505 200]);
b('simulink/Sinks/Scope', 'y', 'Position', [540 115 570 145]);
b('simulink/Signal Routing/Mux', 'MuxU', 'Inputs', '2', 'Position', [500 240 505 300]);
b('simulink/Sinks/Scope', 'u', 'Position', [540 255 570 285]);
l('r/1', 'u1/1');  l('u1/1', 'Planta1/1');  l('Planta1/1', 'K/1');  l('K/1', 'u1/2');  l('Planta1/1', 'C1/1');
l('r/1', 'e/1');   l('e/1', 'z/1');  l('z/1', 'Ke/1');  l('Ke/1', 'u2/1');  l('u2/1', 'Planta2/1');
l('Planta2/1', 'K2/1');  l('K2/1', 'u2/2');  l('Planta2/1', 'C2/1');  l('C2/1', 'e/2');
l('C1/1', 'MuxY/1');  l('C2/1', 'MuxY/2');  l('MuxY/1', 'y/1');
l('u1/1', 'MuxU/1');  l('u2/1', 'MuxU/2');  l('MuxU/1', 'u/1');
set_param(mdl, 'StopTime', '1.5');
save_system(mdl);
fprintf('Modelo %s.slx creado. Ejecute sim(''%s'') y compare los Scope.\n', mdl, mdl);
