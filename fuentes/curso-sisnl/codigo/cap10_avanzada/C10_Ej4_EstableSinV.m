%% C10_Ej4_EstableSinV -- Notas: sección 10.3 (estable, invariante en el tiempo y sin V(x))
% QUÉ HACE   Para x1' = x2, x2' = sin^2(pi/|x|^2) x2 - x1 (Kellett-Braun, ec. 2.51):
%            (1) verifica que los círculos |x|^2 = 1/n son órbitas (el radio no cambia);
%            (2) simula una trayectoria entre Gamma_3 y Gamma_2 y mide hacia dónde va.
% OBSERVE    Entre dos órbitas el radio solo crece: la trayectoria espirala hacia la
%            órbita exterior y nunca la cruza.
% ESPERADO   Radios de las órbitas 1, 0.707, 0.577; desde |x| = 0.6, |x| -> 0.707.
% EXPLORE    Arranque en |x| = 0.3. ¿Entre qué órbitas queda? ¿Por qué el origen es
%            estable pero no asintóticamente estable?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:sinV]
f = @(t, x) [x(2); sin(pi/max(x'*x, 1e-12))^2*x(2) - x(1)];
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-13);
for n = 1:3
    [~, X] = ode45(f, [0 2*pi], [1/sqrt(n); 0], opc);
    fprintf('Gamma_%d: radio %.4f, variación del radio en una vuelta = %.1e\n', ...
            n, 1/sqrt(n), max(abs(sqrt(sum(X.^2, 2)) - 1/sqrt(n))));
end
[t, X] = ode45(f, [0 400], [0.6; 0], opc);  r = sqrt(sum(X.^2, 2));
fprintf('desde |x| = 0.6: |x(400)| = %.4f  (Gamma_2: %.4f);  ¿r creciente? %d\n', ...
        r(end), 1/sqrt(2), all(diff(r) > -1e-9));
% [fin:sinV]

fig = estiloFigura(560, 540);  th = linspace(0, 2*pi, 300);  hold on;
for n = 1:4, plot(cos(th)/sqrt(n), sin(th)/sqrt(n)); end
plot(X(:, 1), X(:, 2), 'k', 'LineWidth', 0.6);  axis equal;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
