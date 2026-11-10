%% C7_Ej7_Jordan -- Notas: sección 7.7 (estabilidad de sistemas lineales)
% QUÉ HACE   Conecta dos copias de S: x' = Ax + Bu, y = Cx (A = [0 1; -1 0]) en paralelo
%            y en serie. Las dos matrices tienen espectro {j, j, -j, -j}; compara el rango
%            de A - jI (criterio de bloques de Jordan) y simula la salida en serie.
% OBSERVE    Paralelo: rango 2 = n - q, bloques de Jordan de orden 1, estable.
%            Serie: rango 3 > n - q, un bloque de orden 2: resonancia, y(t) = (t/2) sin t.
% ESPERADO   rank(A_P - jI) = 2, rank(A_S - jI) = 3; max|y - (t/2) sin t| < 1e-9.
% EXPLORE    Agregue fricción (A = [0 1; -1 -0.1]). ¿Sigue habiendo diferencia?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:jordan]
A = [0 1; -1 0];  B = [0; 1];  C = [1 0];
AP = [A zeros(2); zeros(2) A];          % paralelo
AS = [A zeros(2); B*C A];               % serie: la salida de la primera entra a la segunda
fprintf('eig(A_P) = %s\neig(A_S) = %s\n', num2str(eig(AP).', '%.3g '), num2str(eig(AS).', '%.3g '));
fprintf('rank(A_P - jI) = %d,  rank(A_S - jI) = %d   (n - q = 2)\n', ...
        rank(AP - 1i*eye(4)), rank(AS - 1i*eye(4)));
t = linspace(0, 30, 601);  x0 = [1; 0; 0; 0];
yS = zeros(size(t));  yP = zeros(size(t));
for k = 1:numel(t)
    xs = expm(AS*t(k))*x0;  yS(k) = xs(3);
    xp = expm(AP*t(k))*[1; 0; 1; 0];  yP(k) = xp(3);
end
fprintf('serie: max|y - (t/2) sin t| = %.1e\n', max(abs(yS - t/2.*sin(t))));
fprintf('paralelo: A_P + A_P'' = 0 -> |x|^2 constante (max|A_P + A_P''| = %g)\n', max(max(abs(AP + AP'))));
% [fin:jordan]

fig = estiloFigura(1100, 420);
plot(t, yP, t, yS, t, t/2, 'k:', t, -t/2, 'k:');  grid on;
xlabel('$t$');  legend('paralelo', 'serie', '$\pm t/2$');  title('Mismo espectro, distinto comportamiento');
