%% C9_Ej10_Inestabilidad -- Notas: sección 9.7 (inestabilidad)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Verifica en mallas las derivadas de los tres ejemplos de inestabilidad:
%            primer teorema (Vdot definida positiva), segundo teorema (Vdot - 2V >= 0
%            aunque Vdot < 0 en algunos puntos) y Chetaev (Vdot >= ||x||^2/2 en B_{1/2}).
% OBSERVE    En el segundo ejemplo, Vdot es negativa en (0, 0.5); el teorema no la necesita
%            positiva. Con V = x1 en el ejemplo de Chetaev, Vdot < 0 en (delta^2, -delta).
% ESPERADO   min Vdot/||x||^2 en B_{1/2} = 0.50 (la versión anterior daba 3/8).
% EXPLORE    Agrande la bola a r = 0.9 y a r = 1.1. ¿Dónde deja de valer la cota?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:inestabilidad]
[TH, RR] = meshgrid(linspace(0, 2*pi, 721), linspace(1e-3, 0.5, 400));
X1 = RR.*cos(TH);  X2 = RR.*sin(TH);
% primer teorema: V = ||x||^2/2
F1 = 2*X2 + X1.*(X1.^2 + 2*X2.^4);  F2 = -2*X1 + X2.*(X1.^2 + X2.^4);
Vd = X1.*F1 + X2.*F2;
fprintf('1er teorema: max |Vdot - (x1^4 + x1^2x2^2 + 2x1^2x2^4 + x2^6)| = %.1e;  min Vdot = %.1e (> 0)\n', ...
    max(abs(Vd(:) - (X1(:).^4 + X1(:).^2.*X2(:).^2 + 2*X1(:).^2.*X2(:).^4 + X2(:).^6))), min(Vd(:)));
% segundo teorema: V = (x1^2 - x2^2)/2
F1 = X1 + 3*X2.*sin(X2).^2 + 5*X1.*X2.^2.*sin(X1).^2;  F2 = 3*X1.*sin(X2).^2 + X2 - 5*X1.^2.*X2.*cos(X1).^2;
V = (X1.^2 - X2.^2)/2;  Vd = X1.*F1 - X2.*F2;
fprintf('2o teorema: min(Vdot - 2V) = %.1e (>= 0);  min Vdot = %.3f (< 0)\n', min(Vd(:) - 2*V(:)), min(Vd(:)));
f2 = @(x) [x(1) + 3*x(2)*sin(x(2))^2 + 5*x(1)*x(2)^2*sin(x(1))^2; 3*x(1)*sin(x(2))^2 + x(2) - 5*x(1)^2*x(2)*cos(x(1))^2];
p = [0; 0.5];  F = f2(p);
fprintf('            en (0, 0.5): V = %.3f, Vdot = %.3f\n', (p(1)^2 - p(2)^2)/2, p(1)*F(1) - p(2)*F(2));
% Chetaev: V = x1 - x2^2/2
Vd = X1.^2 + X2.^2 + X2.^3 - X1.^3.*X2;
fprintf('Chetaev: min Vdot/||x||^2 en B_{1/2} = %.3f\n', min(Vd(:)./RR(:).^2));
d = 0.1;  fprintf('con V = x1, en (delta^2, -delta), delta = 0.1: V = %.2f, Vdot = %.1e\n', d^2, d^4 - d^3);
% [fin:inestabilidad]

% ---- Figura de las notas (fig:vt-inestabilidad) ---------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
op = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.01);
fig = estiloFigura(1250, 430);
subplot(1, 3, 1);  hold on;  grid on;
fA = @(t, x) [2*x(2) + x(1)*(x(1)^2 + 2*x(2)^4); -2*x(1) + x(2)*(x(1)^2 + x(2)^4)];
[~, X] = ode45(fA, [0 200], [0.25; 0], odeset(op, 'MaxStep', 0.02, 'Events', @(t, x) eventoODE(norm(x) - 1.3, 1, 0)));
plot(X(:, 1), X(:, 2), 'Color', co, 'LineWidth', 0.9);  plot(0, 0, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
axis equal;  axis([-1.3 1.3 -1.3 1.3]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');  title('primer teorema: $\dot V>0$');
subplot(1, 3, 2);  hold on;
g1 = linspace(-1, 1, 300);  [Y1, Y2] = meshgrid(g1);  pintarZonas(g1, g1, Y1.^2 > Y2.^2, co, 0.15);
sal1 = odeset(op, 'Events', @(t, x) eventoODE(norm(x) - 1, 1, 0));
for x0 = [[0.05; 0.02], [-0.05; -0.03], [0.02; 0.6], [-0.03; -0.7]]
    [~, X] = ode45(@(t, x) f2(x), [0 10], x0, sal1);  plot(X(:, 1), X(:, 2), 'Color', no, 'LineWidth', 0.9);
end
plot(0, 0, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
axis equal;  axis([-1 1 -1 1]);  box on;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('segundo: $\dot V\ge2V$; $V>0$ en coral');
subplot(1, 3, 3);  hold on;
fC = @(t, x) [x(1)^2 + x(2)^3; -x(2) + x(1)^3];
g3 = linspace(-0.5, 0.5, 300);  [Y1, Y2] = meshgrid(g3);  pintarZonas(g3, g3, (Y1 > Y2.^2/2) & (Y1.^2 + Y2.^2 < 0.25), ve, 0.25);
th = linspace(0, 2*pi, 300);  plot(0.5*cos(th), 0.5*sin(th), ':', 'Color', gr);
sal6 = odeset(op, 'Events', @(t, x) eventoODE(norm(x) - 0.6, 1, 0));
for x0 = [[0.02; 0.15], [0.03; -0.18], [0.01; 0]]
    [~, X] = ode45(fC, [0 200], x0, sal6);  plot(X(:, 1), X(:, 2), 'Color', no, 'LineWidth', 0.9);
end
[~, X] = ode45(fC, [0 10], [-0.2; 0.2], op);  plot(X(:, 1), X(:, 2), 'Color', az, 'LineWidth', 0.9);
plot(0, 0, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
axis equal;  axis([-0.55 0.55 -0.55 0.55]);  box on;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
title('Chetaev: $U=\{x_1>x_2^2/2\}$');
