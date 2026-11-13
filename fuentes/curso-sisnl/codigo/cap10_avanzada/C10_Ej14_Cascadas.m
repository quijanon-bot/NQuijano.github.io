%% C10_Ej14_Cascadas -- Notas: sección 10.7 (cascadas)
% QUÉ HACE   (1) x1' = -x1 + x1^2 x2, x2' = -x2 desde (2, 2): escape y su tiempo.
%            (2) x1' = -x1 + x1 x2^2, x2' = -x2 desde (1, 3): solución cerrada y pico.
%            (3) x1' = -x1 + x2^2, x2' = -x2 + w con w = 0.3 sin t: cascada ISS.
% OBSERVE    (1) escapa aunque los dos subsistemas sean GAS; (2) no escapa: el
%            transitorio es grande pero el origen es GAS; (3) queda acotada.
% ESPERADO   (1) t_e = ln(2)/2 = 0.347. (2) pico 18.2 = e^{4 - ln 3} en t = ln 3.
%            (3) limsup |x1| <= (limsup |x2|)^2.
% EXPLORE    En (1), ¿qué pasa desde (1, 1.9)? ¿Y desde (1, 2.1)? Compare con x10 x20 > 2.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:cascadas]
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12, 'Events', @(t, x) deal(abs(x(1)) - 1e8, 1, 1));
[~, ~, te] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -x(2)], [0 2], [2; 2], opc);
fprintf('(1) escape en t = %.5f;  ln(2)/2 = %.5f\n', te, log(2)/2);
x1c = @(t) exp(-t + 9/2*(1 - exp(-2*t)));
[t, X] = ode45(@(t, x) [-x(1) + x(1)*x(2)^2; -x(2)], [0 10], [1; 3], odeset('RelTol', 1e-11, 'AbsTol', 1e-12));
fprintf('(2) error contra la cerrada: %.1e;  pico = %.3f en t = ln 3; x1(10) = %.2e\n', ...
        max(abs(X(:, 1) - x1c(t))), x1c(log(3)), X(end, 1));
[t3, Z] = ode45(@(t, x) [-x(1) + x(2)^2; -x(2) + 0.3*sin(t)], linspace(0, 60, 6001), [2; -2], odeset('RelTol', 1e-10));
Z = Z(t3 >= 30, :);
fprintf('(3) limsup |x1| = %.4f <= (limsup |x2|)^2 = %.4f\n', max(abs(Z(:, 1))), max(abs(Z(:, 2)))^2);
% [fin:cascadas]

fig = estiloFigura(700, 420);  plot(t, X);  grid on;  xlabel('$t$');  legend('$x_1$', '$x_2$');
title('$\dot x_1=-x_1+x_1x_2^2$: transitorio grande, sin escape');
