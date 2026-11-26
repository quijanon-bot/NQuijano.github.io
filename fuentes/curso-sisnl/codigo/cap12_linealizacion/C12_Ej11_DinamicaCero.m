%% C12_Ej11_DinamicaCero -- Notas: secciones 12.9 y 12.10 (dinámica cero)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Caso lineal: x1' = x2, x2' = alpha x3 + u, x3' = beta x3 - u, y = x1,
%            con G(s) = (s - (alpha + beta))/(s^2 (s - beta)). Ley entrada/salida
%            u = -alpha x3 + v, v = -4 y - 4 y'. Compara alpha + beta = -1 y +1.
%            (2) Fase mínima: x' = (x3 - x2^3, -x2, x1^2 - x3) + (0, -1, 1) u, y = x1
%            (r = 2, dinámica cero z3' = -z3), con u = (v - L_f^2 h)/(L_g L_f h).
%            (3) n = 3, r = 1 en forma normal: xi' = -3 xi, eta' = [s -2; 2 s] eta + [xi; 0].
% OBSERVE    (1) La salida es IDÉNTICA en los dos casos; el cero en s = +1 se ve en el
%            estado interno y en el control, que crecen como e^t. (2) y y TODO el estado
%            van a cero: la dinámica cero es exponencialmente estable.
%            (3) Después de caer a Z*, solo la dinámica cero decide.
% ESPERADO   (1) y(6) = 8.0e-5 en ambos; x3(6) = -0.0096 (cero en -1) y 179.3 (cero en +1).
%            (2) |x(10)| < 1e-3 desde (1, 0.5, -0.5).  (3) |eta(14)| = 0.039 (s = -0.25)
%            y 6.86 (s = 0.12).
% EXPLORE    En (1), ¿qué pasa con alpha + beta = 0? ¿Es el sistema de fase mínima?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:lineal]
t = linspace(0, 6, 601);  casos = [1 -2; 2 -1];  X = cell(1, 2);
for j = 1:2
    al = casos(j, 1);  be = casos(j, 2);
    u = @(x) -al*x(3) - 4*x(1) - 4*x(2);
    [~, X{j}] = ode45(@(t, x) [x(2); al*x(3) + u(x); be*x(3) - u(x)], t, [1; 0; 0], opc);
    fprintf('alpha + beta = %+d (cero de G en s = %+d): y(6) = %.1e, x3(6) = %.4g\n', al + be, al + be, ...
            X{j}(end, 1), X{j}(end, 3));
end
% [fin:lineal]

% [ini:faseminima]
f  = @(x) [x(3) - x(2)^3; -x(2); x(1)^2 - x(3)];  g = [0; -1; 1];
a  = @(x) 3*x(2)^3 + x(1)^2 - x(3);              % L_f^2 h
b  = @(x) 1 + 3*x(2)^2;                           % L_g L_f h  (nunca se anula)
v  = @(x) -2*x(1) - 3*(x(3) - x(2)^3);           % polos en -1, -2 sobre (y, y')
[t2, X2] = ode45(@(t, x) f(x) + g*(v(x) - a(x))/b(x), [0 10], [1; 0.5; -0.5], opc);
fprintf('fase mínima: |x(10)| = %.1e\n', norm(X2(end, :)));
% [fin:faseminima]

% [ini:tres]
for s = [-0.25 0.12]
    M = [s -2; 2 s];
    [~, Z] = ode45(@(t, z) [-3*z(1); M*z(2:3) + [z(1); 0]], [0 14], [1.2; 1.0; 0.3], opc);
    fprintf('s = %+.2f: |eta(14)| = %.4f,  xi(14) = %.1e\n', s, norm(Z(end, 2:3)), Z(end, 1));
end
% [fin:tres]



% ---- Figura de las notas (fig:fl-ceros) ------------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
t = linspace(0, 6, 601);  oo = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
sl = @(y) sign(y).*log10(1 + abs(y));                 % escala "symlog": lineal cerca de 0, logarítmica lejos
marcas = [-100 -10 -1 0 1 10 100];
fig = estiloFigura(1300, 420);  pares = [1 -2; 2 -1];  cs = [az; co];  es = {'-', '--'};
for j = 1:2
    al = pares(j, 1);  be = pares(j, 2);
    [~, X] = ode45(@(tt, x) [x(2); al*x(3) + (-al*x(3) - 4*x(1) - 4*x(2)); be*x(3) - (-al*x(3) - 4*x(1) - 4*x(2))], t, [1; 0; 0], oo);
    u = -al*X(:,3) - 4*X(:,1) - 4*X(:,2);
    subplot(1, 3, 1);  plot(t, X(:,1), es{j}, 'Color', cs(j,:));  hold on;
    subplot(1, 3, 2);  plot(t, sl(X(:,3)), es{j}, 'Color', cs(j,:));  hold on;
    subplot(1, 3, 3);  plot(t, sl(u), es{j}, 'Color', cs(j,:));  hold on;
end
subplot(1, 3, 1);  title('$y(t)$: id\''entica');  legend('cero en $-1$', 'cero en $+1$');
subplot(1, 3, 2);  title('$x_3(t)$');  subplot(1, 3, 3);  title('$u(t)$');
for j = 1:3
    subplot(1, 3, j);  grid on;  box on;  xlabel('$t$');
    if j > 1, set(gca, 'YTick', sl(marcas), 'YTickLabel', {'-100', '-10', '-1', '0', '1', '10', '100'}); end
end

% ---- Figura de las notas (fig:fl-cero3d) -----------------------------------------------------
cz = @(e1, e2) 0.3*(e1.^2 - e2.^2);  [G1, G2] = meshgrid(linspace(-2.2, 2.2, 30));
fig2 = estiloFigura(1200, 520);  sgs = [-0.25 0.12];  cs = [ve; co];
tit = {'fase m\''inima ($s=-0.25$)', 'fase no m\''inima ($s=+0.12$)'};
for j = 1:2
    subplot(1, 2, j);  hold on;
    surf(G1, G2, cz(G1, G2), 'FaceColor', az, 'FaceAlpha', 0.18, 'EdgeColor', 'none');
    M = [sgs(j) -2; 2 sgs(j)];
    [~, Z] = ode45(@(t, z) [-3*z(1); M*z(2:3) + [z(1); 0]], linspace(0, 14, 3000), [1.2; 1.0; 0.3], oo);
    Z(abs(Z(:,2)) >= 2.2 | abs(Z(:,3)) >= 2.2, :) = NaN;        % fuera de la caja: se corta la curva
    plot3(Z(:,2), Z(:,3), Z(:,1) + cz(Z(:,2), Z(:,3)), 'Color', cs(j,:), 'LineWidth', 1.5);
    plot3(1.0, 0.3, 1.2 + cz(1.0, 0.3), 'o', 'Color', no, 'MarkerFaceColor', no, 'MarkerSize', 4);
    view(-35 + 90, 25);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  zlabel('$x_3$');  title(tit{j});
end
