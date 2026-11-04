%% C11_Ej6_PasividadLocal -- Notas: sección 11.5 (pasividad solo local)
% QUÉ HACE   Para x' = x^3 - k x + u, y = x, V = x^2/2, calcula V' - u y = x^2(x^2 - k)
%            y construye la prueba de que el sistema NO es pasivo en todo R:
%            con u constante se mantiene x(t) = xb fuera de |x| <= sqrt(k).
% OBSERVE    Con xb = 1.5 y k = 1 el sistema ENTREGA energía (int u y < 0)
%            sin gastar la que tiene (V no cambia).
% ESPERADO   int_0^T u y dt = -2.8125 T;  V(T) - V(0) = 0.
% EXPLORE    Repita con xb = 0.8: ¿qué signo tiene ahora la potencia?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:local]
k  = 1;   xb = 1.5;
ub = -(xb^3 - k*xb);                      % entrada que mantiene x(t) = xb
[t, x] = ode45(@(t, x) x^3 - k*x + ub, [0 4], xb, odeset('RelTol', 1e-12, 'AbsTol', 1e-12));
fprintf('x(4) - xb = %.1e   (el estado no se mueve)\n', x(end) - xb);
fprintf('potencia u y = %.4f (negativa: entrega energía)\n', ub*xb);
fprintf('int_0^4 u y dt = %.4f,   V(4) - V(0) = %.4f\n', 4*ub*xb, x(end)^2/2 - xb^2/2);
% [fin:local]

xx = linspace(-1.8, 1.8, 400);
fig = estiloFigura(700, 400);
plot(xx, xx.^2.*(xx.^2 - k)); hold on; plot(xx, 0*xx, 'k'); grid on;
xlabel('$x$'); title('$\dot V - u\,y = x^2(x^2-k)$');
