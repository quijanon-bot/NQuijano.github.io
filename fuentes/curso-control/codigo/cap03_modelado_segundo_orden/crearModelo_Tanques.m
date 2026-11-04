%% crearModelo_Tanques -- Construye "Tanques.slx" (sección 3.3)
% Dos tanques interactuantes: modelo NO LINEAL (integradores y raíces
% cuadradas) y modelo LINEALIZADO (función de transferencia), alimentados con
% el mismo escalón en f_i. Un Scope compara h2 de ambos.
% El modelo se CONSTRUYE por código: así no hay que versionar un .slx binario.
% USO   1) ejecute este script (calcula el equilibrio y la TF);
%       2) cambie df (tamaño del escalón) en el workspace;
%       3) sim('Tanques').  Pruebe df = 0.01 y df = 0.05 m^3/s.
% ACTIVIDAD (problema de los tanques): cuantifique el error en el valor final.
clear; clc;
A1 = 2;  A2 = 3;  Cv1 = 0.1;  Cv2 = 0.05;  h2e = 4;
fe = Cv2*sqrt(h2e);  h1e = h2e + (fe/Cv1)^2;
C1 = Cv1/(2*sqrt(h1e - h2e));  C3 = Cv2/(2*sqrt(h2e));
num = 1/C3;                                          % ganancia DC = 1/C3
den = [A1*A2/(C1*C3), A1/C1 + A2/C3 + A1/C3, 1];     % misma TF de las notas, normalizada
df = 0.01;
vars = {'A1','A2','Cv1','Cv2','h1e','h2e','fe','num','den','df'};
for k = 1:numel(vars), assignin('base', vars{k}, eval(vars{k})); end

mdl = 'Tanques';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);
b = @(tipo, nombre, varargin) add_block(tipo, [mdl '/' nombre], varargin{:});
b('simulink/Sources/Step', 'Escalon', 'Time', '100', 'Before', '0', 'After', 'df', 'Position', [20 100 50 130]);
b('simulink/Sources/Constant', 'fe', 'Value', 'fe', 'Position', [20 40 50 60]);
b('simulink/Math Operations/Sum', 'fi', 'Inputs', '++', 'Position', [90 60 110 80]);
% --- no lineal ---
b('simulink/Math Operations/Sum', 'Balance1', 'Inputs', '+-', 'Position', [150 60 170 80]);
b('simulink/Math Operations/Gain', '1/A1', 'Gain', '1/A1', 'Position', [190 55 230 85]);
b('simulink/Continuous/Integrator', 'h1', 'InitialCondition', 'h1e', 'Position', [250 55 280 85]);
b('simulink/Math Operations/Sum', 'h1-h2', 'Inputs', '+-', 'Position', [310 60 330 80]);
b('simulink/User-Defined Functions/Fcn', 'f1', 'Expr', 'Cv1*sqrt(max(u,0))', 'Position', [350 55 430 85]);
b('simulink/Math Operations/Sum', 'Balance2', 'Inputs', '+-', 'Position', [460 60 480 80]);
b('simulink/Math Operations/Gain', '1/A2', 'Gain', '1/A2', 'Position', [500 55 540 85]);
b('simulink/Continuous/Integrator', 'h2', 'InitialCondition', 'h2e', 'Position', [560 55 590 85]);
b('simulink/User-Defined Functions/Fcn', 'f2', 'Expr', 'Cv2*sqrt(max(u,0))', 'Position', [560 130 640 160]);
% --- lineal ---
b('simulink/Continuous/Transfer Fcn', 'Lineal', 'Numerator', 'num', 'Denominator', 'den', 'Position', [250 200 330 240]);
b('simulink/Math Operations/Bias', 'mas h2e', 'Bias', 'h2e', 'Position', [370 205 410 235]);
b('simulink/Signal Routing/Mux', 'Mux', 'Inputs', '2', 'Position', [650 60 655 230]);
b('simulink/Sinks/Scope', 'h2: NL vs lineal', 'Position', [690 130 720 160]);

l = @(a, c) add_line(mdl, a, c, 'autorouting', 'on');
l('fe/1', 'fi/1');  l('Escalon/1', 'fi/2');  l('fi/1', 'Balance1/1');
l('Balance1/1', '1/A1/1');  l('1/A1/1', 'h1/1');  l('h1/1', 'h1-h2/1');
l('h1-h2/1', 'f1/1');  l('f1/1', 'Balance1/2');  l('f1/1', 'Balance2/1');
l('Balance2/1', '1/A2/1');  l('1/A2/1', 'h2/1');  l('h2/1', 'h1-h2/2');
l('h2/1', 'f2/1');  l('f2/1', 'Balance2/2');  l('h2/1', 'Mux/1');
l('Escalon/1', 'Lineal/1');  l('Lineal/1', 'mas h2e/1');  l('mas h2e/1', 'Mux/2');
l('Mux/1', 'h2: NL vs lineal/1');
set_param(mdl, 'StopTime', '4000');
save_system(mdl);
fprintf('Modelo %s.slx creado. Ejecute sim(''%s'').\n', mdl, mdl);
