%% C4_Ej12_VariedadCentral -- Notas: sección 4.8 (la variedad central)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Para y' = y z, z' = -z + a y^2 calcula los coeficientes de
%            h(y) = h2 y^2 + h4 y^4 igualando coeficientes en la ecuación de
%            invariancia (sin toolbox simbólico: un sistema de dos ecuaciones).
%            (2) Simula el sistema completo con a = -1 y compara y(t) con el sistema
%            reducido y' = a y^3 - 2 a^2 y^5. (3) Distancia de z(t) a h(y(t)).
% OBSERVE    z no tiende a 0: tiende a h(y) ~ a y^2. Si se pusiera z = 0, el reducido
%            sería y' = 0 y no decidiría nada.
% ESPERADO   h2 = a, h4 = -2 a^2.  a = -1: y(40) = 0.1055 (completo), 0.1025
%            (reducido), 0.1048 (y' = -y^3 solo).  |z - h(y)| < 1e-3 después de t = 10.
% EXPLORE    Repita con a = 0. ¿Qué predice el reducido? Compare con la solución
%            exacta y(t) = y0 exp(z0 (1 - e^{-t})).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:central]
a = -1;
% invariancia: h'(y) y h(y) + h(y) - a y^2 = 0, con h = h2 y^2 + h4 y^4
%   y^2:  h2 - a = 0          y^4:  2 h2^2 + h4 = 0
h2 = a;  h4 = -2*h2^2;
fprintf('h(y) = %g y^2 + (%g) y^4\n', h2, h4);
hfun = @(y) h2*y.^2 + h4*y.^4;
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) [x(1)*x(2); -x(2) + a*x(1)^2], [0 40], [0.3; 0.2], opc);
[~, yr] = ode45(@(t, y) a*y^3 - 2*a^2*y^5, t, 0.3, opc);
fprintf('y(40): completo %.4f, reducido %.4f, con y'' = a y^3 solo: %.4f\n', X(end, 1), yr(end), 0.3/sqrt(1 + 2*0.09*40));
d = abs(X(:, 2) - hfun(X(:, 1)));
fprintf('max |z - h(y)| para t > 10: %.2e\n', max(d(t > 10)));
% [fin:central]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  plot(t, X(:, 1), t, yr, '--');  grid on;  xlabel('$t$');  legend('$y$ (completo)', '$y$ (reducido)');
subplot(1, 2, 2);  semilogy(t, d);  grid on;  xlabel('$t$');  ylabel('$|z-h(y)|$');  title('Ca\''ida r\''apida sobre la variedad');

% [ini:unica]
% y' = y^2, z' = -z: las curvas z = c exp(1/y), y < 0, son invariantes y llegan al
% origen tangentes al eje y con todas sus derivadas nulas: no hay una sola variedad central.
yy = -0.05;
fprintf('exp(1/y)/y^5 en y = %.2f: %.2e (tiende a 0)\n', yy, exp(1/yy)/yy^5);
% [fin:unica]

fig2 = estiloFigura(1000, 440);                   % la figura de las notas: a = -1 y a = 1
[Y0, Z0] = meshgrid([-0.8 -0.5 -0.25 0.25 0.5 0.8], [-0.75 0.75]);  s = linspace(-0.62, 0.62, 200);
for k = 1:2
    aa = 2*k - 3;  ax = subplot(1, 2, k);
    retratoFase(ax, @(x) [x(1)*x(2); -x(2) + aa*x(1)^2], [-1 1], [-0.8 0.8], 'X0', [Y0(:)'; Z0(:)'], 'T', 30, 'N', 15);
    plot(ax, s, aa*s.^2 - 2*aa^2*s.^4, 'Color', [42 157 143]/255, 'LineWidth', 2.5);
    plot(ax, [-1 1], [0 0], 'k:');  xlabel(ax, '$y$');  ylabel(ax, '$z$');  title(ax, sprintf('$a=%d$', aa));
end

fig3 = estiloFigura(600, 460);  hold on;          % y' = y^2, z' = -z: muchas variedades centrales
yn = linspace(-1.2, -1e-3, 400);
for c = [-3 -1.5 -0.5 0.5 1.5 3], plot(yn, c*exp(1./yn), 'Color', [30 90 168]/255); end
plot([-1.2 1.2], [0 0], 'Color', [42 157 143]/255, 'LineWidth', 2.5);
plot(0, 0, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k');
xlim([-1.2 1.2]);  ylim([-1.2 1.2]);  grid on;  xlabel('$y$');  ylabel('$z$');
title('$\dot y=y^2$, $\dot z=-z$: $z=c\,e^{1/y}$ para $y<0$');
