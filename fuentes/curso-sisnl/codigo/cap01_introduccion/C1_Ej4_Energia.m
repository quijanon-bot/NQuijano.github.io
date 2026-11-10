%% C1_Ej4_Energia -- Notas: sección 1.5 (la semilla del método de Lyapunov)
% QUÉ HACE   Simula el masa-resorte con fricción m y'' + c y' + k y = 0 (m = 1,
%            k = 4, c = 0.5) desde x(0) = (1, 0) y calcula la energía
%            E = k x1^2/2 + m x2^2/2 a lo largo de la solución. Compara
%            dE/dt numérica con la fórmula -c x2^2.
% OBSERVE    E nunca crece, pero tiene tramos casi planos: en los instantes en
%            que x2 = 0, dE/dt = 0. La solución toca el conjunto {x2 = 0} y no se
%            queda en él, salvo en el origen: eso es lo que hace falta para
%            concluir que x1 -> 0 (principio de invarianza, capítulo 8).
% ESPERADO   E(0) = 2, E(5) = 0.1827, E(10) = 0.0153, E(20) = 8.5e-5.
%            |dE/dt + c x2^2| < 1e-4 en toda la simulación (la derivada se
%            calcula por diferencias finitas, de ahí el error).
% EXPLORE    Ponga c = 0. ¿Qué le pasa a E? ¿Y si c < 0?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:energia]
m = 1;  k = 4;  c = 0.5;
f = @(t, x) [x(2); (-k*x(1) - c*x(2))/m];
E = @(x) 0.5*k*x(:,1).^2 + 0.5*m*x(:,2).^2;
t = linspace(0, 20, 4001)';
[t, X] = ode45(f, t, [1; 0], odeset('RelTol', 1e-11, 'AbsTol', 1e-12));
En = E(X);
dE = gradient(En, t);                       % derivada numérica de E(x(t))
fprintf('E(0) = %.4f, E(5) = %.4f, E(10) = %.4f, E(20) = %.2e\n', En(1), En(1001), En(2001), En(end));
fprintf('max |dE/dt + c x2^2| = %.1e  (diferencias finitas)\n', max(abs(dE(2:end-1) + c*X(2:end-1,2).^2)));
% [fin:energia]

fig = estiloFigura(1000, 420);
subplot(1, 2, 1); plot(t, X); grid on; xlabel('$t$'); legend('$x_1=y$', '$x_2=\dot y$'); title('estados');
subplot(1, 2, 2); semilogy(t, En); grid on; xlabel('$t$'); ylabel('$E(x(t))$');
title('la energ\''ia nunca crece');
