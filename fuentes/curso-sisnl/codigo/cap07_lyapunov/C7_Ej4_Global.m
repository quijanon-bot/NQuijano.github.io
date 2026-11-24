%% C7_Ej4_Global -- Notas: sección 7.5 (estabilidad global y exponencial)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) x1' = -6 x1/(1+x1^2)^2 + 2 x2, x2' = -2(x1 + x2)/(1+x1^2)^2 con
%            V = x1^2/(1+x1^2) + x2^2: Vdot < 0 en todo x ~= 0, pero V no es
%            radialmente no acotada y hay soluciones que se van a infinito.
%            (2) x' = -x - x^3 con V = x^2/2: cota exponencial |x(t)| <= |x0| e^{-t}.
% OBSERVE    (1) Desde (2, 2): x1 crece sin límite y x2 tiende a ~1.91; V(x(t)) sí
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

% ---- Figura de las notas (fig:ly-noacotada) ---------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  am = [224 159 62]/255;  gr = [0.78 0.78 0.78];
fig1 = estiloFigura(1000, 460);  hold on;
[X1, X2] = meshgrid(linspace(-7, 7, 400), linspace(-3, 3, 300));
VV = X1.^2./(1 + X1.^2) + X2.^2;
[Cc, hc] = contour(X1, X2, VV, [0.3 0.6 0.9 1.5 2.5], 'LineColor', gr, 'LineWidth', 0.9);
clabel(Cc, hc, 'FontSize', 8);
contour(X1, X2, VV, [1 1], 'LineColor', am, 'LineWidth', 2.5);      % c = 1: frontera entre cerrados y abiertos
x0s = [2 2; -2 -2; 0.5 0.5; -1.5 0.6];  cols = [co; co; az; az];
for i = 1:4
    [~, Y] = ode45(f, linspace(0, 400, 40001), x0s(i, :)', opc);  m = abs(Y(:,1)) < 7;
    plot(Y(m,1), Y(m,2), 'Color', cols(i, :), 'LineWidth', 1.4);
    plot(x0s(i,1), x0s(i,2), 'o', 'Color', cols(i, :), 'MarkerFaceColor', cols(i, :), 'MarkerSize', 4);
end
axis([-7 7 -3 3]);  xlabel('$x_1$');  ylabel('$x_2$');
title('$\dot V<0$ en todo $x\neq0$, y aun as\''i hay soluciones que se van');

% Figura adicional (no est\'a en las notas): la cota exponencial de x' = -x - x^3
fig2 = estiloFigura(560, 420);  semilogy(ts, xe, ts, 3*exp(-ts), '--');  grid on;
xlabel('$t$');  legend('$x(t)$', '$|x_0|e^{-t}$');  title('$\dot x=-x-x^3$: cota exponencial');
