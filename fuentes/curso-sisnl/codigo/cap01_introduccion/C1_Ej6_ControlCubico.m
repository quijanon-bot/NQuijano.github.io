%% C1_Ej6_ControlCubico -- Notas: sección 1.6 (cuando el control lineal no sirve)
% QUÉ HACE   Planta x' = x + u^3, x(0) = 1. Compara u = 0, la realimentación
%            lineal u = -k x y la no lineal u = -(k x)^(1/3), con k = 5.
% OBSERVE    Con u = -k x el lazo cerrado es x' = x - k^3 x^3: el origen sigue
%            siendo INESTABLE (su linealización es x' = x) y aparecen dos
%            equilibrios nuevos, +-k^(-3/2). Desde x(0) = 1 la solución llega a
%            k^(-3/2) = 0.0894, no al origen. Con u = -(k x)^(1/3) el lazo
%            cerrado es x' = (1 - k) x: exponencialmente estable.
% ESPERADO   x(5) con u = -k x: 0.0894.  x(5) con u = -(kx)^(1/3): exp(-20) = 2.1e-9.
%            Ninguna ganancia lineal estabiliza el origen: el lazo x' = x - k^3 x^3
%            tiene f'(0) = 1 para todo k.
% EXPLORE    Pruebe x(0) = -1 y x(0) = 1e-6 con u = -k x. ¿A dónde converge cada uno?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:leyes]
k = 5;  x0 = 1;  opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-14);
u_nula   = @(x) 0;
u_lineal = @(x) -k*x;
u_nolin  = @(x) -nthroot(k*x, 3);           % raíz cúbica REAL (no (k*x)^(1/3))
leyes = {u_nula, u_lineal, u_nolin};  nombres = {'u = 0', 'u = -k x', 'u = -(k x)^(1/3)'};
for i = 1:3
    u = leyes{i};  T = 5;  if i == 1, T = 3; end
    [t, x] = ode45(@(t, x) x + u(x)^3, [0 T], x0, opc);
    fprintf('%-18s x(%g) = %.4g\n', nombres{i}, T, x(end));
    sol{i} = [t x];                                                        %#ok<SAGROW>
end
fprintf('Equilibrios nuevos con u = -k x:  +-k^(-3/2) = +-%.4f\n', k^(-1.5));
% [fin:leyes]

fig = estiloFigura(1000, 420);
subplot(1, 2, 1); hold on; for i = 1:3, plot(sol{i}(:,1), sol{i}(:,2)); end
grid on; ylim([-0.1 1.5]); xlabel('$t$'); ylabel('$x$'); legend('$u=0$', '$u=-kx$', '$u=-(kx)^{1/3}$');
subplot(1, 2, 2); s = linspace(-0.25, 0.25, 501); plot(s, s - k^3*s.^3, s, (1 - k)*s); hold on;
plot([-0.25 0.25], [0 0], 'k'); plot([-1 0 1]*k^(-1.5), [0 0 0], 'ko'); grid on;
xlabel('$x$'); ylabel('$\dot x$'); legend('$u=-kx$', '$u=-(kx)^{1/3}$'); title('campo en lazo cerrado');
