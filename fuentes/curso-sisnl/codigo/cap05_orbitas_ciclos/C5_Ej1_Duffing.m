%% C5_Ej1_Duffing -- Notas: sección 5.1 (más allá de los equilibrios)
% QUÉ HACE   Oscilador de Duffing sin forzamiento ni fricción, x'' + x^3 - x = 0:
%            equilibrios, valores propios del jacobiano, la energía
%            H = x2^2/2 - x1^2/2 + x1^4/4 a lo largo de una simulación y el
%            período de las órbitas cerradas alrededor de (1, 0).
%            Al final, el contraejemplo x1' = -x2 + x1 r^2, x2' = x1 + x2 r^2.
% OBSERVE    En (+-1, 0) la linealización da +-j sqrt(2): no concluye. H se conserva,
%            así que las órbitas son curvas de nivel de H: centros no lineales.
%            El período depende de la órbita (no hay un solo "omega").
%            En el contraejemplo la linealización también da +-j, pero r crece.
% ESPERADO   lambda(0,0) = +-1 (silla); lambda(+-1,0) = +-1.4142j.
%            H en (+-1,0) = -0.25; variación de H en 50 s: < 1e-8.
%            Período cerca del centro: 2 pi/sqrt(2) = 4.4429; para H = -0.2: 4.6307;
%            para H = -0.01: 7.4087 (crece sin cota al acercarse a la homoclínica H = 0).
%            Contraejemplo desde r0 = 0.5: r = r0/sqrt(1 - 2 r0^2 t), escapa en t = 2.
% EXPLORE    Agregue fricción (delta = 0.2). ¿Qué pasa con H(x(t))? ¿Y con las órbitas cerradas?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:linealizacion]
f = @(t, x) [x(2); x(1) - x(1)^3];
J = @(x) [0 1; 1 - 3*x(1)^2 0];
for xe = [-1 0 1]
    fprintf('equilibrio (%2d, 0): valores propios %s\n', xe, mat2str(eig(J([xe 0])).', 4));
end
% [fin:linealizacion]

% [ini:energia]
H = @(x) x(:,2).^2/2 - x(:,1).^2/2 + x(:,1).^4/4;
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
[t, X] = ode45(f, [0 50], [1.3; 0], opc);
fprintf('H(x(t)): de %.10f a %.10f (variación %.1e)\n', H(X(1,:)), H(X(end,:)), max(H(X)) - min(H(X)));
% [fin:energia]

% [ini:periodo]
% Período de la órbita de nivel H = h alrededor de (1,0): x2 = 0 en los dos
% extremos x1min < 1 < x1max; T = 2 * int dx1 / x2 (se integra la ODE).
for h = [-0.2 -0.01]
    x1max = sqrt(1 + sqrt(1 + 4*h));              % raíz de -x^2/2 + x^4/4 = h
    ev  = odeset(opc, 'Events', @(t, x) deal(x(2), 0, 0));
    [~, ~, te] = ode45(f, [0 100], [x1max; 0], ev);
    te = te(te > 1e-6);                           % el primer cruce es x1min (medio período)
    fprintf('H = %5.2f: período %.4f\n', h, te(2));
end
fprintf('cerca del centro: 2 pi / sqrt(2) = %.4f\n', 2*pi/sqrt(2));
% [fin:periodo]

% [ini:contraejemplo]
g = @(t, x) [-x(2) + x(1)*(x(1)^2 + x(2)^2); x(1) + x(2)*(x(1)^2 + x(2)^2)];
[t2, X2] = ode45(g, [0 1.99], [0.5; 0], opc);
fprintf('contraejemplo: r(1.99) = %.3f  (exacto %.3f); escapa en t = 1/(2 r0^2) = 2\n', ...
        norm(X2(end,:)), 0.5/sqrt(1 - 2*0.25*1.99));
% [fin:contraejemplo]

fig = estiloFigura(700, 560);
[x1, x2] = meshgrid(linspace(-2, 2, 301), linspace(-1.5, 1.5, 301));
contour(x1, x2, x2.^2/2 - x1.^2/2 + x1.^4/4, [-0.24 -0.2 -0.1 -0.03 0 0.1 0.3 0.6 1]); hold on;
plot(X(:,1), X(:,2), 'LineWidth', 2.5); plot([-1 0 1], [0 0 0], 'ko', 'MarkerFaceColor', 'k');
axis equal; grid on; xlabel('$x_1$'); ylabel('$x_2$'); title('Duffing: curvas de nivel de $H$');
