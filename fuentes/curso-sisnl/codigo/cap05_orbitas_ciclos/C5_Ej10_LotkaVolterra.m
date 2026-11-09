%% C5_Ej10_LotkaVolterra -- Notas: sección 5.10 (tres modelos presa-depredador)
% QUÉ HACE   (1) Lotka-Volterra clásico (a, b, c, d) = (6, 3, 2, 1): conserva
%            K = d v - c ln v + b p - a ln p y el promedio en un período es el
%            equilibrio (c/d, a/b) = (2, 2). (2) Con competencia (e, f > 0): la
%            función de Volterra decrece y todo converge al equilibrio interior.
%            (3) Rosenzweig-MacArthur v' = v(1 - v/K) - v p/(1 + v),
%            p' = p(beta v/(1 + v) - gamma) con beta = 2, gamma = 1: K = 2.5 estable,
%            K = 5 ciclo límite.
% OBSERVE    Tres respuestas cualitativamente distintas con la misma idea: un
%            continuo de órbitas cerradas (no son ciclos límite), un equilibrio
%            globalmente atractor y un ciclo límite aislado.
% ESPERADO   (1) variación de K a lo largo de la solución < 1e-8; período 1.8761; promedios (2, 2) con error < 1e-3.
%            (2) (a,b,c,d,e,f) = (1,1,0.5,1,0.5,0.2): equilibrio (0.6364, 0.6818).
%            (3) K_H = (beta + gamma)/(beta - gamma) = 3; K = 5: v oscila entre 0.0465 y 4.4666.
% EXPLORE    Aumente K de 2.5 a 5 en pasos de 0.25. ¿Cómo crece la amplitud del
%            ciclo? (Es la "paradoja del enriquecimiento" de Rosenzweig.)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);

% [ini:clasico]
a = 6; b = 3; c = 2; d = 1;
lv = @(t, x) [x(1)*(a - b*x(2)); x(2)*(-c + d*x(1))];
Kf = @(x) d*x(:,1) - c*log(x(:,1)) + b*x(:,2) - a*log(x(:,2));
ev = odeset(opc, 'Events', @(t, x) deal(x(2) - a/b, 0, 1));   % cruce hacia arriba de p = a/b
[t, X, te] = ode45(lv, linspace(0, 10, 40001), [4; 2], ev);
k = t >= te(1) & t <= te(2);                                    % exactamente un período
fprintf('(1) variación de K = %.1e;  período = %.4f;  promedios: v = %.4f, p = %.4f\n', ...
        max(Kf(X)) - min(Kf(X)), te(2) - te(1), ...
        trapz(t(k), X(k,1))/(te(2) - te(1)), trapz(t(k), X(k,2))/(te(2) - te(1)));
% [fin:clasico]

% [ini:competencia]
a = 1; b = 1; c = 0.5; d = 1; e = 0.5; f = 0.2;
v3 = (a*f + b*c)/(b*d + e*f);  p3 = (a*d - c*e)/(b*d + e*f);
lvc = @(t, x) [x(1)*(a - e*x(1) - b*x(2)); x(2)*(-c + d*x(1) - f*x(2))];
[t, X] = ode45(lvc, [0 80], [0.2; 2], opc);
W = d*(X(:,1) - v3*log(X(:,1))) + b*(X(:,2) - p3*log(X(:,2)));
fprintf('(2) equilibrio (%.4f, %.4f); x(80) = (%.4f, %.4f); W decreciente: %d\n', ...
        v3, p3, X(end,1), X(end,2), all(diff(W) <= 1e-10));
% [fin:competencia]

% [ini:rosenzweig]
beta = 2;  gam = 1;  vs = gam/(beta - gam);
fprintf('(3) v* = %g, K_H = %g\n', vs, (beta + gam)/(beta - gam));
for K = [2.5 5]
    rm = @(t, x) [x(1)*(1 - x(1)/K) - x(1)*x(2)/(1 + x(1)); x(2)*(beta*x(1)/(1 + x(1)) - gam)];
    ps = (1 - vs/K)*(1 + vs);
    [t, X] = ode45(rm, [0 800], [1.1*vs; ps], odeset(opc, 'MaxStep', 0.5));
    v = X(t > 600, 1);
    fprintf('    K = %.1f: equilibrio (%g, %.4f); en régimen v entre %.4f y %.4f\n', K, vs, ps, min(v), max(v));
end
% [fin:rosenzweig]
