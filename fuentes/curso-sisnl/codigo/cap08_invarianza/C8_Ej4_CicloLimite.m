%% C8_Ej4_CicloLimite -- Notas: sección 8.4 (LaSalle con V no definida positiva)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% ---- Figura de las notas (fig:iv-ciclo) -----------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
th = linspace(0, 2*pi, 300);  r1 = sqrt(1 - 2*sqrt(c));  r2 = sqrt(1 + 2*sqrt(c));
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;
fill([r2*cos(th) r1*cos(fliplr(th))], [r2*sin(th) r1*sin(fliplr(th))], 1 - 0.2*(1 - az), 'EdgeColor', 'none');
plot(cos(th), sin(th), 'Color', co, 'LineWidth', 2.4);
for x0 = [[1.3; 0.3], [0; -0.4]]
    [~, X] = ode45(f, [0 12], x0, opc);  plot(X(:, 1), X(:, 2), 'Color', no, 'LineWidth', 0.9);
end
plot(0, 0, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
text(-0.45, 0.05, '$E=M$', 'Color', co);  text(0.6, 1.25, '$\Omega_c$', 'Color', az);
axis equal;  axis([-1.6 1.6 -1.6 1.6]);  box on;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
title('anillo $\Omega_{0.2}$ y el ciclo');
subplot(1, 2, 2);  hold on;  grid on;
fill([r1 r2 r2 r1], [0 0 0.6 0.6], 1 - 0.12*(1 - az), 'EdgeColor', 'none');
rr = linspace(0, 1.6, 400);  plot(rr, (rr.^2 - 1).^2/4, 'Color', no);
plot([0 1.6], [c c], '--', 'Color', az, 'LineWidth', 1);
mk = {'o', 's'};  x0s = [[1.3; 0.3], [0; -0.4]];
for j = 1:2
    [ts, X] = ode45(f, linspace(0, 12, 40), x0s(:, j), opc);  R = hypot(X(:, 1), X(:, 2));
    scatter(R, (R.^2 - 1).^2/4, 20, ts, 'filled', 'Marker', mk{j});
end
try, colormap(gca, parula); catch, colormap(gca, viridis); end   % (Octave: viridis)  text(0.02, 0.22, '$c=0.2$', 'Color', az);
axis([0 1.6 0 0.6]);  box on;  xlabel('$r$');  ylabel('$V=\frac14(r^2-1)^2$');
title('el sombrero: $V(0)$ es un m\''aximo');
