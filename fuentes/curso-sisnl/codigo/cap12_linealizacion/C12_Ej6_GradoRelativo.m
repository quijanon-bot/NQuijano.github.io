%% C12_Ej6_GradoRelativo -- Notas: sección 12.5 (grado relativo)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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



% ---- Figura de las notas (fig:fl-gradolineal) ------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
fig = estiloFigura(800, 500);  tt = logspace(-3, 0.4, 120);
nums = {1, 1, 1, [1 2]};  dens = {[1 1], [1 2 1], [1 3 3 1], [1 4 3]};  cs = [az; vi; co; am];  es = {'-', '-', '-', '--'};
for j = 1:4
    den = dens{j};  num = nums{j};  n = numel(den) - 1;
    A_ = [zeros(n-1, 1) eye(n-1); -fliplr(den(2:end))];  B_ = [zeros(n-1, 1); 1];
    C_ = zeros(1, n);  C_(1:numel(num)) = fliplr(num);
    y = zeros(size(tt));
    for kk = 1:29, y = y + C_*A_^(kk-1)*B_*tt.^kk/factorial(kk); end
    loglog(tt, abs(y), es{j}, 'Color', cs(j,:));  hold on;
end
for r = 1:3, loglog(tt(1:40), tt(1:40).^r/factorial(r), ':', 'Color', gr, 'LineWidth', 0.9); end
grid on;  box on;  xlabel('$t$');  ylabel('$y(t)$ (escal\''on)');  title('Cerca de $t=0$: $y\approx CA^{r-1}B\,t^r/r!$');
legend('$1/(s+1)$, $r=1$', '$1/(s+1)^2$, $r=2$', '$1/(s+1)^3$, $r=3$', '$(s+2)/((s+1)(s+3))$, $r=1$', 'Location', 'southeast');
