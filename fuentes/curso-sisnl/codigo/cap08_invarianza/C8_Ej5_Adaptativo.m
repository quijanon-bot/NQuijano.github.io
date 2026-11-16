%% C8_Ej5_Adaptativo -- Notas: sección 8.4 (control adaptativo: una recta de equilibrios)
% QUÉ HACE   Lazo y' = -(k - a) y, k' = gamma y^2 (planta y' = a y + u, u = -k y).
%            Compara k(T) con k_inf = a + sqrt((k0 - a)^2 + gamma y0^2).
% OBSERVE    k_inf depende de la condición inicial y NO es la constante b > a del
%            análisis con V = y^2/2 + (k - b)^2/(2 gamma).
% ESPERADO   a = gamma = 1: desde (2, -1), k_inf = 1 + 2 sqrt2 = 3.828; desde (0.5, 3), 3.062.
% EXPLORE    Pruebe y0 = 0. ¿Qué da la fórmula? ¿Qué hace la simulación?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:adaptativo]
a = 1;  gamma = 1;
f = @(t, z) [-(z(2) - a)*z(1); gamma*z(1)^2];               % z = (y, k)
kinf = @(z0) a + sqrt((z0(2) - a)^2 + gamma*z0(1)^2);
for z0 = [[2; -1], [0.5; 3], [-1; 0]]
    [~, Z] = ode45(f, [0 60], z0, opc);
    fprintf('(y0, k0) = (%4.1f, %4.1f): k(60) = %.6f, fórmula = %.6f, y(60) = %.1e\n', z0, Z(end, 2), kinf(z0), Z(end, 1));
end
% [fin:adaptativo]

[t, Z] = ode45(f, [0 8], [2; -1], opc);
fig = estiloFigura(800, 420);  plot(t, Z(:, 1), t, Z(:, 2), [0 8], kinf([2; -1])*[1 1], '--');
grid on;  xlabel('$t$');  legend('$y(t)$', '$k(t)$', '$k_\infty$');
