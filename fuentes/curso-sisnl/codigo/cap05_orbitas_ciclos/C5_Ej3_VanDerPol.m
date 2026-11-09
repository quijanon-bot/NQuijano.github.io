%% C5_Ej3_VanDerPol -- Notas: sección 5.3 (van der Pol y Liénard)
% QUÉ HACE   Simula x'' + mu (x^2 - 1) x' + x = 0 para mu = 1 y mu = 5 desde
%            adentro y desde afuera del ciclo; mide período y amplitud; verifica
%            las hipótesis del teorema de Liénard con F(x) = mu (x^3/3 - x).
% OBSERVE    Todas las trayectorias (salvo el origen) llegan al MISMO ciclo, con
%            la misma amplitud: la oscilación la fija el sistema, no la condición
%            inicial. Con mu = 5 aparece la oscilación de relajación.
% ESPERADO   mu = 1: período 6.6633, amplitud 2.0086.  mu = 5: período 11.612,
%            amplitud 2.02.  F tiene su único cero positivo en a = sqrt(3) = 1.7321.
% EXPLORE    Grafique el período en función de mu (0.1 a 10). Para mu grande se
%            aproxima a (3 - 2 ln 2) mu. ¿A partir de qué mu la aproximación es buena?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:ciclo]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
for mu = [1 5]
    f = @(t, x) [x(2); -x(1) - mu*(x(1)^2 - 1)*x(2)];
    [t, X] = ode45(f, [0 200], [0.5; 0], opc);
    k  = find(t > 100);
    sube = k(X(k(1:end-1), 2) < 0 & X(k(2:end), 2) >= 0 & X(k(1:end-1), 1) < 0);  % mínimos de x1
    T = mean(diff(t(sube)));
    fprintf('mu = %g: período %.4f, amplitud %.4f\n', mu, T, max(X(k, 1)));
end
% [fin:ciclo]

% [ini:lienard]
mu = 1;  F = @(x) mu*(x.^3/3 - x);
a = fzero(F, [1 2]);
fprintf('F(x) = mu (x^3/3 - x): cero positivo a = %.4f (sqrt(3) = %.4f); F < 0 en (0, a), F creciente para x > a\n', a, sqrt(3));
% [fin:lienard]

fig = estiloFigura(1000, 420);
for j = 1:2
    mus = [1 5]; mu = mus(j); subplot(1, 2, j); hold on;
    for x0 = [0.1 0; 3 3; -3 -3].'
        [~, X] = ode45(@(t, x) [x(2); -x(1) - mu*(x(1)^2 - 1)*x(2)], [0 40], x0, opc);
        plot(X(:,1), X(:,2));
    end
    grid on; xlabel('$x$'); ylabel('$\dot x$'); title(sprintf('$\\mu=%g$', mu));
end
