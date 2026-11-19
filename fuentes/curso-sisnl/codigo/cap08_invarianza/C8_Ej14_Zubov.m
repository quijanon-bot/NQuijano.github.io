%% C8_Ej14_Zubov -- Notas: sección 8.8 (la ecuación de Zubov con solución cerrada)
% QUÉ HACE   [z1] x' = -x + x^3, h = 2 x^2: V = x^2 resuelve la ecuación de Zubov.
%            [z2] x1' = -x1 + 2 x1^2 x2, x2' = -x2: W = x2^2/2 + x1^2/(2(1 - x1 x2)),
%            V = 1 - exp(-W). Evalúa el residuo de la ecuación en una malla dentro de
%            {x1 x2 < 1} y simula a ambos lados de la hipérbola.
% OBSERVE    V -> 1 al acercarse a la hipérbola x1 x2 = 1: es la frontera exacta.
% ESPERADO   Residuos ~ 1e-12. (1.9, 0.5) converge; (2.1, 0.5) escapa.
% EXPLORE    Repita [z1] con h = x^2. ¿Cambia V? ¿Cambia {V < 1}?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:z1]
x = linspace(-0.99, 0.99, 199);
res1 = 2*x.*(-x + x.^3) + 2*x.^2.*(1 - x.^2);              % V'(x) f(x) + h (1 - V) con V = x^2
fprintf('[z1] max |residuo| = %.1e\n', max(abs(res1)));
% [fin:z1]

% [ini:z2]
f = @(t, x) [-x(1) + 2*x(1)^2*x(2); -x(2)];
W = @(x1, x2) x2.^2/2 + x1.^2./(2*(1 - x1.*x2));
[X1, X2] = meshgrid(linspace(-3, 3, 241));  dentro = X1.*X2 < 0.98;
h = 1e-6;  F1 = -X1 + 2*X1.^2.*X2;  F2 = -X2;               % derivadas por diferencias centradas
Wd = (W(X1 + h, X2) - W(X1 - h, X2))/(2*h).*F1 + (W(X1, X2 + h) - W(X1, X2 - h))/(2*h).*F2;
res2 = Wd + X1.^2 + X2.^2;                                  % dW/dt + h(x) debe ser 0
fprintf('[z2] max |dW/dt + ||x||^2| en {x1 x2 < 0.98} = %.1e\n', max(abs(res2(dentro))));
[~, X] = ode45(f, [0 30], [1.9; 0.5], opc);
fprintf('desde (1.9, 0.5), w = 0.95: ||x(30)|| = %.1e\n', norm(X(end, :)));
salir = odeset(opc, 'Events', @(t, x) eventoODE(x(1) - 1e3, 1, 0));
[te, ~] = ode45(f, [0 30], [2.1; 0.5], salir);
fprintf('desde (2.1, 0.5), w = 1.05: x1 = 1000 en t = %.3f\n', te(end));
% [fin:z2]

fig = estiloFigura(560, 520);  VV = 1 - exp(-W(X1, X2));  VV(~(X1.*X2 < 1)) = NaN;
contour(X1, X2, VV, [0.25 0.5 0.75 0.9 0.99]);  hold on;  xx = linspace(0.34, 3, 100);
plot(xx, 1./xx, 'r', -xx, -1./xx, 'r', 'LineWidth', 2);  axis equal;  grid on;  title('niveles de $V$');
