%% crearModelo_AntiWindup -- Construye "AntiWindup.slx" (sección 7.6)
% Dos lazos con el bloque PID Controller de Simulink (forma ideal) sobre
% e^{-4s}/(10s+1) y salida limitada a [0, 1.5]: uno sin anti-windup y otro con
% back-calculation (Kb = 1/Tt). Kc = 3, Ti = 8, Td = 2, N = 10.
% USO   1) ejecute este script;  2) sim('AntiWindup');  3) compare en el Scope.
%       Cambie Tt en el espacio de trabajo y vuelva a simular.
clear; clc;
Kc = 3;  Ti = 8;  Td = 2;  N = 10;  Tt = 4;
for v = {'Kc', 'Ti', 'Td', 'N', 'Tt'}, assignin('base', v{1}, eval(v{1})); end
mdl = 'AntiWindup';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
b = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
l = @(a, c) add_line(mdl, a, c, 'autorouting', 'on');
b('simulink/Sources/Step', 'r', 'Time', '0', 'Position', [20 140 50 170]);
b('simulink/Sinks/Scope', 'y', 'NumInputPorts', '2', 'Position', [560 130 590 180]);
modos = {'none', 'back-calculation'};
for k = 1:2
    y0 = 40 + (k-1)*170;  suf = num2str(k);
    b('simulink/Math Operations/Sum', ['e' suf], 'Inputs', '+-', 'Position', [100 y0+25 120 y0+45]);
    b('simulink/Continuous/PID Controller', ['PID' suf], 'Form', 'Ideal', 'P', 'Kc', 'I', '1/Ti', 'D', 'Td', ...
      'N', 'N/Td', 'LimitOutput', 'on', 'UpperSaturationLimit', '1.5', 'LowerSaturationLimit', '0', ...
      'AntiWindupMode', modos{k}, 'Kb', '1/Tt', 'Position', [160 y0+15 230 y0+55]);
    b('simulink/Continuous/Transport Delay', ['L' suf], 'DelayTime', '4', 'Position', [270 y0+20 320 y0+50]);
    b('simulink/Continuous/Transfer Fcn', ['G' suf], 'Numerator', '1', 'Denominator', '[10 1]', 'Position', [360 y0+15 420 y0+55]);
    l('r/1', ['e' suf '/1']);  l(['e' suf '/1'], ['PID' suf '/1']);  l(['PID' suf '/1'], ['L' suf '/1']);
    l(['L' suf '/1'], ['G' suf '/1']);  l(['G' suf '/1'], ['e' suf '/2']);  l(['G' suf '/1'], ['y/' suf]);
end
set_param(mdl, 'StopTime', '100');
save_system(mdl);
fprintf('Modelo %s.slx creado. Ejecute sim(''%s''). Arriba sin anti-windup, abajo con back-calculation.\n', mdl, mdl);
