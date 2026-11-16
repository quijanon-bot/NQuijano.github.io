%% C8_Ej2_PenduloLaSalle -- Notas: sección 8.3 (el péndulo con fricción, por fin)
% QUÉ HACE   Péndulo x1' = x2, x2' = -a sin x1 - b x2 (a = 1, b = 0.3) con la energía V:
%            dibuja Omega_c (c = 1.8), las otras componentes de {V <= c}, el conjunto E,
%            los cruces de la solución con E y el balance b int x2^2 = V(x0) - V(x(t)).
%            [permanencia] calcula M con derivadas de Lie sobre E.
% OBSERVE    En cada cruce Vdot = 0 pero V sigue bajando. Sobre E el campo es vertical.
% ESPERADO   Borde de E: 2.498. 12 cruces en [0, 40]. Balance exacto hasta 1e-7.
%            Solo x1 = 0 anula h, L_f h y L_f^2 h en |x1| < pi: M = {0}.
% EXPLORE    Arranque en (1.2, 0) + (2 pi, 0). ¿A qué equilibrio llega? ¿Contradice el teorema?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:pendulo]
a = 1;  b = 0.3;  c = 1.8;
f = @(t, x) [x(2); -a*sin(x(1)) - b*x(2)];
V = @(x1, x2) a*(1 - cos(x1)) + x2.^2/2;
xE = acos(1 - c/a);                                         % E = {(x1, 0) : |x1| <= xE}
fprintf('E = {x2 = 0, |x1| <= %.3f}\n', xE);
x0 = [2; 0.8];
g = @(t, z) [f(t, z(1:2)); z(2)^2];                         % z(3) = int x2^2
[t, Z] = ode45(g, linspace(0, 40, 40001), [x0; 0], opc);
cruces = sum(diff(sign(Z(:, 2))) ~= 0);
balance = b*Z(end, 3) - (V(x0(1), x0(2)) - V(Z(end, 1), Z(end, 2)));
fprintf('V(x0) = %.3f, cruces con E en [0, 40]: %d, error del balance = %.1e\n', V(x0(1), x0(2)), cruces, balance);
% [fin:pendulo]

% [ini:permanencia]
% Sobre E (x2 = 0) se exige h = x2, L_f h y L_f^2 h nulas a la vez.
h   = @(x) x(2);
Lfh = @(x) [0 1]*f(0, x);                                   % = -a sin x1 - b x2
xs  = linspace(-xE, xE, 2001);
Lf  = arrayfun(@(q) Lfh([q; 0]), xs);
fprintf('puntos de E con L_f h = 0: x1 = %s\n', mat2str(xs(abs(Lf) < 1e-12), 3));
% [fin:permanencia]

fig = estiloFigura(1100, 460);
subplot(1, 2, 1);  [X1, X2] = meshgrid(linspace(-9.5, 9.5, 500), linspace(-2.6, 2.6, 300));
contourf(X1, X2, double(V(X1, X2) <= c) + double(V(X1, X2) <= c & abs(X1) < pi), [0.5 1.5 2.5]);  hold on;
plot([-xE xE], [0 0], 'r', 'LineWidth', 4);  plot(Z(:, 1), Z(:, 2), 'k', 'LineWidth', 1);
xlabel('$x_1$');  ylabel('$x_2$');  title('$\Omega_c$, otras componentes y $E$');
subplot(1, 2, 2);  plot(t, V(Z(:, 1), Z(:, 2)), t, -b*Z(:, 2).^2);  xlim([0 20]);  grid on;
xlabel('$t$');  legend('$V(x(t))$', '$\dot V(x(t))$');
