function retratoFase(ax, f, xl, yl, varargin)
% RETRATOFASE  Retrato de fase de  x' = f(x),  x en R^2  (capítulos 4 y 5).
%   retratoFase(ax, f, [x1min x1max], [x2min x2max])  dibuja el campo con
%   flechas normalizadas (solo la dirección) y trayectorias desde una malla
%   de condiciones iniciales en el borde de la ventana.
%   f es una función de un vector columna:  f = @(x) [x(2); -x(1)].
%   Opciones (pares nombre-valor):
%     'X0'      matriz 2 x k de condiciones iniciales (por defecto, el borde).
%     'T'       tiempo de integración (10).     'Atras'  true: también t < 0.
%     'N'       flechas por eje (21).           'Color'  color de las trayectorias.
%     'Equilibrios'  matriz 2 x m: se marcan con un círculo (lleno si la
%                    jacobiana numérica es Hurwitz, vacío si no).
%   Las trayectorias se detienen al salir de la ventana (evento de ode45).
%   Compatible con MATLAB y GNU Octave.
p = struct('X0', [], 'T', 10, 'Atras', false, 'N', 21, 'Color', [30 90 168]/255, 'Equilibrios', []);
for k = 1:2:numel(varargin), p.(varargin{k}) = varargin{k+1}; end
hold(ax, 'on');
[X1, X2] = meshgrid(linspace(xl(1), xl(2), p.N), linspace(yl(1), yl(2), p.N));
U = zeros(size(X1));  V = U;
for i = 1:numel(X1)
    v = f([X1(i); X2(i)]);  U(i) = v(1);  V(i) = v(2);
end
M = hypot(U, V);  M(M == 0) = 1;
quiver(ax, X1, X2, U./M, V./M, 0.5, 'Color', [201 209 222]/255);
if isempty(p.X0)
    u = linspace(0.05, 0.95, 6);
    p.X0 = [xl(1) + u*(xl(2) - xl(1)), xl(1) + u*(xl(2) - xl(1)), xl(1)*ones(1, 6), xl(2)*ones(1, 6);
            yl(1)*ones(1, 6), yl(2)*ones(1, 6), yl(1) + u*(yl(2) - yl(1)), yl(1) + u*(yl(2) - yl(1))];
end
margen = 0.02*[diff(xl) diff(yl)];
caja = [xl(1) - margen(1), xl(2) + margen(1), yl(1) - margen(2), yl(2) + margen(2)];
opc = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'Events', @(t, x) salir(t, x, caja));
sentidos = 1;  if p.Atras, sentidos = [1 -1]; end
for k = 1:size(p.X0, 2)
    for s = sentidos
        [~, X] = ode45(@(t, x) s*f(x)*dentro(x, caja), [0 p.T], p.X0(:, k), opc);
        plot(ax, X(:, 1), X(:, 2), 'Color', p.Color, 'LineWidth', 1.2);
    end
end
for k = 1:size(p.Equilibrios, 2)
    xe = p.Equilibrios(:, k);
    A = jacobianoNumerico(@(x) f(x), xe);
    if all(real(eig(A)) < 0), cara = [20 33 61]/255; else, cara = [1 1 1]; end
    plot(ax, xe(1), xe(2), 'o', 'MarkerSize', 8, 'MarkerEdgeColor', [20 33 61]/255, ...
         'MarkerFaceColor', cara, 'LineWidth', 1.2);
end
axis(ax, [xl yl]);  grid(ax, 'on');  xlabel(ax, '$x_1$');  ylabel(ax, '$x_2$');
end

function d = dentro(x, caja)
% 1 dentro de la caja, 0 afuera: congela la solución al salir (así no hace falta
% integrar soluciones que escapan en tiempo finito, aunque el evento falle).
d = double(x(1) >= caja(1) && x(1) <= caja(2) && x(2) >= caja(3) && x(2) <= caja(4));
end

function [valor, terminal, direccion] = salir(~, x, caja)
valor = min([x(1) - caja(1), caja(2) - x(1), x(2) - caja(3), caja(4) - x(2)]);
terminal = 1;  direccion = -1;
end
