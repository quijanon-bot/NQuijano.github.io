%% C9_Ej7_MarkusYamabe -- Notas: sección 9.5 (los valores propios no bastan)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Calcula los valores propios de A(t) en muchos instantes, verifica que
%            Phi(t,0) = [e^{t/2}cos t, e^{-t}sin t; -e^{t/2}sin t, e^{-t}cos t] resuelve
%            Phi' = A Phi y simula desde (1, 0).
% OBSERVE    Valores propios -1/4 +- j sqrt(7)/4 para todo t, y ||x(t)|| = e^{t/2}.
% ESPERADO   ||x(10)|| = e^5 = 148.4.
% EXPLORE    Simule desde (0, 1). ¿Por qué esa solución sí converge?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-13);

% [ini:markus]
A = @(t) [-1 + 1.5*cos(t)^2, 1 - 1.5*sin(t)*cos(t); -1 - 1.5*sin(t)*cos(t), -1 + 1.5*sin(t)^2];
Phi = @(t) [exp(t/2)*cos(t), exp(-t)*sin(t); -exp(t/2)*sin(t), exp(-t)*cos(t)];
lam = zeros(2, 50);  err = 0;  h = 1e-6;
for j = 1:50
    t = 0.2*j;  lam(:, j) = eig(A(t));
    err = max(err, norm((Phi(t + h) - Phi(t - h))/(2*h) - A(t)*Phi(t)));
end
fprintf('valores propios: Re en [%.4f, %.4f], |Im| en [%.4f, %.4f]\n', min(real(lam(:))), ...
    max(real(lam(:))), min(abs(imag(lam(:)))), max(abs(imag(lam(:)))));
fprintf('max ||Phi'' - A Phi|| = %.1e\n', err);
[~, X] = ode45(@(t, x) A(t)*x, [0 10], [1; 0], opc);
fprintf('||x(10)|| = %.2f   e^5 = %.2f\n', norm(X(end, :)), exp(5));
% [fin:markus]

% ---- Figura de las notas (fig:vt-markus) ----------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
[t, X] = ode45(@(t, x) A(t)*x, linspace(0, 8, 3000), [1; 0], opc);  m = t <= 6.5;
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  grid on;
plot(X(m, 1), X(m, 2), 'Color', co, 'LineWidth', 1.4);
tfs = [0 1.2];  cl2 = [az; ve];
for j = 1:2
    [~, Y] = ode45(@(t, x) A(tfs(j))*x, linspace(0, 12, 1500), [1; 0], opc);    % campo congelado A(tf)
    plot(Y(:, 1), Y(:, 2), '--', 'Color', cl2(j, :));
end
plot(0, 0, 'o', 'MarkerFaceColor', no, 'MarkerEdgeColor', no);
axis equal;  axis([-22 22 -22 22]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');
legend('soluci\''on de $\dot x=A(t)x$', 'campo congelado $A(0)$', 'campo congelado $A(1.2)$', 'Location', 'southwest');
title('desde $(1,0)$: la real se va, las congeladas no');
subplot(1, 2, 2);  semilogy(t, sqrt(sum(X.^2, 2)), 'Color', co);  hold on;
semilogy(t, exp(t/2), '--', 'Color', no);  semilogy(t, exp(-t/4), ':', 'Color', az);
grid on;  xlabel('$t$');  legend('$\|x(t)\|$', '$e^{t/2}$', '$e^{-t/4}$ (los valores propios)', 'Location', 'west');
title('$\lambda(A(t))=-0.25\pm0.66j$ para todo $t$');
