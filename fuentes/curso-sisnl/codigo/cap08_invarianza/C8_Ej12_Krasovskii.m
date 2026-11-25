%% C8_Ej12_Krasovskii -- Notas: sección 8.7 (el método de Krasovskii)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   [k1] x1' = -3 x1 + x2, x2' = x1 - x2 - x2^3 con P = R = I: verifica en una malla
%            que -(J' + J + I) es definida positiva y simula en el plano z = f(x).
%            [matrizP] oscilador x1' = x2, x2' = -x1 - x2: P = I falla, el P de Lyapunov no.
% OBSERVE    ||f(x(t))|| decrece a lo largo de todas las soluciones.
% ESPERADO   Mínimo valor propio de -(2J + I) en la malla > 0 (vale 1 + 30 x2^2 sobre 5...).
%            Oscilador: con P = I el mayor valor propio de J + J' es 0; P = [1.5 0.5; 0.5 1].
% EXPLORE    Cambie -x2^3 por +x2^3. ¿Dónde se pierde la condición?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:k1]
f = @(x) [-3*x(1) + x(2); x(1) - x(2) - x(2)^3];
J = @(x) [-3 1; 1 -1 - 3*x(2)^2];
lmin = Inf;
for x2 = linspace(-5, 5, 201)                               % J solo depende de x2
    lmin = min(lmin, min(eig(-(J([0; x2])' + J([0; x2]) + eye(2)))));
end
fprintf('min lambda(-(J''+J+I)) en x2 in [-5, 5] = %.3f > 0\n', lmin);
subeMax = -Inf;
for th = linspace(0, 2*pi, 13)
    [~, X] = ode45(@(t, x) f(x), linspace(0, 6, 1501), 2.2*[cos(th); sin(th)], opc);
    nz = arrayfun(@(i) norm(f(X(i, :)')), 1:size(X, 1));
    subeMax = max(subeMax, max(diff(nz)));
end
fprintf('mayor subida de ||f(x(t))|| en 13 soluciones = %.1e (debe ser < 0)\n', subeMax);
% [fin:k1]

% [ini:matrizP]
A = [0 1; -1 -1];
fprintf('P = I: max eig(A + A'') = %.3f (no hay R > 0)\n', max(eig(A + A')));
P = ecuacionLyapunov(A, eye(2));
fprintf('P de Lyapunov = [%.2f %.2f; %.2f %.2f]; A''P + PA = -I; V = x''(A''PA)x con A''PA =\n', P);
disp(A'*P*A);
% [fin:matrizP]

% ---- Figura de las notas (fig:iv-krasovskii) ------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(1200, 520);
[X1, X2] = meshgrid(linspace(-2.6, 2.6, 400));
subplot(1, 2, 1);  hold on;
contour(X1, X2, (-3*X1 + X2).^2 + (X1 - X2 - X2.^3).^2, [0.5 2 6 15 30], 'LineColor', az, 'LineWidth', 0.9);
subplot(1, 2, 2);  hold on;  tc = linspace(0, 2*pi, 200);
for rr = [4 8 12], plot(rr*cos(tc), rr*sin(tc), 'Color', cl, 'LineWidth', 0.8);  end
for th = linspace(0, 2*pi, 13)
    if th >= 2*pi - 1e-9, continue;  end                      % 12 condiciones iniciales
    [~, X] = ode45(@(t, x) f(x), linspace(0, 6, 1500), 2.2*[cos(th); sin(th)], opc);
    Zf = [-3*X(:, 1) + X(:, 2), X(:, 1) - X(:, 2) - X(:, 2).^3];  % z = f(x)
    subplot(1, 2, 1);  plot(X(:, 1), X(:, 2), 'Color', no, 'LineWidth', 0.8);
    subplot(1, 2, 2);  plot(Zf(:, 1), Zf(:, 2), 'Color', vi, 'LineWidth', 0.8);
end
subplot(1, 2, 1);  axis equal;  axis([-2.6 2.6 -2.6 2.6]);  box on;  grid on;
xlabel('$x_1$');  ylabel('$x_2$');  title('plano $x$: niveles de $\|f(x)\|^2$');
subplot(1, 2, 2);  axis equal;  axis([-14 14 -14 14]);  box on;  grid on;
xlabel('$z_1$');  ylabel('$z_2$');  title('plano $z=f(x)$');
