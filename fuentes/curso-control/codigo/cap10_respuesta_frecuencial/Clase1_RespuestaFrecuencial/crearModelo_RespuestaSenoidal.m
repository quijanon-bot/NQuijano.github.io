%% crearModelo_RespuestaSenoidal -- Construye "RespuestaSenoidal.slx" (sección 10.2)
% Sine Wave -> G'(s) -> Scope (entrada y salida en el mismo Scope) y To Workspace.
% El modelo se CONSTRUYE por código: así no hay que versionar un .slx binario.
% USO   1) ejecute este script;  2) cambie w, num y den en el workspace;
%       3) sim('RespuestaSenoidal') y mida amplitud y desfase en el Scope.
%       La última sección mide automáticamente y compara con bode(G,w).
% ACTIVIDAD (problema [M] de la sección 10.13): G(s) = 100/(s^2+4s+100),
%       w = 1, 10 y 50. ¿En cuál la salida es mayor que la entrada?
clear; clc;
mdl = 'RespuestaSenoidal';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);  open_system(mdl);

add_block('simulink/Sources/Sine Wave', [mdl '/Senoide'], ...
    'Amplitude', '1', 'Frequency', 'w', 'Position', [40 80 90 120]);
add_block('simulink/Continuous/Transfer Fcn', [mdl '/G(s)'], ...
    'Numerator', 'num', 'Denominator', 'den', 'Position', [160 75 260 125]);
add_block('simulink/Signal Routing/Mux', [mdl '/Mux'], 'Inputs', '2', 'Position', [320 70 325 130]);
add_block('simulink/Sinks/Scope', [mdl '/Scope'], 'Position', [380 80 410 120]);
add_block('simulink/Sinks/To Workspace', [mdl '/aWS'], 'VariableName', 'xz', ...
    'SaveFormat', 'Array', 'Position', [380 150 440 180]);

add_line(mdl, 'Senoide/1', 'G(s)/1');
add_line(mdl, 'Senoide/1', 'Mux/1', 'autorouting', 'on');
add_line(mdl, 'G(s)/1', 'Mux/2');
add_line(mdl, 'Mux/1', 'Scope/1');
add_line(mdl, 'Mux/1', 'aWS/1', 'autorouting', 'on');
set_param(mdl, 'StopTime', '20', 'MaxStep', '1e-3');

% Parámetros (en el workspace base)
num = 1;  den = [1 10];  w = 1;
assignin('base', 'num', num);  assignin('base', 'den', den);  assignin('base', 'w', w);
save_system(mdl);
fprintf('Modelo %s.slx creado. Ejecute sim(''%s'') y vea el Scope.\n', mdl, mdl);

%% Medición automática de amplitud y fase (último periodo)
out = sim(mdl, 'ReturnWorkspaceOutputs', 'on');  xz = out.get('xz');  tt = out.get('tout');
T = 2*pi/w;  idx = tt > tt(end) - T;
A = (max(xz(idx,2)) - min(xz(idx,2)))/2;
[~, i1] = max(xz(idx,1));  [~, i2] = max(xz(idx,2));  ti = tt(idx);
desfase = -rad2deg(w*(ti(i2) - ti(i1)));
fprintf('Simulink: amplitud = %.4f, desfase = %.2f grados\n', A, desfase);
[m, f] = bode(tf(num, den), w);
fprintf('bode:     amplitud = %.4f, desfase = %.2f grados\n', m, f);
