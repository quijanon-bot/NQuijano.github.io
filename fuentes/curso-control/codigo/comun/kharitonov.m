function P = kharitonov(bajo, alto)
% KHARITONOV  Los cuatro polinomios de Kharitonov de una familia de intervalo.
%   P = kharitonov(bajo, alto)
%   bajo, alto: coeficientes mínimos y máximos en orden DESCENDENTE
%   (como en roots/poly): [a0 a1 ... an] para a0 s^n + ... + an.
%   P: matriz 4 x (n+1); cada fila es un polinomio en orden descendente.
%   Se construyen desde el término independiente hacia arriba con los
%   patrones (-,-,+,+), (+,+,-,-), (-,+,+,-), (+,-,-,+) que se repiten.
%   La familia es robustamente estable si y solo si las cuatro filas son Hurwitz:
%       all(arrayfun(@(k) all(real(roots(P(k,:))) < 0), 1:4))
patrones = [0 0 1 1; 1 1 0 0; 0 1 1 0; 1 0 0 1];   % 0 = mínimo, 1 = máximo
lo = fliplr(bajo(:).');  hi = fliplr(alto(:).');   % ascendente: an, a(n-1), ...
m = numel(lo);  P = zeros(4, m);
for k = 1:4
    usarAlto = logical(patrones(k, mod(0:m-1, 4) + 1));
    asc = lo;  asc(usarAlto) = hi(usarAlto);
    P(k, :) = fliplr(asc);
end
end
