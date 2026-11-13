%% C6_Ej7_Genetico -- Notas: sección 6.5 (el interruptor genético de Griffith)
% QUÉ HACE   (1) Para x' = -a x + y, y' = x^2/(1+x^2) - b y calcula los equilibrios,
%            sus (tau, delta) y su tipo, y el valor crítico a_c = 1/(2b).
%            (2) Histéresis: con b = 0.35, el gen encendido sigue encendido con
%            a = 1.3, se apaga con a = 1.6 y sigue apagado al volver a a = 1.3.
% OBSERVE    En a = a_c los dos equilibrios no nulos chocan en x = 1 para cualquier b.
% ESPERADO   b = 0.35: a_c = 1.4286. a = 1: x* = 0 (nodo), 0.4084 (silla), 2.4488 (nodo).
% EXPLORE    Desde el estado apagado con a = 1, ¿qué pulso de proteína (x(0)) hace
%            falta para encender el gen? Compare con la variedad estable de la silla.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:genetico]
b = 0.35;  a = 1;  ac = 1/(2*b);
fprintf('b = %.2f: a_c = 1/(2b) = %.4f\n', b, ac);
d = 1 - 4*a^2*b^2;
xs = [0, (1 - sqrt(d))/(2*a*b), (1 + sqrt(d))/(2*a*b)];
for x = xs
    J = [-a 1; 2*x/(1 + x^2)^2 -b];
    fprintf('a = %g: x* = %.4f, y* = %.4f, tau = %.3f, delta = %+.4f: %s\n', ...
            a, x, a*x, trace(J), det(J), clasificarEquilibrio(J));
end
% [fin:genetico]

% [ini:histeresis]
F = @(a) @(t, z) [-a*z(1) + z(2); z(1)^2/(1 + z(1)^2) - b*z(2)];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
z = [2; 2.6];
for a = [1.3 1.6 1.3]
    [~, Z] = ode45(F(a), [0 400], z, opc);  z = Z(end, :).';
    fprintf('a = %.1f: x final = %.4f\n', a, z(1));
end
% [fin:histeresis]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  xx = linspace(0, 3.6, 300);  hold on;
plot(xx, xx.^2./(b*(1 + xx.^2)), 'k');
for aa = [0.93 ac 2.4], plot(xx, aa*xx, '--'); end
axis([0 3.6 0 3.2]);  grid on;  xlabel('$x$');  ylabel('$y$');  title('Nulclinas');
retratoFase(subplot(1, 2, 2), @(z) F(1)(0, z), [0 3.5], [0 3.5], 'T', 30, 'Equilibrios', [xs; xs]);
title('$a=1$, $b=0.35$');  xlabel('$x$');  ylabel('$y$');
