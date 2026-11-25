%% C8_Ej2_PenduloLaSalle -- Notas: sección 8.3 (el péndulo con fricción, por fin)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Péndulo x1' = x2, x2' = -a sin x1 - b x2 (a = 1, b = 0.3) con la energía V:
%            dibuja Omega_c (c = 1.8), las otras componentes de {V <= c}, el conjunto E,
%            los cruces de la solución con E y el balance b int x2^2 = V(x0) - V(x(t)).
%            [permanencia] calcula M con derivadas de Lie sobre E.
% OBSERVE    En cada cruce Vdot = 0 pero V sigue bajando. Sobre E el campo es vertical.
% ESPERADO   Borde de E: 2.498. 12 cruces en [0, 40]. Balance exacto hasta 1e-7.
%            Solo x1 = 0 anula h, L_f h y L_f^2 h en |x1| < pi: M = {0}.
% EXPLORE    Arranque en (1.2, 0) + (2 pi, 0). ¿A qué equilibrio llega? ¿Contradice el teorema?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:pendulo]
a = 1;  b = 0.3;  c = 1.8;
f = @(t, x) [x(2); -a*sin(x(1)) - b*x(2)];
V = @(x1, x2) a*(1 - cos(x1)) + x2.^2/2;
xE = acos(1 - c/a);                                         % E = {(x1, 0) : |x1| <= xE}
fprintf('E = {x2 = 0, |x1| <= %.3f}\n', xE);
x0 = [2; 0.8];
g = @(t, z) [f(t, z(1:2)); z(2)^2];                         % z(3) = int x2^2
[t, Z] = ode45(g, linspace(0, 40, 40001), [x0; 0], opc);
cruces = sum(diff(sign(Z(:, 2))) ~= 0);
balance = b*Z(end, 3) - (V(x0(1), x0(2)) - V(Z(end, 1), Z(end, 2)));
fprintf('V(x0) = %.3f, cruces con E en [0, 40]: %d, error del balance = %.1e\n', V(x0(1), x0(2)), cruces, balance);
% [fin:pendulo]

% [ini:permanencia]
% Sobre E (x2 = 0) se exige h = x2, L_f h y L_f^2 h nulas a la vez.
h   = @(x) x(2);
Lfh = @(x) [0 1]*f(0, x);                                   % = -a sin x1 - b x2
xs  = linspace(-xE, xE, 2001);
Lf  = arrayfun(@(q) Lfh([q; 0]), xs);
fprintf('puntos de E con L_f h = 0: x1 = %s\n', mat2str(xs(abs(Lf) < 1e-12), 3));
% [fin:permanencia]

% ---- Figura de las notas (fig:iv-pendulo) ---------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
ev = odeset(opc, 'Events', @(t, x) eventoODE(x(2), 0, 0));
[~, ~, tc, Xc] = ode45(f, [0 40], x0, ev);                    % cruces con E (x2 = 0)
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;
x1 = linspace(-9.5, 9.5, 700);  x2 = linspace(-2.6, 2.6, 400);  [X1, X2] = meshgrid(x1, x2);  VV = V(X1, X2);
pintarZonas(x1, x2, {VV <= c & abs(X1) >= pi, VV <= c & abs(X1) < pi}, [gr; az], [0.22 0.25]);
contour(X1, X2, VV, [2*a 2*a], 'LineColor', no, 'LineWidth', 0.9);       % separatrices, V = 2a
plot(Z(:, 1), Z(:, 2), 'Color', no, 'LineWidth', 0.9);
plot([-xE xE], [0 0], 'Color', co, 'LineWidth', 3);
plot(Xc(:, 1), Xc(:, 2), 's', 'Color', co, 'MarkerFaceColor', co, 'MarkerSize', 4);
for q = linspace(-xE, xE, 7)                                  % el campo sobre E es vertical
    if abs(q) > 0.05, quiver(q, 0, 0, -0.55*a*sin(q), 0, 'Color', vi, 'LineWidth', 1.1, 'MaxHeadSize', 0.8); end
end
plot([-2 0 2]*pi, [0 0 0], 'o', 'MarkerFaceColor', no, 'MarkerEdgeColor', no);
plot([-1 1]*pi, [0 0], 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
text(-9.2, 2.15, 'gris: $\{V\le c\}$ fuera de $\Omega_c$', 'Color', gr);
text(-1.1, -1.85, '$\Omega_c$', 'Color', az);  text(1.0, 0.25, '$E$', 'Color', co);
axis([-9.5 9.5 -2.6 2.6]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');
title('$\Omega_c$ ($c=1.8$), $E$ y una trayectoria');
subplot(1, 2, 2);  hold on;  grid on;
plot(t, V(Z(:, 1), Z(:, 2)), 'Color', az);  plot(t, -b*Z(:, 2).^2, 'Color', co, 'LineWidth', 1.3);
for te = tc(1:min(6, end))', plot([te te], [-1.5 2], ':', 'Color', gr, 'LineWidth', 0.6);  end
xlim([0 20]);  xlabel('$t$');  legend('$V(x(t))$', '$\dot V(x(t))$', 'Location', 'northeast');
title('$\dot V=0$ en los cruces; $V$ sigue bajando');
