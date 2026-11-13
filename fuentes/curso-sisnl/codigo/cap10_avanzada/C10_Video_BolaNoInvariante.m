%% C10_Video_BolaNoInvariante -- Video V10_2: la bola no es invariante; el conjunto de nivel sí
% QUÉ MUESTRA  El oscilador x' = A x + B w, A = [0 1; -4 -0.2], w = 0.2 sin 1.3t, desde
%              (2.45, 0), dentro de B_mu (mu = 2.50). La trayectoria sale de la bola
%              (||x||/mu > 1) pero V/eta nunca pasa de 1.
% USO          Ejecute. Video en videos/V10_2_bola_no_invariante.mp4 (.avi en Linux).
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
HACER_VIDEO = true;

A = [0 1; -4 -0.2];  B = [0; 1];  P = ecuacionLyapunov(A, eye(2));
mu = 2*norm(P*B)*0.2/0.5;  eta = max(eig(P))*mu^2;
t = linspace(0, 20, 2001);
[~, X] = ode45(@(t, x) A*x + B*0.2*sin(1.3*t), t, [2.45; 0], odeset('RelTol', 1e-9, 'AbsTol', 1e-11));
n = sqrt(sum(X.^2, 2));  V = sum((X*P).*X, 2);
th = linspace(0, 2*pi, 300);  [Uv, Dv] = eig(P);  E = Uv*diag(sqrt(eta./diag(Dv)))*[cos(th); sin(th)];
fig = estiloFigura(1280, 600);
if HACER_VIDEO
    if ~exist(fullfile(raiz, 'videos'), 'dir'), mkdir(fullfile(raiz, 'videos')); end
    vid = abrirVideo(fullfile(raiz, 'videos', 'V10_2_bola_no_invariante'), 24);
end
for j = round(linspace(1, numel(t), 150))
    clf(fig);
    subplot(1, 2, 1);  hold on;  fill(mu*cos(th), mu*sin(th), [1 0.9 0.9]);  plot(E(1, :), E(2, :), 'b', 'LineWidth', 2.5);
    plot(X(1:j, 1), X(1:j, 2), 'k', 'LineWidth', 0.8);  plot(X(j, 1), X(j, 2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
    axis equal;  axis([-5.6 5.6 -5.6 5.6]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('$B_\mu$ y $\Omega_\eta$');
    subplot(1, 2, 2);  plot(t(1:j), n(1:j)/mu, t(1:j), V(1:j)/eta, [0 20], [1 1], 'k--');
    axis([0 20 0 2]);  grid on;  xlabel('$t$');  legend('$\|x\|/\mu$', '$V/\eta$');
    drawnow;  if HACER_VIDEO, writeVideo(vid, getframe(fig)); end
end
if HACER_VIDEO, close(vid); end
