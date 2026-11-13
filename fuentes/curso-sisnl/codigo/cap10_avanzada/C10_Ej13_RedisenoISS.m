%% C10_Ej13_RedisenoISS -- Notas: sección 10.6 (estabilizar no es robustecer)
% QUÉ HACE   Para x' = x + (x^2 + 1)(u + w), con w un error aditivo en el actuador:
%            (1) cancelación exacta k = -2x/(x^2+1), con w = 1 desde x(0) = 0;
%            (2) rediseño k1 = k - L_gV, V = x^2/2, con w = 1;
%            (3) Sontag con kappa = 1, con w = 1;
%            (4) cancelación con w = 0.1: equilibrios x_- y x_+ y escape desde 10.5.
% OBSERVE    La cancelación escapa aun desde el equilibrio; las otras dos leyes quedan
%            acotadas. Con w pequeño, la cancelación tiene un umbral x_+ ~ 1/w.
% ESPERADO   Escape en 4 pi/(3 sqrt 3) = 2.418; k1: x -> 0.4887; Sontag: x -> 0.386;
%            w = 0.1: x_- = 0.101, x_+ = 9.90.
% EXPLORE    Repita (2) con V2 = ln(1 + x^2)/2, para la cual L_gV2 = x. ¿Dónde se asienta x?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:rediseno]
k  = @(x) -2*x/(x^2 + 1);
k1 = @(x) k(x) - x*(x^2 + 1);                            % - L_gV con V = x^2/2
kS = @(x) leySontag(x^2, x*(x^2 + 1), 1);                % Sontag con kappa = 1
planta = @(x, u, w) x + (x^2 + 1)*(u + w);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, x) deal(x - 1e6, 1, 1));
[~, ~, te] = ode45(@(t, x) planta(x, k(x), 1), [0 5], 0, opc);
fprintf('cancelación, w = 1: escapa en t = %.4f (4 pi/(3 sqrt3) = %.4f)\n', te, 4*pi/(3*sqrt(3)));
[~, X1] = ode45(@(t, x) planta(x, k1(x), 1), [0 10], 0, opc);
[~, XS] = ode45(@(t, x) planta(x, kS(x), 1), [0 10], 0, opc);
fprintf('con -L_gV, w = 1: x(10) = %.4f;  Sontag kappa = 1: x(10) = %.4f\n', X1(end), XS(end));
e = 0.1;  xm = (1 - sqrt(1 - 4*e^2))/(2*e);  xp = (1 + sqrt(1 - 4*e^2))/(2*e);
[~, ~, te2] = ode45(@(t, x) planta(x, k(x), e), [0 5], 10.5, opc);
fprintf('cancelación, w = 0.1: x_- = %.4f, x_+ = %.4f; desde 10.5 escapa en t = %.3f\n', xm, xp, te2);
% [fin:rediseno]

fig = estiloFigura(700, 420);  [t1, Y1] = ode45(@(t, x) planta(x, k(x), 1), [0 2.4], 0);
[t2, Y2] = ode45(@(t, x) planta(x, k1(x), 1), [0 6], 0);
plot(t1, Y1, t2, Y2);  ylim([-0.5 10]);  grid on;  xlabel('$t$');  ylabel('$x$');  legend('cancelaci\''on', 'con $-L_gV$');
