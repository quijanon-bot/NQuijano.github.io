%% C7_Ej6_TerminoCruzado -- Notas: secciones 7.6 y 7.8 (péndulo: inclinar la energía)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Péndulo con fricción (a = 1, b = 0.5) con la candidata
%               V = (1/2) x' P x + a(1 - cos x1),   P = [b p12  p12; p12  1],  0 < p12 < b,
%            cuyo Vdot = -a p12 x1 sin x1 - (b - p12) x2^2 es definida negativa en
%            D = {|x1| < pi}. Calcula el mayor nivel c*(p12) con Omega_c dentro de D, y
%            simula la trayectoria desde (1.5, 3), que arranca en D y sale de él.
% OBSERVE    p12 = 0 (la energía) da c* = 2a = 2; p12 = b/2 da el máximo c* = 2.3084.
%            La trayectoria desde (1.5, 3) tiene Vdot < 0 mientras está en D... y aun así
%            termina en (2 pi, 0): D NO es una estimación de la región de atracción.
% ESPERADO   c*(b/2) = 2.3084; V(1.5, 3) = 6.695 > c*; sale de D en t = 0.724.
% EXPLORE    Grafique c*(p12) para p12 en [0, b]. ¿Por qué el máximo está en b/2?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:cruzado]
a = 1;  b = 0.5;  p12 = b/2;
V  = @(x1, x2) 0.5*(b*p12*x1.^2 + 2*p12*x1.*x2 + x2.^2) + a*(1 - cos(x1));
Vd = @(x1, x2) -a*p12*x1.*sin(x1) - (b - p12)*x2.^2;
cEst = @(q) 2*a + pi^2/2*q.*(b - q);                 % min de V sobre |x1| = pi
x2s = linspace(-4, 4, 80001);
fprintf('c*(b/2) = %.4f (fórmula) = %.4f (mínimo numérico en x1 = pi); energía: %.4f\n', ...
        cEst(p12), min(V(pi, x2s)), cEst(0));
[X1, X2] = meshgrid(linspace(-pi + 1e-3, pi - 1e-3, 301), linspace(-4, 4, 301));
W = Vd(X1, X2);  W(abs(X1) + abs(X2) < 1e-2) = -1;
fprintf('max Vdot en D sin el origen: %.2e (< 0)\n', max(W(:)));
% [fin:cruzado]

% [ini:sale]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, x) eventoODE(x(1) - pi, 1, 1));
[t, X, te] = ode45(@(t, x) [x(2); -a*sin(x(1)) - b*x(2)], [0 60], [1.5; 3], opc);
[~, Y] = ode45(@(t, x) [x(2); -a*sin(x(1)) - b*x(2)], [0 60], [1.5; 3], odeset('RelTol', 1e-10));
fprintf('V(1.5,3) = %.3f > c*; sale de D en t = %.3f; termina en x1 = %.4f pi\n', ...
        V(1.5, 3), te, Y(end, 1)/pi);
% [fin:sale]

% ---- Figura de las notas (fig:ly-cruzado) -----------------------------------
co = [209 73 91]/255;  am = [224 159 62]/255;  ve = [42 157 143]/255;  gr = [0.78 0.78 0.78];
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;
[X1, X2] = meshgrid(linspace(-4.5, 8, 500), linspace(-3.6, 3.6, 300));
VE = a*(1 - cos(X1)) + X2.^2/2;  VP = V(X1, X2);
VE(abs(X1) > pi) = NaN;  VP(abs(X1) > pi) = NaN;          % solo dentro de D
fill([-pi pi pi -pi], [-3.6 -3.6 3.6 3.6], [0.94 0.95 0.97], 'EdgeColor', 'none');
contour(X1, X2, VE, (cEst(0) - 0.01)*[1 1], 'LineColor', am, 'LineStyle', '--', 'LineWidth', 1.6);
contour(X1, X2, VP, [0.5 1 1.5], 'LineColor', gr, 'LineWidth', 0.8);
contour(X1, X2, VP, (cEst(p12) - 0.01)*[1 1], 'LineColor', ve, 'LineWidth', 2.5);
plot(Y(:,1), Y(:,2), 'Color', co, 'LineWidth', 1.4);
plot(1.5, 3, 'o', 'Color', co, 'MarkerFaceColor', co);  plot(2*pi, 0, 'o', 'Color', co, 'MarkerFaceColor', co);
plot(0, 0, 'ko', 'MarkerFaceColor', 'k');
plot([-pi -pi], [-3.6 3.6], 'k:', [pi pi], [-3.6 3.6], 'k:', 'LineWidth', 0.7);  text(-3, 3.1, '$D$');
axis([-4.5 8 -3.6 3.6]);  xlabel('$x_1$');  ylabel('$x_2$');  title('$\Omega_{c^*}$: energ\''ia y $p_{12}=b/2$');
subplot(1, 2, 2);  q = linspace(0, b, 200);  plot(q, cEst(q), 'Color', ve);  hold on;
plot([b/2 b/2], [2 cEst(b/2)], 'k:', 'LineWidth', 0.8);  grid on;
xlabel('$p_{12}$');  ylabel('$c^*(p_{12})$');  title('El mejor nivel, en $b/2$');
