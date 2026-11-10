%% C12_Ej12_Global -- Notas: sección 12.10 (de local a global)
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
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, z) deal(z(2) - 1e6, 1, 0));
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

fig = estiloFigura(1100, 420);
subplot(1, 2, 1); e = linspace(0.3, 6, 200); plot(e, 2./e, e, 6./e); hold on;
plot(E0(:), X0(:), 'k.'); axis([0 4.5 0 3.5]); grid on; xlabel('$\eta_0$'); ylabel('$\xi_0$');
legend('$k=1$', '$k=5$'); title('Escape arriba de $\eta_0\xi_0=k+1$');
subplot(1, 2, 2); plot(t, xF, t, xC); grid on; xlabel('$t$'); ylabel('$x$');
legend('cancela', 'conserva'); title('No cancelar lo que ayuda');
