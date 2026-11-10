%% crearModelo_DiodoTunel -- Construye DiodoTunel.slx por código (Simulink)
% QUÉ HACE   Arma C v' = (E - v)/R - h(v) con un integrador, un bloque
%            Polynomial para la característica h(v) y una fuente E que sube y
%            baja lentamente (Repeating Sequence). Simula 8000 ns y compara con
%            ode45. Es el modelo de la histeresis de la sección 2.6.
% OBSERVE    Grafique v contra E: sube por una rama, salta en E = 1.65 V, baja
%            por la otra y salta en E = 0.65 V.
% ESPERADO   max |v_Simulink - v_ode45| < 1e-4 (si falla, el mensaje dice qué bloque).
% REQUIERE   Simulink.
clear; close all; clc;
nombre = 'DiodoTunel';  R = 1.5;  C = 2;  Tm = 4000;  Emax = 1.8;
if bdIsLoaded(nombre), close_system(nombre, 0); end
new_system(nombre);  open_system(nombre);
set_param(nombre, 'StopTime', num2str(2*Tm), 'Solver', 'ode45', 'RelTol', '1e-9', 'AbsTol', '1e-11', ...
          'MaxStep', '0.5', 'SaveOutput', 'on', 'SaveFormat', 'Array');
b = @(tipo, nom, pos) add_block(['simulink/' tipo], [nombre '/' nom], 'Position', pos);
b('Sources/Repeating Sequence', 'E', [40 95 80 125]);
set_param([nombre '/E'], 'rep_seq_t', mat2str([0 Tm 2*Tm]), 'rep_seq_y', mat2str([0 Emax 0]));
b('Math Operations/Sum', 'EmenosV', [130 95 160 125]); set_param([nombre '/EmenosV'], 'Inputs', '+-');
b('Math Operations/Gain', 'invR', [200 95 240 125]);   set_param([nombre '/invR'], 'Gain', '1/R');
b('Math Operations/Polynomial', 'h', [200 180 260 210]);
set_param([nombre '/h'], 'coefs', '[83.72 -226.31 229.62 -103.79 17.76 0]');   % potencias decrecientes
b('Math Operations/Sum', 'nodo', [290 95 320 125]);    set_param([nombre '/nodo'], 'Inputs', '+-');
b('Math Operations/Gain', 'invC', [350 95 390 125]);   set_param([nombre '/invC'], 'Gain', '1/C');
b('Continuous/Integrator', 'v', [430 95 460 125]);     set_param([nombre '/v'], 'InitialCondition', '0');
b('Sinks/Out1', 'yv', [520 95 550 125]);  b('Sinks/Out1', 'yE', [520 30 550 60]);
l = @(a, c) add_line(nombre, a, c, 'autorouting', 'on');
l('E/1', 'EmenosV/1');  l('v/1', 'EmenosV/2');  l('EmenosV/1', 'invR/1');  l('invR/1', 'nodo/1');
l('v/1', 'h/1');  l('h/1', 'nodo/2');  l('nodo/1', 'invC/1');  l('invC/1', 'v/1');
l('v/1', 'yv/1');  l('E/1', 'yE/1');
save_system(nombre);
assignin('base', 'R', R);  assignin('base', 'C', C);
out = sim(nombre, 'ReturnWorkspaceOutputs', 'on');
tS = out.tout;  YS = out.yout;                      % columnas: v, E
[h, ~] = diodoTunel();  Ef = @(t) Emax*min(t, 2*Tm - t)/Tm;
[~, vO] = ode45(@(t, v) ((Ef(t) - v)/R - h(v))/C, tS, 0, odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 0.5));
err = max(abs(YS(:,1) - vO));
if err < 1e-4
    fprintf('DiodoTunel.slx coincide con ode45: max |error| = %.1e\n', err);
else
    warning('Diferencia %.2e: revise el bloque "h" (coeficientes en potencias DECRECIENTES) y "nodo" (+-).', err);
end
figure; plot(YS(:,2), YS(:,1)); grid on; xlabel('E [V]'); ylabel('v [V]'); title('DiodoTunel.slx: histéresis');
