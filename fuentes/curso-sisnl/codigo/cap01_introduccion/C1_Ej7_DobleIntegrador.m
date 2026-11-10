%% C1_Ej7_DobleIntegrador -- Notas: sección 1.6 (estructura variable)
% QUÉ HACE   Doble integrador x1' = x2, x2' = u, desde x(0) = (1, 1), con cuatro
%            leyes: u = 0; u = -k x1 (k = 5); el PD u = -x1 - x2; y la ley de
%            estructura variable u = k3 x1 con k3 = +1 si x1 s < 0, k3 = -1 si
%            x1 s > 0, donde s = x1 + x2.
% OBSERVE    u = -k x1 da un oscilador: acotado, sin converger. La ley de
%            estructura variable alterna dos sistemas que, cada uno por
%            separado, NO convergen (un centro y una silla); juntos llevan el
%            estado a la recta s = 0 y lo deslizan por ella como x1' = -x1.
% ESPERADO   Llega a s = 0 en t = pi/2 = 1.5708, en el punto (1, -1). Tiempo
%            al 2 % de la norma inicial: 5.48 (estructura variable) y 8.91 (PD).
%            Sobrepico de x1: ninguno (estructura variable), -0.209 (PD).
% EXPLORE    Use ode45 con las tolerancias por defecto y mire u(t) después de
%            t = pi/2: el lado derecho es discontinuo y la ley "conmuta" muy
%            rápido (chattering). ¿Qué significa "solución" aquí? (Filippov)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:vsc]
k3 = @(x) 1 - 2*(x(1)*(x(1) + x(2)) > 0);     % +1 si x1 s < 0,  -1 si x1 s > 0
leyes = {@(x) 0, @(x) -5*x(1), @(x) -x(1) - x(2), @(x) k3(x)*x(1)};
nombres = {'u = 0', 'u = -5 x1', 'PD', 'estructura variable'};
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 1e-3);
t = linspace(0, 10, 10001)';
for i = 1:4
    u = leyes{i};
    [~, X] = ode45(@(t, x) [x(2); u(x)], t, [1; 1], opc);
    nx = sqrt(sum(X.^2, 2));
    t2 = t(find(nx > 0.02*nx(1), 1, 'last'));
    fprintf('%-20s  t(2%%) = %5.2f   min x1 = %7.3f\n', nombres{i}, t2, min(X(:,1)));
    Xs{i} = X;                                                              %#ok<SAGROW>
end
s = Xs{4}(:,1) + Xs{4}(:,2);  ia = find(abs(s) < 1e-3, 1);
fprintf('Estructura variable: llega a s = 0 en t = %.4f, x = (%.3f, %.3f)\n', t(ia), Xs{4}(ia,:));
% [fin:vsc]

fig = estiloFigura(1100, 430);
subplot(1, 2, 1); hold on; for i = 2:4, plot(Xs{i}(:,1), Xs{i}(:,2)); end
plot([-1.5 1.5], [1.5 -1.5], 'k--'); grid on; axis equal; axis([-1.5 1.7 -1.6 1.6]);
xlabel('$x_1$'); ylabel('$x_2$'); legend('$u=-5x_1$', 'PD', 'estructura variable', '$s=0$');
subplot(1, 2, 2); plot(t, Xs{3}(:,1), t, Xs{4}(:,1)); grid on; xlabel('$t$'); ylabel('$x_1$');
legend('PD', 'estructura variable');
