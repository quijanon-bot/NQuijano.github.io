%% C3_Ej1_Linealizacion -- Notas: sección 3.2 (linealización con series de Taylor)
% QUÉ HACE   Linealiza simbólicamente (Symbolic Math Toolbox) un sistema de
%            una variable alrededor de un punto que NO es de equilibrio, y el
%            reactor de dos variables alrededor de su equilibrio.
% OBSERVE    Si el punto no es de equilibrio queda un término constante f(x0):
%            la aproximación es afín, no lineal. En el equilibrio desaparece.
% ESPERADO   f(5) = 35.36, f'(5) = 12.37;  reactor: xhat' = -3 xhat + uhat
% EXPLORE    Encuentre el rango de x en el que el error relativo es < 5 %.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:simbolica]
syms x real
f  = x*sqrt(x^2 + 5*x);
df = diff(f, x)                        % derivada simbólica
x0 = 5;
a0 = double(subs(f, x, x0))            % f(x0)  = 35.36 (no es cero: x0 no es equilibrio)
a1 = double(subs(df, x, x0))           % f'(x0) = 12.37
flin = @(xx) a0 + a1*(xx - x0);        % aproximación de primer orden
solve(f == 0, x)                       % los equilibrios son x* = 0 y x* = -5
% [fin:simbolica]
xx = linspace(0, 10, 400);
fig = estiloFigura(900, 420);
plot(xx, double(subs(f, x, xx)), xx, flin(xx), '--'); grid on;
legend('$f(x)$', 'linealizada en $x_0=5$', 'Location', 'northwest'); xlabel('$x$');

% [ini:reactor]
syms xs us real
k = 1;  V = 1;  c = 2;                 % L/(mol min), L, mol/L
F  = -k*xs^2 + us*(c - xs)/V;
J  = jacobian(F, [xs us]);             % [df/dx, df/du]
ab = double(subs(J, [xs us], [1 1]))   % -> [-3  1]:  xhat' = -3 xhat + uhat
G  = tf(ab(2), [1 -ab(1)])             % Xhat(s)/Uhat(s) = 1/(s+3)
% [fin:reactor]
