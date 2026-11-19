%% C9_Ej11_VanDerPol -- Notas: sección 9.7 (inestable no es no acotado)
% QUÉ HACE   Van der Pol con mu = 1: mide el rango de ||x|| sobre el ciclo límite y el
%            tiempo que tarda en salir de la bola unitaria la solución desde (delta, 0).
% OBSERVE    El origen es inestable y todas las soluciones están acotadas.
% ESPERADO   1.53 <= ||x|| <= 2.83 en el ciclo; salida en t = 8.90, 18.97, 27.23 para
%            delta = 1e-2, 1e-4, 1e-6 (aprox. 2 ln(1/delta)).
% EXPLORE    Cambie mu por 0.2. ¿Cómo cambia el tiempo de salida? Relaciónelo con la parte
%            real de los valores propios del origen.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-14);

% [ini:vdp]
f = @(t, x) [x(2); -x(1) + (1 - x(1)^2)*x(2)];
[t, X] = ode45(f, linspace(0, 100, 100001), [2; 0], opc);
nx = sqrt(sum(X(t > 60, :).^2, 2));
fprintf('ciclo: %.3f <= ||x|| <= %.3f\n', min(nx), max(nx));
sal = odeset(opc, 'Events', @(t, x) eventoODE(norm(x) - 1, 1, 1));
for d = [1e-2 1e-4 1e-6]
    [te, ~] = ode45(f, [0 100], [d; 0], sal);
    fprintf('delta = %.0e: sale de B_1 en t = %.2f   (2 ln(1/delta) = %.2f)\n', d, te(end), 2*log(1/d));
end
% [fin:vdp]

fig = estiloFigura(600, 520);  plot(X(t > 60, 1), X(t > 60, 2), 'r', 'LineWidth', 2);  hold on;
[~, Y] = ode45(f, [0 30], [0.01; 0], opc);  plot(Y(:, 1), Y(:, 2), 'k');
th = linspace(0, 2*pi, 200);  plot(cos(th), sin(th), 'k:');  axis equal;  grid on;
title('inestable, y todo queda acotado');
