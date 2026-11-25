%% C8_Ej3_Duffing -- Notas: sección 8.4 (resorte con amortiguamiento cuadrático)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   x1' = x2, x2' = -(k0 x1 + k1 x1^3) - beta x2 |x2| con la energía V.
%            Resorte duro (k1 = 1): GAS y decaimiento ~ 1/t. Resorte blando (k1 = -1):
%            c* = k0^2/(4|k1|) y un punto con V(x0) < c* que escapa.
% OBSERVE    (1.2, 0) tiene V = 0.2016 < 0.25 y escapa: está en OTRA componente.
% ESPERADO   duro: amplitud x t ~ 6 entre t = 100 y 400. blando: escapa en t = 2.40;
%            (0.9, 0), con V = 0.241, converge.
% EXPLORE    Cambie beta x2|x2| por beta x2. ¿Sigue siendo lento el decaimiento?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:duffing]
k0 = 1;  beta = 0.4;
fd = @(k1) @(t, x) [x(2); -(k0*x(1) + k1*x(1)^3) - beta*x(2)*abs(x(2))];
V  = @(k1, x) k0*x(1)^2/2 + k1*x(1)^4/4 + x(2)^2/2;
% resorte duro: GAS, pero no exponencial
[t, X] = ode45(fd(1), linspace(0, 400, 400001), [2; 0], opc);
for T = [100 200 400]
    fprintf('duro: amplitud(%3d) x %3d = %.2f\n', T, T, max(abs(X(t >= T - 10 & t <= T, 1)))*T);
end
% resorte blando: la componente equivocada
cs = k0^2/(4*abs(-1));
fprintf('blando: c* = %.3f, V(1.2, 0) = %.4f, V(0.9, 0) = %.4f\n', cs, V(-1, [1.2; 0]), V(-1, [0.9; 0]));
escape = odeset(opc, 'Events', @(t, x) eventoODE(abs(x(1)) - 50, 1, 0));
[te, Xe] = ode45(fd(-1), [0 100], [1.2; 0], escape);
fprintf('desde (1.2, 0): |x1| = 50 en t = %.2f\n', te(end));
[~, Xb] = ode45(fd(-1), [0 300], [0.9; 0], opc);
fprintf('desde (0.9, 0): ||x(300)|| = %.1e\n', norm(Xb(end, :)));
% [fin:duffing]

% ---- Figura de las notas (fig:iv-duffing) ---------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(1200, 460);
x1 = linspace(-2.5, 2.5, 500);  x2 = linspace(-1.6, 1.6, 400);  [X1, X2] = meshgrid(x1, x2);
[Q1, Q2] = meshgrid(linspace(-2.5, 2.5, 17), linspace(-1.6, 1.6, 17));
for k1 = [1 -1]
    subplot(1, 2, 1 + (k1 < 0));  hold on;
    VV = X1.^2/2 + k1*X1.^4/4 + X2.^2/2;
    F1 = Q2;  F2 = -(Q1 + k1*Q1.^3) - beta*Q2.*abs(Q2);  nF = hypot(F1, F2) + eps;
    if k1 > 0
        quiver(Q1, Q2, F1./nF, F2./nF, 0.4, 'Color', cl);
        contour(X1, X2, VV, [0.1 0.4 1 2], 'LineColor', az, 'LineWidth', 0.8);
        for x0 = [[1.4; 0], [-1.0; 1.2], [0.4; -1.4]]
            [~, Xq] = ode45(fd(1), [0 40], x0, opc);  plot(Xq(:, 1), Xq(:, 2), 'Color', no, 'LineWidth', 0.9);
        end
        plot(0, 0, 'o', 'MarkerFaceColor', no, 'MarkerEdgeColor', no);
        title('resorte duro ($k_1=1$): GAS');
    else
        cc = 0.245;                                           % c* = 0.25 y V(0.9, 0) = 0.241 < cc
        pintarZonas(x1, x2, {VV <= cc & abs(X1) >= 1, VV <= cc & abs(X1) < 1}, [gr; az], [0.25 0.25]);
        quiver(Q1, Q2, F1./nF, F2./nF, 0.4, 'Color', cl);
        contour(X1, X2, VV, [0.25 0.25], 'LineColor', no, 'LineWidth', 1);
        [~, Xq] = ode45(fd(-1), [0 60], [0.9; 0], opc);  plot(Xq(:, 1), Xq(:, 2), 'Color', ve, 'LineWidth', 1);
        sal3 = odeset(opc, 'Events', @(t, x) eventoODE(abs(x(1)) - 3, 1, 0));
        [~, Xq] = ode45(fd(-1), [0 20], [1.2; 0], sal3);  plot(Xq(:, 1), Xq(:, 2), 'Color', co, 'LineWidth', 1.4);
        plot(1.2, 0, 'o', 'Color', co, 'MarkerFaceColor', co, 'MarkerSize', 4);
        plot(0, 0, 'o', 'MarkerFaceColor', no, 'MarkerEdgeColor', no);
        plot([-1 1], [0 0], 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
        text(1.25, 0.12, '$V(x_0)=0.20<c$', 'Color', co);
        title('resorte blando ($k_1=-1$): local');
    end
    axis([-2.5 2.5 -1.6 1.6]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');
end
