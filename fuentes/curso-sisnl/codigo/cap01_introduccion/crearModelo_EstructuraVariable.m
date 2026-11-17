%% crearModelo_EstructuraVariable -- Construye EstructuraVariable.slx por código (Simulink)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Arma el doble integrador x1' = x2, x2' = u con la ley de estructura
%            variable u = 4 k3 x1, k3 = -sgn(x1 s), s = x1 + x2 (sección 1.6). Usa un
%            bloque Switch que elige entre +4 x1 y -4 x1 según el signo de x1 s.
%            Simula 10 s desde (1, 1) y compara con la solución de Filippov
%            (centro hasta s = 0 en t = 0.4636; luego x1' = -x1 sobre s = 0).
% OBSERVE    Después de t = 0.46 el Switch conmuta en cada paso: es el
%            deslizamiento sobre s = 0 (chattering). Por eso se simula con paso
%            fijo (ode4, h = 1e-4) y sin detección de cruces por cero en el
%            Switch: con detección, Simulink intenta ubicar cada conmutación,
%            encuentra 1000 seguidas en t = 0.4636 y detiene la simulación.
% EXPLORE    Cambie 'ZeroCross' del bloque k3 a 'on' y el solver a ode45 de paso
%            variable: el error de Simulink es la huella del chattering.
% ESPERADO   max |x1_Simulink - x1_Filippov| < 1e-3 (si falla, el mensaje dice qué bloque).
% REQUIERE   Simulink.
clear; close all; clc;
nombre = 'EstructuraVariable';  x0 = [1; 1];
carpeta = fileparts(mfilename('fullpath'));  archivo = fullfile(carpeta, [nombre '.slx']);
if bdIsLoaded(nombre), close_system(nombre, 0); end
if exist(archivo, 'file'), delete(archivo); end       % evita dos modelos con el mismo nombre
new_system(nombre);  open_system(nombre);
set_param(nombre, 'StopTime', '10', 'SolverType', 'Fixed-step', 'Solver', 'ode4', ...
          'FixedStep', '1e-4', 'SaveOutput', 'on', 'SaveFormat', 'Array');
b = @(tipo, nom, pos) add_block(['simulink/' tipo], [nombre '/' nom], 'Position', pos);
b('Continuous/Integrator', 'x2', [300 100 330 130]);  set_param([nombre '/x2'], 'InitialCondition', num2str(x0(2)));
b('Continuous/Integrator', 'x1', [420 100 450 130]);  set_param([nombre '/x1'], 'InitialCondition', num2str(x0(1)));
b('Math Operations/Sum', 's', [420 200 450 230]);      set_param([nombre '/s'], 'Inputs', '++');
b('Math Operations/Product', 'x1s', [500 200 530 230]);
b('Math Operations/Gain', 'menos', [500 280 530 310]); set_param([nombre '/menos'], 'Gain', '-4');
b('Math Operations/Gain', 'cuatro', [500 340 530 370]); set_param([nombre '/cuatro'], 'Gain', '4');
b('Signal Routing/Switch', 'k3', [220 100 250 150]);
set_param([nombre '/k3'], 'Criteria', 'u2 > Threshold', 'Threshold', '0', 'ZeroCross', 'off');   % x1 s > 0 -> u = -4 x1
b('Sinks/Out1', 'y1', [520 100 550 130]);  b('Sinks/Out1', 'y2', [520 40 550 70]);
l = @(a, c) add_line(nombre, a, c, 'autorouting', 'on');
l('x2/1', 'x1/1');  l('x1/1', 'y1/1');  l('x2/1', 'y2/1');
l('x1/1', 's/1');  l('x2/1', 's/2');  l('x1/1', 'x1s/1');  l('s/1', 'x1s/2');
l('x1/1', 'menos/1');  l('menos/1', 'k3/1');  l('x1s/1', 'k3/2');  l('x1/1', 'cuatro/1');  l('cuatro/1', 'k3/3');
l('k3/1', 'x2/1');
save_system(nombre, archivo);
out = sim(nombre, 'ReturnWorkspaceOutputs', 'on');
tS = out.tout;  YS = out.yout;                       % columnas: x1, x2
% Referencia: solución de Filippov (centro x1'' = -4 x1 hasta s = 0; luego x1' = -x1).
ts = atan(4/3)/2;  XO = zeros(numel(tS), 1);
XO(tS <= ts) = cos(2*tS(tS <= ts)) + 0.5*sin(2*tS(tS <= ts));
XO(tS > ts) = exp(-(tS(tS > ts) - ts));
err = max(abs(YS(:,1) - XO(:,1)));
if err < 1e-3
    fprintf('EstructuraVariable.slx coincide con la solución de Filippov: max |error| = %.1e\n', err);
else
    warning('Diferencia %.2e: revise el bloque "k3" (Switch: entrada 1 = -4 x1 cuando x1 s > 0).', err);
end
figure; plot(YS(:,1), YS(:,2)); grid on; xlabel('$x_1$'); ylabel('$x_2$'); title('EstructuraVariable.slx');
