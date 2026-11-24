%% C7_Ej3_Energia -- Notas: sección 7.4 (método directo)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Evalúa la energía V = a(1 - cos x1) + x2^2/2 a lo largo de soluciones del
%            péndulo con y sin fricción, y la compara con Vdot = -b x2^2.
%            (2) x' = -g(x) con g(x) = sin x + x^3 y V = int_0^x g: Vdot = -g(x)^2.
% OBSERVE    (1) Con fricción V decrece, pero con "escalones": se detiene cada vez que
%            x2 = 0. Vdot <= 0 da estabilidad, no estabilidad asintótica (eso lo arregla
%            el capítulo 8, o la V con término cruzado de la sección 7.6).
% ESPERADO   (1) b = 0: V constante (variación < 1e-8). b = 0.5: V(0) - V(20) =
%            int_0^20 b x2^2 dt.   (2) V decrece a cero desde x0 = 2.
% EXPLORE    ¿En qué instantes V deja de decrecer? Compare con los cruces x2 = 0.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:energia]
a = 1;  opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);  t = linspace(0, 20, 4001);
V = @(X) a*(1 - cos(X(:,1))) + X(:,2).^2/2;
for b = [0 0.5]
    [~, X] = ode45(@(t, x) [x(2); -a*sin(x(1)) - b*x(2)], t, [2.5; 0], opc);
    Vt = V(X);  disip = trapz(t, b*X(:,2).^2);
    fprintf('b = %.1f: V(0) = %.4f, V(20) = %.4f, int b x2^2 = %.4f, max dV = %.1e\n', ...
            b, Vt(1), Vt(end), disip, max(diff(Vt)));
end
% [fin:energia]

% [ini:gx]
g = @(x) sin(x) + x.^3;  Vg = @(x) 1 - cos(x) + x.^4/4;      % V = int_0^x g
[~, xg] = ode45(@(t, x) -g(x), t, 2, opc);
fprintf('x'' = -g(x): V(0) = %.4f, V(20) = %.2e; Vdot = -g^2 <= 0\n', Vg(2), Vg(xg(end)));
% [fin:gx]

% ---- Figura de las notas (fig:ly-energia): b = 0.5, desde (2.5, 0) ---------
az = [30 90 168]/255;  co = [209 73 91]/255;  ve = [42 157 143]/255;
fig1 = estiloFigura(1100, 420);
subplot(1, 2, 1);  hold on;  grid on;
h1 = plot(t, Vt, 'Color', ve);  h2 = plot(t, X(:,2), 'Color', az, 'LineWidth', 1);
ceros = t([false; diff(sign(X(:,2))) ~= 0]);           % instantes en que x2 = 0
for c = ceros, plot([c c], [-2 2], ':', 'Color', co, 'LineWidth', 0.8); end
ylim([-2 2]);  xlabel('$t$');  legend([h1 h2], '$V(x(t))$', '$x_2(t)$');
title('$\dot V=-bx_2^2$: se detiene si $x_2=0$');
subplot(1, 2, 2);  plot(t, -b*X(:,2).^2, 'Color', co);  grid on;  xlabel('$t$');
title('$\dot V(x(t))\le 0$, con ceros aislados');

% Figura adicional (no est\'a en las notas): x' = -g(x)
fig2 = estiloFigura(560, 420);  plot(t, Vg(xg));  grid on;  xlabel('$t$');  ylabel('$V$');  title('$\dot x=-g(x)$');
