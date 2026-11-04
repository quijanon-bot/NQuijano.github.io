%% C11_Ej12_Cascada -- Notas: sección 11.9 (pasivación de una cascada)
% QUÉ HACE   z' = u (H1 pasivo, y = z) en cascada con x' = -x + x^2 z (H2, GAS si z = 0).
%            Compara la ley "ingenua" u = -k z con la ley por pasivación
%            u = -(dW/dx F(x,y))' - k y = -x^3 - k z, con W = x^2/2.
% OBSERVE    Con u = -k z, z -> 0 exponencialmente y aun así x escapa a infinito
%            en tiempo finito si x0 z0 > 1 + k. Con la pasivación, U = W + z^2/2
%            no crece y el origen es globalmente estable.
% ESPERADO   x0 = 1, z0 = 3, k = 1: escape en t = ln(3)/2 = 0.5493.
%            Con pasivación: |(x, z)|(30) ~ 1e-13 y U no creciente.
% EXPLORE    Halle con la fórmula exacta el tiempo de escape para z0 = 2.5.
clear; close all; clc;

% [ini:escape]
k = 1;  x0 = 1;  z0 = 3;                   % x0 z0 = 3 > 1 + k = 2
evento = @(t, x) deal(abs(x(1)) - 1e6, 1, 0);
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12, 'Events', evento);
[t, X, te] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -k*x(2)], [0 5], [x0; z0], opc);
% fórmula exacta: con w = 1/x, w' = w - z0 e^{-k t}  ->  w = 0 en
tex = log((z0/(1 + k))/(z0/(1 + k) - 1/x0))/(1 + k);
fprintf('u = -k z: |x| llega a 1e6 en t = %.4f;  escape exacto en t = %.4f\n', te, tex);
% [fin:escape]

% [ini:pasivacion]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -x(1)^3 - k*x(2)], [0 30], [x0; z0], opc);
U = X(:,1).^2/2 + X(:,2).^2/2;             % W(x) + V(z)
fprintf('pasivación: |(x,z)|(30) = %.1e;  ¿U no creciente? %d\n', norm(X(end,:)), ...
        all(diff(U) <= 1e-12));
% [fin:pasivacion]
