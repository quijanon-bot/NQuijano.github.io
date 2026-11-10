%% C12_Ej6_GradoRelativo -- Notas: sección 12.5 (grado relativo)
% QUÉ HACE   (1) Sistemas lineales: calcula los parámetros de Markov C A^k B de cuatro
%            funciones de transferencia y mide la pendiente de la respuesta al escalón
%            cerca de t = 0 en escala log-log. (2) Van der Pol con dos salidas.
%            (3) Levitador: L_g L_f^2 h en función de la corriente. (4) x' = u, y = x^2.
% OBSERVE    Cerca de t = 0, y(t) ~ C A^(r-1) B t^r / r!: la pendiente en log-log ES el
%            grado relativo. En el levitador, b(x) = L_g L_f^2 h es proporcional a la
%            corriente: en i = 0 el grado relativo no está definido.
% ESPERADO   r = 1, 2, 3, 1 para G1..G4 (pendientes 0.999, 1.999, 2.999, 0.998).
%            Van der Pol: r = 2 con y = x1, r = 1 con y = x1^2 + x2.
%            Levitador en el equilibrio (y = 0.05, i = 6.2642): b = -125.28.
% EXPLORE    G5 = (s - 1)/(s + 1)^3. ¿Cuál es su grado relativo? ¿Qué signo tiene y(t)
%            para t pequeño? (Pista: C A^(r-1) B.)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:markov]
% realizaciones en forma canónica controlable: (num, den) -> (A, B, C)
G = {[1], [1 1]; [1], conv([1 1], [1 1]); [1], conv([1 1], conv([1 1], [1 1])); [1 2], conv([1 1], [1 3])};
tl = logspace(-4, -2, 20);  r = zeros(1, 4);  pend = r;
for j = 1:4
    num = G{j, 1};  den = G{j, 2};  n = numel(den) - 1;
    A = [zeros(n-1, 1) eye(n-1); -fliplr(den(2:end))];  B = [zeros(n-1, 1); 1];
    C = zeros(1, n);  C(1:numel(num)) = fliplr(num);
    k = 0;  while abs(C*A^k*B) < 1e-12, k = k + 1; end;  r(j) = k + 1;
    escalon = @(t) sum(arrayfun(@(k) C*A^(k-1)*B*t^k/factorial(k), 1:25));  % y = sum C A^(k-1) B t^k/k!
    y = arrayfun(escalon, tl);
    p = polyfit(log(tl), log(abs(y)), 1);  pend(j) = p(1);
    fprintf('G%d: Markov C A^k B = %s  ->  r = %d,  pendiente log-log = %.3f\n', j, ...
            mat2str(arrayfun(@(k) C*A^k*B, 0:n-1)), r(j), pend(j));
end
% [fin:markov]

% [ini:vdp]
mu = 1;  f = @(x) [x(2); -x(1) + mu*(1 - x(1)^2)*x(2)];  g = @(x) [0; 1];
x = [0.7; -0.4];
h1 = @(x) x(1);  Lfh1 = @(x) derivadaLie(f, h1, x);
fprintf('y = x1:          L_g h = %.3g,  L_g L_f h = %.3g  ->  r = 2\n', derivadaLie(g, h1, x), derivadaLie(g, Lfh1, x));
h2 = @(x) x(1)^2 + x(2);
fprintf('y = x1^2 + x2:   L_g h = %.3g  ->  r = 1\n', derivadaLie(g, h2, x));
% [fin:vdp]

% [ini:levitador]
P = parametrosLevitador();  [xs, ~] = equilibrioLevitador(0.05, P);
[~, ~, b] = leyExactaLevitador(xs, [0 0 0 0], [0 0 0], P);
fprintf('levitador en el equilibrio (y = 0.05, i = %.4f): b = L_g L_f^2 h = %.4f\n', xs(3), b);
ii = linspace(-8, 8, 161);  bi = -P.L0*P.a*ii./(P.m*(P.a + 0.05)^2*P.L(0.05));
fprintf('b se anula en i = %g: allí el grado relativo no está definido\n', ii(bi == 0));
% [fin:levitador]

% [ini:nodefinido]
% x' = u, y = x^2:  L_g h = 2x. Para x ~= 0, r = 1; en x = 0, L_g h(0) = 0 pero L_g h no
% es idénticamente cero cerca de 0: ninguna de las dos condiciones de la definición se cumple.
% [fin:nodefinido]

fig = estiloFigura(1000, 420);
subplot(1, 2, 1); hold on;
for j = 1:4
    num = G{j,1}; den = G{j,2}; n = numel(den) - 1;
    A = [zeros(n-1,1) eye(n-1); -fliplr(den(2:end))]; B = [zeros(n-1,1); 1]; C = zeros(1,n); C(1:numel(num)) = fliplr(num);
    tt = logspace(-3, 0.3, 60); yy = arrayfun(@(t) sum(arrayfun(@(k) C*A^(k-1)*B*t^k/factorial(k), 1:25)), tt);
    loglog(tt, abs(yy));
end
set(gca, 'XScale', 'log', 'YScale', 'log'); grid on; xlabel('$t$'); ylabel('$y(t)$'); title('Pendiente = $r$');
subplot(1, 2, 2); plot(ii, bi); grid on; xlabel('$i$ [A]'); ylabel('$L_gL_f^2h$'); title('Levitador, $y=0.05$');
