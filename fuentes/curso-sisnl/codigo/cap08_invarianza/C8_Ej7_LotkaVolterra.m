%% C8_Ej7_LotkaVolterra -- Notas: sección 8.4 (la función de Volterra)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% ---- Figura de las notas (fig:iv-lotka) -----------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(1200, 460);
[Vg, Pg] = meshgrid(linspace(0.02, 4.2, 300), linspace(0.02, 3.2, 300));
ee = [0 0.2];  TT = [60 120];  tit = {'$e=0$: $V$ se conserva', '$e=0.2$: converge'};
for j = 1:2
    e = ee(j);  vs = c/d;  ps = (a - e*vs)/b;
    f = @(t, z) [z(1)*(a - e*z(1) - b*z(2)); z(2)*(-c + d*z(1))];
    subplot(1, 2, j);  hold on;
    contour(Vg, Pg, d*(Vg - vs - vs*log(Vg/vs)) + b*(Pg - ps - ps*log(Pg/ps)), [0.1 0.4 0.9 1.6], 'LineColor', cl, 'LineWidth', 0.8);
    [~, Z] = ode45(f, linspace(0, TT(j), 8000), [2; 0.2], opc);  plot(Z(:, 1), Z(:, 2), 'Color', az, 'LineWidth', 1);
    if e > 0
        plot([vs vs], [0 3.2], 'Color', co, 'LineWidth', 1.6);  text(vs + 0.05, 2.9, '$E=\{v=v^*\}$', 'Color', co);
        plot(vs, ps, 'o', 'MarkerFaceColor', no, 'MarkerEdgeColor', no);
    else
        plot(vs, ps, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
    end
    axis([0 4.2 0 3.2]);  box on;  grid on;  xlabel('$v$');  ylabel('$p$');  title(tit{j});
end
