%% C8_Ej3_Duffing -- Notas: sección 8.4 (resorte con amortiguamiento cuadrático)
% QUÉ HACE   x1' = x2, x2' = -(k0 x1 + k1 x1^3) - beta x2 |x2| con la energía V.
%            Resorte duro (k1 = 1): GAS y decaimiento ~ 1/t. Resorte blando (k1 = -1):
%            c* = k0^2/(4|k1|) y un punto con V(x0) < c* que escapa.
% OBSERVE    (1.2, 0) tiene V = 0.2016 < 0.25 y escapa: está en OTRA componente.
% ESPERADO   duro: amplitud x t ~ 6 entre t = 100 y 400. blando: escapa en t = 2.40;
%            (0.9, 0), con V = 0.241, converge.
% EXPLORE    Cambie beta x2|x2| por beta x2. ¿Sigue siendo lento el decaimiento?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:duffing]
k0 = 1;  beta = 0.4;
fd = @(k1) @(t, x) [x(2); -(k0*x(1) + k1*x(1)^3) - beta*x(2)*abs(x(2))];
V  = @(k1, x) k0*x(1)^2/2 + k1*x(1)^4/4 + x(2)^2/2;
% resorte duro: GAS, pero no exponencial
[t, X] = ode45(fd(1), linspace(0, 400, 400001), [2; 0], opc);
for T = [100 200 400]
    fprintf('duro: amplitud(%3d) x %3d = %.2f\n', T, T, max(abs(X(t >= T - 10 & t <= T, 1)))*T);
end
% resorte blando: la componente equivocada
cs = k0^2/(4*abs(-1));
fprintf('blando: c* = %.3f, V(1.2, 0) = %.4f, V(0.9, 0) = %.4f\n', cs, V(-1, [1.2; 0]), V(-1, [0.9; 0]));
escape = odeset(opc, 'Events', @(t, x) deal(abs(x(1)) - 50, 1, 0));
[te, Xe] = ode45(fd(-1), [0 100], [1.2; 0], escape);
fprintf('desde (1.2, 0): |x1| = 50 en t = %.2f\n', te(end));
[~, Xb] = ode45(fd(-1), [0 300], [0.9; 0], opc);
fprintf('desde (0.9, 0): ||x(300)|| = %.1e\n', norm(Xb(end, :)));
% [fin:duffing]

fig = estiloFigura(1000, 420);
subplot(1, 2, 1);  plot(X(t < 60, 1), X(t < 60, 2));  axis equal;  grid on;  title('resorte duro');
subplot(1, 2, 2);  plot(Xb(:, 1), Xb(:, 2), Xe(:, 1), Xe(:, 2));  axis([-2.5 2.5 -1.6 1.6]);  grid on;
title('resorte blando');  legend('$V(x_0)=0.241$', '$V(x_0)=0.202$, escapa');
