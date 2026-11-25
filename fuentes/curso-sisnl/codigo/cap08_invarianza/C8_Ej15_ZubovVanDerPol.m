%% C8_Ej15_ZubovVanDerPol -- Notas: sección 8.8 (Zubov numérico, van der Pol en tiempo invertido)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   x1' = -x2, x2' = x1 + (x1^2 - 1) x2. Calcula W(x0) = int_0^inf ||phi_t(x0)||^2 dt
%            en puntos y en una malla (zubovMalla), y compara con x'Px del capítulo 7.
% OBSERVE    Cerca del origen W ~ x'Px (Zubov contiene a la ecuación de Lyapunov); W explota
%            en el ciclo límite, la frontera de la región de atracción.
% ESPERADO   W(0.1, 0) = 0.0150, W(1, 0) = 1.60, W(1.9, 0) = 11.2, W(2.1, 0) = Inf.
%            Área de la región 13.7; mejor elipse (c* = 2.30) 6.46: el 47 %.
% EXPLORE    Cambie h por 2 x1^2 + x2^2 (problema 8.12). ¿Cambia {V < 1}?
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
addpath(raiz);

% [ini:zubov]
f = @(t, x) [-x(2); x(1) + (x(1)^2 - 1)*x(2)];
hfun = @(x) x(1)^2 + x(2)^2;
P = ecuacionLyapunov([0 -1; 1 -1], eye(2));                 % la P del capítulo 7
for x0 = [[0.1; 0], [1; 0], [1.9; 0], [2.1; 0]]
    fprintf('W(%.1f, %.1f) = %8.4f   x''Px = %.4f\n', x0, zubovMalla(f, x0(1), x0(2), hfun), x0'*P*x0);
end
n = 41;  g = linspace(-3, 3, n);                            % malla gruesa (sube n para la figura)
W = zubovMalla(f, g, g, hfun);
dA = (g(2) - g(1))^2;
fprintf('área de {W < Inf} en la malla = %.1f (interior del ciclo: 13.7)\n', sum(isfinite(W(:)))*dA);
fprintf('área de la mejor elipse x''Px <= 2.30: %.2f\n', pi*2.30/sqrt(det(P)));
% [fin:zubov]

% ---- Figura de las notas (fig:iv-zubov-vdp) -------------------------------------
% (La figura de las notas usa n = 91; con n = 41 se ve igual, un poco más gruesa.)
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
[X1, X2] = meshgrid(g);  VV = 1 - exp(-W);  VV(isinf(W)) = NaN;
[tc, Xc] = ode45(@(t, x) [x(2); -x(1) + (1 - x(1)^2)*x(2)], linspace(0, 40, 8000), [2; 0], odeset('RelTol', 1e-10));
mc = tc > 30;                                                % el ciclo, ya asentado
th = linspace(0, 2*pi, 300);  U = [cos(th); sin(th)];  R = sqrt(2.30./sum(U.*(P*U), 1));  % x'Px = 2.30
fig = estiloFigura(1200, 500);
subplot(1, 2, 1);  hold on;
contour(X1, X2, VV, [0.5 0.9 0.99 0.999], 'LineColor', az, 'LineWidth', 1);
plot(Xc(mc, 1), Xc(mc, 2), 'Color', co, 'LineWidth', 1.8);  plot(U(1, :).*R, U(2, :).*R, 'Color', ve, 'LineWidth', 1.6);
axis equal;  axis([-3 3 -3 3]);  box on;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');
title('Zubov (azul), ciclo (coral), cuadr\''atica (verde)');
subplot(1, 2, 2);  hold on;
pcolor(X1, X2, VV);  shading interp;  colormap(gca, [linspace(1, az(1), 256)' linspace(1, az(2), 256)' linspace(1, az(3), 256)']);  caxis([0 1]);  colorbar;
plot(Xc(mc, 1), Xc(mc, 2), 'Color', co, 'LineWidth', 1.2);
axis equal;  axis([-3 3 -3 3]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');  title('$V(x)$ en la malla (blanco: $W=\infty$)');
