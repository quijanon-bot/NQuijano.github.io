%% C3_Ej1_Metricas -- Notas: sección 3.2 (espacios métricos)
% QUÉ HACE   Calcula la distancia entre los mismos dos puntos de R^2 con d1, d2
%            y d_inf; la distancia de Hamming entre palabras; y las distancias
%            d1 y d_inf entre dos funciones continuas en [0, 1].
% OBSERVE    Los puntos son los mismos; el número cambia con la métrica. Entre
%            funciones, d1 mide el área entre las curvas y d_inf la mayor
%            separación vertical.
% ESPERADO   x = (1,1), y = (4,3):  d1 = 5, d2 = sqrt(13) = 3.6056, d_inf = 3.
%            Hamming(casa, cama) = 1, Hamming(casa, masa) = 1, Hamming(cama, masa) = 2.
%            f = sin(2 pi t), g = t:  d1 = 0.9214, d_inf = 1.7627 (en t = 0.7754).
%            d(x,y) = (x - y)^2 NO es métrica: d(0,2) = 4 > d(0,1) + d(1,2) = 2.
% EXPLORE    Pruebe la desigualdad triangular de Hamming con 1000 ternas de
%            palabras aleatorias. ¿Encuentra algún contraejemplo?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:vectores]
x = [1; 1];  y = [4; 3];
d1   = sum(abs(x - y));            % Manhattan
d2   = sqrt(sum((x - y).^2));      % euclidiana
dinf = max(abs(x - y));            % máxima componente
fprintf('d1 = %g,  d2 = %.4f,  d_inf = %g\n', d1, d2, dinf);
% [fin:vectores]

% [ini:hamming]
hamming = @(a, b) sum(a ~= b);     % número de posiciones distintas
fprintf('Hamming: casa-cama = %d, casa-masa = %d, cama-masa = %d\n', ...
        hamming('casa', 'cama'), hamming('casa', 'masa'), hamming('cama', 'masa'));
% [fin:hamming]

% [ini:funciones]
t = linspace(0, 1, 200001);
f = sin(2*pi*t);  g = t;
d1f   = trapz(t, abs(f - g));                 % área entre las curvas
[dinff, k] = max(abs(f - g));                 % mayor separación vertical
fprintf('funciones: d1 = %.4f,  d_inf = %.4f (en t = %.4f)\n', d1f, dinff, t(k));
% [fin:funciones]

% [ini:nometrica]
d = @(a, b) (a - b).^2;           % "parece" una distancia
fprintf('(x-y)^2: d(0,2) = %g  >  d(0,1) + d(1,2) = %g\n', d(0,2), d(0,1) + d(1,2));
% [fin:nometrica]

fig = estiloFigura(1000, 420);
subplot(1,2,1); plot([x(1) y(1)], [x(2) y(2)], '-o', [x(1) y(1) y(1)], [x(2) x(2) y(2)], '--');
axis equal; grid on; xlim([0 5]); ylim([0 4]); title('$d_1=5$, $d_2=\sqrt{13}$, $d_\infty=3$');
subplot(1,2,2); plot(t, f, t, g); hold on; plot([t(k) t(k)], [f(k) g(k)], 'k', 'LineWidth', 3);
grid on; xlabel('$t$'); legend('$f=\sin 2\pi t$', '$g=t$', '$d_\infty$', 'Location', 'southwest');
