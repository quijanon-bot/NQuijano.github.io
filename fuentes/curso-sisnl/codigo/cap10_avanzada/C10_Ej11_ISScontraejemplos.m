%% C10_Ej11_ISScontraejemplos -- Notas: sección 10.6 (GES con w = 0 no basta)
% QUÉ HACE   (1) x' = -x + x w con w = 2: crecimiento exponencial.
%            (2) x' = -3x + (1 + 2x^2) w con w = 1, x(0) = 2: compara la simulación con
%            la solución cerrada x(t) = (3 - e^t)/(3 - 2e^t) y mide el escape.
% OBSERVE    Los dos sistemas son GES con w = 0, y una entrada constante los dispara.
% ESPERADO   Escape en t = ln(3/2) = 0.405.
% EXPLORE    Use w = 0.1 en (2). ¿Desde qué x(0) escapa? (Busque las raíces de 0.2x^2 - 3x + 0.1.)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:contra]
fprintf('(1) x(5) con w = 2 y x(0) = 1: %.1f = e^5\n', exp(5));
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12, 'Events', @(t, x) deal(x - 1e6, 1, 1));
[t, X, te] = ode45(@(t, x) -3*x + (1 + 2*x^2), [0 1], 2, opc);
xc = @(t) (3 - exp(t))./(3 - 2*exp(t));
fprintf('(2) escape simulado en t = %.5f;  ln(3/2) = %.5f\n', te, log(1.5));
fprintf('    error contra la solución cerrada en t = 0.3: %.1e\n', abs(interp1(t, X, 0.3) - xc(0.3)));
% [fin:contra]

fig = estiloFigura(700, 420);  plot(t, X, t, xc(t), '--');  ylim([0 50]);  grid on;  xlabel('$t$');  ylabel('$x$');
