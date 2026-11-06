%% crearModelo_Retardo -- Construye "Retardo.slx" (sección 5.6)
% Dos copias del lazo K -> e^{-Ts} -> 1/(s+1) con retroalimentación unitaria:
% arriba con el bloque Transport Delay (retardo exacto), abajo con la
% aproximación de Padé de primer orden (1 - Ts/2)/(1 + Ts/2).
% USO   1) ejecute este script;  2) cambie K y T en el espacio de trabajo;
%       3) sim('Retardo').  Con T = 1, pruebe K = 2, 2.3, 2.5 y 3.
clear; clc;
K = 2.5;  T = 1;
assignin('base', 'K', K);  assignin('base', 'T', T);
mdl = 'Retardo';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
b = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
l = @(a, c) add_line(mdl, a, c, 'autorouting', 'on');
b('simulink/Sources/Step', 'r', 'Time', '0', 'Position', [20 120 50 150]);
b('simulink/Sinks/Scope', 'y', 'NumInputPorts', '2', 'Position', [520 110 550 160]);
for k = 1:2
    y0 = 40 + (k-1)*160;  suf = num2str(k);
    b('simulink/Math Operations/Sum', ['e' suf], 'Inputs', '+-', 'Position', [100 y0+25 120 y0+45]);
    b('simulink/Math Operations/Gain', ['K' suf], 'Gain', 'K', 'Position', [150 y0+20 190 y0+50]);
    if k == 1
        b('simulink/Continuous/Transport Delay', 'retardo', 'DelayTime', 'T', 'Position', [220 y0+20 280 y0+50]);
        bloque = 'retardo';
    else
        b('simulink/Continuous/Transfer Fcn', 'pade1', 'Numerator', '[-T/2 1]', 'Denominator', '[T/2 1]', 'Position', [220 y0+15 290 y0+55]);
        bloque = 'pade1';
    end
    b('simulink/Continuous/Transfer Fcn', ['planta' suf], 'Numerator', '1', 'Denominator', '[1 1]', 'Position', [330 y0+15 390 y0+55]);
    l('r/1', ['e' suf '/1']);  l(['e' suf '/1'], ['K' suf '/1']);  l(['K' suf '/1'], [bloque '/1']);
    l([bloque '/1'], ['planta' suf '/1']);  l(['planta' suf '/1'], ['e' suf '/2']);  l(['planta' suf '/1'], ['y/' suf]);
end
set_param(mdl, 'StopTime', '30');
save_system(mdl);
fprintf('Modelo %s.slx creado (K = %g, T = %g). Ejecute sim(''%s'').\n', mdl, K, T, mdl);
