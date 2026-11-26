%% C12_Ej12_Global -- Notas: sección 12.10 (de local a global)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) xi' = -k xi, eta' = -eta + eta^2 xi: el origen es LES y la dinámica cero
%            eta' = -eta es GES, pero hay escape en tiempo finito si eta0 xi0 > k + 1.
%            Compara la fórmula del escape con la simulación, para k = 1 y k = 5.
%            (2) x' = x - x^3 + u desde x(0) = 3: cancelar (u = x^3 - 2x) contra conservar
%            (u = -2x) el término estabilizante -x^3.
% OBSERVE    (1) Subir k agranda la región que converge, pero nunca la vuelve global: el
%            subsistema eta no es ISS respecto a xi. (2) La cancelación pide u(0) = 21 y
%            gasta 12.7 veces más energía de control... para converger más lento.
% ESPERADO   (1) con xi0 = 2, eta0 = 2, k = 1: escape en t = ln(2)/2 = 0.3466 s.
%            (2) int u^2: 117/2 = 58.5 (cancela) y 2 ln 10 = 4.605 (conserva).
%                x(1) = 1.104 (cancela) y 0.372 (conserva).
% EXPLORE    En (1), ¿qué pasa en la frontera eta0 xi0 = k + 1? Resuelva w = 1/eta.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:iss]
tEsc = @(k, xi0, eta0) log((xi0/(k + 1))/(xi0/(k + 1) - 1/eta0))/(k + 1);   % si eta0 xi0 > k + 1
k = 1;  xi0 = 2;  eta0 = 2;
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, z) eventoODE(z(2) - 1e6, 1, 0));
[t, Z] = ode45(@(t, z) [-k*z(1); -z(2) + z(2)^2*z(1)], [0 3], [xi0; eta0], opc);
fprintf('k = %g, xi0 = %g, eta0 = %g: fórmula t_e = %.4f s, simulación (eta = 1e6) %.4f s\n', ...
        k, xi0, eta0, tEsc(k, xi0, eta0), t(end));
for k = [1 5]
    [E0, X0] = meshgrid(linspace(0.5, 4, 8), linspace(0.4, 3, 7));
    fprintf('k = %g: escapan %d de %d condiciones iniciales de la rejilla (eta0 xi0 > k + 1)\n', ...
            k, sum(E0(:).*X0(:) > k + 1), numel(E0));
end
% [fin:iss]

% [ini:nocancelar]
t = linspace(0, 4, 4001);  o = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
[~, xF] = ode45(@(t, x) x - x^3 + (x^3 - 2*x), t, 3, o);     % cancela:  x' = -x
[~, xC] = ode45(@(t, x) x - x^3 - 2*x, t, 3, o);             % conserva: x' = -x - x^3
uF = xF.^3 - 2*xF;  uC = -2*xC;
fprintf('u(0): cancela %g, conserva %g\n', uF(1), uC(1));
fprintf('int u^2 (0..4): cancela %.3f, conserva %.3f (razón %.1f)\n', trapz(t, uF.^2), trapz(t, uC.^2), ...
        trapz(t, uF.^2)/trapz(t, uC.^2));
fprintf('x(1): cancela %.3f, conserva %.3f\n', xF(1001), xC(1001));
% [fin:nocancelar]



% ---- Figura de las notas (fig:fl-escape) -----------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
fig = estiloFigura(1200, 480);  e = linspace(0.3, 4.5, 200);  ks = [1 5];
for j = 1:2
    k = ks(j);  subplot(1, 2, j);  hold on;
    patch([e fliplr(e)], [max(min((k + 1)./e, 3.5), 0) 3.5*ones(size(e))], claro(co, 0.12), 'EdgeColor', 'none');
    plot(e, (k + 1)./e, 'Color', co, 'LineWidth', 1.2);
    for e0 = [0.6 1.2 2.0 3.0 4.0]
        for x0 = [0.6 1.6 2.8]
            [~, Z] = ode45(@(t, z) [-k*z(1); -z(2) + z(2)^2*z(1)], [0 5], [x0; e0], ...
                           odeset('RelTol', 1e-9, 'MaxStep', 0.01, 'Events', @(t, z) eventoODE(z(2) - 6, 1, 0)));
            if e0*x0 > k + 1, c = co; else, c = az; end
            plot(Z(:,2), Z(:,1), 'Color', c, 'LineWidth', 0.9);  plot(e0, x0, 'o', 'Color', c, 'MarkerFaceColor', c, 'MarkerSize', 3);
        end
    end
    axis([0 4.5 0 3.2]);  box on;  xlabel('$\eta$');  ylabel('$\xi$');
    title(sprintf('$k=%d$: escapa si $\\eta_0\\xi_0>%d$', k, k + 1));
end

% ---- Figura de las notas (fig:fl-nocancelar) -------------------------------------------------
t = linspace(0, 4, 4001);  oo = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, xF] = ode45(@(tt, x) x - x^3 + (x^3 - 2*x), t, 3, oo);  [~, xC] = ode45(@(tt, x) x - x^3 - 2*x, t, 3, oo);
uF = xF.^3 - 2*xF;  uC = -2*xC;
fig2 = estiloFigura(1300, 420);
subplot(1, 3, 1);  hold on;  plot(t, xF, 'Color', co);  plot(t, xC, 'Color', az);  title('$x(t)$');  legend('cancela', 'conserva');
subplot(1, 3, 2);  hold on;  plot(t, uF, 'Color', co);  plot(t, uC, 'Color', az);  title('$u(t)$');
subplot(1, 3, 3);  hold on;  plot(t, cumtrapz(t, uF.^2), 'Color', co);  plot(t, cumtrapz(t, uC.^2), 'Color', az);
title('$\int_0^t u^2\,d\tau$');
for j = 1:3, subplot(1, 3, j);  grid on;  box on;  xlabel('$t$');  end
