%% C4_Ej8_Centro -- Notas: sección 4.5 (cuando la linealización es un centro)
% QUÉ HACE   Para x1' = x2, x2' = -x1 - eps x1^2 x2 con eps = 1, 0, -1: jacobiana en
%            el origen (la misma para los tres), V = x1^2 + x2^2 a lo largo de una
%            solución y el retrato.
% OBSERVE    La linealización es un centro (lambda = +-j) para todo eps. Con eps = 1
%            el radio baja lentamente; con eps = -1 sube. Lo decide el término cúbico.
% ESPERADO   eps = 1: r(60) = 0.2297 desde r(0) = 0.5. eps = 0: r constante.
%            eps = -1: r crece, de 0.3 a 0.456 en t = 25.
% EXPLORE    Cambie el término por -eps x2^3. ¿Cambia la conclusión? ¿Y con
%            -eps x1^3 (un resorte no lineal)?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:epsilon]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
fig = estiloFigura(1200, 400);
valores = [1 0 -1];  x0s = [0.5 0.5 0.3];  Ts = [60 2*pi 25];
for k = 1:3
    e = valores(k);
    f = @(t, x) [x(2); -x(1) - e*x(1)^2*x(2)];
    A = jacobianoNumerico(@(x) f(0, x), [0; 0]);
    [t, X] = ode45(f, [0 Ts(k)], [x0s(k); 0], opc);
    r = hypot(X(:, 1), X(:, 2));
    fprintf('eps = %+d: lambda(0) = %s;  r(0) = %.2f, r(%g) = %.4f\n', e, num2str(eig(A).', '%.3f  '), r(1), t(end), r(end));
    subplot(1, 3, k);  plot(X(:, 1), X(:, 2));  axis equal;  axis([-1.4 1.4 -1.4 1.4]);  grid on;
    title(sprintf('$\\varepsilon=%d$', e));
end
% [fin:epsilon]
