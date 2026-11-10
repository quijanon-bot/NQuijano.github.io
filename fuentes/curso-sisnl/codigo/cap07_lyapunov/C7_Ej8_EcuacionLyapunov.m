%% C7_Ej8_EcuacionLyapunov -- Notas: sección 7.7 (la ecuación de Lyapunov)
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

fig = estiloFigura(1100, 420);
plot(t, nx, t, sqrt(Vx/Vx(1)), t, sqrt(max(l)/min(l))*exp(-t/(2*max(l))), '--');  grid on;
xlabel('$t$');  legend('$|x(t)|$', '$\sqrt{V(x(t))/V(x_0)}$', 'cota de Lyapunov');
title('Hurwitz no quiere decir que la norma decrezca');
