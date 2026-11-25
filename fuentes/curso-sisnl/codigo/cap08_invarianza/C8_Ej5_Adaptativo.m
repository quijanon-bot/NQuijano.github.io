%% C8_Ej5_Adaptativo -- Notas: sección 8.4 (control adaptativo: una recta de equilibrios)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% ---- Figura de las notas (fig:iv-adaptativo) ------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;
[Yg, Kg] = meshgrid(linspace(-3, 3, 300), linspace(-2.5, 5, 300));
contour(Yg, Kg, Yg.^2/2 + (Kg - 2).^2/2, [0.5 2 4.5 8], '--', 'LineColor', cl, 'LineWidth', 0.8);  % V con b = 2
plot([0 0], [-2.5 a], 'Color', co, 'LineWidth', 2.4);  plot([0 0], [a 5], 'Color', ve, 'LineWidth', 2.4);
for z0 = [[2; -1], [-1; 0], [0.5; 3], [-2.5; 2]]
    [~, Z] = ode45(f, [0 30], z0, opc);
    plot(Z(:, 1), Z(:, 2), 'Color', no, 'LineWidth', 1);  plot(z0(1), z0(2), 'o', 'Color', no, 'MarkerFaceColor', no, 'MarkerSize', 3);
    plot(0, kinf(z0), 'p', 'Color', am, 'MarkerFaceColor', am, 'MarkerSize', 10);
end
text(0.15, -2.2, 'inestables', 'Color', co);  text(0.15, 4.5, 'estables', 'Color', ve);
axis([-3 3 -2.5 5]);  box on;  grid on;  xlabel('$y$');  ylabel('$k$');  title('plano $(y,k)$, $a=\gamma=1$');
subplot(1, 2, 2);  hold on;  grid on;
[t, Z] = ode45(f, linspace(0, 8, 801), [2; -1], opc);
plot(t, Z(:, 1), 'Color', az);  plot(t, Z(:, 2), 'Color', vi);
plot([0 8], kinf([2; -1])*[1 1], '--', 'Color', am, 'LineWidth', 1.1);  plot([0 8], [2 2], ':', 'Color', gr, 'LineWidth', 1);
text(4.6, 4.15, '$k_\infty=3.83$', 'Color', am);  text(5.2, 1.6, '$b=2$ (ficci\''on)', 'Color', gr);
xlim([0 8]);  xlabel('$t$');  legend('$y(t)$', '$k(t)$', 'Location', 'east');  title('$(y_0,k_0)=(2,-1)$');
