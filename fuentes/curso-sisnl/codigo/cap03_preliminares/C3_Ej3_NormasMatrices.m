%% C3_Ej3_NormasMatrices -- Notas: sección 3.3 (normas inducidas de matrices)
% QUÉ HACE   Calcula ||A||_1, ||A||_2 e ||A||_inf con las fórmulas de las notas
%            y con norm(); verifica las cotas entre ellas; y muestra que la
%            norma 2 NO es el mayor |valor propio|.
% OBSERVE    ||A||_2 se alcanza en el vector singular derecho: el círculo
%            unitario se convierte en una elipse cuyo semieje mayor es ||A||_2.
%            Para N = [0 1; 0 0], rho(N) = 0 pero ||N||_2 = 1.
% ESPERADO   A = [1 2; -3 4]: ||A||_1 = 6, ||A||_inf = 7, ||A||_2 = 5.1167,
%            sqrt(||A||_1 ||A||_inf) = 6.4807, radio espectral rho(A) = 3.1623.
% EXPLORE    Con M = [-1 10; 0 -2] (Hurwitz), grafique ||expm(M t)||_2: ¿crece
%            antes de decrecer? ¿Por qué eso no contradice la estabilidad?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:inducidas]
A = [1 2; -3 4];
n1   = max(sum(abs(A), 1));            % máxima suma por columnas
ninf = max(sum(abs(A), 2));            % máxima suma por filas
n2   = sqrt(max(eig(A.'*A)));          % raíz del mayor valor propio de A'A
fprintf('||A||_1 = %g (%g),  ||A||_inf = %g (%g),  ||A||_2 = %.4f (%.4f)\n', ...
        n1, norm(A, 1), ninf, norm(A, inf), n2, norm(A, 2));
fprintf('||A||_2 <= sqrt(||A||_1 ||A||_inf) = %.4f\n', sqrt(n1*ninf));
% [fin:inducidas]

% [ini:espectral]
fprintf('radio espectral de A = %.4f  <=  ||A||_2 = %.4f\n', max(abs(eig(A))), n2);
N = [0 1; 0 0];
fprintf('N = [0 1; 0 0]:  rho(N) = %g,  ||N||_2 = %g\n', max(abs(eig(N))), norm(N));
% [fin:espectral]

fig = estiloFigura(560, 560);
th = linspace(0, 2*pi, 400);  U = [cos(th); sin(th)];  Y = A*U;
[~, ~, Vs] = svd(A);  v = A*Vs(:,1);          % imagen del vector singular derecho
plot(U(1,:), U(2,:), Y(1,:), Y(2,:)); hold on;
quiver(0, 0, v(1), v(2), 0, 'LineWidth', 2.5);
axis equal; grid on; legend('$\|x\|_2=1$', '$Ax$', '$\|A\|_2$', 'Location', 'southoutside');
