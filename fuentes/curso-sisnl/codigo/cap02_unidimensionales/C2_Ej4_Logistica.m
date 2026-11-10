%% C2_Ej4_Logistica -- Notas: sección 2.5 (poblaciones: logística y cosecha)
% QUÉ HACE   Ecuación logística normalizada con cosecha constante,
%            x' = x (1 - x) - h  (x: población / capacidad, tiempo en 1/r).
%            Calcula los equilibrios para h = 0, 0.2 y 0.3 y simula.
% OBSERVE    Para h < 1/4 hay dos equilibrios: el de arriba es estable y el de
%            abajo es un umbral (si la población está por debajo, se extingue).
%            Al subir h se acercan; en h = 1/4 chocan; para h > 1/4 no queda
%            ninguno y la población se extingue en tiempo finito desde
%            cualquier condición inicial. (Adelanto de la silla-nodo, cap. 6.)
% ESPERADO   h = 0.2: x* = 0.2764 (inestable) y 0.7236 (estable).
%            h = 0.3, x0 = 0.5: x = 0 en t = atan(0.5/a)/a = 5.1441, a = sqrt(h - 1/4).
% EXPLORE    Con h = 0.2, ¿desde qué x0 se extingue la población? ¿Qué cosecha
%            máxima sostenible da el modelo, y por qué es peligroso operar ahí?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:cosecha]
for h = [0 0.2 0.3]
    d = 1 - 4*h;
    if d >= 0
        xs = [(1 - sqrt(d))/2, (1 + sqrt(d))/2];
        fprintf('h = %.2f:  equilibrios %.4f (f'' = %+.3f) y %.4f (f'' = %+.3f)\n', h, ...
                xs(1), 1 - 2*xs(1), xs(2), 1 - 2*xs(2));
    else
        fprintf('h = %.2f:  sin equilibrios (h > 1/4)\n', h);
    end
end
% [fin:cosecha]

% [ini:extincion]
h = 0.3;  a = sqrt(h - 1/4);
ev = @(t, x) deal(x, 1, -1);                    % detener cuando x = 0
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12, 'Events', ev);
[t, x, te] = ode45(@(t, x) x*(1 - x) - h, [0 20], 0.5, opc);
fprintf('h = 0.3 desde x0 = 0.5: extinción en t = %.4f (exacto %.4f)\n', te, atan(0.5/a)/a);
% [fin:extincion]

fig = estiloFigura(1100, 420);
ax = subplot(1, 2, 1); hold(ax, 'on'); s = linspace(0, 1, 401);
plot(ax, s, s.*(1 - s), s, s.*(1 - s) - 0.2, s, s.*(1 - s) - 0.3); plot(ax, [0 1], [0 0], 'k');
grid(ax, 'on'); xlabel(ax, '$x$'); ylabel(ax, '$\dot x$'); legend(ax, '$h=0$', '$h=0.2$', '$h=0.3$');
subplot(1, 2, 2); hold on;
for x0 = [0.2 0.3 0.5 0.9]
    [ti, xi] = ode45(@(t, x) x*(1 - x) - 0.2, [0 20], x0, odeset('Events', ev)); plot(ti, xi);
end
plot(t, x, 'k--'); grid on; xlabel('$t$'); ylabel('$x(t)$'); title('$h=0.2$ (llenas) y $h=0.3$ (a trazos)');
