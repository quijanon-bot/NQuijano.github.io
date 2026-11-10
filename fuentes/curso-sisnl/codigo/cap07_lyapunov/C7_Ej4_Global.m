%% C7_Ej4_Global -- Notas: sección 7.5 (estabilidad global y exponencial)
% QUÉ HACE   (1) x1' = -6 x1/(1+x1^2)^2 + 2 x2, x2' = -2(x1 + x2)/(1+x1^2)^2 con
%            V = x1^2/(1+x1^2) + x2^2: Vdot < 0 en todo x ~= 0, pero V no es
%            radialmente no acotada y hay soluciones que se van a infinito.
%            (2) x' = -x - x^3 con V = x^2/2: cota exponencial |x(t)| <= |x0| e^{-t}.
% OBSERVE    (1) Desde (2, 2): x1 crece sin límite y x2 tiende a ~2; V(x(t)) sí
%            decrece, pero hacia 1 + x2(inf)^2 ~ 4.66... nunca hacia 0.
% ESPERADO   (1) x1(200) > 700, x2(200) ~ 1.91.  (2) x(1) = 0.3724 <= 3/e = 1.1036.
% EXPLORE    Pruebe condiciones iniciales con V(x0) < 1. ¿Convergen todas? ¿Por qué?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:noacotada]
f = @(t, x) [-6*x(1)/(1 + x(1)^2)^2 + 2*x(2); -2*(x(1) + x(2))/(1 + x(1)^2)^2];
V = @(X) X(:,1).^2./(1 + X(:,1).^2) + X(:,2).^2;
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(f, [0 200], [2; 2], opc);  Vt = V(X);
fprintf('desde (2,2): x(200) = (%.1f, %.3f); V(0) = %.3f, V(200) = %.3f; max dV = %.1e\n', ...
        X(end, 1), X(end, 2), Vt(1), Vt(end), max(diff(Vt)));
[~, Y] = ode45(f, [0 200], [0.5; 0.5], opc);
fprintf('desde (0.5,0.5) (V = %.2f < 1): |x(200)| = %.1e\n', V([0.5 0.5]), norm(Y(end, :)));
% [fin:noacotada]

% [ini:exponencial]
ts = linspace(0, 3, 301);
[~, xe] = ode45(@(t, x) -x - x^3, ts, 3, opc);
fprintf('x'' = -x - x^3 desde 3: x(1) = %.4f <= 3/e = %.4f; max(x - 3e^{-t}) = %.2e\n', ...
        interp1(ts, xe, 1), 3/exp(1), max(xe - 3*exp(-ts(:))));
% [fin:exponencial]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  [X1, X2] = meshgrid(linspace(-6, 6, 241), linspace(-2.5, 2.5, 201));
contour(X1, X2, X1.^2./(1 + X1.^2) + X2.^2, [0.25 0.5 0.75 1 1.5 2]);  hold on;
plot(X(X(:,1) < 6, 1), X(X(:,1) < 6, 2), 'LineWidth', 2.5);  grid on;
xlabel('$x_1$');  ylabel('$x_2$');  title('$V$ no radialmente no acotada');
subplot(1, 2, 2);  semilogy(ts, xe, ts, 3*exp(-ts), '--');  grid on;
xlabel('$t$');  legend('$x(t)$', '$|x_0|e^{-t}$');  title('$\dot x=-x-x^3$: cota exponencial');
