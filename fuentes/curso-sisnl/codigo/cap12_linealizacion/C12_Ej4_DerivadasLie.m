%% C12_Ej4_DerivadasLie -- Notas: sección 12.4 (derivadas de Lie)
% QUÉ HACE   (1) Van der Pol con mu = 1 y lambda = (x1^2 + x2^2)/2: compara la fórmula
%            L_f lambda = mu (1 - x1^2) x2^2 con d lambda/dt medida sobre la solución.
%            (2) Levitador: compara las fórmulas cerradas de L_g L_f^2 h y L_f^3 h (las
%            que usa leyExactaLevitador) con derivadas de Lie numéricas (derivadaLie.m).
% OBSERVE    L_f lambda es la derivada a lo largo de las trayectorias: la misma V-punto de
%            la unidad de Lyapunov. En van der Pol cambia de signo en |x1| = 1: inyecta
%            energía cerca del origen y la disipa lejos; de ahí sale el ciclo límite.
% ESPERADO   max|d lambda/dt - L_f lambda| = 4e-3 (diferencias en el tiempo, dt = 0.01);
%            derivada de Lie numérica contra la fórmula: 1e-9.
%            Levitador: diferencias relativas fórmula vs. numérica < 1e-6.
% EXPLORE    Calcule L_f lambda para lambda = x1^2/2 + x2^2/2 + x1 x2/4. ¿En qué región es
%            negativa? ¿Encierra el ciclo?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:vdp]
mu = 1;  f = @(x) [x(2); -x(1) + mu*(1 - x(1)^2)*x(2)];
lam = @(x) (x(1)^2 + x(2)^2)/2;
t = linspace(0, 16, 1601);  opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
[~, X] = ode45(@(t, x) f(x), t, [0.2; 0], opc);
L = mu*(1 - X(:,1).^2).*X(:,2).^2;                 % fórmula
lamt = 0.5*sum(X.^2, 2);  dlam = gradient(lamt, t(2) - t(1));   % derivada medida
Lnum = arrayfun(@(i) derivadaLie(f, lam, X(i,:).'), (1:numel(t)).');
fprintf('max|d lambda/dt - L_f lambda| = %.1e (diferencias en el tiempo)\n', max(abs(dlam(3:end-2) - L(3:end-2))));
fprintf('max|L_f lambda numérica - fórmula| = %.1e\n', max(abs(Lnum - L)));
% [fin:vdp]

% [ini:levitador]
P = parametrosLevitador();
fL = @(x) modeloLevitador(x, 0, P);  gL = @(x) [0; 0; 1/P.L(x(1))];
xi3 = @(x) P.g - P.k/P.m*x(2) - P.L0*P.a*x(3)^2/(2*P.m*(P.a + x(1))^2);   % L_f^2 h (cerrada)
for x = [0.04 0.1 5; 0.08 -0.3 7; 0.02 0.5 3].'
    [~, ~, b] = leyExactaLevitador(x, [0 0 0 0], [0 0 0], P);
    u0 = leyExactaLevitador(x, [0 0 0 0], [0 0 0], P);      % = -L_f^3 h / b
    Lf3 = -u0*b;
    bn = derivadaLie(gL, xi3, x);  Lf3n = derivadaLie(fL, xi3, x);
    fprintf('x = %s:  L_g L_f^2 h = %.5f (num %.5f),  L_f^3 h = %.4f (num %.4f)\n', ...
            mat2str(x.', 3), b, bn, Lf3, Lf3n);
end
% [fin:levitador]

fig = estiloFigura(1000, 420);
[g1, g2] = meshgrid(linspace(-3, 3, 241));
subplot(1, 2, 1); contourf(g1, g2, sign(mu*(1 - g1.^2).*g2.^2), [-1 0 1]); hold on;
plot(X(:,1), X(:,2), 'k'); axis equal; xlabel('$x_1$'); ylabel('$x_2$'); title('signo de $L_f\lambda$');
subplot(1, 2, 2); plot(t, L, t, dlam, '--'); grid on; xlabel('$t$'); legend('$L_f\lambda$', '$d\lambda/dt$');
