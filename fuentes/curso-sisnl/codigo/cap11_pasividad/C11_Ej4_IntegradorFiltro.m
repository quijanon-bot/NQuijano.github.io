%% C11_Ej4_IntegradorFiltro -- Notas: sección 11.5 (integrador frente a filtro)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Con el mismo almacenamiento V = x^2/2, compara 1/s (sin pérdidas)
%            con 1/(s+1) (OSP y estrictamente pasivo): balance ante la misma
%            entrada y diagrama de Nyquist.
% OBSERVE    En 1/s toda la energía suministrada queda almacenada; en 1/(s+1)
%            una parte se disipa (int y^2). En Nyquist, 1/s vive sobre el eje
%            imaginario (fase -90°) y 1/(s+1) estrictamente a la derecha.
% ESPERADO   1/s: V(T) - V(0) = int u y (residuo ~1e-12);
%            1/(s+1): V(T) - V(0) = int u y - int y^2.
% EXPLORE    Pruebe 1/(s-1) con el mismo V: ¿qué término del balance cambia de signo?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:energia]
u   = @(t) sin(t) + 0.5*sin(3*t);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.01);
[t, xi] = ode45(@(t, x) u(t), [0 20], 0, opc);          % integrador: x' = u, y = x
[~, xf] = ode45(@(t, x) -x + u(t), t, 0, opc);           % filtro: x' = -x + u, y = x
[Si, ~, ri] = balanceEnergia(t, xi.^2/2, u(t).*xi, 0*t);
[Sf, Df, rf] = balanceEnergia(t, xf.^2/2, u(t).*xf, xf.^2);
fprintf('integrador: residuo %.1e (lossless: nada se disipa)\n', max(abs(ri)));
fprintf('filtro:     residuo %.1e, disipado en [0,20] = %.3f\n', max(abs(rf)), Df(end));
% [fin:energia]

% [ini:nyquist]
w  = logspace(-3, 3, 2000);
Gi = respFrec(1, [1 0], w);   Gf = respFrec(1, [1 1], w);
fprintf('min Re 1/(jw) = %.2g;   min Re 1/(jw+1) = %.2g (> 0, tiende a 0 como 1/w^2)\n', ...
        min(real(Gi)), min(real(Gf)));
% [fin:nyquist]

% ---- Figura de las notas (fig:pa-intfiltro) --------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
w = logspace(-3, 3, 4000);  G1 = 1./(1j*w);  G2 = 1./(1j*w + 1);
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;
patch([0 1.6 1.6 0], [-1.6 -1.6 1.6 1.6], claro(az, 0.06), 'EdgeColor', 'none');
plot([-1 2], [0 0], 'Color', gr, 'LineWidth', 0.6);  plot([0 0], [-2 2], 'Color', gr, 'LineWidth', 0.6);
h = [plot(real(G2), imag(G2), 'Color', co), plot([0 0], [-1.6 1.6], 'Color', az)];
plot(real(G2), -imag(G2), ':', 'Color', co, 'LineWidth', 1);
axis equal;  axis([-0.6 1.4 -1 1]);  grid on;  box on;  xlabel('Re');  ylabel('Im');  title('Nyquist');
legend(h, '$1/(s+1)$', '$1/s$ (eje imaginario)', 'Location', 'southeast');
subplot(1, 2, 2);
semilogx(w, rad2deg(angle(G1)), 'Color', az);  hold on;
semilogx(w, rad2deg(angle(G2)), 'Color', co);
semilogx(w([1 end]), [-90 -90], '--', 'Color', gr, 'LineWidth', 0.8);
ylim([-100 5]);  grid on;  box on;  xlabel('$\omega$ (rad/s)');  ylabel('fase ($^\circ$)');
title('fase: el ``exceso'''' del filtro');  legend('$1/s$', '$1/(s+1)$', 'Location', 'east');
