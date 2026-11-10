%% C2_Ej7_HalconPaloma -- Notas: sección 2.7 (halcón y paloma)
% QUÉ HACE   Dinámica del replicador p_i' = p_i (F_i(p) - Fbar(p)), F = Pi p,
%            Fbar = p' Pi p, en el juego halcón-paloma. Con p2 = 1 - p1 se reduce
%            a p1' = (1/2) p1 (1 - p1) (v - c p1). Verifica que la matriz de
%            pagos original y la que resulta de restar v a la segunda columna
%            dan la misma dinámica, y simula para v = 1, c = 3.
% OBSERVE    Si v < c la población converge a la mezcla p1 = v/c desde cualquier
%            estado interior; si v > c, a "todos halcones". El intervalo [0, 1]
%            es invariante: ninguna solución sale de él.
% ESPERADO   Diferencia entre Pi_o, Pi y la forma reducida < 1e-15.
%            v = 1, c = 3: p1(40) = 1/3 desde cualquier p1(0) en (0, 1);
%            f'(v/c) = -(v/2)(1 - v/c) = -1/3.
% EXPLORE    Use Pi = diag(a, b) con a, b > 0 (juego de coordinación). ¿Qué
%            equilibrio es ahora inestable?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:replicador]
replicador = @(p, Pi) p.*(Pi*p - p.'*Pi*p);
v = 1;  c = 3;
Pio = [(v - c)/2, v; 0, v/2];                     % pagos originales
Pi  = [(v - c)/2, 0; 0, -v/2];                    % se restó v a la columna 2
f = @(p1) 0.5*p1.*(1 - p1).*(v - c*p1);           % forma reducida
err = 0;
for p1 = linspace(0, 1, 101)
    p = [p1; 1 - p1];  a = replicador(p, Pio);  b = replicador(p, Pi);
    err = max([err, abs(a(1) - b(1)), abs(a(1) - f(p1))]);
end
fprintf('Diferencia máxima entre Pi_o, Pi y la forma reducida: %.1e\n', err);
fprintf('f''(v/c) = %.4f\n', -v/2*(1 - v/c));
% [fin:replicador]

fig = estiloFigura(1100, 420);
ax = subplot(1, 2, 1); lineaFase(ax, f, [0 1], 'Equilibrios', [0 v/c 1]);
xlabel(ax, '$p_1$'); ylabel(ax, '$\dot p_1$'); title(ax, sprintf('$v=%g$, $c=%g$', v, c));
subplot(1, 2, 2); hold on;
for p0 = [0.01 0.1 0.2 0.5 0.7 0.9 0.99]
    [t, p] = ode45(@(t, p) f(p), [0 40], p0, odeset('RelTol', 1e-10, 'AbsTol', 1e-12)); plot(t, p);
    pf(p0 == [0.01 0.1 0.2 0.5 0.7 0.9 0.99]) = p(end);                        %#ok<SAGROW>
end
fprintf('p1(40) desde siete condiciones iniciales: %s\n', mat2str(pf, 6));
grid on; xlabel('$t$'); ylabel('$p_1(t)$'); title('fracci\''on de halcones');
