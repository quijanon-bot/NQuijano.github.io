%% C7_Ej2_Indirecto -- Notas: sección 7.3 (método indirecto)
% QUÉ HACE   (1) Jacobiano del péndulo con fricción (a = 1, b = 0.5) en (0,0) y en (pi,0).
%            (2) x' = a x - x^3 para a = -1, 0, 1: valor propio de la linealización en el
%            origen y lo que hacen las soluciones; compara x' = -x^3 con x' = -x.
% OBSERVE    (2) Con a = 0 la linealización es x' = 0 y no decide nada: el origen de
%            x' = -x^3 es asintóticamente estable, pero la convergencia es algebraica
%            (como 1/sqrt(2t)), no exponencial.
% ESPERADO   (1) (0,0): -0.25 +- 0.968j (Hurwitz).  (pi,0): 0.781 y -1.281 (silla).
%            (2) desde x0 = 1: x(10) = 0.2182 con -x^3, contra 4.54e-5 con -x.
% EXPLORE    Repita (2) con x' = +x^3. ¿Qué dice la linealización? ¿Qué pasa realmente?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:jacobiano]
a = 1;  b = 0.5;
J = @(x1) [0 1; -a*cos(x1) -b];                  % jacobiano de f en (x1, 0)
fprintf('(0,0):  eig = %s\n', num2str(eig(J(0)).', '%.4f  '));
fprintf('(pi,0): eig = %s\n', num2str(eig(J(pi)).', '%.4f  '));
% [fin:jacobiano]

% [ini:cubico]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);  t = linspace(0, 10, 1001);
for aa = [-1 0 1]
    fprintf('x'' = %+d x - x^3: linealización en 0 tiene valor propio %+d\n', aa, aa);
end
[~, xc] = ode45(@(t, x) -x^3, t, 1, opc);
[~, xl] = ode45(@(t, x) -x, t, 1, opc);
fprintf('x(10): con -x^3 %.4f (exacto 1/sqrt(21) = %.4f), con -x %.3e\n', xc(end), 1/sqrt(21), xl(end));
% [fin:cubico]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  semilogy(t, xc, t, xl);  grid on;
xlabel('$t$');  ylabel('$x(t)$');  legend('$\dot x=-x^3$', '$\dot x=-x$');  title('Asint\''otica no es exponencial');
subplot(1, 2, 2);  xx = linspace(-1.6, 1.6, 300);  hold on;  grid on;
plot(xx, -xx - xx.^3, xx, -xx.^3, xx, xx - xx.^3);  plot(xx, 0*xx, 'k');
xlabel('$x$');  ylabel('$\dot x$');  legend('$a=-1$', '$a=0$', '$a=1$');  title('$\dot x=ax-x^3$');
