%% C12_Ej8_VanDerPolFL -- Notas: sección 12.7 (linealización entrada/salida)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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



% ---- Figura de las notas (fig:fl-vdpfl) ------------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
mu = 1;  ton = 10;  oo = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.01);
uf = @(t, x) (t >= ton)*(x(1) - mu*(1 - x(1)^2)*x(2) - 4*x(1) - 4*x(2));
t = linspace(0, 16, 3201);  k0 = find(t >= ton, 1);
[~, S1] = ode45(@(t, x) [x(2); -x(1) + mu*(1 - x(1)^2)*x(2)], t(1:k0), [0.5; 0], oo);
[~, S2] = ode45(@(tt, x) [x(2); -x(1) + mu*(1 - x(1)^2)*x(2) + uf(tt, x)], t(k0:end), S1(end,:).', oo);
[~, E] = ode45(@(tt, e) [e(2); -4*e(1) - 4*e(2)], t(k0:end), S1(end,:).', oo);
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  plot(S1(:,1), S1(:,2), 'Color', cl);  plot(S2(:,1), S2(:,2), 'Color', az);
plot(S1(end,1), S1(end,2), 'o', 'Color', co, 'MarkerFaceColor', co, 'MarkerSize', 4);
grid on;  box on;  xlabel('$x_1$');  ylabel('$x_2$');  title('Plano de fase');
subplot(1, 2, 2);  hold on;  plot(t(1:k0), S1(:,1), 'Color', cl, 'HandleVisibility', 'off');
plot(t(k0:end), S2(:,1), 'Color', az);  plot(t(k0:end), E(:,1), '--', 'Color', co, 'LineWidth', 1.2);
yl = ylim;  plot([ton ton], yl, ':', 'Color', gr, 'HandleVisibility', 'off');  ylim(yl);
xlim([0 16]);  grid on;  box on;  xlabel('$t$');  ylabel('$y=x_1$');  title('Ley conectada en $t=10$');
legend('planta', '$\ddot y+4\dot y+4y=0$', 'Location', 'southeast');
