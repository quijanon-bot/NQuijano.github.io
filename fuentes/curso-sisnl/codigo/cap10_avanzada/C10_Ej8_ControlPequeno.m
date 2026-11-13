%% C10_Ej8_ControlPequeno -- Notas: sección 10.4 (cuando falla la propiedad de control pequeño)
% QUÉ HACE   Para x' = x + x^2 u con V = x^2/2 (CLF): aplica Sontag,
%            k(x) = -(1 + sqrt(1 + x^8))/x, y simula desde x(0) = 1.
% OBSERVE    x(t) -> 0 pero |u(t)| crece sin cota: la ley no es continua en el origen.
%            Por Artstein, ninguna realimentación continua estabiliza este sistema.
% ESPERADO   x(8) = 3.2e-4 (~ e^{-8}); |u(8)| = 6249.
% EXPLORE    Cambie a x' = x^3 + x^2 u (sí hay control pequeño). ¿Qué pasa con |u|?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:pequeno]
k = @(x) leySontag(x^2, x^3);
fprintf('k(0.1) = %.3f, cerrada: %.3f\n', k(0.1), -(1 + sqrt(1 + 0.1^8))/0.1);
[t, X] = ode45(@(t, x) x + x^2*k(x), [0 8], 1, odeset('RelTol', 1e-10, 'AbsTol', 1e-14));
fprintf('x(8) = %.3e (e^{-8} = %.3e);  |u(8)| = %.0f\n', X(end), exp(-8), abs(k(X(end))));
% [fin:pequeno]

fig = estiloFigura(700, 420);
semilogy(t, abs(X), t, abs(arrayfun(k, X)));  grid on;  xlabel('$t$');  legend('$|x|$', '$|u|$');
