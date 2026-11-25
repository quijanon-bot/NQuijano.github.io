%% C9_Ej3_DerivadaParcial -- Notas: sección 9.4 (la derivada a lo largo de las soluciones)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Para x' = -x/10 y V = (2 + sin t) x^2 compara la derivada numérica de
%            V(t, x(t)) con la fórmula correcta (con dV/dt) y con la incompleta.
% OBSERVE    Sin el término dV/dt la fórmula dice "Vdot < 0 siempre"; la realidad es que
%            V sube durante parte de cada periodo.
% ESPERADO   La correcta coincide con la numérica (error ~1e-8); en t = 0, Vdot/x^2 = 0.6.
% EXPLORE    Cambie la tasa 1/10 por 1. ¿Para qué tasa deja V de subir?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:derivada]
a = 0.1;  t = linspace(0, 30, 30001)';  x = exp(-a*t);   % solución exacta desde x0 = 1
V = (2 + sin(t)).*x.^2;
Vnum = gradient(V, t);                                    % derivada numérica de V(t, x(t))
Vbien = (cos(t) - 2*a*(2 + sin(t))).*x.^2;                % dV/dt + dV/dx f
Vmal  = -2*a*(2 + sin(t)).*x.^2;                          % olvidando dV/dt
fprintf('max |Vnum - Vbien| = %.1e\n', max(abs(Vnum(2:end-1) - Vbien(2:end-1))));
fprintf('max |Vnum - Vmal|  = %.2f\n', max(abs(Vnum - Vmal)));
fprintf('Vdot/x^2 en t = 0: %.2f (> 0)\n', Vbien(1)/x(1)^2);
fprintf('fracción del tiempo con Vdot > 0: %.2f\n', mean(Vbien > 0));
% [fin:derivada]

% ---- Figura de las notas (fig:vt-parcial) ---------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(1200, 440);
subplot(1, 2, 1);  plot(t, V, 'Color', az);  grid on;  xlabel('$t$');
title('$V(t,x(t))=(2+\sin t)\,x(t)^2$: sube a ratos');
subplot(1, 2, 2);  hold on;  grid on;
plot(t, Vbien./x.^2, 'Color', co);  plot(t, Vmal./x.^2, '--', 'Color', gr);  plot([0 30], [0 0], 'Color', no, 'LineWidth', 0.6);
ylim([-2.6 2.4]);  xlabel('$t$');  ylabel('$\dot V/x^2$');
legend('correcta: $\cos t-0.2(2+\sin t)$', 'sin $\partial V/\partial t$: $-0.2(2+\sin t)$', 'Location', 'northeast');
title('el t\''ermino $\partial V/\partial t$ cambia el signo');
