%% C8_Ej1_ConjuntosLimite -- Notas: sección 8.2 (tres conjuntos omega-límite)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Simula (a) el oscilador amortiguado, (b) van der Pol con mu = 1 desde (0.1, 0)
%            y (c) x1' = 0.5, x2' = -x2; marca las muestras phi_n(x0), n = 1, 2, ...
% OBSERVE    En (b) las muestras se reparten por todo el ciclo: la solución tiende al
%            CONJUNTO Gamma sin tender a ningún punto. En (c) no hay muestras acotadas.
% ESPERADO   (a) omega = {0}. (b) amplitud del ciclo 2.009 en x1. (c) omega vacío.
% EXPLORE    En (b) arranque en (4, 0), fuera del ciclo. ¿Cambia omega(x0)?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:limite]
fa = @(t, x) [x(2); -x(1) - 0.4*x(2)];                    % (a) oscilador amortiguado
fv = @(t, x) [x(2); -x(1) + (1 - x(1)^2)*x(2)];           % (b) van der Pol, mu = 1
fc = @(t, x) [0.5; -x(2)];                                % (c) sin acotación
[~, Xa] = ode45(fa, [0 30], [2; 0], opc);
[tv, Xv] = ode45(fv, [0 80], [0.1; 0], opc);
[~, Xn] = ode45(fv, 0:60, [0.1; 0], opc);                 % muestras phi_n(x0)
[~, Xc] = ode45(fc, [0 12], [-2.5; 2], opc);
fprintf('(a) x(30) = (%.1e, %.1e): omega = {0}\n', Xa(end, :));
fprintf('(b) amplitud en t in [60, 80]: max x1 = %.3f, min x1 = %.3f\n', max(Xv(tv > 60, 1)), min(Xv(tv > 60, 1)));
fprintf('(c) x1(12) = %.1f -> infinito: omega vacío\n', Xc(end, 1));
% [fin:limite]

% ---- Figura de las notas (fig:iv-limite) ----------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(1200, 400);
subplot(1, 3, 1);  hold on;  grid on;
plot(Xa(:, 1), Xa(:, 2), 'Color', az, 'LineWidth', 1.2);
plot(0, 0, 'o', 'MarkerFaceColor', no, 'MarkerEdgeColor', no);
axis equal;  axis([-2.3 2.3 -2.3 2.3]);  xlabel('$x_1$');  ylabel('$x_2$');  title('(a) $\omega(x_0)=\{0\}$');
subplot(1, 3, 2);  hold on;  grid on;
plot(Xv(:, 1), Xv(:, 2), 'Color', cl, 'LineWidth', 0.8);
[tg, Xg] = ode45(fv, [0 100], [2; 0], opc);  m = tg > 80;      % el ciclo Gamma
plot(Xg(m, 1), Xg(m, 2), 'Color', co, 'LineWidth', 1.6);
scatter(Xn(2:end, 1), Xn(2:end, 2), 18, 1:60, 'filled');  try, colormap(gca, parula); catch, colormap(gca, viridis); end   % (Octave: viridis)
axis equal;  axis([-3 3 -3 3]);  xlabel('$x_1$');  ylabel('$x_2$');  title('(b) $\omega(x_0)=\Gamma$');
subplot(1, 3, 3);  hold on;  grid on;
plot(Xc(:, 1), Xc(:, 2), 'Color', vi, 'LineWidth', 1.4);
quiver(2.6, 0, 0.8, 0, 0, 'Color', vi, 'LineWidth', 1.4, 'MaxHeadSize', 0.5);
axis([-3 3.6 -0.5 2.3]);  xlabel('$x_1$');  ylabel('$x_2$');  title('(c) $\omega(x_0)=\emptyset$');
