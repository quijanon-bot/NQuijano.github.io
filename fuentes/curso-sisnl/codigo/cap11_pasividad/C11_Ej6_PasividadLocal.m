%% C11_Ej6_PasividadLocal -- Notas: sección 11.5 (pasividad solo local)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Para x' = x^3 - k x + u, y = x, V = x^2/2, calcula V' - u y = x^2(x^2 - k)
%            y construye la prueba de que el sistema NO es pasivo en todo R:
%            con u constante se mantiene x(t) = xb fuera de |x| <= sqrt(k).
% OBSERVE    Con xb = 1.5 y k = 1 el sistema ENTREGA energía (int u y < 0)
%            sin gastar la que tiene (V no cambia).
% ESPERADO   int_0^T u y dt = -2.8125 T;  V(T) - V(0) = 0.
% EXPLORE    Repita con xb = 0.8: ¿qué signo tiene ahora la potencia?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:local]
k  = 1;   xb = 1.5;
ub = -(xb^3 - k*xb);                      % entrada que mantiene x(t) = xb
[t, x] = ode45(@(t, x) x^3 - k*x + ub, [0 4], xb, odeset('RelTol', 1e-12, 'AbsTol', 1e-12));
fprintf('x(4) - xb = %.1e   (el estado no se mueve)\n', x(end) - xb);
fprintf('potencia u y = %.4f (negativa: entrega energía)\n', ub*xb);
fprintf('int_0^4 u y dt = %.4f,   V(4) - V(0) = %.4f\n', 4*ub*xb, x(end)^2/2 - xb^2/2);
% [fin:local]

% ---- Figura de las notas (fig:pa-local) ------------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
k = 1;  x = linspace(-1.8, 1.8, 600);  d = x.^2.*(x.^2 - k);
fig = estiloFigura(1200, 440);
subplot(1, 2, 1);  hold on;
h = [rell(x, max(d, 0), 0*x, claro(co, 0.25)), rell(x, min(d, 0), 0*x, claro(ve, 0.25))];
plot(x, d, 'Color', no);  plot([-2 2], [0 0], 'Color', gr, 'LineWidth', 0.6);  plot([0 0], [-1 3], 'Color', gr, 'LineWidth', 0.6);
axis([-1.8 1.8 -0.5 2.0]);  grid on;  box on;  xlabel('$x$');
title('$\dot V-u\,y=x^2(x^2-k)$, $k=1$');  legend(h, 'crea energ\''ia', 'disipa', 'Location', 'north');
subplot(1, 2, 2);  hold on;  T = linspace(0, 4, 200);  xb = 1.5;
plot(T, -xb^2*(xb^2 - k)*T, 'Color', co);  plot(T, 0*T, 'Color', az);
grid on;  box on;  xlabel('$T$ (s)');  title('$x(t)\equiv 1.5$ con $u$ constante');
legend('$\int_0^T u\,y\,dt$', '$V(x(T))-V(x(0))=0$', 'Location', 'southwest');
