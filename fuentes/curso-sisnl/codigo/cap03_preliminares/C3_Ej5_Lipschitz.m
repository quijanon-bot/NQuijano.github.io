%% C3_Ej5_Lipschitz -- Notas: sección 3.8 (condición de Lipschitz)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Estima la mayor pendiente de las secantes |f(x)-f(y)|/|x-y| de x^3,
%            sat(x) y x^(1/3) en intervalos alrededor del origen; y verifica la
%            constante L = 1 + a1 + a2 del ejemplo f = (-x1 + x1 x2, x2 - x1 x2)
%            en la caja |x1| <= a1, |x2| <= a2 con la norma infinito.
% OBSERVE    x^3: la pendiente crece como 3 a^2 (local, no global). sat: nunca
%            pasa de 1 (global, aunque no es C^1). x^(1/3): crece sin cota al
%            achicar el intervalo (no es Lipschitz en 0).
% ESPERADO   x^3 en [-a, a]: sup = 3 a^2 (a = 1 -> 3, a = 10 -> 300).
%            sat: sup = 1.  x^(1/3) en [-h, h]: sup = h^(-2/3) (secante por 0).
%            Caja a1 = 1, a2 = 2: L = 4 y ningún cociente lo supera; con rng(0), el mayor
%            cociente aleatorio es 3.5717 en MATLAB R2024a (3.6969 en Octave 8.4); junto a la
%            esquina (-1,-2), 3.9999: la constante no se puede mejorar.
% EXPLORE    Cambie la norma a la 2. ¿Cambia la constante? ¿Cambia la conclusión?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:secantes]
pend = @(f, x, y) abs(f(x) - f(y)) ./ abs(x - y);
sat  = @(x) min(1, max(-1, x));
for a = [1 10]
    x = linspace(-a, a, 2001);  [X, Y] = meshgrid(x);  M = X ~= Y;
    P = pend(@(s) s.^3, X(M), Y(M));
    fprintf('x^3 en [-%g, %g]: mayor pendiente = %.2f  (3a^2 = %g)\n', a, a, max(P), 3*a^2);
end
x = linspace(-5, 5, 2001);  [X, Y] = meshgrid(x);  M = X ~= Y;
fprintf('sat en [-5, 5]: mayor pendiente = %.4f\n', max(pend(sat, X(M), Y(M))));
for h = [1e-1 1e-3 1e-6]
    fprintf('x^(1/3), secante entre 0 y %g: pendiente = %.1f\n', h, pend(@(s) nthroot(s, 3), h, 0));
end
% [fin:secantes]

% [ini:caja]
f  = @(x) [-x(1) + x(1)*x(2); x(2) - x(1)*x(2)];
a1 = 1;  a2 = 2;  L = 1 + a1 + a2;
rng(0);  peor = 0;                  % semilla fija
for k = 1:50000
    p = [a1; a2].*(2*rand(2,1) - 1);  q = [a1; a2].*(2*rand(2,1) - 1);
    peor = max(peor, norm(f(p) - f(q), inf)/norm(p - q, inf));
end
p = [-a1; -a2];  q = p + 1e-4*[1; 1];   % junto a la esquina
esquina = norm(f(p) - f(q), inf)/norm(p - q, inf);
fprintf('caja a1 = %g, a2 = %g:  L = %g\n', a1, a2, L);
fprintf('mayor cociente: aleatorio %.4f, esquina %.4f\n', peor, esquina);
% [fin:caja]

fig = estiloFigura(1000, 380);             % la figura de las notas, con los conos
s = linspace(-1.5, 1.5, 601);  xx = [-1.5 1.5];
cono = @(x0, y0, L) fill([xx fliplr(xx)], [y0 + L*(xx - x0), fliplr(y0 - L*(xx - x0))], ...
                         [0.5 0.6 0.8], 'FaceAlpha', 0.12, 'EdgeColor', 'none');
subplot(1,3,1); hold on; cono(1, 1, 3); plot(s, s.^3); plot(1, 1, 'o');
grid on; ylim([-3.5 3.5]); title('$x^3$: $L=3a^2$ en $[-a,a]$');
subplot(1,3,2); hold on; cono(0.3, 0.3, 1); plot(s, sat(s)); plot(0.3, 0.3, 'o');
grid on; ylim([-1.6 1.6]); title('sat: $L=1$ global');
subplot(1,3,3); hold on; for L = [2 8 40], cono(0, 0, L); end; plot(s, nthroot(s, 3));
grid on; ylim([-1.6 1.6]); title('$x^{1/3}$: ning\''un cono sirve en 0');
