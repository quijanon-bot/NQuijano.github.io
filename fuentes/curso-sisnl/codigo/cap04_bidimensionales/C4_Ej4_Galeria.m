%% C4_Ej4_Galeria -- Notas: sección 4.4 (los retratos lineales)
% QUÉ HACE   Dibuja los seis retratos de la figura 4.4 en coordenadas propias:
%            nodo estable, silla, estrella, nodo impropio, foco estable y centro,
%            con clasificarEquilibrio para el título.
% OBSERVE    En el nodo (lambda = -6, -2) las trayectorias llegan tangentes al eje
%            z2, la dirección LENTA. En el nodo impropio hay una sola recta invariante.
% ESPERADO   Los seis tipos, en ese orden, en los títulos.
% EXPLORE    Cambie el nodo a diag(-2,-6). ¿Por qué eje llegan ahora? Rote las
%            matrices con R = [cos t -sin t; sin t cos t], A -> R A R'. ¿Qué cambia?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:galeria]
casos = {[-6 0; 0 -2], [-1 0; 0 2], [-1 0; 0 -1], [-1 1; 0 -1], [-0.5 -2; 2 -0.5], [0 -2; 2 0]};
fig = estiloFigura(1150, 720);
th = linspace(0, 2*pi, 13);  th(end) = [];
for k = 1:6
    A = casos{k};
    ax = subplot(2, 3, k);
    X0 = 0.95*[cos(th); sin(th)];
    if k == 6, X0 = [0.2 0.4 0.6 0.8; 0 0 0 0]; end
    retratoFase(ax, @(x) A*x, [-1 1], [-1 1], 'X0', X0, 'T', 12, 'N', 13);
    title(clasificarEquilibrio(A));
end
% [fin:galeria]
