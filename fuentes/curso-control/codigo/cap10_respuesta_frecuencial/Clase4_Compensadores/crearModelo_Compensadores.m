%% crearModelo_Compensadores -- Construye "Compensadores.slx" (sección 10.11)
% Tres lazos con la MISMA referencia (escalón o rampa, con un selector):
% sin compensar, adelanto y atraso. Salidas a un Scope y esfuerzos u(t) a otro.
% Doble clic en el bloque Selector para cambiar entre escalón y rampa.
clear; clc;
if ~exist('disenoAdelanto', 'file'), addpath(fileparts(mfilename('fullpath'))); end
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
Gp = zpk([], [0 -2], 40);
[~, il] = disenoAdelanto(Gp, 45, 10);  [~, ig] = disenoAtraso(Gp, 45, 5);
mdl = 'Compensadores';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
add_block('simulink/Sources/Step', [mdl '/Escalon'], 'Position', [20 40 50 70]);
add_block('simulink/Sources/Ramp', [mdl '/Rampa'], 'Position', [20 100 50 130]);
add_block('simulink/Signal Routing/Manual Switch', [mdl '/Selector'], 'Position', [90 70 120 100]);
add_line(mdl, 'Escalon/1', 'Selector/1');  add_line(mdl, 'Rampa/1', 'Selector/2');
add_block('simulink/Signal Routing/Mux', [mdl '/MuxY'], 'Inputs', '4', 'Position', [620 60 625 300]);
add_block('simulink/Sinks/Scope', [mdl '/Salidas'], 'Position', [680 165 710 195]);
add_block('simulink/Signal Routing/Mux', [mdl '/MuxU'], 'Inputs', '3', 'Position', [620 360 625 460]);
add_block('simulink/Sinks/Scope', [mdl '/Esfuerzos'], 'Position', [680 395 710 425]);
add_line(mdl, 'Selector/1', 'MuxY/4', 'autorouting', 'on');
nom = {'SinComp', 'Adelanto', 'Atraso'};
num = {'1', mat2str(il.alpha*[1 il.wL], 6), mat2str([1 ig.wH]/ig.alpha, 6)};
den = {'1', mat2str([1 il.wH], 6), mat2str([1 ig.wL], 6)};
for i = 1:3
    y0 = 40 + 110*(i-1);
    add_block('simulink/Math Operations/Sum', [mdl '/S' nom{i}], 'Inputs', '|+-', 'Position', [180 y0+25 200 y0+45]);
    add_block('simulink/Continuous/Transfer Fcn', [mdl '/Gc' nom{i}], 'Numerator', num{i}, 'Denominator', den{i}, 'Position', [240 y0+15 340 y0+55]);
    add_block('simulink/Continuous/Zero-Pole', [mdl '/Gp' nom{i}], 'Zeros', '[]', 'Poles', '[0 -2]', 'Gain', '40', 'Position', [390 y0+15 490 y0+55]);
    add_line(mdl, 'Selector/1', ['S' nom{i} '/1'], 'autorouting', 'on');
    add_line(mdl, ['S' nom{i} '/1'], ['Gc' nom{i} '/1']);
    add_line(mdl, ['Gc' nom{i} '/1'], ['Gp' nom{i} '/1']);
    add_line(mdl, ['Gc' nom{i} '/1'], ['MuxU/' num2str(i)], 'autorouting', 'on');   % esfuerzo u(t)
    add_line(mdl, ['Gp' nom{i} '/1'], ['MuxY/' num2str(i)], 'autorouting', 'on');
    add_line(mdl, ['Gp' nom{i} '/1'], ['S' nom{i} '/2'], 'autorouting', 'on');
end
add_line(mdl, 'MuxY/1', 'Salidas/1');  add_line(mdl, 'MuxU/1', 'Esfuerzos/1');
set_param(mdl, 'StopTime', '20');
save_system(mdl);
fprintf('Modelo %s.slx creado (doble clic en el Selector para cambiar escalón/rampa).\n', mdl);
