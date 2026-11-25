%% C9_Ej4_TrampaE1 -- Notas: sección 9.4 (la trampa de Vdot < 0)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Simula x' = -x/(1 + t)^2 con V = x^2 (Vdot < 0 fuera del origen) desde
%            x0 = 1 y varios t0, y compara x(t) con el límite x0 exp(-1/(1 + t0)).
% OBSERVE    Ninguna solución llega a cero: la disipación se apaga con el reloj.
% ESPERADO   Límites 0.368 (t0 = 0), 0.913 (t0 = 10).
% EXPLORE    ¿Qué W3(x) haría falta para que el teorema aplicara? ¿Existe?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-13);

% [ini:trampae1]
f = @(t, x) -x/(1 + t)^2;
for t0 = [0 1 3 10 30]
    [~, x] = ode45(f, [t0 5000], 1, opc);
    fprintf('t0 = %4.0f:  x(5000) = %.4f   límite exp(-1/(1+t0)) = %.4f\n', t0, x(end), exp(-1/(1 + t0)));
end
% [fin:trampae1]

% ---- Figura de las notas (fig:vt-e1) --------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
cols = [az; ve; am; vi; co];
fig = estiloFigura(760, 420);  hold on;  grid on;  t0s = [0 1 3 10 30];
for j = 1:5
    t0 = t0s(j);  t = linspace(t0, 120, 600);
    plot(t, exp(1./(1 + t) - 1/(1 + t0)), 'Color', cols(j, :), 'LineWidth', 1.4);
end
for j = 1:5, plot([0 120], exp(-1/(1 + t0s(j)))*[1 1], ':', 'Color', cols(j, :));  end
axis([0 120 0 1.05]);  xlabel('$t$');  ylabel('$x(t)$, $x_0=1$');
legend(arrayfun(@(v) sprintf('$t_0=%d$', v), t0s, 'UniformOutput', false), 'Location', 'southeast');
title('$\dot x=-x/(1+t)^2$: $\dot V<0$ y aun as\''i $x(t)\not\to0$');
