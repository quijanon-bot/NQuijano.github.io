%% C8_Ej7_LotkaVolterra -- Notas: sección 8.4 (la función de Volterra)
% QUÉ HACE   v' = v (a - e v - b p), p' = p (-c + d v) con a = b = d = 1, c = 0.5.
%            Con e = 0 la función de Volterra se conserva; con e = 0.2, Vdot = -d e (v - v*)^2
%            y la solución converge a (v*, p*) = (0.5, 0.9).
% OBSERVE    Con e > 0 la solución cruza transversalmente E = {v = v*}.
% ESPERADO   e = 0: variación de V < 1e-7. e = 0.2: ||x(300) - x*|| < 1e-4.
% EXPLORE    Arranque en el eje p = 0. ¿Llega a (v*, p*)? ¿Contradice lo anterior?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:lotka]
a = 1;  b = 1;  c = 0.5;  d = 1;
for e = [0 0.2]
    vs = c/d;  ps = (a - e*vs)/b;
    f = @(t, z) [z(1)*(a - e*z(1) - b*z(2)); z(2)*(-c + d*z(1))];
    V = @(v, p) d*(v - vs - vs*log(v/vs)) + b*(p - ps - ps*log(p/ps));
    [t, Z] = ode45(f, linspace(0, 300, 30001), [2; 0.2], opc);
    VZ = V(Z(:, 1), Z(:, 2));
    fprintf('e = %.1f: (v*, p*) = (%.2f, %.2f), V(0) = %.4f, V(300) = %.2e, max subida de V = %.1e\n', ...
        e, vs, ps, VZ(1), VZ(end), max([0; diff(VZ)]));
end
% [fin:lotka]

fig = estiloFigura(560, 480);  plot(Z(:, 1), Z(:, 2));  hold on;  plot(vs, ps, 'ko', 'MarkerFaceColor', 'k');
xline(vs, 'r');  grid on;  xlabel('$v$');  ylabel('$p$');  title('$e=0.2$');
