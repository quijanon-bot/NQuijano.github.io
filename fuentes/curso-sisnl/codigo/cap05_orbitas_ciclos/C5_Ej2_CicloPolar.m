%% C5_Ej2_CicloPolar -- Notas: sección 5.3 (ciclos límite)
% QUÉ HACE   x1' = -x2 + x1(1 - r^2), x2' = x1 + x2(1 - r^2). En polares
%            r' = r(1 - r^2), theta' = 1. Compara la simulación con la solución
%            exacta r(t) = (1 + (1/r0^2 - 1) e^{-2t})^{-1/2} y dibuja los tres
%            tipos de ciclo: estable, inestable y semiestable.
% OBSERVE    Desde adentro y desde afuera las trayectorias se acercan a r = 1:
%            el círculo unitario es una órbita cerrada AISLADA. La linealización
%            en el origen (foco inestable) no ve el ciclo.
% ESPERADO   Valores propios en el origen: 1 +- j.  Desde r0 = 0.1: r(5) = 0.997760;
%            desde r0 = 2: r(5) = 1.000017. Error contra la solución exacta < 1e-10.
% EXPLORE    Con r' = r(1 - r)^2 (semiestable), ¿qué pasa desde r0 = 0.5 y desde r0 = 1.5?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:ciclo]
f = @(t, x) [-x(2) + x(1)*(1 - x(1)^2 - x(2)^2); x(1) + x(2)*(1 - x(1)^2 - x(2)^2)];
fprintf('valores propios en el origen: %s\n', mat2str(eig([1 -1; 1 1]).', 3));
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
rexacta = @(t, r0) (1 + (1/r0^2 - 1)*exp(-2*t)).^(-1/2);
for r0 = [0.1 2]
    [t, X] = ode45(f, linspace(0, 5, 501), [r0; 0], opc);
    r = vecnorm(X.');
    fprintf('r0 = %.1f: r(5) = %.6f (exacto %.6f), error máximo %.1e\n', ...
            r0, r(end), rexacta(5, r0), max(abs(r - rexacta(t.', r0))));
end
% [fin:ciclo]

fig = estiloFigura(1100, 380);
casos = {@(r) r.*(1 - r.^2), @(r) -r.*(1 - r.^2), @(r) r.*(1 - r).^2};
nombres = {'estable', 'inestable', 'semiestable'};
for k = 1:3
    subplot(1, 3, k); hold on; th = linspace(0, 2*pi, 200); plot(cos(th), sin(th), 'k', 'LineWidth', 3);
    for r0 = [0.4 1.6]
        tf = 6; if k == 2 && r0 > 1, tf = 0.2; end   % escapa en t = ln(r0^2/(r0^2-1))/2 = 0.248
        [~, Y] = ode45(@(t, y) [casos{k}(y(1)); 1], [0 tf], [r0; 0], opc);
        plot(Y(:,1).*cos(Y(:,2)), Y(:,1).*sin(Y(:,2)));
    end
    axis equal; axis([-2 2 -2 2]); title(nombres{k});
end
