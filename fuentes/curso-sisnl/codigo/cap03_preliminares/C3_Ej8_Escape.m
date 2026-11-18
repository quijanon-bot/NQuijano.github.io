%% C3_Ej8_Escape -- Notas: sección 3.9 (intervalo máximo y existencia global)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Compara x' = x^2 (escapa en tiempo finito) con x' = -x^3 (existe
%            para todo t >= 0), ninguna de las dos globalmente Lipschitz.
% OBSERVE    ode45 avisa que no puede seguir cerca de t = 1 para x' = x^2. La
%            solución de x' = -x^3 nunca sale de [-|x0|, |x0|]: ese compacto
%            invariante es lo que garantiza la existencia global.
% ESPERADO   x' = x^2, x0 = 1: x(t) = 1/(1 - t), x(0.99) = 100.
%            x' = -x^3, x0 = 2: x(t) = 2/sqrt(1 + 8 t), x(10) = 0.2222.
% EXPLORE    Pruebe x' = x - x^3 desde x0 = 3. ¿Existe para todo t >= 0? ¿Qué
%            compacto invariante usaría?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:escape]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t1, X1] = ode45(@(t, x) x^2, [0 0.99], 1, opc);
fprintf('x'' = x^2: x(0.99) = %.4f  (exacto 1/(1 - 0.99) = 100)\n', X1(end));
[t2, X2] = ode45(@(t, x) -x^3, [0 10], 2, opc);
fprintf('x'' = -x^3: x(10) = %.4f  (exacto 2/sqrt(81) = %.4f)\n', X2(end), 2/9);
% [fin:escape]

fig = estiloFigura(1000, 380);             % la figura de las notas
subplot(1,2,1); dg = (sqrt(2) - 1)/2;        % intervalo que garantiza el teorema local
patch([0 dg dg 0], [1 1 1e3 1e3], [0.16 0.62 0.56], 'FaceAlpha', 0.18, 'EdgeColor', 'none'); hold on;
semilogy(t1, X1); set(gca, 'YScale', 'log'); plot([1 1], [1 1e3], 'k--'); xlim([0 1.05]); ylim([1 1e3]);
grid on; xlabel('$t$'); legend('garantizado: $[0,\,0.207]$', '$x(t)=1/(1-t)$', '$t=1$', 'Location', 'northwest');
title('$\dot x=x^2$, $x(0)=1$: escapa en $t=1$');
subplot(1,2,2); hold on;
for x0 = [2 -1 0.5]
    [tt, XX] = ode45(@(t, x) -x^3, [0 10], x0, opc);  plot(tt, XX);
end
grid on; xlabel('$t$'); legend('$x_0=2$', '$x_0=-1$', '$x_0=0.5$'); title('$\dot x=-x^3$: existe para todo $t\geq0$');
