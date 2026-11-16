%% C8_Ej4_CicloLimite -- Notas: sección 8.4 (LaSalle con V no definida positiva)
% QUÉ HACE   r' = r(1 - r^2), theta' = 1 en cartesianas, con V = (r^2 - 1)^2/4.
%            Comprueba Vdot = -r^2 (1 - r^2)^2 <= 0 en una malla, calcula el anillo
%            Omega_c para c = 0.2 y simula dos soluciones dentro de él.
% OBSERVE    V(0) = 1/4 es un MÁXIMO local: V no es definida positiva, y aun así
%            LaSalle prueba que el ciclo atrae.
% ESPERADO   Anillo 0.325 <= r <= 1.376. Las soluciones terminan con r = 1.
% EXPLORE    Tome c = 0.3 (> 1/4). ¿Qué es ahora E? ¿Qué concluye LaSalle?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:ciclo]
f = @(t, x) [x(1)*(1 - x(1)^2 - x(2)^2) - x(2); x(2)*(1 - x(1)^2 - x(2)^2) + x(1)];
[X1, X2] = meshgrid(linspace(-2, 2, 201));  R2 = X1.^2 + X2.^2;
gradV1 = (R2 - 1).*X1;  gradV2 = (R2 - 1).*X2;               % grad V
Vd = gradV1.*(X1.*(1 - R2) - X2) + gradV2.*(X2.*(1 - R2) + X1);
fprintf('max |Vdot + r^2 (1 - r^2)^2| en la malla = %.1e\n', max(abs(Vd(:) + R2(:).*(1 - R2(:)).^2)));
c = 0.2;
fprintf('anillo Omega_c: %.3f <= r <= %.3f\n', sqrt(1 - 2*sqrt(c)), sqrt(1 + 2*sqrt(c)));
for x0 = [[1.3; 0.3], [0; -0.4]]
    [~, X] = ode45(f, [0 20], x0, opc);
    fprintf('desde (%.1f, %.1f): r(20) = %.6f\n', x0, norm(X(end, :)));
end
% [fin:ciclo]

fig = estiloFigura(560, 520);  th = linspace(0, 2*pi, 300);
plot(cos(th), sin(th), 'r', 'LineWidth', 2.5);  hold on;
for x0 = [[1.3; 0.3], [0; -0.4]], [~, X] = ode45(f, [0 20], x0, opc);  plot(X(:, 1), X(:, 2), 'k');  end
axis equal;  grid on;  title('$E=M$ es el ciclo');
