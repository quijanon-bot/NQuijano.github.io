%% C11_Ej4_IntegradorFiltro -- Notas: sección 11.5 (integrador frente a filtro)
% QUÉ HACE   Con el mismo almacenamiento V = x^2/2, compara 1/s (sin pérdidas)
%            con 1/(s+1) (OSP y estrictamente pasivo): balance ante la misma
%            entrada y diagrama de Nyquist.
% OBSERVE    En 1/s toda la energía suministrada queda almacenada; en 1/(s+1)
%            una parte se disipa (int y^2). En Nyquist, 1/s vive sobre el eje
%            imaginario (fase -90°) y 1/(s+1) estrictamente a la derecha.
% ESPERADO   1/s: V(T) - V(0) = int u y (residuo ~1e-12);
%            1/(s+1): V(T) - V(0) = int u y - int y^2.
% EXPLORE    Pruebe 1/(s-1) con el mismo V: ¿qué término del balance cambia de signo?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:energia]
u   = @(t) sin(t) + 0.5*sin(3*t);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.01);
[t, xi] = ode45(@(t, x) u(t), [0 20], 0, opc);          % integrador: x' = u, y = x
[~, xf] = ode45(@(t, x) -x + u(t), t, 0, opc);           % filtro: x' = -x + u, y = x
[Si, ~, ri] = balanceEnergia(t, xi.^2/2, u(t).*xi, 0*t);
[Sf, Df, rf] = balanceEnergia(t, xf.^2/2, u(t).*xf, xf.^2);
fprintf('integrador: residuo %.1e (lossless: nada se disipa)\n', max(abs(ri)));
fprintf('filtro:     residuo %.1e, disipado en [0,20] = %.3f\n', max(abs(rf)), Df(end));
% [fin:energia]

% [ini:nyquist]
w  = logspace(-3, 3, 2000);
Gi = respFrec(1, [1 0], w);   Gf = respFrec(1, [1 1], w);
fprintf('min Re 1/(jw) = %.2g;   min Re 1/(jw+1) = %.2g (> 0, tiende a 0 como 1/w^2)\n', ...
        min(real(Gi)), min(real(Gf)));
% [fin:nyquist]

fig = estiloFigura(1000, 420);
subplot(1,2,1); plot(t, Si, t, xi.^2/2, '--', t, Sf, t, xf.^2/2, '--'); grid on;
legend('$\int uy$ (1/s)', '$V$ (1/s)', '$\int uy$ (1/(s+1))', '$V$ (1/(s+1))', 'Location', 'northwest');
xlabel('$t$');
subplot(1,2,2); plot(real(Gf), imag(Gf), [0 0], [-1.5 1.5]); axis equal; grid on;
xlim([-0.5 1.5]); ylim([-1 1]); legend('$1/(s+1)$', '$1/s$'); title('Nyquist');
