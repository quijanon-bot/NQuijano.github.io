%% C4_Ej1_CampoVectorial -- Notas: sección 4.2 (el plano de fase)
% QUÉ HACE   (1) Dibuja con quiver el campo x1' = 2 x1 x2, x2' = x1 x2, con
%            flechas normalizadas, y algunas trayectorias. (2) Masa-resorte
%            x1' = x2, x2' = -w^2 x1 (w = 2): campo y órbitas cerradas.
% OBSERVE    (1) Las trayectorias son rectas x1 - 2 x2 = cte (paralelas a (2,1)),
%            y los dos ejes están hechos de equilibrios. (2) El flujo gira en
%            sentido HORARIO y w^2 x1^2 + x2^2 se conserva.
% ESPERADO   (1) f(1,2) = (4,2); desde (1,2), x1 - 2 x2 = -3 todo el tiempo.
%            (2) variación de w^2 x1^2 + x2^2 en 10 s: ~1e-9 (error numérico).
% EXPLORE    Dibuje (1) sin normalizar las flechas (quiver(X1,X2,U,V)). ¿Qué se ve
%            peor? Agregue fricción a (2): x2' = -w^2 x1 - b x2.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:campo]
f = @(x) [2*x(1)*x(2); x(1)*x(2)];
fprintf('f(1,2) = (%g, %g)\n', f([1; 2]));
fig = estiloFigura(1100, 480);
ax = subplot(1, 2, 1);
retratoFase(ax, f, [-3 3], [-3 3], 'X0', [1 -1 2 -2 0.5; 2 -2 -1 1 -0.5], 'T', 2, 'Atras', true);
title('$\dot x_1=2x_1x_2,\ \dot x_2=x_1x_2$');
[~, X] = ode45(@(t, x) f(x), [0 0.3], [1; 2], odeset('RelTol', 1e-10));
fprintf('desde (1,2): x1 - 2 x2 va de %.6f a %.6f\n', 1 - 2*2, X(end, 1) - 2*X(end, 2));
% [fin:campo]

% [ini:resorte]
w = 2;  g = @(x) [x(2); -w^2*x(1)];
ax = subplot(1, 2, 2);
retratoFase(ax, g, [-1.6 1.6], [-3.2 3.2], 'X0', [0.2 0.4 0.6 0.8 1.0 1.3; zeros(1, 6)], 'T', 2*pi/w);
title('Masa--resorte, $\omega=2$');
[~, X] = ode45(@(t, x) g(x), [0 10], [1; 0], odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
E = w^2*X(:, 1).^2 + X(:, 2).^2;
fprintf('masa-resorte: variación de w^2 x1^2 + x2^2 = %.2e\n', max(E) - min(E));
% [fin:resorte]
