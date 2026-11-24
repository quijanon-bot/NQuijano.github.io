%% C7_Ej8_EcuacionLyapunov -- Notas: sección 7.7 (la ecuación de Lyapunov)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Resuelve A'P + PA = -Q para A = [0 -1; 1 -1], Q = I, con
%            ecuacionLyapunov (sin toolboxes), y comprueba que P es la integral
%            int_0^inf e^{A't} Q e^{At} dt y que x0'P x0 es el costo int x'Qx dt.
%            (2) A = [-1 10; 0 -2] (Hurwitz, no normal): |x(t)| crece antes de decaer,
%            pero V = x'Px decrece siempre.
% OBSERVE    (1) La P del curso es lyap(A', Q) en MATLAB, NO lyap(A, Q).
%            (2) La norma euclidiana no es una función de Lyapunov para este A; la
%            ecuación de Lyapunov construye la "métrica" en la que sí decrece.
% ESPERADO   (1) P = [1.5 -0.5; -0.5 1]; x0'P x0 = 1.96 para x0 = (1.2, 1).
%            (2) |x(ln 2)| = 2.512 desde (0, 1); M = sqrt(lmax/lmin) = 7.244.
% EXPLORE    Cambie Q en (1). ¿Cambia la estabilidad? ¿Cambia P? ¿Cambia la cota de (2)?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:lyap]
A = [0 -1; 1 -1];  Q = eye(2);
P = ecuacionLyapunov(A, Q);
fprintf('P = [%g %g; %g %g], eig(P) = (%.4f, %.4f), residuo = %.1e\n', P, eig(P), ...
        norm(A'*P + P*A + Q));
t = linspace(0, 40, 8001);  Pint = zeros(2);  x0 = [1.2; 1];  costo = 0;
for k = 1:numel(t) - 1          % regla del trapecio
    E0 = expm(A*t(k));  E1 = expm(A*t(k + 1));  h = t(k + 1) - t(k);
    Pint = Pint + h/2*(E0'*Q*E0 + E1'*Q*E1);
    costo = costo + h/2*((E0*x0)'*Q*(E0*x0) + (E1*x0)'*Q*(E1*x0));
end
fprintf('max|P - int e^{A''t}Qe^{At}| = %.1e;  x0''P x0 = %.4f, costo = %.4f\n', ...
        max(abs(P(:) - Pint(:))), x0'*P*x0, costo);
% [fin:lyap]

% [ini:nonormal]
A = [-1 10; 0 -2];  P = ecuacionLyapunov(A, eye(2));  l = eig(P);
fprintf('eig(A + A'') = (%.3f, %.3f): A + A'' no es definida negativa\n', eig(A + A'));
t = linspace(0, 8, 801);  X = zeros(2, numel(t));
for k = 1:numel(t), X(:, k) = expm(A*t(k))*[0; 1]; end
nx = sqrt(sum(X.^2));  Vx = sum(X.*(P*X));
fprintf('|x(ln 2)| = %.4f (arranca en 1);  max diff(V) = %.1e (< 0)\n', ...
        norm(expm(A*log(2))*[0; 1]), max(diff(Vx)));
fprintf('cota: |x(t)| <= %.3f |x0| e^{-%.4f t}\n', sqrt(max(l)/min(l)), 1/(2*max(l)));
% [fin:nonormal]

% ---- Figuras de las notas ----------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  ve = [42 157 143]/255;
ang = linspace(0, 2*pi, 300);  U = [cos(ang); sin(ang)];

% Figura 7.x (fig:ly-costo): P como costo, con A = [0 -1; 1 -1] y Q = I
A1 = [0 -1; 1 -1];  P1 = ecuacionLyapunov(A1, eye(2));  x0 = [1.2; 1];
tc = linspace(0, 12, 1201);  Xc = zeros(2, numel(tc));
for k = 1:numel(tc), Xc(:, k) = expm(A1*tc(k))*x0; end
Vc = sum(Xc.*(P1*Xc));  acum = cumtrapz(tc, sum(Xc.^2));       % lo que falta y lo pagado
fig1 = estiloFigura(1100, 420);
subplot(1, 2, 1);  ar = area(tc', [Vc' acum']);  hold on;
set(ar(1), 'FaceColor', ve);  set(ar(2), 'FaceColor', [0.85 0.87 0.91]);
plot(tc, (x0'*P1*x0)*ones(size(tc)), 'k--', 'LineWidth', 0.8);
xlim([0 12]);  xlabel('$t$');  legend('$V(x(t))$: lo que falta', '$\int_0^t x^\top x\,d\tau$: lo pagado', 'Location', 'east');
title(sprintf('$x_0^\\top Px_0=%.2f$: el costo total', x0'*P1*x0));
subplot(1, 2, 2);  hold on;  th = linspace(0, 2*pi, 61);  th(end) = [];
for k = 1:numel(th)
    dd = [cos(th(k)); sin(th(k))];  pk = dd/sqrt(dd'*P1*dd);              % punto de costo 1
    plot(pk(1), pk(2), 'o', 'Color', az, 'MarkerFaceColor', az, 'MarkerSize', 3);
end
Ee = chol(P1) \ U;  plot(Ee(1,:), Ee(2,:), 'Color', ve, 'LineWidth', 1.2);     % x'P1x = 1
axis equal;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('Costo 1: puntos y la elipse $x^\top Px=1$');

% Figura 7.x (fig:ly-nonormal): A = [-1 10; 0 -2] desde (0, 1)
fig2 = estiloFigura(1100, 420);
subplot(1, 2, 1);  hold on;
[X1, X2] = meshgrid(linspace(-3, 3, 300), linspace(-1.5, 1.5, 200));  S = A + A';
W = S(1,1)*X1.^2 + 2*S(1,2)*X1.*X2 + S(2,2)*X2.^2;  W(W <= 0) = NaN;     % donde la norma crece
contourf(X1, X2, W, [0 1e9], 'LineStyle', 'none');  colormap(gca, [0.98 0.89 0.91]);
L = chol(P);
for k = [1 find(t >= log(2), 1) find(t >= 1.5, 1)]
    plot(nx(k)*U(1,:), nx(k)*U(2,:), 'Color', co, 'LineWidth', 0.8);
    Ee = L \ (sqrt(Vx(k))*U);  plot(Ee(1,:), Ee(2,:), 'Color', ve, 'LineWidth', 1.2);
end
plot(X(1,:), X(2,:), 'Color', az);  plot(0, 1, 'o', 'Color', az, 'MarkerFaceColor', az);
axis equal;  axis([-3 3 -1.5 1.5]);  xlabel('$x_1$');  ylabel('$x_2$');  title('C\''irculos (rojo) y elipses de $P$');
subplot(1, 2, 2);  hold on;
plot(t, nx, 'Color', co);  plot(t, sqrt(Vx/Vx(1)), 'Color', ve);
plot(t, sqrt(max(l)/min(l))*exp(-t/(2*max(l))), '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1);
xlim([0 6]);  ylim([0 8]);  grid on;  xlabel('$t$');
legend('$\|x(t)\|$', '$\sqrt{V(x(t))/V(x_0)}$', 'cota de Lyapunov');  title('Hurwitz, pero la norma crece');
