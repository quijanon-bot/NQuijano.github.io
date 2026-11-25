%% C8_Ej11_GradientePendulo -- Notas: sección 8.6 (el gradiente variable deduce la V del cap. 7)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Péndulo x1' = x2, x2' = -sin x1 - b x2 (b = 0.5). Con g = (sin x1 + k b x1 + k x2,
%            k x1 + x2): V = 1 - cos x1 + (k b x1^2 + 2 k x1 x2 + x2^2)/2 y
%            Vdot = -k x1 sin x1 - (b - k) x2^2. Compara la energía con V a lo largo de una solución
%            y calcula c*(k) = 2 + pi^2 k (b - k)/2.
% OBSERVE    La energía baja con escalones (Vdot = 0 en x2 = 0); V baja estrictamente.
% ESPERADO   Máximo de c*(k) en k = b/2 = 0.25 con c* = 2.308.
% EXPLORE    Tome k = b. ¿Qué pasa con Vdot y con la definición positiva de V?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:pendulo]
b = 0.5;  k = b/2;
f = @(t, x) [x(2); -sin(x(1)) - b*x(2)];
E = @(x) 1 - cos(x(:, 1)) + x(:, 2).^2/2;
V = @(x) 1 - cos(x(:, 1)) + (k*b*x(:, 1).^2 + 2*k*x(:, 1).*x(:, 2) + x(:, 2).^2)/2;
[t, X] = ode45(f, linspace(0, 20, 4001), [2; 0.8], opc);
fprintf('mayor subida de la energía = %.1e, de V = %.1e (debe ser < 0)\n', max(diff(E(X))), max(diff(V(X))));
kk = linspace(0, b, 101);  cs = 2 + pi^2*kk.*(b - kk)/2;
[cmax, i] = max(cs);
fprintf('c*(k) máximo en k = %.3f: c* = %.3f\n', kk(i), cmax);
% [fin:pendulo]

% ---- Figura de las notas (fig:iv-gradiente-pendulo) -----------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
Ef = @(x1, x2) 1 - cos(x1) + x2.^2/2;
Vf = @(x1, x2) 1 - cos(x1) + (k*b*x1.^2 + 2*k*x1.*x2 + x2.^2)/2;
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;
[X1, X2] = meshgrid(linspace(-3.4, 3.4, 400), linspace(-2.6, 2.6, 400));
contour(X1, X2, Ef(X1, X2), [0.2 0.6 1.2 2.0], '--', 'LineColor', gr, 'LineWidth', 0.8);
contour(X1, X2, Vf(X1, X2), [0.2 0.6 1.2 2.0], 'LineColor', az, 'LineWidth', 1.1);
contour(X1, X2, Vf(X1, X2), (2 + pi^2*k*(b - k)/2)*[1 1], 'LineColor', ve, 'LineWidth', 1.8);
plot([pi pi], [-2.6 2.6], ':', 'Color', no, 'LineWidth', 0.6);  plot(-[pi pi], [-2.6 2.6], ':', 'Color', no, 'LineWidth', 0.6);
plot(X(:, 1), X(:, 2), 'Color', no, 'LineWidth', 0.9);
axis([-3.4 3.4 -2.6 2.6]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');  title('energ\''ia (gris) y $V$ inclinada (azul)');
subplot(1, 2, 2);  hold on;  grid on;
plot(t, E(X), '--', 'Color', gr);  plot(t, V(X), 'Color', az);
xlim([0 20]);  xlabel('$t$');  legend('energ\''ia', '$V$');  title('escalones contra descenso estricto');
