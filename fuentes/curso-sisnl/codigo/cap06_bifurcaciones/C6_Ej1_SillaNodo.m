%% C6_Ej1_SillaNodo -- Notas: sección 6.3 (la bifurcación silla-nodo)
% QUÉ HACE   (1) Dibuja la línea de fase de x' = mu + x^2 para mu = -1, 0, 1.
%            (2) Diagrama de bifurcación: equilibrios +-sqrt(-mu) con su estabilidad.
%            (3) Verifica las condiciones de la silla-nodo para la cosecha
%            x' = x(1-x) - h en (x*, h) = (1/2, 1/4).
% OBSERVE    En mu = 0 el equilibrio es semiestable (la línea de fase lo clasifica por
%            el signo de f, no por f'(0) = 0). Para mu > 0 no hay equilibrios.
% ESPERADO   mu = -1: -1 estable, +1 inestable. Cosecha: f_x = 0, f_h = -1, f_xx = -2.
% EXPLORE    Cambie a x' = mu - x^2 (la "de cielo azul"). ¿De qué lado aparecen
%            ahora los equilibrios? ¿Cuál es estable?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:sillanodo]
mus = [-1 0 1];
fig = estiloFigura(1300, 420);
for k = 1:3
    mu = mus(k);
    if mu < 0, eqc = [-sqrt(-mu) sqrt(-mu)]; elseif mu == 0, eqc = 0; else, eqc = []; end
    eq = lineaFase(subplot(1, 4, k), @(x) mu + x.^2, [-2 2], 'Equilibrios', eqc);
    title(sprintf('$\\mu=%g$', mu));  xlabel('$x$');  ylabel('$\\dot x$');  ylim([-1.5 4]);
    for i = 1:numel(eq.x), fprintf('mu = %+g: x* = %+.3f %s\n', mu, eq.x(i), eq.tipo{i}); end
end
m = linspace(-2, 0, 200);                       % diagrama: mu = -x^2
subplot(1, 4, 4);  hold on;
plot(m, -sqrt(-m), '-', 'Color', [20 33 61]/255);      % rama estable
plot(m,  sqrt(-m), '--', 'Color', [209 73 91]/255);    % rama inestable
plot(0, 0, 'o', 'MarkerFaceColor', [0.6 0.6 0.6], 'MarkerEdgeColor', 'k');
grid on;  xlabel('$\mu$');  ylabel('$x^*$');  xlim([-2 1]);  title('Diagrama de bifurcaci\''on');
% [fin:sillanodo]

% [ini:cosecha]
% x' = x(1-x) - h: condiciones del teorema de la silla-nodo en (1/2, 1/4)
fx  = @(x, h) 1 - 2*x;      fh = @(x, h) -1;      fxx = @(x, h) -2;
fprintf('cosecha: f = %g, f_x = %g, f_h = %g, f_xx/2 = %g\n', 0.5*(1 - 0.5) - 0.25, ...
        fx(0.5, 0.25), fh(0.5, 0.25), fxx(0.5, 0.25)/2);
% forma normal exacta: x' = (1/4 - h) - (x - 1/2)^2
x = linspace(0, 1, 7);  h = 0.2;
fprintf('max |x(1-x) - h - [(1/4-h) - (x-1/2)^2]| = %.1e\n', max(abs(x.*(1 - x) - h - ((0.25 - h) - (x - 0.5).^2))));
% [fin:cosecha]
