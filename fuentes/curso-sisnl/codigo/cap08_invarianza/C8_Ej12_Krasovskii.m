%% C8_Ej12_Krasovskii -- Notas: sección 8.7 (el método de Krasovskii)
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
