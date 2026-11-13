%% C6_Ej6_SillaNodo2D -- Notas: sección 6.5 (bifurcaciones de equilibrios en el plano)
% QUÉ HACE   (1) Retratos de fase de x1' = mu - x1^2, x2' = -x2 para mu = -1, 0, 1.
%            (2) El recorrido de (tau, delta) de cada rama en el plano traza-determinante.
%            (3) La horquilla escondida x1' = mu x1 - x1 x2, x2' = -x2 + x1^2: simula con
%            mu = 0.1 y compara con la reducción a la variedad central.
% OBSERVE    (2) el nodo y la silla llegan a (-1, 0) desde lados opuestos del eje
%            delta = 0. (3) El estado no se queda en x2 = 0: cae sobre x2 = x1^2.
% ESPERADO   nodo: tau = -2 sqrt(mu) - 1, delta = 2 sqrt(mu); silla: delta = -2 sqrt(mu).
%            Escondida, mu = 0.1: equilibrios (+-0.3162, 0.1), tau = -1, delta = 0.2.
% EXPLORE    En la escondida, cambie -x1 x2 por +x1 x2. ¿Qué tipo de horquilla queda?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:sillanodo2d]
fig = estiloFigura(1300, 420);
mus = [-1 0 1];
for k = 1:3
    mu = mus(k);  f = @(x) [mu - x(1)^2; -x(2)];
    if mu > 0, eqs = [sqrt(mu) -sqrt(mu); 0 0]; elseif mu == 0, eqs = [0; 0]; else, eqs = zeros(2, 0); end
    retratoFase(subplot(1, 4, k), f, [-2 2], [-2 2], 'T', 4, 'Equilibrios', eqs);
    title(sprintf('$\\mu=%g$', mu));  xlabel('$x_1$');  ylabel('$x_2$');
end
m = linspace(0, 2, 100);
subplot(1, 4, 4);  hold on;
plot(-2*sqrt(m) - 1, 2*sqrt(m), 'Color', [30 90 168]/255);      % rama del nodo
plot(2*sqrt(m) - 1, -2*sqrt(m), 'Color', [209 73 91]/255);      % rama de la silla
tt = linspace(-4, 4, 100);  plot(tt, tt.^2/4, 'k:', [-4 4], [0 0], 'k-');
grid on;  xlabel('$\tau$');  ylabel('$\delta$');  title('Ruta 1: cruce de $\delta=0$');
for mu = [1 0.25]
    Jn = [-2*sqrt(mu) 0; 0 -1];  Js = [2*sqrt(mu) 0; 0 -1];
    fprintf('mu = %.2f: nodo (tau, delta) = (%.3f, %.3f); silla (%.3f, %.3f)\n', mu, trace(Jn), det(Jn), trace(Js), det(Js));
end
% [fin:sillanodo2d]

% [ini:escondida]
mu = 0.1;
f = @(t, x) [mu*x(1) - x(1)*x(2); -x(2) + x(1)^2];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(f, [0 200], [0.05; 0], opc);
J = jacobianoNumerico(@(x) f(0, x), [sqrt(mu); mu]);
fprintf('escondida: x(200) = (%.4f, %.4f), sqrt(mu) = %.4f; tau = %.3f, delta = %.3f\n', ...
        X(end, :), sqrt(mu), trace(J), det(J));
% variedad central con mu = 0: h = x1^2 + 2 x1^4  ->  x1' = -x1^3 - 2 x1^5
k = t > 20;
fprintf('max |x2 - x1^2| para t > 20: %.2e (la variedad, no el eje)\n', max(abs(X(k, 2) - X(k, 1).^2)));
% [fin:escondida]
