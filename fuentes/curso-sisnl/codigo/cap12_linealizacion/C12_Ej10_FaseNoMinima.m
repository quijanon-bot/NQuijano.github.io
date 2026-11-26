%% C12_Ej10_FaseNoMinima -- Notas: sección 12.9 (un ejemplo que se ve perfecto)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   x1' = x1 + x2,  x2' = 3 x1^2 x2 + x1 + u,  y = -x1^3 + x2  (r = 1).
%            Con xi = h(x), eta = x1:  xi' = eta - 3 eta^3 + u,  eta' = xi + eta + eta^3.
%            Ley: u = -eta + 3 eta^3 + v,  v = -k xi  (k = 2)  =>  xi' = -2 xi.
%            Verifica las coordenadas y simula desde x(0) = (0.05, 0.6).
% OBSERVE    La salida converge como se diseñó; la trayectoria llega a la curva
%            Z* = {x2 = x1^3} y se va por ella: allí manda la dinámica cero
%            eta' = eta + eta^3, que escapa en tiempo finito. El control explota.
% ESPERADO   Coordenadas: error < 1e-6. |eta| = 2.2 en t = 1.394 s (con |y| = 0.037).
%            Solo la dinámica cero, desde eta0 = 0.05: escape en t = ln(1 + 1/eta0^2)/2 = 2.997 s.
% EXPLORE    Cambie la salida a y = x2 + x1 (¿grado relativo?, ¿dinámica cero?).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:coordenadas]
f = @(x) [x(1) + x(2); 3*x(1)^2*x(2) + x(1)];  g = @(x) [0; 1];  h = @(x) -x(1)^3 + x(2);
err = 0;
for i = 1:50
    x = 2*rand(2, 1) - 1;  xi = h(x);  eta = x(1);
    err = max([err, abs(derivadaLie(g, h, x) - 1), abs(derivadaLie(f, h, x) - (eta - 3*eta^3)), ...
               abs(f(x)'*[1; 0] - (xi + eta + eta^3))]);
end
fprintf('L_g h = 1, L_f h = eta - 3 eta^3, eta'' = xi + eta + eta^3: error máximo %.1e\n', err);
% [fin:coordenadas]

% [ini:escape]
k = 2;  u = @(x) -x(1) + 3*x(1)^3 - k*(-x(1)^3 + x(2));
lazo = @(t, x) f(x) + g(x)*u(x);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.005, 'Events', @(t, x) eventoODE(abs(x(1)) - 2.2, 1, 0));
[t, X] = ode45(lazo, [0 10], [0.05; 0.6], opc);
y = -X(:,1).^3 + X(:,2);
fprintf('|eta| = 2.2 en t = %.3f s; en ese instante |y| = %.3f (y(0) = %.3f)\n', t(end), abs(y(end)), y(1));
fprintf('dinámica cero sola desde 0.05: escapa en t = %.3f s\n', log(1 + 1/0.05^2)/2);
% [fin:escape]



% ---- Figura de las notas (fig:fl-nominima) ---------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rhs = @(t, x) [x(1) + x(2); 3*x(1)^2*x(2) + x(1) + (-x(1) + 3*x(1)^3 - 2*(-x(1)^3 + x(2)))];
[t, X] = ode45(rhs, [0 10], [0.05; 0.6], odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.002, ...
               'Events', @(t, x) eventoODE(abs(x(1)) - 2.2, 1, 0)));
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  xx = linspace(-0.3, 2.4, 300);
plot(xx, xx.^3, 'Color', claro(ve, 0.6), 'LineWidth', 4);  plot(X(:,1), X(:,2), 'Color', az);
plot(0.05, 0.6, 'o', 'Color', no, 'MarkerFaceColor', no, 'MarkerSize', 4);
axis([-0.3 2.4 -1 11]);  grid on;  box on;  xlabel('$x_1=\eta$');  ylabel('$x_2$');  title('Llega a $Z^*$ y se va por ella');
legend('$Z^*=\{x_2=x_1^3\}$', 'Location', 'northwest');
subplot(1, 2, 2);  hold on;  plot(t, -X(:,1).^3 + X(:,2), 'Color', az);  plot(t, X(:,1), 'Color', co);
grid on;  box on;  xlabel('$t$');  title('$y\to0$ como se dise\~n\''o; $\eta$ escapa');
legend('$y=\xi$', '$\eta=x_1$', 'Location', 'northwest');
