%% C7_Ej10_RegionAtraccion -- Notas: sección 7.8 (estimar la región de atracción)
% QUÉ HACE   Van der Pol en tiempo invertido, x1' = -x2, x2' = x1 + (x1^2 - 1) x2. Su
%            linealización es A = [0 -1; 1 -1], así que P = [1.5 -0.5; -0.5 1] (de
%            A'P + PA = -I) da una función de Lyapunov local V = x'Px. Calcula
%            c* = min{V(x) : Vdot(x) = 0, x ~= 0} y la cota con bolas.
% OBSERVE    Omega_c = {V <= c} con c < c* es una estimación válida de la región de
%            atracción: es invariante y Vdot < 0 dentro. La región real llega hasta el
%            ciclo límite (inestable): la estimación elíptica es conservadora.
% ESPERADO   Vdot = -|x|^2 - x1^3 x2 + 2 x1^2 x2^2; c* = 2.3045; cota con bola 0.618.
% EXPLORE    Repita con Q = diag(1, q) para q en [0.2, 5]. ¿Cuánto mejora el área?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:region]
f = @(t, x) [-x(2); x(1) + (x(1)^2 - 1)*x(2)];
P = ecuacionLyapunov([0 -1; 1 -1], eye(2));
th = linspace(0, 2*pi, 72001);  c = cos(th);  s = sin(th);
k = -c.^3.*s + 2*c.^2.*s.^2;               % Vdot(r d) = -r^2 + k r^4: se anula en r^2 = 1/k
r = 1./sqrt(k(k > 0));  D = [c(k > 0); s(k > 0)].*[r; r];
Vt = sum(D.*(P*D));  [cEst, i] = min(Vt);
fprintf('c* = %.4f, tangencia en x = (%.3f, %.3f); cota con bola: %.4f\n', ...
        cEst, D(:, i), min(eig(P))*2/sqrt(5));
% [fin:region]

opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, X] = ode45(@(t, x) -f(t, x), [0 20], [2; 0], opc);       % el ciclo: tiempo hacia atrás
[~, Y] = ode45(f, [0 20], 0.99*sqrt(cEst)*D(:, i)/sqrt(D(:, i)'*P*D(:, i)), opc);
fprintf('desde la frontera de Omega_c* (x 0.99): |x(20)| = %.1e\n', norm(Y(end, :)));
fig = estiloFigura(700, 620);
[X1, X2] = meshgrid(linspace(-3, 3, 301));
V = 1.5*X1.^2 - X1.*X2 + X2.^2;  W = -X1.^2 - X2.^2 - X1.^3.*X2 + 2*X1.^2.*X2.^2;
contour(X1, X2, W, [0 0], 'k');  hold on;  contour(X1, X2, V, cEst*[1 1], 'LineWidth', 3);
n = size(X, 1);  plot(X(round(n/2):end, 1), X(round(n/2):end, 2), 'LineWidth', 2);  plot(Y(:,1), Y(:,2));
axis equal;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('$\Omega_{c^*}$, $\{\dot V=0\}$ y el ciclo l\''imite');
