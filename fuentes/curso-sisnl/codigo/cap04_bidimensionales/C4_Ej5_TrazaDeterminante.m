%% C4_Ej5_TrazaDeterminante -- Notas: sección 4.4 (traza, determinante y un barrido)
% QUÉ HACE   (1) Clasifica varias matrices con clasificarEquilibrio (teorema de
%            traza y determinante) y dice el sentido de giro de los focos y centros.
%            (2) Barre a en x1' = a x1, x2' = -x2 y dibuja el retrato para cinco valores.
% OBSERVE    (1) [1 -5; 1 -1] es un centro antihorario (a21 = 1 > 0); la masa-resorte
%            [0 1; -4 0], uno horario. (2) En a = -1 la dirección lenta cambia de eje;
%            en a = 0 aparece una recta de equilibrios; para a > 0, silla.
% ESPERADO   (1) silla, foco estable horario, nodo impropio inestable, centro antihorario.
% EXPLORE    Construya una matriz con traza -1 y det 0.2 y otra con traza -1 y det 0.3.
%            ¿Qué tipo es cada una? Ubíquelas en el plano traza-determinante.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:clasificar]
lista = {[1 2; 3 4], [-2 1; -1 -2], [2 1; -1 0], [1 -2; 1 -1], [1 -5; 1 -1], [0 1; -4 0]};
for k = 1:numel(lista)
    [tipo, info] = clasificarEquilibrio(lista{k});
    fprintf('%-22s tau = %5.2f  det = %5.2f  %-16s %s\n', mat2str(lista{k}), info.traza, info.det, tipo, info.giro);
end
% [fin:clasificar]

% [ini:barrido]
fig = estiloFigura(1250, 300);
th = linspace(0, 2*pi, 15);  th(end) = [];
valores = [-4 -1 -0.3 0 1];
for k = 1:5
    a = valores(k);  ax = subplot(1, 5, k);
    retratoFase(ax, @(x) [a*x(1); -x(2)], [-1 1], [-1 1], 'X0', 0.95*[cos(th); sin(th)], 'T', 12, 'N', 11);
    title(sprintf('$a=%g$: %s', a, clasificarEquilibrio([a 0; 0 -1])));
end
% [fin:barrido]
