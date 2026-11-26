%% C10_Ej2_Conjuntos -- Notas: sección 10.2 (la bola no es invariante; resorte endurecido)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Oscilador x' = A x + B w, A = [0 1; -4 -0.2], |w| <= 0.2: calcula P
%            (A'P + PA = -I), mu = 2||PB|| 0.2/theta y la cota b = mu sqrt(lmax/lmin);
%            simula desde (2.45, 0), dentro de B_mu, con w = 0.2 sin 1.3t.
%            (2) Resorte endurecido x1' = x2, x2' = -(1 + x1^2) x1 - x2 + w, |w| <= 0.3:
%            mu = sqrt5 M/theta, b = alpha1^{-1}(alpha2(mu)) y el limsup simulado.
% OBSERVE    La trayectoria del oscilador sale de B_mu (llega a 4.5) pero nunca sale de
%            Omega_eta. En el resorte, limsup ||x|| < mu < b.
% ESPERADO   Oscilador: mu = 2.50, b = 5.01, max ||x|| = 4.50, max V/eta < 1.
%            Resorte: mu = 0.745, b = 1.30; limsup 0.30 (cos t), 0.17 (cos 2t), 0.28 (cte).
% EXPLORE    Ponga w = 0 en el oscilador. ¿Sigue saliendo de B_mu? ¿Por qué?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:conjuntos]
A = [0 1; -4 -0.2];  B = [0; 1];  wmax = 0.2;  theta = 0.5;
P = ecuacionLyapunov(A, eye(2));  lam = eig(P);
mu = 2*norm(P*B)*wmax/theta;  eta = max(lam)*mu^2;  b = mu*sqrt(max(lam)/min(lam));
fprintf('P = [%.3f %.3f; %.3f %.3f], lambda = %.3f, %.3f\n', P, min(lam), max(lam));
fprintf('mu = %.3f, eta = %.2f, b = %.3f\n', mu, eta, b);
[t, X] = ode45(@(t, x) A*x + B*wmax*sin(1.3*t), linspace(0, 40, 8001), [2.45; 0], opc);
nx = sqrt(sum(X.^2, 2));  VX = sum((X*P).*X, 2);
fprintf('desde ||x(0)|| = 2.45 < mu: max ||x|| = %.3f, max V/eta = %.3f\n', max(nx), max(VX)/eta);
% [fin:conjuntos]

% [ini:resorte]
M = 0.3;  th = 0.9;  Pr = [1.5 0.5; 0.5 1];  lr = eig(Pr);
mur = sqrt(5)*M/th;  br = sqrt((max(lr)*mur^2 + mur^4/2)/min(lr));
fprintf('resorte: mu = %.3f, b = %.3f\n', mur, br);
ws = {@(t) M*cos(t), @(t) M*cos(2*t), @(t) M};  nom = {'0.3 cos t', '0.3 cos 2t', '0.3'};
for i = 1:3
    w = ws{i};
    [tz, Z] = ode45(@(t, x) [x(2); -(1 + x(1)^2)*x(1) - x(2) + w(t)], linspace(0, 80, 16001), [2; 0], opc);
    fprintf('  w = %-11s limsup ||x|| = %.3f\n', nom{i}, max(sqrt(sum(Z(tz >= 50, :).^2, 2))));
end
% [fin:resorte]

% ---- Figura de las notas (fig:av-conjuntos) -------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
fig = estiloFigura(1250, 520);  an = linspace(0, 2*pi, 300);
subplot(1, 2, 1);  hold on;
fill(mu*cos(an), mu*sin(an), claro(co, 0.12), 'EdgeColor', co, 'LineWidth', 1.4);
[Uv, Dv] = eig(P);  E = Uv*diag(sqrt(eta./diag(Dv)))*[cos(an); sin(an)];
plot(E(1, :), E(2, :), 'Color', az, 'LineWidth', 2);
plot(b*cos(an), b*sin(an), '--', 'Color', ve, 'LineWidth', 1.4);
plot(X(:, 1), X(:, 2), 'Color', no, 'LineWidth', 0.8);  plot(2.45, 0, 'o', 'Color', no, 'MarkerFaceColor', no, 'MarkerSize', 4);
text(-1.6, 0.3, '$B_\mu$', 'Color', co);  text(-1.2, 4.0, '$\Omega_\eta$', 'Color', az);  text(3.2, 4.2, '$B_b$', 'Color', ve);
axis equal;  axis([-5.4 5.4 -5.4 5.4]);  grid on;  box on;  xlabel('$x_1$');  ylabel('$x_2$');
title(sprintf('$\\mu=%.2f$, $b=%.2f$, m\\''ax $\\|x\\|=%.2f$', mu, b, max(nx)));
subplot(1, 2, 2);  hold on;  cs = [az; vi; am];
lab = {'$w=0.3\cos t$', '$w=0.3\cos 2t$', '$w\equiv0.3$'};
for i = 1:3
    w = ws{i};
    [tz, Z] = ode45(@(t, x) [x(2); -(1 + x(1)^2)*x(1) - x(2) + w(t)], linspace(0, 30, 3000), [2; 0], opc);
    plot(tz, sqrt(sum(Z.^2, 2)), 'Color', cs(i, :), 'LineWidth', 1.3);
end
plot([0 30], [mur mur], '--', 'Color', co, 'LineWidth', 1.2);  text(25, mur + 0.05, sprintf('$\\mu=%.3f$', mur), 'Color', co);
plot([0 30], [br br], '--', 'Color', ve, 'LineWidth', 1.2);  text(25, br + 0.05, sprintf('$b=%.2f$', br), 'Color', ve);
axis([0 30 0 2.2]);  grid on;  box on;  xlabel('$t$');  ylabel('$\|x(t)\|$');
legend(lab, 'Location', 'north', 'Orientation', 'horizontal');  title('resorte endurecido forzado');
