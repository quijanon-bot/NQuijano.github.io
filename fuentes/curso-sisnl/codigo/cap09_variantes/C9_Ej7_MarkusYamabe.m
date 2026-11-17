%% C9_Ej7_MarkusYamabe -- Notas: sección 9.5 (los valores propios no bastan)
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

[t, X] = ode45(@(t, x) A(t)*x, linspace(0, 8, 800), [1; 0], opc);
fig = estiloFigura(700, 380);  semilogy(t, sqrt(sum(X.^2, 2)), t, exp(t/2), 'k--', t, exp(-t/4), 'b:');
grid on;  xlabel('$t$');  legend('$\|x(t)\|$', '$e^{t/2}$', '$e^{-t/4}$');
