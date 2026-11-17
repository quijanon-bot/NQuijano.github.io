%% C9_Ej3_DerivadaParcial -- Notas: sección 9.4 (la derivada a lo largo de las soluciones)
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

fig = estiloFigura(900, 360);
subplot(1, 2, 1);  plot(t, V, 'LineWidth', 1.5);  grid on;  xlabel('$t$');  title('$V(t,x(t))$');
subplot(1, 2, 2);  plot(t, Vbien./x.^2, 'r', t, Vmal./x.^2, 'k--');  grid on;  xlabel('$t$');
legend('con $\partial V/\partial t$', 'sin $\partial V/\partial t$');  title('$\dot V/x^2$');
