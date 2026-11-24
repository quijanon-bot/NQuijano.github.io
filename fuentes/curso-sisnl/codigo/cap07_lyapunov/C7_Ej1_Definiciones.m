%% C7_Ej1_Definiciones -- Notas: sección 7.2 (estable, asintóticamente estable)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% ---- Figuras de las notas -------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  gr = [0.78 0.78 0.78];

% Figura 7.x (fig:ly-pendulos): péndulo sin y con fricción, con niveles de la energía
fig1 = estiloFigura(1100, 440);
[X1, X2] = meshgrid(linspace(-1.5*pi, 1.5*pi, 300), linspace(-3, 3, 240));
E = a*(1 - cos(X1)) + X2.^2/2;
[Q1, Q2] = meshgrid(linspace(-1.5*pi, 1.5*pi, 19), linspace(-3, 3, 19));
bs = [0 0.5];
tit = {'Sin fricci\''on: estable, no asint\''oticamente', 'Con fricci\''on: asint\''oticamente estable'};
for k = 1:2
    subplot(1, 2, k);  hold on;
    contour(X1, X2, E, [0.25 0.75 1.5 2 2.6 3.5], 'LineColor', gr, 'LineWidth', 0.8);
    U = Q2;  W = -a*sin(Q1) - bs(k)*Q2;  N = hypot(U, W) + 1e-12;
    quiver(Q1, Q2, U./N, W./N, 0.45, 'Color', gr, 'LineWidth', 0.6);
    for x0 = [0.6 0; 1.6 0; 2.6 0; -2 2.4]'
        [~, Y] = ode45(@(t, x) [x(2); -a*sin(x(1)) - bs(k)*x(2)], linspace(0, 30, 3001), x0, opc);
        plot(Y(:,1), Y(:,2), 'Color', az, 'LineWidth', 1.3);
        plot(x0(1), x0(2), 'o', 'Color', co, 'MarkerFaceColor', co, 'MarkerSize', 4);
    end
    plot(0, 0, 'ko', 'MarkerFaceColor', 'k');  plot([-pi pi], [0 0], 'ko', 'MarkerFaceColor', 'w');
    axis([-1.5*pi 1.5*pi -3 3]);  set(gca, 'XTick', [-pi 0 pi], 'XTickLabel', {'$-\pi$', '0', '$\pi$'});
    xlabel('$x_1$');  ylabel('$x_2$');  title(tit{k});
end

% Figura 7.x (fig:ly-polar): tres soluciones y la distancia a (1,0) desde theta0 = 0.1
fig2 = estiloFigura(1100, 440);
subplot(1, 2, 1);  hold on;  th = linspace(0, 2*pi, 200);
plot(cos(th), sin(th), 'Color', gr, 'LineWidth', 3);
z0s = [1 0.1; 0.4 2.5; 1.6 4.0];  cols = [co; az; vi];
for i = 1:3
    [~, W] = ode45(fp, linspace(0, 400, 8001), z0s(i, :)', opc);
    plot(W(:,1).*cos(W(:,2)), W(:,1).*sin(W(:,2)), 'Color', cols(i, :), 'LineWidth', 1.3);
    plot(z0s(i,1)*cos(z0s(i,2)), z0s(i,1)*sin(z0s(i,2)), 'o', 'Color', cols(i, :), ...
         'MarkerFaceColor', cols(i, :), 'MarkerSize', 4);
end
plot(1, 0, 'ko', 'MarkerFaceColor', 'k');  plot(0, 0, 'ko', 'MarkerFaceColor', 'w');
axis equal;  axis([-1.8 1.8 -1.6 1.6]);  xlabel('$x_1$');  ylabel('$x_2$');  title('Todas llegan a $(1,0)$...');
subplot(1, 2, 2);  plot(t, d, 'Color', co);  grid on;  xlim([0 120]);
xlabel('$t$');  ylabel('$\|x(t)-(1,0)\|$');  title('...pero desde $\theta_0=0.1$ se aleja hasta 2');
