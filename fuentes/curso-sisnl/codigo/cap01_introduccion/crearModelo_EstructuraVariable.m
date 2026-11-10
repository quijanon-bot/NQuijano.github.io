%% crearModelo_EstructuraVariable -- Construye EstructuraVariable.slx por código (Simulink)
% QUÉ HACE   Arma el doble integrador x1' = x2, x2' = u con la ley de estructura
%            variable u = k3 x1, k3 = -sgn(x1 s), s = x1 + x2 (sección 1.6). Usa un
%            bloque Switch que elige entre +x1 y -x1 según el signo de x1 s.
%            Simula 10 s desde (1, 1) y compara con ode45.
% OBSERVE    Después de t = pi/2 el Switch conmuta continuamente: es el
%            deslizamiento sobre s = 0. Active la detección de cruces por cero
%            del Switch (está activada por defecto) y compare con desactivarla.
% ESPERADO   max |x1_Simulink - x1_ode45| < 1e-3 (si falla, el mensaje dice qué bloque).
% REQUIERE   Simulink.
clear; close all; clc;
nombre = 'EstructuraVariable';  x0 = [1; 1];
if bdIsLoaded(nombre), close_system(nombre, 0); end
new_system(nombre);  open_system(nombre);
set_param(nombre, 'StopTime', '10', 'Solver', 'ode45', 'RelTol', '1e-9', 'AbsTol', '1e-11', ...
          'MaxStep', '1e-3', 'SaveOutput', 'on', 'SaveFormat', 'Array');
b = @(tipo, nom, pos) add_block(['simulink/' tipo], [nombre '/' nom], 'Position', pos);
b('Continuous/Integrator', 'x2', [300 100 330 130]);  set_param([nombre '/x2'], 'InitialCondition', num2str(x0(2)));
b('Continuous/Integrator', 'x1', [420 100 450 130]);  set_param([nombre '/x1'], 'InitialCondition', num2str(x0(1)));
b('Math Operations/Sum', 's', [420 200 450 230]);      set_param([nombre '/s'], 'Inputs', '++');
b('Math Operations/Product', 'x1s', [500 200 530 230]);
b('Math Operations/Gain', 'menos', [500 280 530 310]); set_param([nombre '/menos'], 'Gain', '-1');
b('Signal Routing/Switch', 'k3', [220 100 250 150]);
set_param([nombre '/k3'], 'Criteria', 'u2 > Threshold', 'Threshold', '0');   % x1 s > 0 -> u = -x1
b('Sinks/Out1', 'y1', [520 100 550 130]);  b('Sinks/Out1', 'y2', [520 40 550 70]);
l = @(a, c) add_line(nombre, a, c, 'autorouting', 'on');
l('x2/1', 'x1/1');  l('x1/1', 'y1/1');  l('x2/1', 'y2/1');
l('x1/1', 's/1');  l('x2/1', 's/2');  l('x1/1', 'x1s/1');  l('s/1', 'x1s/2');
l('x1/1', 'menos/1');  l('menos/1', 'k3/1');  l('x1s/1', 'k3/2');  l('x1/1', 'k3/3');
l('k3/1', 'x2/1');
save_system(nombre);
out = sim(nombre, 'ReturnWorkspaceOutputs', 'on');
tS = out.tout;  YS = out.yout;                       % columnas: x1, x2
k3 = @(x) 1 - 2*(x(1)*(x(1) + x(2)) > 0);
[~, XO] = ode45(@(t, x) [x(2); k3(x)*x(1)], tS, x0, odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 1e-3));
err = max(abs(YS(:,1) - XO(:,1)));
if err < 1e-3
    fprintf('EstructuraVariable.slx coincide con ode45: max |error| = %.1e\n', err);
else
    warning('Diferencia %.2e: revise el bloque "k3" (Switch: entrada 1 = -x1 cuando x1 s > 0).', err);
end
figure; plot(YS(:,1), YS(:,2)); grid on; xlabel('x_1'); ylabel('x_2'); title('EstructuraVariable.slx');
