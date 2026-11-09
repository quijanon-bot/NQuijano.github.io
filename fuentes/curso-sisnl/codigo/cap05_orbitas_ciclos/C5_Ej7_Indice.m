%% C5_Ej7_Indice -- Notas: sección 5.7 (teoría del índice)
% QUÉ HACE   Calcula numéricamente el índice de circunferencias para: un nodo,
%            un foco, un centro, una silla, z^2 (índice 2), el campo
%            (x1^2 x2, x1^2 - x2^2) (índice 0) y el ejemplo con una silla y un foco.
% OBSERVE    El índice es un entero y no cambia al deformar la curva mientras no
%            cruce un equilibrio. Coincide con sign(det J) cuando det J ~= 0. Para
%            (x1^2 x2, x1^2 - x2^2) el único equilibrio tiene índice 0: ninguna
%            curva cerrada puede ser órbita (una órbita encierra índice +1).
% ESPERADO   nodo +1, foco +1, centro +1, silla -1, z^2 +2, (x1^2 x2, x1^2-x2^2) 0.
%            Ejemplo silla + foco: índice de un círculo que rodea a ambos = 0;
%            de uno que rodea solo el foco (1,1) = +1.
% EXPLORE    Construya un campo con índice -2 en el origen (pista: conjugado de z^3... o z-barra^2).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:indices]
casos = { 'nodo estable', @(x) -x;
          'foco inestable', @(x) [1 -1; 1 1]*x;
          'centro', @(x) [-x(2); x(1)];
          'silla', @(x) [x(1); -x(2)];
          'z^2', @(x) [x(1)^2 - x(2)^2; 2*x(1)*x(2)];
          '(x1^2 x2, x1^2 - x2^2)', @(x) [x(1)^2*x(2); x(1)^2 - x(2)^2] };
for k = 1:size(casos, 1)
    fprintf('%-24s índice = %+.4f\n', casos{k,1}, indiceCurva(casos{k,2}, [0 0], 1));
end
% [fin:indices]

% [ini:ejemplo]
f = @(x) [-x(1) + x(1)*x(2); x(1) + x(2) - 2*x(1)*x(2)];
J = @(x) [-1 + x(2), x(1); 1 - 2*x(2), 1 - 2*x(1)];
for xe = [0 0; 1 1].'
    fprintf('equilibrio (%g,%g): valores propios %s, sign(det J) = %+d\n', xe, ...
            mat2str(eig(J(xe)).', 3), sign(det(J(xe))));
end
fprintf('círculo que rodea ambos: %+.4f;  solo el foco: %+.4f\n', ...
        indiceCurva(f, [0.5 0.5], 2), indiceCurva(f, [1 1], 0.3));
% [fin:ejemplo]

fig = estiloFigura(700, 560);
[x1, x2] = meshgrid(linspace(-1.5, 2.5, 25)); U = -x1 + x1.*x2; V = x1 + x2 - 2*x1.*x2;
L = sqrt(U.^2 + V.^2) + eps; quiver(x1, x2, U./L, V./L, 0.5); hold on;
th = linspace(0, 2*pi, 200); plot(0.5 + 2*cos(th), 0.5 + 2*sin(th), 1 + 0.3*cos(th), 1 + 0.3*sin(th));
plot([0 1], [0 1], 'ko', 'MarkerFaceColor', 'k'); axis equal; grid on;
