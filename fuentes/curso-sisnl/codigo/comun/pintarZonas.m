function pintarZonas(x, y, mascaras, colores, alfas)
% PINTARZONAS  Pinta regiones de una malla con colores claros sobre fondo blanco.
%   pintarZonas(x, y, {M1, M2, ...}, [c1; c2; ...], [a1 a2 ...])
%   x, y: vectores de la malla (Mk(i, j) corresponde al punto (x(j), y(i)));
%   Mk: matrices lógicas; ck: colores RGB en [0, 1]; ak: intensidad (0 = blanco, 1 = color pleno).
%   Usa una sola imagen RGB, sin transparencias: funciona igual en MATLAB y en Octave
%   y se exporta bien con exportgraphics. Llame a "hold on" antes de dibujar encima.
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
if ~iscell(mascaras), mascaras = {mascaras}; end
RGB = ones([size(mascaras{1}) 3]);
for k = 1:numel(mascaras)
    for ch = 1:3
        capa = RGB(:, :, ch);
        capa(mascaras{k}) = 1 - alfas(k)*(1 - colores(k, ch));
        RGB(:, :, ch) = capa;
    end
end
image('XData', [x(1) x(end)], 'YData', [y(1) y(end)], 'CData', RGB);
set(gca, 'YDir', 'normal', 'Layer', 'top');
end
