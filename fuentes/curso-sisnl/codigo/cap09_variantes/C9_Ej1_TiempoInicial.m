%% C9_Ej1_TiempoInicial -- Notas: sección 9.2 (uniformidad)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Simula x' = -x/(1 + t) desde x0 = 1 con varios instantes iniciales t0 y
%            mide cuánto tarda la solución en bajar de 0.1.
% OBSERVE    Misma condición inicial, mismo sistema: solo cambia la hora de arranque.
% ESPERADO   T(0.1, t0) = 9 (1 + t0): 9 con t0 = 0, 909 con t0 = 100.
% EXPLORE    Cambie la tasa por 1/sqrt(1 + t) y por (2 + sin t). ¿Cuál es UAS?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:tiempoinicial]
f = @(t, x) -x/(1 + t);
for t0 = [0 5 10 20 40 100]
    tf = t0 + 12*(1 + t0);
    [t, x] = ode45(f, linspace(t0, tf, 20001), 1, opc);
    T = t(find(x < 0.1, 1)) - t0;                          % primer instante bajo 0.1
    fprintf('t0 = %5.1f:  T(0.1) = %8.2f   (fórmula 9(1 + t0) = %6.0f)\n', t0, T, 9*(1 + t0));
end
% una cota KL por cada t0: beta_t0(r, s) = r (1 + t0)/(1 + t0 + s); su sup en t0 es r
s = 50;  fprintf('beta_t0(1, %d) para t0 = 0, 100, 1e4: %.3f %.3f %.3f\n', s, ...
    1/(1 + s), 101/(101 + s), 10001/(10001 + s));
% [fin:tiempoinicial]

% ---- Figura de las notas (fig:vt-tiempo) ----------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
cols = [az; ve; am; vi; co];
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  grid on;  t0s = [0 5 10 20 40];
for j = 1:5
    t0 = t0s(j);  t = linspace(t0, 80, 400);
    plot(t, (1 + t0)./(1 + t), 'Color', cols(j, :), 'LineWidth', 1.4);
end
for j = 1:5
    t0 = t0s(j);  if t0 + 9*(1 + t0) <= 80, plot(t0 + 9*(1 + t0), 0.1, 'o', 'Color', cols(j, :), 'MarkerFaceColor', cols(j, :), 'MarkerSize', 4);  end
end
plot([0 80], [0.1 0.1], '--', 'Color', gr);
axis([0 80 0 1.05]);  xlabel('$t$');  ylabel('$x(t)$, $x_0=1$');
legend(arrayfun(@(v) sprintf('$t_0=%d$', v), t0s, 'UniformOutput', false), 'Location', 'northeast');
title('cada curva empieza en su $t_0$');
subplot(1, 2, 2);  hold on;  grid on;  s = linspace(0, 60, 400);  t0s = [0 2 5 10 50];
for j = 1:5, plot(s, (1 + t0s(j))./(1 + t0s(j) + s), 'Color', cols(j, :), 'LineWidth', 1.4);  end
plot([0 60], [1 1], ':', 'Color', no, 'LineWidth', 1.2);  text(32, 1.04, '$\sup_{t_0}\beta_{t_0}(1,s)=1$');
axis([0 60 0 1.12]);  xlabel('$s=t-t_0$');
legend(arrayfun(@(v) sprintf('$\\beta_{%d}(1,s)$', v), t0s, 'UniformOutput', false), 'Location', 'southwest');
title('una cota $\mathcal{KL}$ por cada $t_0$, ninguna com\''un');
