%% C5_Ej1_Modos -- Notas: sección 5.1 (qué es estabilidad)
% QUÉ HACE   Simula la respuesta natural (condición inicial, sin entrada) de
%            cuatro sistemas: polo en el semiplano izquierdo, par sobre el eje
%            imaginario, polo en el semiplano derecho y par REPETIDO sobre el eje.
% OBSERVE    Los modos e^{pt} deciden todo: decaen, se sostienen o crecen.
%            Un par repetido en el eje imaginario crece como t sin(t).
% ESPERADO   1/(s+1): asintóticamente estable; 1/(s^2+1): marginal (oscila);
%            1/(s-1): inestable; 1/(s^2+1)^2: inestable (aunque no haya polos
%            con parte real positiva).
% EXPLORE    Aplique un escalón a 1/(s^2+1) y luego un seno de frecuencia 1:
%            ¿la salida queda acotada? (estabilidad marginal NO es BIBO).
clear; close all; clc;
if ~exist('tablaRouth', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:modos]
s = tf('s');
sistemas = {1/(s + 1), 1/(s^2 + 1), 1/(s - 1), 1/(s^2 + 1)^2};
titulos  = {'polo en -1', 'polos en \pm j', 'polo en +1', 'polos dobles en \pm j'};
t = linspace(0, 15, 1501);
for k = 1:4
    disp(titulos{k});  disp(pole(sistemas{k}).')       % ubicación de los polos
    y{k} = impulse(sistemas{k}, t);                     % respuesta natural (impulso)
end
% [fin:modos]
fig = estiloFigura(1100, 520);
for k = 1:4
    subplot(1, 4, k);  plot(t, y{k});  grid on;  title(titulos{k});  xlabel('t (s)');
end

% [ini:bibo]
u = sin(t);                                  % entrada acotada a la frecuencia del polo
yr = lsim(1/(s^2 + 1), u, t);                % marginal: la salida crece sin límite
max(abs(yr))                                 % crece como t/2: no es BIBO estable
% [fin:bibo]
