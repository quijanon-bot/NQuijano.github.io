function fig = estiloFigura(ancho, alto)
% ESTILOFIGURA  Figura blanca, sin barras de herramientas, con la paleta del curso.
%   fig = estiloFigura(ancho, alto)   (en píxeles; por defecto 1100 x 620)
%   Quitar las barras evita que exportgraphics las capture en la imagen.
%   El orden de colores es el mismo de las notas y de la página web:
%   azul, coral, violeta, ámbar, verde.
if nargin < 1, ancho = 1100; alto = 620; end
fig = figure('Color', 'w', 'Position', [80 80 ancho alto]);
set(fig, 'MenuBar', 'none', 'ToolBar', 'none');
paleta = [30 90 168; 209 73 91; 108 74 182; 224 159 62; 42 157 143]/255;
set(fig, 'DefaultAxesColorOrder', paleta);
set(groot, 'defaultAxesFontSize', 12, 'defaultLineLineWidth', 2);
try   % (Octave no acepta algunas de estas propiedades por defecto)
    set(groot, 'defaultAxesTickLabelInterpreter', 'latex', 'defaultTextInterpreter', 'latex', ...
        'defaultLegendInterpreter', 'latex');
catch
end
end
