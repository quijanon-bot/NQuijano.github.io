%% C9_Ej8_Linealizacion -- Notas: sección 9.5 (la linealización necesita uniformidad)
% QUÉ HACE   x1' = -x1 + t x2^2, x2' = x1 - x2 desde (0.1, 0.1) con t0 = 0, 10 y 100,
%            deteniendo la simulación si ||x|| llega a 1e3.
% OBSERVE    La linealización [-1 0; 1 -1] es la misma para todo t0 y es Hurwitz; el
%            término t x2^2 crece con el reloj.
% ESPERADO   t0 = 0 converge; t0 = 10 explota en t = 16.33; t0 = 100 también explota.
% EXPLORE    Con t0 = 10, reduzca la condición inicial hasta que converja. ¿Y con t0 = 100?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, x) deal(norm(x) - 1e3, 1, 0));

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

fig = estiloFigura(700, 380);
for t0 = [0 10 100]
    [t, X] = ode45(f, [t0 t0 + 30], [0.1; 0.1], opc);  semilogy(t - t0, sqrt(sum(X.^2, 2)));  hold on;
end
grid on;  xlabel('$t-t_0$');  ylabel('$\|x\|$');  legend('$t_0=0$', '$t_0=10$', '$t_0=100$');
