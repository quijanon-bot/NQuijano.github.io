%% C7_Ej1_Definiciones -- Notas: sección 7.2 (estable, asintóticamente estable)
% QUÉ HACE   (1) Péndulo x1' = x2, x2' = -a sin x1 - b x2 (a = 1) sin fricción (b = 0) y con
%            fricción (b = 0.5), desde x(0) = (0.3, 0): la energía, la amplitud y |x(t)|.
%            (2) r' = r(1 - r), theta' = sin^2(theta/2): todas las soluciones (r0 > 0)
%            convergen a (1, 0), pero las que arrancan cerca de él dan la vuelta completa.
% OBSERVE    (1) Sin fricción el origen es estable pero no atractivo: la solución se queda
%            a distancia 0.3 para siempre. Con fricción es asintóticamente estable.
%            (2) Converger no es ser estable: desde theta0 = 0.1 la solución se aleja hasta
%            distancia 2 antes de volver.
% ESPERADO   (1) sin fricción: max x1 = 0.3 en t > 5; con fricción |x(40)| ~ 1.6e-5.
%            (2) distancia máxima a (1, 0): 2.000; theta(400) = 0.998 * 2 pi.
% EXPLORE    En (2), reduzca theta0 a 1e-3: ¿se reduce la excursión? ¿Qué tarda más?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:pendulo]
a = 1;  opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
for b = [0 0.5]
    [t, X] = ode45(@(t, x) [x(2); -a*sin(x(1)) - b*x(2)], linspace(0, 40, 4001), [0.3; 0], opc);
    E = a*(1 - cos(X(:,1))) + X(:,2).^2/2;
    fprintf('b = %.1f: E(0) = %.4f, E(40) = %.2e, max x1 (t > 5) = %.4f, |x(40)| = %.2e\n', ...
            b, E(1), E(end), max(X(t > 5, 1)), norm(X(end, :)));
end
% [fin:pendulo]

% [ini:polar]
fp = @(t, z) [z(1)*(1 - z(1)); sin(z(2)/2)^2];          % z = (r, theta)
[t, Z] = ode45(fp, [0 400], [1; 0.1], opc);
d = sqrt((Z(:,1).*cos(Z(:,2)) - 1).^2 + (Z(:,1).*sin(Z(:,2))).^2);
fprintf('polar: theta0 = 0.1, distancia máxima a (1,0) = %.3f, theta(400)/(2 pi) = %.4f\n', ...
        max(d), Z(end, 2)/(2*pi));
% [fin:polar]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  plot(t, d);  grid on;  xlim([0 100]);
xlabel('$t$');  ylabel('distancia a $(1,0)$');  title('Converge, pero no es estable');
subplot(1, 2, 2);  plot(Z(:,1).*cos(Z(:,2)), Z(:,1).*sin(Z(:,2)));  hold on;
plot(1, 0, 'ko', 'MarkerFaceColor', 'k');  axis equal;  grid on;
xlabel('$x_1$');  ylabel('$x_2$');  title('$\theta_0=0.1$: la vuelta completa');
