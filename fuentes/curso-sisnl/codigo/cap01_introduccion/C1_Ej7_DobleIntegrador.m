%% C1_Ej7_DobleIntegrador -- Notas: sección 1.6 (estructura variable)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Doble integrador x1' = x2, x2' = u, desde x(0) = (1, 1), con cuatro
%            leyes: u = 0; u = -k x1 (k = 5); el PD u = -x1 - x2; y la ley de
%            estructura variable u = 4 k3 x1 con k3 = +1 si x1 s < 0, k3 = -1 si
%            x1 s > 0, donde s = x1 + x2.
% OBSERVE    u = -k x1 da un oscilador: acotado, sin converger. La ley de
%            estructura variable alterna dos sistemas que, cada uno por
%            separado, NO convergen (un centro y una silla); juntos llevan el
%            estado a la recta s = 0 y lo deslizan por ella como x1' = -x1.
% ESPERADO   Llega a s = 0 en t = atan(4/3)/2 = 0.4636, en el punto (1, -1).
%            Tiempo al 2 % de la norma inicial: 4.38 (estructura variable) y
%            8.91 (PD). Sobreimpulso de x1: ninguno (estructura variable);
%            el PD cruza el cero y llega a -0.209.
% EXPLORE    Integre la ley conmutada directamente con ode45 (descomente la
%            última línea del bloque) y mire u(t) después de t = 0.46: el lado
%            derecho es discontinuo, el integrador conmuta en cada paso
%            (chattering) y se vuelve muy lento. ¿Qué significa "solución"
%            aquí? (Filippov)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:vsc]
leyes = {@(x) 0, @(x) -5*x(1), @(x) -x(1) - x(2)};
nombres = {'u = 0', 'u = -5 x1', 'PD', 'estructura variable'};
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 1e-3);
t = linspace(0, 10, 10001)';
for i = 1:3
    u = leyes{i};
    [~, X] = ode45(@(t, x) [x(2); u(x)], t, [1; 1], opc);
    Xs{i} = X;                                                              %#ok<SAGROW>
end
% Estructura variable. Mientras x1 s > 0, u = -4 x1: el centro x1'' = -4 x1.
% Al tocar s = 0 los dos campos apuntan hacia la recta y la solución (en el
% sentido de Filippov) desliza por ella con x1' = -x1, x2 = -x1.
evento = @(t, x) eventoODE(x(1) + x(2), 1, -1);          % s = 0, de arriba hacia abajo
[~, ~, ts, xs] = ode45(@(t, x) [x(2); -4*x(1)], [0 10], [1; 1], odeset(opc, 'Events', evento));
antes = t <= ts;  X = zeros(numel(t), 2);
[~, Xa] = ode45(@(t, x) [x(2); -4*x(1)], t(antes), [1; 1], opc);  X(antes, :) = Xa;
X(~antes, 1) = xs(1)*exp(-(t(~antes) - ts));  X(~antes, 2) = -X(~antes, 1);
Xs{4} = X;
for i = 1:4
    nx = sqrt(sum(Xs{i}.^2, 2));
    t2 = t(find(nx > 0.02*nx(1), 1, 'last'));
    fprintf('%-20s  t(2%%) = %5.2f   min x1 = %7.3f\n', nombres{i}, t2, min(Xs{i}(:,1)));
end
fprintf('Estructura variable: llega a s = 0 en t = %.4f, x = (%.3f, %.3f)\n', ts, xs);
% k3 = @(x) 1 - 2*(x(1)*(x(1) + x(2)) > 0);  [~, Xc] = ode45(@(t, x) [x(2); 4*k3(x)*x(1)], [0 3], [1; 1]);
% [fin:vsc]

fig = estiloFigura(1100, 430);
subplot(1, 2, 1); hold on; for i = 2:4, plot(Xs{i}(:,1), Xs{i}(:,2)); end
plot([-1.5 1.5], [1.5 -1.5], 'k--'); grid on; axis equal; axis([-1.5 1.7 -1.6 1.6]);
xlabel('$x_1$'); ylabel('$x_2$'); legend('$u=-5x_1$', 'PD', 'estructura variable', '$s=0$');
subplot(1, 2, 2); plot(t, Xs{3}(:,1), t, Xs{4}(:,1)); grid on; xlabel('$t$'); ylabel('$x_1$');
legend('PD', 'estructura variable');
