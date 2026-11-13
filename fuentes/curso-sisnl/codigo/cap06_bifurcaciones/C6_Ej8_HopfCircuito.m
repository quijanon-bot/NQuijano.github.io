%% C6_Ej8_HopfCircuito -- Notas: sección 6.6 (la bifurcación de Hopf)
% QUÉ HACE   Para el circuito x1' = x2 - (x1^3 - mu x1), x2' = -x1:
%            (1) valores propios del origen al variar mu (cruzan el eje en +-j);
%            (2) retratos de fase para mu = -0.5, 0, 0.5, 1;
%            (3) amplitud (máximo de x1) y período del ciclo en régimen permanente
%            para 12 valores de mu, contra la predicción 2 sqrt(mu/3) y 2 pi.
% OBSERVE    La amplitud sigue la recta de pendiente 1/2 en log-log; el período vale
%            2 pi solo cuando mu -> 0.
% ESPERADO   mu = 0.1: amplitud 0.3652, período 6.287. mu = 1: 1.160 y 6.663.
% EXPLORE    Con mu = 0.01, ¿cuánto tarda la simulación en llegar al ciclo desde
%            x0 = (0.01, 0)? ¿Por qué tanto?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:circuito]
for mu = [-0.5 0 0.5]
    lam = eig([mu 1; -1 0]);
    fprintf('mu = %+.1f: lambda = %+.3f +- %.3fj\n', mu, real(lam(1)), abs(imag(lam(1))));
end
mus = [0.01 0.02 0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.7 0.85 1];
amp = zeros(size(mus));  per = amp;
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
for k = 1:numel(mus)
    mu = mus(k);  f = @(t, x) [x(2) - (x(1)^3 - mu*x(1)); -x(1)];
    [~, X] = ode45(f, [0 600], [0.1; 0], opc);                 % transitorio
    xr = mapaPoincare(@(x) f(0, x), X(end, :), @(x) x(2), -1);   % llegar a Sigma
    [xr, T] = mapaPoincare(@(x) f(0, x), xr, @(x) x(2), -1);     % una vuelta: período
    [~, X] = ode45(f, linspace(0, T, 2000), xr, opc);          % una vuelta
    amp(k) = max(X(:, 1));  per(k) = T;
end
fprintf('mu = 0.1: amplitud %.4f (predicción %.4f), período %.4f\n', amp(mus == 0.1), 2*sqrt(0.1/3), per(mus == 0.1));
fprintf('mu = 1:   amplitud %.4f, período %.4f\n', amp(end), per(end));
% [fin:circuito]

fig = estiloFigura(1300, 700);
ms = [-0.5 0 0.5 1];
for k = 1:4
    mu = ms(k);
    retratoFase(subplot(2, 4, k), @(x) [x(2) - (x(1)^3 - mu*x(1)); -x(1)], [-2 2], [-2 2], ...
                'X0', [0.05 1.5 -1.5; 0 1.5 -1.5], 'T', 40, 'Equilibrios', [0; 0]);
    title(sprintf('$\\mu=%g$', mu));
end
subplot(2, 2, 3);  loglog(mus, amp, 'o', mus, 2*sqrt(mus/3), '-');  grid on;
xlabel('$\mu$');  ylabel('amplitud');  legend('simulada', '$2\sqrt{\mu/3}$', 'Location', 'northwest');
subplot(2, 2, 4);  plot(mus, per, 'o-', [0 1], 2*pi*[1 1], '--');  grid on;
xlabel('$\mu$');  ylabel('per\''iodo');
