%% C11_Ej7_LaSalleRLC -- Notas: sección 11.6 (OSP + ZSO + LaSalle)
% QUÉ HACE   RLC serie (R = L = C = 1) con u = 0: x1' = x2, x2' = -x1 - x2, y = x2,
%            V = (x1^2 + x2^2)/2, V' = -x2^2. Y el contraejemplo sin ZSO:
%            x1' = 0, x2' = -x2 + u, y = x2.
% OBSERVE    En el RLC, V' = 0 en la recta x2 = 0, pero la trayectoria la cruza
%            sin quedarse (ZSO) y V(x(t)) se aplana en cada cruce. En el
%            contraejemplo x1 no se mueve: estable, no asintóticamente estable.
% ESPERADO   RLC: V(20) ~ 1e-9 desde x0 = [1.5; 0]. Contraejemplo: x1(t) = x1(0).
%            Con V_eps = V + eps x1 x2, V_eps' es negativa definida para 0 < eps < 4/5.
% EXPLORE    Verifique numéricamente que con eps = 0.9 V_eps' toma valores positivos.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:lasalle]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) [x(2); -x(1) - x(2)], linspace(0, 20, 4001), [1.5; 0], opc);
V  = (X(:,1).^2 + X(:,2).^2)/2;
cruces = t(find(diff(sign(X(:,2))) ~= 0));
fprintf('V(20) = %.1e;  la trayectoria cruza x2 = 0 en t = %s\n', V(end), ...
        mat2str(cruces(1:4).', 3));
% [fin:lasalle]

% [ini:contraejemplo]
[t2, X2] = ode45(@(t, x) [0; -x(2)], [0 6], [1; 1.2], opc);
fprintf('contraejemplo: x1(6) = %.4f (no se mueve),  x2(6) = %.4f\n', X2(end,1), X2(end,2));
% [fin:contraejemplo]

% [ini:veps]
[x1, x2] = meshgrid(linspace(-1, 1, 201));
for eps_ = [0.5 0.79 0.81 0.9]
    dVe = -eps_*x1.^2 - eps_*x1.*x2 - (1 - eps_)*x2.^2;
    dVe(x1 == 0 & x2 == 0) = -1;
    fprintf('eps = %.2f:  max de dV_eps fuera del origen = %+.2e\n', eps_, max(dVe(:)));
end
% [fin:veps]

fig = estiloFigura(1000, 400);
subplot(1,2,1); plot(X(:,1), X(:,2), [-1.7 1.7], [0 0], 'r'); axis equal; grid on; xlabel('$x_1$'); ylabel('$x_2$');
subplot(1,2,2); plot(t, V); grid on; hold on;
for c = cruces(1:4).', plot([c c], [0 1.2], 'r--'); end
xlim([0 14]); xlabel('$t$'); title('$V(x(t))$');
