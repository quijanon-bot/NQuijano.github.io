%% C10_Ej3_EnergiaFutura -- Notas: sección 10.3 (la energía futura)
% QUÉ HACE   Para x' = A x, A = [0 1; -1 -1]: calcula V(x0) = int_0^inf ||e^{A tau} x0||^2
%            numéricamente y la compara con x0' P x0, P de A'P + PA = -I.
%            Verifica que dV(x(t))/dt = -||x(t)||^2.
% OBSERVE    La integral y la forma cuadrática coinciden: la ecuación de Lyapunov es la
%            condición de que la energía futura se pierda al ritmo ||x||^2.
% ESPERADO   P = [1.5 0.5; 0.5 1]; V(1, 0.5) = 2.25.
% EXPLORE    Repita con A = [0 1; -2 -3]. ¿Coincide con el P del problema 10.4?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:energia]
A = [0 1; -1 -1];  x0 = [1; 0.5];
P = ecuacionLyapunov(A, eye(2));
Vint = integral(@(tau) arrayfun(@(s) norm(expm(A*s)*x0)^2, tau), 0, 60);
fprintf('P = [%.3f %.3f; %.3f %.3f]\n', P);
fprintf('integral = %.6f,  x0''P x0 = %.6f\n', Vint, x0'*P*x0);
t = 1.3;  h = 1e-5;  V = @(s) (expm(A*s)*x0)'*P*(expm(A*s)*x0);
fprintf('dV/dt en t = 1.3: %.6f;  -||x||^2 = %.6f\n', (V(t + h) - V(t - h))/(2*h), -norm(expm(A*t)*x0)^2);
% [fin:energia]

fig = estiloFigura(900, 420);  tt = linspace(0, 12, 400);
n2 = arrayfun(@(s) norm(expm(A*s)*x0)^2, tt);
area(tt, n2, 'FaceAlpha', 0.3);  grid on;  xlabel('$\tau$');  ylabel('$\|\phi(\tau;x_0)\|^2$');
title(sprintf('\\''area $=%.2f=V(x_0)$', Vint));
