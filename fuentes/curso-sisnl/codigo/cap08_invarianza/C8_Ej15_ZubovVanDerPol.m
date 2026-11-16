%% C8_Ej15_ZubovVanDerPol -- Notas: sección 8.8 (Zubov numérico, van der Pol en tiempo invertido)
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

fig = estiloFigura(560, 520);  [X1, X2] = meshgrid(g);  VV = 1 - exp(-W);  VV(isinf(W)) = NaN;
contour(X1, X2, VV, [0.5 0.9 0.99 0.999]);  axis equal;  grid on;  title('niveles de Zubov');
