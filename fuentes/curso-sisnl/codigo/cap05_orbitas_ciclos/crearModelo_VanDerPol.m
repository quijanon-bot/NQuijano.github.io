%% crearModelo_VanDerPol -- Construye VanDerPol.slx por código (Simulink)
% QUÉ HACE   Arma con bloques el oscilador x'' + mu (x^2 - 1) x' + x = 0:
%            dos integradores en cascada (x' y x), un producto para x^2 x' y
%            sumadores. Simula 40 s desde (0.5, 0) con mu = 1, compara contra
%            ode45 y dibuja el plano de fase.
% OBSERVE    El diagrama es la ecuación leída de derecha a izquierda: x'' es la
%            suma de -x (resorte) y -mu (x^2 - 1) x' (amortiguamiento que cambia
%            de signo). Cambie mu en el workspace y vuelva a simular.
% ESPERADO   max |x_Simulink - x_ode45| < 1e-5 (si falla, el mensaje dice qué bloque).
% REQUIERE   Simulink.
clear; close all; clc;
nombre = 'VanDerPol';  mu = 1;  x0 = [0.5; 0];
if bdIsLoaded(nombre), close_system(nombre, 0); end
new_system(nombre);  open_system(nombre);
set_param(nombre, 'StopTime', '40', 'Solver', 'ode45', 'RelTol', '1e-9', 'AbsTol', '1e-10', ...
          'SaveOutput', 'on', 'SaveFormat', 'Array');
b = @(tipo, nom, pos) add_block(['simulink/' tipo], [nombre '/' nom], 'Position', pos);
b('Continuous/Integrator', 'xdot', [300 100 330 130]);  set_param([nombre '/xdot'], 'InitialCondition', num2str(x0(2)));
b('Continuous/Integrator', 'x',    [420 100 450 130]);  set_param([nombre '/x'],    'InitialCondition', num2str(x0(1)));
b('Math Operations/Product', 'x2', [300 180 330 210]);  set_param([nombre '/x2'], 'Inputs', '2');
b('Math Operations/Bias', 'menos1', [360 180 390 210]); set_param([nombre '/menos1'], 'Bias', '-1');
b('Math Operations/Product', 'amort', [420 180 450 210]);
b('Math Operations/Gain', 'mu', [480 180 510 210]);     set_param([nombre '/mu'], 'Gain', 'mu');
b('Math Operations/Sum', 'suma', [220 100 250 130]);    set_param([nombre '/suma'], 'Inputs', '--');
b('Sinks/Out1', 'y', [520 100 550 130]);
b('Sinks/Out1', 'yd', [520 40 550 70]);
l = @(a, c) add_line(nombre, a, c, 'autorouting', 'on');
l('suma/1', 'xdot/1');  l('xdot/1', 'x/1');  l('x/1', 'y/1');  l('xdot/1', 'yd/1');
l('x/1', 'x2/1');  l('x/1', 'x2/2');  l('x2/1', 'menos1/1');
l('menos1/1', 'amort/1');  l('xdot/1', 'amort/2');  l('amort/1', 'mu/1');
l('mu/1', 'suma/2');  l('x/1', 'suma/1');
save_system(nombre);
assignin('base', 'mu', mu);
out = sim(nombre, 'ReturnWorkspaceOutputs', 'on');
tS = out.tout;  YS = out.yout;                       % columnas: x, x'
[~, XO] = ode45(@(t, x) [x(2); -x(1) - mu*(x(1)^2 - 1)*x(2)], tS, x0, odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
err = max(abs(YS(:,1) - XO(:,1)));
if err < 1e-5
    fprintf('VanDerPol.slx coincide con ode45: max |error| = %.1e\n', err);
else
    warning('Diferencia %.2e: revise los bloques "suma" (signos --) y "menos1" (Bias -1).', err);
end
figure; plot(YS(:,1), YS(:,2)); grid on; xlabel('x'); ylabel('dx/dt'); title('VanDerPol.slx');
