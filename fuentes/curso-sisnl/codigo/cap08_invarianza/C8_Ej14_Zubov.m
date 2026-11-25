%% C8_Ej14_Zubov -- Notas: sección 8.8 (la ecuación de Zubov con solución cerrada)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   [z1] x' = -x + x^3, h = 2 x^2: V = x^2 resuelve la ecuación de Zubov.
%            [z2] x1' = -x1 + 2 x1^2 x2, x2' = -x2: W = x2^2/2 + x1^2/(2(1 - x1 x2)),
%            V = 1 - exp(-W). Evalúa el residuo de la ecuación en una malla dentro de
%            {x1 x2 < 1} y simula a ambos lados de la hipérbola.
% OBSERVE    V -> 1 al acercarse a la hipérbola x1 x2 = 1: es la frontera exacta.
% ESPERADO   Residuos ~ 1e-12. (1.9, 0.5) converge; (2.1, 0.5) escapa.
% EXPLORE    Repita [z1] con h = x^2. ¿Cambia V? ¿Cambia {V < 1}?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:z1]
x = linspace(-0.99, 0.99, 199);
res1 = 2*x.*(-x + x.^3) + 2*x.^2.*(1 - x.^2);              % V'(x) f(x) + h (1 - V) con V = x^2
fprintf('[z1] max |residuo| = %.1e\n', max(abs(res1)));
% [fin:z1]

% [ini:z2]
f = @(t, x) [-x(1) + 2*x(1)^2*x(2); -x(2)];
W = @(x1, x2) x2.^2/2 + x1.^2./(2*(1 - x1.*x2));
[X1, X2] = meshgrid(linspace(-3, 3, 241));  dentro = X1.*X2 < 0.98;
h = 1e-6;  F1 = -X1 + 2*X1.^2.*X2;  F2 = -X2;               % derivadas por diferencias centradas
Wd = (W(X1 + h, X2) - W(X1 - h, X2))/(2*h).*F1 + (W(X1, X2 + h) - W(X1, X2 - h))/(2*h).*F2;
res2 = Wd + X1.^2 + X2.^2;                                  % dW/dt + h(x) debe ser 0
fprintf('[z2] max |dW/dt + ||x||^2| en {x1 x2 < 0.98} = %.1e\n', max(abs(res2(dentro))));
[~, X] = ode45(f, [0 30], [1.9; 0.5], opc);
fprintf('desde (1.9, 0.5), w = 0.95: ||x(30)|| = %.1e\n', norm(X(end, :)));
salir = odeset(opc, 'Events', @(t, x) eventoODE(x(1) - 1e3, 1, 0));
[te, ~] = ode45(f, [0 30], [2.1; 0.5], salir);
fprintf('desde (2.1, 0.5), w = 1.05: x1 = 1000 en t = %.3f\n', te(end));
% [fin:z2]

% ---- Figuras de las notas (fig:iv-zubov1d y fig:iv-zubov-hiperbola) ---------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig1 = estiloFigura(1100, 400);
subplot(1, 2, 1);  hold on;  grid on;  xs = linspace(-1.4, 1.4, 400);
plot(xs, -xs + xs.^3, 'Color', az);  plot([-1.4 1.4], [0 0], 'Color', gr, 'LineWidth', 0.6);
plot(0, 0, 'o', 'MarkerFaceColor', no, 'MarkerEdgeColor', no);  plot([-1 1], [0 0], 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
xlabel('$x$');  title('$f(x)=-x+x^3$');
subplot(1, 2, 2);  hold on;  grid on;  xi = linspace(-0.995, 0.995, 400);
plot(xi, xi.^2, 'Color', az);  plot(xi, -log(1 - xi.^2), 'Color', co);
plot([-1 -1], [0 4], ':', 'Color', no);  plot([1 1], [0 4], ':', 'Color', no);  plot([-1 1], [1 1], '--', 'Color', gr, 'LineWidth', 0.8);
ylim([0 4]);  xlabel('$x$');  legend('$V=x^2$', '$W=-\ln(1-x^2)$', 'Location', 'north');
title('$W\to\infty$ en $\partial\mathcal{R}_A$');

fig2 = estiloFigura(700, 520);  hold on;
xg = linspace(-3, 3, 600);  [X1, X2] = meshgrid(xg);  w = X1.*X2;
Wg = X2.^2/2 + X1.^2./(2*(1 - min(w, 0.9999)));  Wg(w >= 1) = Inf;  VV = 1 - exp(-Wg);
pintarZonas(xg, xg, w >= 1, gr, 0.25);
contour(X1, X2, VV, [0.25 0.5 0.75 0.9 0.99], 'LineColor', az, 'LineWidth', 1);
xx = linspace(0.34, 3, 200);  plot(xx, 1./xx, 'Color', co, 'LineWidth', 1.8);  plot(-xx, -1./xx, 'Color', co, 'LineWidth', 1.8);
for x0 = [[1.9; 0.5], [-2.5; -0.35], [0.35; 2.5]]
    [~, X] = ode45(f, [0 15], x0, opc);  plot(X(:, 1), X(:, 2), 'Color', no, 'LineWidth', 1);
end
sal3 = odeset(opc, 'Events', @(t, x) eventoODE(abs(x(1)) - 3, 1, 0));
[~, X] = ode45(f, [0 10], [2.1; 0.5], sal3);  plot(X(:, 1), X(:, 2), '--', 'Color', co, 'LineWidth', 1.2);
axis equal;  axis([-3 3 -3 3]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');
title('niveles de $V$; $\mathcal{R}_A=\{x_1x_2<1\}$');
