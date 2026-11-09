%% C3_Ej8_Escape -- Notas: sección 3.9 (intervalo máximo y existencia global)
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

fig = estiloFigura(1000, 380);
subplot(1,2,1); semilogy(t1, X1); grid on; xlabel('$t$'); title('$\dot x=x^2$: escape en $t=1$');
subplot(1,2,2); plot(t2, X2); grid on; xlabel('$t$'); title('$\dot x=-x^3$: existe para todo $t$');
