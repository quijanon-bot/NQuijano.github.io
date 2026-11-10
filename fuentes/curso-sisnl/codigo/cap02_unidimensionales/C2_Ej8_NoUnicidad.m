%% C2_Ej8_NoUnicidad -- Notas: sección 2.8 (¿es única la solución?)
% QUÉ HACE   (1) Muestra la trampa de implementación de la raíz cúbica:
%            (-8)^(1/3) no es -2 en MATLAB. (2) Simula x' = x^(1/3) desde 0 y desde
%            1e-12. (3) Simula x' = -x^(1/3) desde x0 = 1: llega a 0 en tiempo
%            finito, algo imposible si f es localmente Lipschitz.
% OBSERVE    Desde 0, ode45 devuelve x = 0 y no avisa que hay infinitas
%            soluciones. Con -x^(1/3) la solución se detiene en 0 en t = 1.5.
% ESPERADO   (-8)^(1/3) = 1 + 1.7321i;  nthroot(-8, 3) = -2.
%            x' = x^(1/3): x(3) = 0 desde 0, x(3) = 2.8284 desde 1e-12.
%            x' = -x^(1/3), x0 = 1: x = 0 en T = (3/2) x0^(2/3) = 1.5.
% EXPLORE    ¿Por qué ningún x' = f(x) con f localmente Lipschitz llega a un
%            equilibrio en tiempo finito? (Pista: corra el tiempo hacia atrás.)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:raiz]
fprintf('(-8)^(1/3) = %s     nthroot(-8, 3) = %g\n', num2str((-8)^(1/3)), nthroot(-8, 3));
% [fin:raiz]

% [ini:ode45]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-14);
[~, X0] = ode45(@(t, x) nthroot(x, 3), [0 3], 0, opc);
[~, Xe] = ode45(@(t, x) nthroot(x, 3), [0 3], 1e-12, opc);
fprintf('x'' = x^(1/3): desde 0, x(3) = %g;  desde 1e-12, x(3) = %.4f;  (2)^(3/2) = %.4f\n', ...
        X0(end), Xe(end), 2^1.5);
% [fin:ode45]

% [ini:tiempofinito]
ev = @(t, x) deal(x - 1e-9, 1, -1);
[t, x, te] = ode45(@(t, x) -nthroot(x, 3), [0 3], 1, odeset('RelTol', 1e-10, 'AbsTol', 1e-14, 'Events', ev));
fprintf('x'' = -x^(1/3) desde 1: llega a 0 en t = %.4f  (exacto 1.5)\n', te);
% [fin:tiempofinito]

fig = estiloFigura(760, 400); tt = linspace(0, 3, 601);
xc = @(t, c) (t > c).*((2/3)*max(t - c, 0)).^(3/2);
hold on; for c = [0 0.5 1 1.5], plot(tt, xc(tt, c)); end; plot(tt, 0*tt, 'k', 'LineWidth', 3);
grid on; xlabel('$t$'); ylabel('$x$'); title('$\dot x=x^{1/3}$, $x(0)=0$');
