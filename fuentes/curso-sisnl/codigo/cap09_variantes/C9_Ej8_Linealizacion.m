%% C9_Ej8_Linealizacion -- Notas: sección 9.5 (la linealización necesita uniformidad)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   x1' = -x1 + t x2^2, x2' = x1 - x2 desde (0.1, 0.1) con t0 = 0, 10 y 100,
%            deteniendo la simulación si ||x|| llega a 1e3.
% OBSERVE    La linealización [-1 0; 1 -1] es la misma para todo t0 y es Hurwitz; el
%            término t x2^2 crece con el reloj.
% ESPERADO   t0 = 0 converge; t0 = 10 explota en t = 16.33; t0 = 100 también explota.
% EXPLORE    Con t0 = 10, reduzca la condición inicial hasta que converja. ¿Y con t0 = 100?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, x) eventoODE(norm(x) - 1e3, 1, 0));

% [ini:linealizacion]
f = @(t, x) [-x(1) + t*x(2)^2; x(1) - x(2)];
fprintf('valores propios de la linealización: %g %g\n', eig([-1 0; 1 -1]));
for t0 = [0 10 100]
    [t, X] = ode45(f, [t0 t0 + 50], [0.1; 0.1], opc);
    if norm(X(end, :)) >= 1e3 - 1
        fprintf('t0 = %3d: explota en t = %.2f\n', t0, t(end));
    else
        fprintf('t0 = %3d: converge, ||x(t0 + 50)|| = %.1e\n', t0, norm(X(end, :)));
    end
end
% [fin:linealizacion]

% ---- Figura de las notas (fig:vt-linealizacion) ---------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(760, 420);  t0s = [0 10 100];  cl3 = [az; am; co];  et = cell(1, 4);
for j = 1:3
    t0 = t0s(j);  [t, X] = ode45(f, [t0 t0 + 40], [0.1; 0.1], odeset(opc, 'MaxStep', 0.01));
    semilogy(t - t0, sqrt(sum(X.^2, 2)), 'Color', cl3(j, :), 'LineWidth', 1.4);  hold on;
    et{j} = sprintf('$t_0=%d$', t0);  if norm(X(end, :)) >= 1e3 - 1, et{j} = [et{j} ' (escapa)'];  end
end
[t, X] = ode45(@(t, x) [-x(1); x(1) - x(2)], linspace(0, 40, 500), [0.1; 0.1], odeset('RelTol', 1e-10, 'AbsTol', 1e-14));
semilogy(t, sqrt(sum(X.^2, 2)), '--', 'Color', gr);  et{4} = 'linealizaci\''on (para todo $t_0$)';
ylim([1e-12 2e3]);  grid on;  xlabel('$t-t_0$');  ylabel('$\|x\|$');  legend(et);
title('$\dot x_1=-x_1+t\,x_2^2$: desde $(0.1,0.1)$');
