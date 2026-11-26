%% C11_Ej12_Cascada -- Notas: sección 11.9 (pasivación de una cascada)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   z' = u (H1 pasivo, y = z) en cascada con x' = -x + x^2 z (H2, GAS si z = 0).
%            Compara la ley "ingenua" u = -k z con la ley por pasivación
%            u = -(dW/dx F(x,y))' - k y = -x^3 - k z, con W = x^2/2.
% OBSERVE    Con u = -k z, z -> 0 exponencialmente y aun así x escapa a infinito
%            en tiempo finito si x0 z0 > 1 + k. Con la pasivación, U = W + z^2/2
%            no crece y el origen es globalmente estable.
% ESPERADO   x0 = 1, z0 = 3, k = 1: escape en t = ln(3)/2 = 0.5493.
%            Con pasivación: |(x, z)|(30) ~ 1e-13 y U no creciente.
% EXPLORE    Halle con la fórmula exacta el tiempo de escape para z0 = 2.5.
clear; close all; clc;
if ~exist('eventoODE', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:escape]
k = 1;  x0 = 1;  z0 = 3;                   % x0 z0 = 3 > 1 + k = 2
evento = @(t, x) eventoODE(abs(x(1)) - 1e6, 1, 0);
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12, 'Events', evento);
[t, X, te] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -k*x(2)], [0 5], [x0; z0], opc);
% fórmula exacta: con w = 1/x, w' = w - z0 e^{-k t}  ->  w = 0 en
tex = log((z0/(1 + k))/(z0/(1 + k) - 1/x0))/(1 + k);
fprintf('u = -k z: |x| llega a 1e6 en t = %.4f;  escape exacto en t = %.4f\n', te, tex);
% [fin:escape]

% [ini:pasivacion]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -x(1)^3 - k*x(2)], [0 30], [x0; z0], opc);
U = X(:,1).^2/2 + X(:,2).^2/2;             % W(x) + V(z)
fprintf('pasivación: |(x,z)|(30) = %.1e;  ¿U no creciente? %d\n', norm(X(end,:)), ...
        all(diff(U) <= 1e-12));
% [fin:pasivacion]

% ---- Figura de las notas (fig:pa-cascadafig) -------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.002, 'Events', @(t, x) eventoODE(abs(x(1)) - 50, 1, 0));
fig = estiloFigura(1200, 440);
subplot(1, 2, 1);  hold on;  z0s = [1 1.9 2.1 3];  cs = [az; ve; am; co];
for j = 1:4
    [t, X] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -x(2)], [0 6], [1; z0s(j)], opc);
    plot(t, X(:,1), 'Color', cs(j,:));
end
ylim([-0.2 8]);  grid on;  box on;  xlabel('$t$');  ylabel('$x(t)$');  title('$u=-kz$: escape si $x_0z_0>1+k$');
legend('$z_0=1$', '$z_0=1.9$', '$z_0=2.1$', '$z_0=3$');
subplot(1, 2, 2);  hold on;  z0s = [1 3 10];  cs = [az; co; vi];
for j = 1:3
    [t, X] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -x(1)^3 - x(2)], linspace(0, 6, 3001), [1; z0s(j)], odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
    plot(t, X(:,1), 'Color', cs(j,:));
end
grid on;  box on;  xlabel('$t$');  ylabel('$x(t)$');  title('pasivaci\''on: $u=-x^3-kz$');
legend('$z_0=1$', '$z_0=3$', '$z_0=10$');
