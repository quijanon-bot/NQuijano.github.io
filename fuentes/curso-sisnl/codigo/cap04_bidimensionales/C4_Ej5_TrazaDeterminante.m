%% C4_Ej5_TrazaDeterminante -- Notas: sección 4.4 (traza, determinante y un barrido)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

fig2 = estiloFigura(700, 520);  hold on;          % el plano traza-determinante de las notas
tau = linspace(-5, 6, 441);  plot(tau, tau.^2/4, 'k', 'LineWidth', 1.5);  plot([-5 6], [0 0], 'k');
plot([0 0], [0 6], 'Color', [42 157 143]/255, 'LineWidth', 2.5);
for k = 1:numel(lista)                             % las matrices de arriba, numeradas
    A = lista{k};  plot(trace(A), det(A), 'o', 'MarkerFaceColor', [209 73 91]/255, 'MarkerEdgeColor', 'none');
    text(trace(A) + 0.12, det(A) + 0.25*(1 + (k == 6)), sprintf('%d', k));
end
text(-3.6, 3.6, 'focos estables');  text(1.6, 3.6, 'focos inestables');  text(-3.8, 1.2, 'nodos estables');
text(2.3, 1.2, 'nodos inestables');  text(-0.7, -1.8, 'sillas');  text(0.15, 5.6, 'centros');
xlim([-5 6]);  ylim([-3 6]);  grid on;  xlabel('$\tau=\mathrm{tr}\,A$');  ylabel('$\delta=\det A$');
title('El plano traza--determinante');
