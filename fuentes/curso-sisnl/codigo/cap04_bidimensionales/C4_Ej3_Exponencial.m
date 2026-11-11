%% C4_Ej3_Exponencial -- Notas: sección 4.3 (exponencial de matriz y diagonalización)
% QUÉ HACE   Para A = [-1 -3; 0 2]: valores y vectores propios con eig, el cambio
%            de coordenadas z = P^{-1} x que diagonaliza, y la comparación de
%            P*diag(exp(lambda t))*P^{-1} con expm(A t) y con la fórmula de las notas.
% OBSERVE    Aunque a11 = -1 < 0, x1(t) contiene e^{2t}: desde (1,1),
%            x1 = 2 e^{-t} - e^{2t} se anula en t = ln(2)/3 y se va a -infinito.
% ESPERADO   lambda = -1, 2;  P^{-1} A P = diag(-1, 2);  errores ~1e-15.
% EXPLORE    Repita con A = [0 1; 0 0] (no diagonalizable). ¿Qué devuelve eig? ¿Es
%            invertible la P que devuelve? Compare expm(A t) con I + A t.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:diagonal]
A = [-1 -3; 0 2];
[P, D] = eig(A);                         % columnas de P: vectores propios
disp('P^{-1} A P ='); disp(P\A*P);
t = 0.7;
E1 = P*diag(exp(diag(D)*t))/P;           % P e^{Dt} P^{-1}
E2 = expm(A*t);
E3 = [exp(-t), exp(-t) - exp(2*t); 0, exp(2*t)];   % fórmula de las notas
fprintf('|P e^{Dt} P^-1 - expm(At)| = %.1e,  |fórmula - expm| = %.1e\n', norm(E1 - E2), norm(E3 - E2));
x1 = @(t) [1 0]*expm(A*t)*[1; 1];
tc = fzero(x1, [0.01 1]);
fprintf('desde (1,1), x1(t) = 0 en t = %.6f  (ln(2)/3 = %.6f)\n', tc, log(2)/3);
% [fin:diagonal]

fig = estiloFigura(900, 380);
tt = linspace(0, 1.2, 300);  X = zeros(2, numel(tt));
for k = 1:numel(tt), X(:, k) = expm(A*tt(k))*[1; 1]; end
plot(tt, X);  grid on;  xlabel('$t$');  legend('$x_1(t)$', '$x_2(t)$');
title('$a_{11}=-1$ y sin embargo $x_1$ diverge');
