%% C5_Ej9_PoincareBendixson -- Notas: sección 5.9 (Poincaré-Bendixson)
% QUÉ HACE   x1' = x1 + x2 - x1 r^2, x2' = -2 x1 + x2 - x2 r^2 (Khalil, ej. 2.8).
%            Verifica las dos condiciones del criterio: el único equilibrio es un
%            foco inestable y M = {V <= c}, V = x1^2 + x2^2, es positivamente
%            invariante para c >= 3/2. Luego simula desde adentro y desde afuera.
% OBSERVE    En la frontera V = c, V' <= 3c - 2c^2, que es <= 0 si c >= 3/2. El
%            criterio garantiza una órbita periódica en M; la simulación muestra
%            un ciclo límite que atrae a las dos condiciones iniciales.
% ESPERADO   Valores propios en el origen: 1 +- 1.4142j.
%            max V' en V = c:  c = 1 -> +1;  c = 1.5 -> 0;  c = 2 -> -2.
%            Ciclo (no es un círculo): r entre 0.8501 y 1.1302, período 4.442.
% EXPLORE    ¿Es el ciclo un círculo? Grafique r(t) en régimen.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:criterio]
f = @(t, x) [x(1) + x(2) - x(1)*(x(1)^2 + x(2)^2); -2*x(1) + x(2) - x(2)*(x(1)^2 + x(2)^2)];
fprintf('valores propios en el origen: %s\n', mat2str(eig([1 1; -2 1]).', 4));
th = linspace(0, 2*pi, 20001);
for c = [1 1.5 2]
    x1 = sqrt(c)*cos(th);  x2 = sqrt(c)*sin(th);
    Vd = 2*c - 2*x1.*x2 - 2*c^2;                 % V' = 2 r^2 - 2 x1 x2 - 2 r^4 en r^2 = c
    fprintf('c = %.1f: max de V'' en la frontera = %+.4f  (3c - 2c^2 = %+.4f)\n', c, max(Vd), 3*c - 2*c^2);
end
% [fin:criterio]

% [ini:simulacion]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
for x0 = [0.01 0; 1.2 0].'
    [t, X] = ode45(f, [0 60], x0, opc);
    k = t > 40;  r = vecnorm(X(k,:).');
    fprintf('desde (%.2f, %.2f): en régimen r entre %.4f y %.4f\n', x0, min(r), max(r));
end
tk = t(k);  x1k = X(k,1);
cruza = tk([false; x1k(1:end-1) < 0 & x1k(2:end) >= 0]);
fprintf('período del ciclo = %.4f\n', mean(diff(cruza)));
% [fin:simulacion]

fig = estiloFigura(560, 560); hold on;
plot(sqrt(1.5)*cos(th), sqrt(1.5)*sin(th), 'k--');
for x0 = [0.01 0; 1.2 0].', [~, X] = ode45(f, [0 30], x0, opc); plot(X(:,1), X(:,2)); end
axis equal; grid on; xlabel('$x_1$'); ylabel('$x_2$'); title('$M=\{V\le 3/2\}$ atrapa al ciclo');
