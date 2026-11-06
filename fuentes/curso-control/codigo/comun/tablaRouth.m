function [T, cambios, notas] = tablaRouth(p, epsilon)
% TABLAROUTH  Tabla de Routh-Hurwitz de un polinomio (coeficientes en orden
% descendente, como en roots/poly) y número de cambios de signo en la
% primera columna (= número de raíces con parte real positiva).
%   [T, cambios, notas] = tablaRouth([1 2 3 4 5])
%   Casos especiales (sección 5.4 de las notas):
%     - cero en la primera columna: se reemplaza por epsilon (por defecto 1e-6);
%     - fila completa de ceros: se reemplaza por la derivada del polinomio
%       auxiliar (la fila anterior), que contiene las raíces simétricas.
%   Sin salidas, imprime la tabla.  Es numérica: para tablas con parámetros
%   (K, Kc, Ki) haga la tabla a mano o con syms.
if nargin < 2, epsilon = 1e-6; end
p = p(:).';  n = numel(p) - 1;  ancho = ceil((n + 1)/2);
T = zeros(n + 1, ancho);
f0 = p(1:2:end);  f1 = p(2:2:end);
T(1, 1:numel(f0)) = f0;  T(2, 1:numel(f1)) = f1;
notas = {};  tol = 1e-12*max(1, max(abs(p)));
for i = 2:n+1
    if i > 2
        a = T(i-2, :);  b = T(i-1, :);
        for k = 1:ancho-1
            T(i, k) = (b(1)*a(k+1) - a(1)*b(k+1))/b(1);
        end
    end
    if all(abs(T(i, :)) < tol) && i <= n      % fila de ceros: polinomio auxiliar
        orden = n - i + 2;                        % grado del auxiliar (fila i-1)
        T(i, :) = T(i-1, :).*(orden - 2*(0:ancho-1));
        notas{end+1} = sprintf('fila s^%d de ceros: derivada del auxiliar de grado %d', n-i+1, orden); %#ok<AGROW>
    end
    if abs(T(i, 1)) < tol && i <= n           % cero solo en la primera columna
        T(i, 1) = epsilon;
        notas{end+1} = sprintf('cero en la primera columna de s^%d: se usa epsilon', n-i+1); %#ok<AGROW>
    end
end
col = T(:, 1);
cambios = sum(sign(col(1:end-1)) .* sign(col(2:end)) < 0);
if nargout == 0
    for i = 1:n+1
        fprintf('  s^%-2d |', n-i+1);  fprintf(' %10.4g', T(i, :));  fprintf('\n');
    end
    for k = 1:numel(notas), fprintf('  (%s)\n', notas{k}); end
    fprintf('  cambios de signo en la primera columna: %d\n', cambios);
    clear T
end
end
