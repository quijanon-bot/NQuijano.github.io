%% C11_LineaTiempo -- Notas: sección 11.1 (de Brune a Byrnes, Isidori y Willems)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Dibuja la línea de tiempo de la pasividad (fig:pa-linea). La figura
%            de las notas es el diagrama TikZ notas/figuras/tikz/t_linea_tiempo.tex;
%            este script es su versión en MATLAB, con los mismos hitos y colores.
% OBSERVE    En ámbar, Zames (1966) y Willems (1972): los dos trabajos que
%            convierten la pasividad en una propiedad de cualquier sistema dinámico.
% ESPERADO   Una figura con 8 hitos alternados arriba y abajo del eje.
% EXPLORE    Agregue un hito (p. ej., 1997, Sepulchre, Janković y Kokotović,
%            "Constructive Nonlinear Control") y vea cómo se reacomoda la figura.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

az = [30 90 168]/255;  am = [224 159 62]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;
ev = {'1931', 'Brune',                         'funciones reales|positivas';
      '1944', 'Lur''e y|Postnikov',            'estabilidad|absoluta';
      '1961', 'Popov',                         'criterio|frecuencial';
      '1962-63', 'Yakubovich,|Kalman',         'lema KYP';
      '1966', 'Zames',                         'pasividad|entrada-salida';
      '1972', 'Willems',                       'sistemas|disipativos';
      '1976', 'Hill y|Moylan',                 'disipativo \rightarrow|Lyapunov';
      '1991', 'Byrnes, Isidori|y Willems',     'pasivación por|retroalimentación'};
n = size(ev, 1);
fig = figure('Color', 'w', 'Position', [100 100 1100 300]);
ax = axes('Position', [0.02 0.02 0.96 0.96]);  hold on;  axis off;
plot([-0.6, n - 0.4], [0 0], 'Color', gr, 'LineWidth', 1.5);
for i = 1:n
    x = i - 1;  s = 1 - 2*mod(i - 1, 2);              % +1 arriba, -1 abajo (alternados)
    c = az;  if any(strcmp(ev{i,1}, {'1966', '1972'})), c = am; end
    plot([x x], [0 0.5*s], 'Color', c, 'LineWidth', 1.2);
    plot(x, 0, 'o', 'MarkerSize', 7, 'MarkerFaceColor', c, 'MarkerEdgeColor', c);
    anio = [ev(i,1), strsplit(ev{i,2}, '|')];
    tema = strsplit(ev{i,3}, '|');
    if s > 0, va1 = 'bottom'; va2 = 'top'; else, va1 = 'top'; va2 = 'bottom'; end
    text(x, 0.55*s, anio, 'HorizontalAlignment', 'center', 'VerticalAlignment', va1, ...
        'FontWeight', 'bold', 'FontSize', 10, 'Color', 0.25*no + 0.75*c, 'Interpreter', 'tex');
    text(x, -0.15*s, tema, 'HorizontalAlignment', 'center', 'VerticalAlignment', va2, ...
        'FontSize', 9, 'Color', gr, 'Interpreter', 'tex');
end
xlim([-0.7, n - 0.3]);  ylim([-2.0 2.0]);
