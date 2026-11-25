%% C8_Ej10_GradienteVariable -- Notas: sección 8.6 (el gradiente variable y su barrido)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   x1' = x2, x2' = -(x1 + x2) - sin(x1 + x2). Con g = (a11 x1 + x2, x1 + x2):
%            V = a11 x1^2/2 + x1 x2 + x2^2/2, Vdot = (a11 - 2) x1 x2 - x1^2 - y sin y, y = x1 + x2.
%            [g1] a11 = 2: c* = pi^2/2. [barrido] área del estimado contra a11.
% OBSERVE    La elección "limpia" a11 = 2 no da el mayor estimado.
% ESPERADO   a11 = 2: c* = 4.935, área = pi^3 = 31.0. Mejor a11 ~ 1.46-1.48 (según la malla) con área ~ 37.4.
%            Con a11 = 1.1 el estimado colapsa.
% EXPLORE    Simule desde (6, -2), fuera del estimado. ¿Converge? ¿Qué dice eso del estimado?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:g1]
a11 = 2;
V  = @(x1, x2) a11*x1.^2/2 + x1.*x2 + x2.^2/2;
Vd = @(x1, x2) (a11 - 2)*x1.*x2 - x1.^2 - (x1 + x2).*sin(x1 + x2);
cs = nivelCritico(V, Vd, [-8 8], [-8 8], 1601);
fprintf('a11 = 2: c* en malla = %.3f (exacto pi^2/2 = %.3f), área = %.2f (pi^3 = %.2f)\n', ...
    cs, pi^2/2, pi*cs/sqrt(a11/4 - 1/4), pi^3);
% [fin:g1]

% [ini:barrido]
aa = 1.1:0.02:4;  area = zeros(size(aa));
for i = 1:numel(aa)
    Va  = @(x1, x2) aa(i)*x1.^2/2 + x1.*x2 + x2.^2/2;
    Vda = @(x1, x2) (aa(i) - 2)*x1.*x2 - x1.^2 - (x1 + x2).*sin(x1 + x2);
    area(i) = pi*nivelCritico(Va, Vda, [-12 12], [-12 12], 801)/sqrt(aa(i)/4 - 1/4);  % elipse {V <= c}
end
[amax, imax] = max(area);
fprintf('mejor a11 = %.2f con área %.1f; con a11 = 1.1 el área es %.3f\n', aa(imax), amax, area(1));
% [fin:barrido]

% ---- Figuras de las notas (fig:iv-gradiente y fig:iv-barrido) --------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig1 = estiloFigura(1200, 480);
subplot(1, 2, 1);  hold on;
x = linspace(-8, 8, 801);  [X1, X2] = meshgrid(x);
pintarZonas(x, x, Vd(X1, X2) > 0, co, 0.25);
contour(X1, X2, V(X1, X2), pi^2/2*[1 1], 'LineColor', az, 'LineWidth', 1.8);      % c* = pi^2/2
plot([-8 8], pi - [-8 8], ':', 'Color', no, 'LineWidth', 0.8);  plot([-8 8], -pi - [-8 8], ':', 'Color', no, 'LineWidth', 0.8);
fg = @(t, x) [x(2); -(x(1) + x(2)) - sin(x(1) + x(2))];
x0s = [[2; 0.5], [-1.5; 3], [6; -2], [-6; 7.5]];  col = [no; no; gr; gr];
for j = 1:4
    [~, X] = ode45(fg, [0 25], x0s(:, j), odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
    plot(X(:, 1), X(:, 2), 'Color', col(j, :), 'LineWidth', 1);
end
axis equal;  axis([-8 8 -8 8]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');  title('$a_{11}=2$: $x_1^2+(x_1+x_2)^2<\pi^2$');
subplot(1, 2, 2);  hold on;  grid on;
plot(aa, area, 'Color', az);  plot(2, pi^3, 'o', 'Color', co, 'MarkerFaceColor', co);
plot(aa(imax), amax, 'p', 'Color', am, 'MarkerFaceColor', am, 'MarkerSize', 12);
text(2.1, pi^3 + 0.8, '$a_{11}=2$: $\pi^3=31.0$', 'Color', co);
text(aa(imax) + 0.12, amax + 0.2, sprintf('$a_{11}\\approx%.2f$: $%.1f$', aa(imax), amax), 'Color', am);
ylim([0 42]);  xlabel('$a_{11}$');  ylabel('\''area de $\Omega_{c^*}$');  title('la elecci\''on limpia no es la mejor');

fig2 = estiloFigura(1200, 340);
x = linspace(-6, 6, 601);  [X1, X2] = meshgrid(x);  a4 = [1.1 1.48 2 3];
for j = 1:4
    Va  = @(x1, x2) a4(j)*x1.^2/2 + x1.*x2 + x2.^2/2;
    Vda = @(x1, x2) (a4(j) - 2)*x1.*x2 - x1.^2 - (x1 + x2).*sin(x1 + x2);
    csj = nivelCritico(Va, Vda, [-6 6], [-6 6], 601);
    subplot(1, 4, j);  hold on;
    pintarZonas(x, x, Vda(X1, X2) > 0, co, 0.25);
    if csj > 1e-3, contour(X1, X2, Va(X1, X2), csj*[1 1], 'LineColor', az, 'LineWidth', 1.6);  end
    axis equal;  axis([-6 6 -6 6]);  box on;  set(gca, 'XTick', [], 'YTick', []);
    title(sprintf('$a_{11}=%g$', a4(j)));
end
