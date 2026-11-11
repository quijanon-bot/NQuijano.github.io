%% C4_Ej9_Duffing -- Notas: sección 4.6 (la ecuación de Duffing)
% QUÉ HACE   (1) Clasifica los equilibrios de x1' = x2, x2' = x1 - x1^3 - delta x2
%            para varios delta. (2) Simula desde (1.5, 0) y (2, 0) con delta = 0.5
%            y grafica x1(t) y la energía E = x2^2/2 - x1^2/2 + x1^4/4.
% OBSERVE    (1) (+-1,0) son focos si delta < 2 sqrt(2) = 2.83 y nodos si no; el
%            origen es siempre una silla. (2) Con más energía, la viga pasa sobre la
%            barrera (E = 0) y termina en el otro pozo.
% ESPERADO   delta = 0.5: silla 0.781, -1.281; focos -0.25 +- 1.392j.
%            (1.5,0) -> (1,0);  (2,0) -> (-1,0).  dE/dt = -delta x2^2 <= 0.
% EXPLORE    Busque la condición inicial (x1, 0) más pequeña, con x1 > 1, que termina
%            en (-1,0). ¿Qué energía tiene? (Pista: bisección.)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:duffing]
for delta = [0.5 1 2*sqrt(2) 3]
    J0 = [0 1; 1 -delta];  J1 = [0 1; -2 -delta];
    fprintf('delta = %.3f: (0,0) %s;  (+-1,0) %s, lambda = %s\n', delta, clasificarEquilibrio(J0), ...
            clasificarEquilibrio(J1, 1e-9), num2str(eig(J1).', '%.3f  '));
end
delta = 0.5;
f = @(t, x) [x(2); x(1) - x(1)^3 - delta*x(2)];
E = @(X) X(:, 2).^2/2 - X(:, 1).^2/2 + X(:, 1).^4/4;
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
fig = estiloFigura(1100, 420);
for x0 = [1.5 2]
    [t, X] = ode45(f, [0 60], [x0; 0], opc);
    fprintf('desde (%.1f, 0): termina en (%.4f, %.4f); E: %.3f -> %.3f\n', x0, X(end, :), E(X(1, :)), E(X(end, :)));
    subplot(1, 2, 1);  hold on;  plot(t, X(:, 1));
    subplot(1, 2, 2);  hold on;  plot(t, E(X));
end
subplot(1, 2, 1);  grid on;  xlabel('$t$');  ylabel('$x_1$');  legend('$x_0=(1.5,0)$', '$x_0=(2,0)$');
subplot(1, 2, 2);  grid on;  xlabel('$t$');  ylabel('$E$');  yline(0, '--');  title('La barrera est\''a en $E=0$');
% [fin:duffing]
