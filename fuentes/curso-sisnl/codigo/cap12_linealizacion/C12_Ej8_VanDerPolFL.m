%% C12_Ej8_VanDerPolFL -- Notas: sección 12.7 (linealización entrada/salida)
% QUÉ HACE   Van der Pol x1' = x2, x2' = -x1 + mu (1 - x1^2) x2 + u con y = x1 (r = n = 2).
%            Hasta t = 10 el oscilador está libre (ciclo límite). Desde t = 10:
%              u = x1 - mu (1 - x1^2) x2 + v,   v = -4 x1 - 4 x2   =>  y'' + 4 y' + 4 y = 0.
% OBSERVE    El ciclo límite desaparece por construcción: el lazo cerrado es LINEAL en
%            todo el plano, porque Phi es la identidad (resultado global). La salida sigue
%            la predicción lineal hasta la precisión del integrador.
% ESPERADO   max|y - predicción| tras conectar < 1e-9;  max|u| = 1.97.
% EXPLORE    Use v = -k^2 x1 - 2k x2 con k = 1, 4, 10. ¿Cómo crece el máximo de |u|?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:ley]
mu = 1;  ton = 10;
u = @(t, x) (t >= ton)*(x(1) - mu*(1 - x(1)^2)*x(2) - 4*x(1) - 4*x(2));
vdp = @(t, x) [x(2); -x(1) + mu*(1 - x(1)^2)*x(2) + u(t, x)];
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12, 'MaxStep', 0.01);
t1 = linspace(0, ton, 1001);  t2 = linspace(ton, 16, 601);
[~, X1] = ode45(vdp, t1, [0.5; 0], opc);                % libre
[~, X2] = ode45(vdp, t2, X1(end,:).', opc);             % con la ley
[~, E]  = ode45(@(t, e) [e(2); -4*e(1) - 4*e(2)], t2, X1(end,:).', opc);
U = arrayfun(@(i) u(t2(i), X2(i,:).'), 1:numel(t2));
fprintf('max|y - predicción lineal| = %.1e,  max|u| = %.2f\n', max(abs(X2(:,1) - E(:,1))), max(abs(U)));
% [fin:ley]

fig = estiloFigura(1000, 420);
subplot(1, 2, 1); plot(X1(:,1), X1(:,2), 'Color', [.6 .6 .6]); hold on; plot(X2(:,1), X2(:,2));
grid on; xlabel('$x_1$'); ylabel('$x_2$'); title('Plano de fase');
subplot(1, 2, 2); plot(t1, X1(:,1), 'Color', [.6 .6 .6]); hold on; plot(t2, X2(:,1), t2, E(:,1), 'k--');
grid on; xlabel('$t$'); ylabel('$y=x_1$'); title('Desde $t=10$: $\ddot y+4\dot y+4y=0$');
