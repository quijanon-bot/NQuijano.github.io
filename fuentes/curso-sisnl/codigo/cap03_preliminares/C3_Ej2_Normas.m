%% C3_Ej2_Normas -- Notas: sección 3.3 (normas y su equivalencia)
% QUÉ HACE   Dibuja las bolas unitarias {||x||_p = 1} para p = 1, 2, inf y 1/2;
%            comprueba las constantes de equivalencia con vectores aleatorios
%            y muestra que en C[0,1] las normas NO son equivalentes.
% OBSERVE    Para p = 1/2 la "bola" no es convexa: ||.||_{1/2} no es norma.
%            Los cocientes ||x||_1/||x||_2 nunca salen de [1, sqrt(n)].
%            Con f_k(t) = t^k: ||f_k||_inf = 1 pero ||f_k||_L1 = 1/(k+1) -> 0.
% ESPERADO   x = (3,4): ||x||_1 = 7, ||x||_2 = 5, ||x||_inf = 4 y 5 <= 7 <= 5 sqrt(2).
%            Contraejemplo p = 1/2: a = (1,0), b = (0,1), ||a+b|| = 4 > ||a|| + ||b|| = 2.
% EXPLORE    ¿Para qué vectores se alcanza la igualdad ||x||_1 = sqrt(n) ||x||_2?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:ejemplo]
x = [3; 4];
fprintf('||x||_1 = %g, ||x||_2 = %g, ||x||_inf = %g\n', norm(x, 1), norm(x, 2), norm(x, inf));
fprintf('5 <= 7 <= 5*sqrt(2) = %.4f\n', 5*sqrt(2));
% [fin:ejemplo]

% [ini:equivalencia]
n = 5;  X = randn(n, 20000);
r12 = vecnorm(X, 1) ./ vecnorm(X, 2);        % debe estar en [1, sqrt(n)]
r2i = vecnorm(X, 2) ./ vecnorm(X, Inf);      % debe estar en [1, sqrt(n)]
fprintf('n = %d:  ||x||_1/||x||_2 en [%.3f, %.3f];  ||x||_2/||x||_inf en [%.3f, %.3f];  sqrt(n) = %.3f\n', ...
        n, min(r12), max(r12), min(r2i), max(r2i), sqrt(n));
% [fin:equivalencia]

% [ini:pmedio]
nmedio = @(v) (sum(sqrt(abs(v))))^2;        % "norma" p = 1/2
a = [1; 0];  b = [0; 1];
fprintf('p = 1/2: ||a+b|| = %g  >  ||a|| + ||b|| = %g\n', nmedio(a + b), nmedio(a) + nmedio(b));
% [fin:pmedio]

% [ini:funciones]
t = linspace(0, 1, 100001);
for k = [1 5 20 100]
    fk = t.^k;
    fprintf('k = %3d:  ||f_k||_inf = %.3f,  ||f_k||_L1 = %.4f,  ||f_k||_L2 = %.4f\n', ...
            k, max(abs(fk)), trapz(t, abs(fk)), sqrt(trapz(t, fk.^2)));
end
% [fin:funciones]

fig = estiloFigura(560, 560);
th = linspace(0, 2*pi, 721);  c = cos(th);  s = sin(th);  hold on;
for p = [0.5 1 2 Inf]
    if isinf(p), r = 1 ./ max(abs(c), abs(s)); else, r = 1 ./ (abs(c).^p + abs(s).^p).^(1/p); end
    plot(r.*c, r.*s);
end
axis equal; grid on; legend('$p=1/2$', '$p=1$', '$p=2$', '$p=\infty$'); title('$\{x:\|x\|_p=1\}$');
