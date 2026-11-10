%% C1_Ej3_Panorama -- Notas: sección 1.3 (cinco cosas que un sistema lineal no puede hacer)
% QUÉ HACE   Seis paneles: (a) retrato del péndulo con fricción y sus infinitos
%            equilibrios; (b) ciclo límite de van der Pol, alcanzado desde
%            adentro y desde afuera; (c) escape en tiempo finito de x' = -x^2;
%            (d) bifurcación silla-nodo de x' = r + x^2; (e) atractor de Lorenz;
%            (f) dos condiciones iniciales de Lorenz que difieren en 1e-9.
%            Además calcula el período del péndulo sin fricción en función de
%            la amplitud.
% OBSERVE    Ninguno de los seis comportamientos es posible en x' = Ax.
%            El período del péndulo crece con la amplitud: un oscilador lineal
%            tiene el mismo período para todas las amplitudes.
% ESPERADO   T/T0 = 1.0019 (10°), 1.0400 (45°), 1.1803 (90°), 2.4394 (170°).
%            Lorenz: la diferencia pasa de 1e-9 a orden 1 cerca de t = 33
%            (el instante exacto depende de las tolerancias del integrador).
% EXPLORE    Repita (f) con RelTol = 1e-6. ¿Cambia el instante en que se separan?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:periodo]
% Péndulo sin fricción, g/l = 1:  T(theta0) = 4 K(sin(theta0/2)) con K la integral
% elíptica completa de primera especie; T0 = 2 pi.
for th0 = [10 45 90 170]
    k = sind(th0/2);
    Kel = integral(@(p) 1./sqrt(1 - k^2*sin(p).^2), 0, pi/2);
    fprintf('theta0 = %3d°:  T/T0 = %.4f\n', th0, 4*Kel/(2*pi));
end
% [fin:periodo]

fig = estiloFigura(1250, 700);
% (a) péndulo con fricción, g/l = 1, k/m = 0.3
subplot(2, 3, 1); hold on;
pend = @(t, x) [x(2); -sin(x(1)) - 0.3*x(2)];
for x0 = [-7 -4 -1 2 5], [~, X] = ode45(pend, [0 30], [x0; 2.2], opc); plot(X(:,1), X(:,2)); end
plot((-3:3)*pi, 0*(-3:3), 'ko', 'MarkerFaceColor', 'k'); grid on; axis([-3*pi 3*pi -4 4]);
title('(a) infinitos equilibrios'); xlabel('$\theta$'); ylabel('$\dot\theta$');
% [ini:vanderpol]
% (b) van der Pol, epsilon = 1: el mismo ciclo desde adentro y desde afuera
subplot(2, 3, 2); hold on;
vdp = @(t, x) [x(2); (1 - x(1)^2)*x(2) - x(1)];
for x0 = [0.1 3.5]
    [~, X] = ode45(vdp, [0 30], [x0; 0], opc); plot(X(:,1), X(:,2));
end
% [fin:vanderpol]
grid on; axis equal; title('(b) ciclo l\''imite'); xlabel('$x_1$'); ylabel('$x_2$');
% (c) escape en tiempo finito de x' = -x^2, x(0) = -1:  x(t) = 1/(t - 1)
subplot(2, 3, 3); t = linspace(0, 0.98, 400); plot(t, 1./(t - 1)); hold on;
plot([1 1], [-60 5], '--'); grid on; axis([0 1.2 -60 5]); title('(c) escape en $t=1$'); xlabel('$t$');
% (d) silla-nodo de x' = r + x^2
subplot(2, 3, 4); r = linspace(-4, 0, 200); plot(r, -sqrt(-r), r, sqrt(-r), '--'); grid on;
axis([-4 2 -2.5 2.5]); title('(d) silla-nodo'); xlabel('$r$'); ylabel('$x^*$');
% [ini:lorenz]
% (e)-(f) Lorenz, sigma = 10, rho = 28, beta = 8/3
lor = @(t, x) [10*(x(2) - x(1)); x(1)*(28 - x(3)) - x(2); x(1)*x(2) - 8/3*x(3)];
o12 = odeset('RelTol', 1e-12, 'AbsTol', 1e-12);
tt = linspace(0, 40, 4001);
[~, Xa] = ode45(lor, tt, [1; 1; 1], o12);
[~, Xb] = ode45(lor, tt, [1 + 1e-9; 1; 1], o12);
d = sqrt(sum((Xa - Xb).^2, 2));
fprintf('Lorenz: |diferencia| > 1 por primera vez en t = %.1f\n', tt(find(d > 1, 1)));
% [fin:lorenz]
subplot(2, 3, 5); plot3(Xa(:,1), Xa(:,2), Xa(:,3), 'LineWidth', 0.6); grid on; view(25, 20);
title('(e) atractor de Lorenz');
subplot(2, 3, 6); semilogy(tt, d + 1e-16); grid on; xlabel('$t$'); ylabel('$\|\Delta x(t)\|$');
title('(f) $\|\Delta x(0)\|=10^{-9}$');
