%% C11_Ej7_LaSalleRLC -- Notas: sección 11.6 (OSP + ZSO + LaSalle)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   RLC serie (R = L = C = 1) con u = 0: x1' = x2, x2' = -x1 - x2, y = x2,
%            V = (x1^2 + x2^2)/2, V' = -x2^2. Y el contraejemplo sin ZSO:
%            x1' = 0, x2' = -x2 + u, y = x2.
% OBSERVE    En el RLC, V' = 0 en la recta x2 = 0, pero la trayectoria la cruza
%            sin quedarse (ZSO) y V(x(t)) se aplana en cada cruce. En el
%            contraejemplo x1 no se mueve: estable, no asintóticamente estable.
% ESPERADO   RLC: V(20) ~ 1e-9 desde x0 = [1.5; 0]. Contraejemplo: x1(t) = x1(0).
%            Con V_eps = V + eps x1 x2, V_eps' es negativa definida para 0 < eps < 4/5.
% EXPLORE    Verifique numéricamente que con eps = 0.9 V_eps' toma valores positivos.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:lasalle]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) [x(2); -x(1) - x(2)], linspace(0, 20, 4001), [1.5; 0], opc);
V  = (X(:,1).^2 + X(:,2).^2)/2;
cruces = t(find(diff(sign(X(:,2))) ~= 0));
fprintf('V(20) = %.1e;  la trayectoria cruza x2 = 0 en t = %s\n', V(end), ...
        mat2str(cruces(1:4).', 3));
% [fin:lasalle]

% [ini:contraejemplo]
[t2, X2] = ode45(@(t, x) [0; -x(2)], [0 6], [1; 1.2], opc);
fprintf('contraejemplo: x1(6) = %.4f (no se mueve),  x2(6) = %.4f\n', X2(end,1), X2(end,2));
% [fin:contraejemplo]

% [ini:veps]
[x1, x2] = meshgrid(linspace(-1, 1, 201));
for eps_ = [0.5 0.79 0.81 0.9]
    dVe = -eps_*x1.^2 - eps_*x1.*x2 - (1 - eps_)*x2.^2;
    dVe(x1 == 0 & x2 == 0) = -1;
    fprintf('eps = %.2f:  max de dV_eps fuera del origen = %+.2e\n', eps_, max(dVe(:)));
end
% [fin:veps]

% ---- Figura de las notas (fig:pa-lasalle) ----------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) [x(2); -x(1) - x(2)], linspace(0, 14, 5001), [1.5; 0], opc);
V = (X(:,1).^2 + X(:,2).^2)/2;
fig = estiloFigura(1300, 440);
subplot(1, 3, 1);  hold on;  th = linspace(0, 2*pi, 300);
for c = [0.25 0.5 0.75 1.0 1.25], plot(sqrt(2*c)*cos(th), sqrt(2*c)*sin(th), 'Color', cl, 'LineWidth', 0.8); end
plot(X(:,1), X(:,2), 'Color', az);  plot([-1.7 1.7], [0 0], 'Color', co, 'LineWidth', 1.6);
axis equal;  axis([-1.7 1.7 -1.7 1.7]);  grid on;  box on;  xlabel('$x_1$');  ylabel('$x_2$');
title('$E=\{x_2=0\}$ en rojo');
subplot(1, 3, 2);  hold on;
cruces = find(diff(sign(X(:,2))) ~= 0);
for i = cruces.', plot(t([i i]), [0 1.2], '--', 'Color', co, 'LineWidth', 0.8); end
plot(t, V, 'Color', no);  xlim([0 14]);  grid on;  box on;  xlabel('$t$');
title('$V(x(t))$: se aplana al cruzar');
subplot(1, 3, 3);  hold on;  t2 = linspace(0, 6, 600);
for x10 = [-1 -0.5 0.5 1]                     % sin ZSO: x1' = 0, x2' = -x2
    plot(x10 + 0*t2, 1.2*exp(-t2), 'Color', vi);
    plot(x10, 1.2*exp(-6), 'o', 'Color', vi, 'MarkerFaceColor', vi, 'MarkerSize', 4);
end
plot([-1.4 1.4], [0 0], 'Color', co, 'LineWidth', 1.6);
axis([-1.4 1.4 -0.2 1.4]);  grid on;  box on;  xlabel('$x_1$');  ylabel('$x_2$');
title('sin ZSO: estable, no AS');
