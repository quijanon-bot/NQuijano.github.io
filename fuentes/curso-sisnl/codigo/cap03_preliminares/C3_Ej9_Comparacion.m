%% C3_Ej9_Comparacion -- Notas: sección 3.10 (lema de comparación)
% QUÉ HACE   Compara la solución de x' = -(1 + x^2) x con la cota |a| e^{-t} del
%            lema de comparación, y la de un sistema de dos estados con la cota
%            ||x(t)||_2 <= e^{-t} ||x(0)||_2 + sqrt(2)(1 - e^{-t}).
% OBSERVE    Las cotas nunca se cruzan con la solución. La segunda no dice que
%            x -> 0, solo que ||x|| termina por debajo de sqrt(2).
% ESPERADO   a = 2: x(1) = 0.3484 <= 2 e^{-1} = 0.7358.
%            Sistema 2D desde (3, -2): max_t (||x(t)|| - cota(t)) < 0;
%            ||x(20)||_2 = 1.4142 (equilibrio (1,1)), justo en la cota sqrt(2).
% EXPLORE    El sistema 2D tiene tres equilibrios. Encuéntrelos. ¿Por qué la cota
%            no puede ser mejor que sqrt(2)?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:escalar]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
a = 2;  [t, X] = ode45(@(t, x) -(1 + x^2)*x, linspace(0, 4, 401), a, opc);
cota = abs(a)*exp(-t);
fprintf('x(1) = %.4f <= %.4f;  max(|x| - cota) = %.2e\n', X(101), cota(101), max(abs(X) - cota));
% [fin:escalar]

% [ini:vectorial]
g  = @(t, x) [-x(1) + 2*x(2)/(1 + x(2)^2); -x(2) + 2*x(1)/(1 + x(1)^2)];
x0 = [3; -2];  [t2, X2] = ode45(g, linspace(0, 20, 2001), x0, opc);
nx = vecnorm(X2.');  cota2 = exp(-t2.')*norm(x0) + sqrt(2)*(1 - exp(-t2.'));
fprintf('max(||x|| - cota) = %.3e;  ||x(20)|| = %.4f;  x(20) = (%.4f, %.4f)\n', ...
        max(nx - cota2), nx(end), X2(end,1), X2(end,2));
% [fin:vectorial]

fig = estiloFigura(1000, 380);
subplot(1,2,1); plot(t, abs(X), t, cota, '--'); grid on; xlabel('$t$'); legend('$|x(t)|$', '$|a|e^{-t}$');
subplot(1,2,2); plot(t2, nx, t2, cota2, '--'); grid on; xlabel('$t$'); legend('$\|x(t)\|_2$', 'cota');
