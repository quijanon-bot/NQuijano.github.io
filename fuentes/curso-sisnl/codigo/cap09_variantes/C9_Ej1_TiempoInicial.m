%% C9_Ej1_TiempoInicial -- Notas: sección 9.2 (uniformidad)
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

fig = estiloFigura(900, 380);  hold on;
for t0 = [0 5 10 20 40]
    t = linspace(t0, 80, 400);  plot(t, (1 + t0)./(1 + t), 'LineWidth', 1.5);
end
plot([0 80], [0.1 0.1], 'k--');  grid on;  xlabel('$t$');  ylabel('$x(t)$');
title('cada curva empieza en su $t_0$');
