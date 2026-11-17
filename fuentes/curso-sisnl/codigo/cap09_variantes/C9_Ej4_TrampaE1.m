%% C9_Ej4_TrampaE1 -- Notas: sección 9.4 (la trampa de Vdot < 0)
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

fig = estiloFigura(700, 380);  hold on;
for t0 = [0 1 3 10 30]
    [t, x] = ode45(f, [t0 120], 1, opc);  plot(t, x, 'LineWidth', 1.4);
    plot([t0 120], exp(-1/(1 + t0))*[1 1], 'k:');
end
grid on;  ylim([0 1.05]);  xlabel('$t$');  ylabel('$x(t)$');  title('$\dot V<0$ y aun as\''i $x\not\to0$');
