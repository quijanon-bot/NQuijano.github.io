%% C2_Ej2_NoHiperbolicos -- Notas: sección 2.3 (cuando f'(x*) = 0)
% QUÉ HACE   Compara x' = -x^3, x' = x^3 y x' = x^2: los tres tienen f(0) = 0 y
%            f'(0) = 0, la misma linealización x' = 0.
% OBSERVE    El origen es estable, inestable y semiestable, respectivamente. En
%            el caso estable el decaimiento es lento, como t^(-1/2): no es
%            exponencial. En los otros dos, las soluciones no solo se alejan:
%            escapan a infinito en tiempo finito.
% ESPERADO   x' = -x^3, x0 = 1:  x(10) = 1/sqrt(21) = 0.2182.
%            x' = x^3, x0 = 1: escape en t = 1/(2 x0^2) = 0.5.
%            x' = x^2: x0 = -1 -> x(10) = -1/11;  x0 = 1 -> escape en t = 1.
% EXPLORE    Compare x' = -x^3 con x' = -x desde x0 = 1. ¿Cuál está más cerca de
%            0 en t = 1? ¿Y en t = 100?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:tres]
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-13);
[~, x] = ode45(@(t, x) -x^3, [0 10], 1, opc);
fprintf('x'' = -x^3: x(10) = %.4f   (exacta 1/sqrt(1 + 2 t) = %.4f)\n', x(end), 1/sqrt(21));
[~, x] = ode45(@(t, x) x^2, [0 10], -1, opc);
fprintf('x'' = x^2, x0 = -1: x(10) = %.4f   (exacta -1/11 = %.4f)\n', x(end), -1/11);
for c = {{@(x) x^3, 1, 0.5}, {@(x) x^2, 1, 1}}
    g = c{1}{1};  x0 = c{1}{2};  te = c{1}{3};
    [~, x] = ode45(@(t, x) g(x), [0 0.999*te], x0, opc);
    fprintf('x(%.3f) = %8.1f: crece sin cota antes de t = %g\n', 0.999*te, x(end), te);
end
% [fin:tres]

fig = estiloFigura(1200, 420); fs = {@(x) -x.^3, @(x) x.^3, @(x) x.^2};
tit = {'$\dot x=-x^3$: estable', '$\dot x=x^3$: inestable', '$\dot x=x^2$: semiestable'};
for i = 1:3
    ax = subplot(1, 3, i); lineaFase(ax, fs{i}, [-1.5 1.5], 'Equilibrios', 0); title(ax, tit{i}); xlabel(ax, '$x$');
end
