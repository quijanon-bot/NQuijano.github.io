%% C6_Ej13_SillaNodoCiclos -- Notas: sección 6.7 (silla-nodo de ciclos)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Para el ejemplo de Sastry de la sección 6.7, que en polares es
%              r' = r((1 - r^2)^2 cos(mu) - sin(mu)),  theta' = (1 - r^2)^2 sin(mu) + cos(mu):
%            (1) grafica r' contra r para mu = -0.1, 0 y 0.1;
%            (2) calcula los ciclos r = sqrt(1 -+ sqrt(tan mu)) y los compara con la
%            simulación en cartesianas; (3) retrato con mu = 0.1 y diagrama de los radios.
% OBSERVE    En mu = 0 hay un ciclo semiestable r = 1; para mu < 0 no hay ciclos y todo
%            escapa; para mu > 0 nacen dos, el interior estable y el exterior inestable.
% ESPERADO   mu = 0.1: ciclos 0.8266 (estable) y 1.1475 (inestable); desde r = 0.3 la
%            simulación converge a 0.8266.
% EXPLORE    Arranque con mu = 0.1 justo afuera del ciclo exterior (r = 1.16). ¿Qué pasa?
%            Baje mu a 0 con el estado en el ciclo interior: ¿adónde se va?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:pliegue]
campo = @(x, m) [-x(1)*sin(m) - x(2)*cos(m) + (1 - x(1)^2 - x(2)^2)^2*(x(1)*cos(m) - x(2)*sin(m));
                  x(1)*cos(m) - x(2)*sin(m) + (1 - x(1)^2 - x(2)^2)^2*(x(1)*sin(m) + x(2)*cos(m))];
mu = 0.1;
rin = sqrt(1 - sqrt(tan(mu)));  rout = sqrt(1 + sqrt(tan(mu)));
fprintf('mu = %.1f: ciclo interior %.4f (estable), exterior %.4f (inestable)\n', mu, rin, rout);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, X] = ode45(@(t, x) campo(x, mu), [0 200], [0.3; 0], opc);
fprintf('desde r = 0.3: r final = %.4f\n', norm(X(end, :)));
% [fin:pliegue]

fig = estiloFigura(1300, 420);
subplot(1, 3, 1);  r = linspace(0, 1.6, 400);  hold on;
cols = [209 73 91; 115 115 115; 30 90 168]/255;  ms = [-0.1 0 0.1];           % como en la figura de las notas
for i = 1:3, plot(r, r.*((1 - r.^2).^2*cos(ms(i)) - sin(ms(i))), 'Color', cols(i, :)); end
plot([0 1.6], [0 0], 'k', 'LineWidth', 0.5);  ylim([-0.3 0.6]);  grid on;
xlabel('$r$');  ylabel('$\dot r$');  legend('$\mu=-0.1$', '$\mu=0$', '$\mu=0.1$', 'Location', 'northwest');
subplot(1, 3, 2);  hold on;  th = linspace(0, 2*pi, 300);
for x0 = [0.15 1.12 1.17]
    opc2 = odeset(opc, 'Events', @(t, x) eventoODE(norm(x) - 1.6, 1, 1));
    [~, Y] = ode45(@(t, x) campo(x, mu), [0 25], [x0; 0], opc2);  plot(Y(:, 1), Y(:, 2), 'LineWidth', 0.8, 'Color', [30 90 168]/255);
end
plot(rin*cos(th), rin*sin(th), 'Color', [42 157 143]/255);  plot(rout*cos(th), rout*sin(th), '--', 'Color', [209 73 91]/255);
axis equal;  axis([-1.6 1.6 -1.6 1.6]);  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('$\mu=0.1$');
subplot(1, 3, 3);  mm = linspace(0, 0.6, 200);  hold on;
plot(mm, sqrt(1 - sqrt(tan(mm))), 'Color', [42 157 143]/255);  plot(mm, sqrt(1 + sqrt(tan(mm))), '--', 'Color', [209 73 91]/255);
plot(0, 1, 'o', 'MarkerFaceColor', [0.67 0.67 0.67], 'MarkerEdgeColor', 'k');
axis([-0.3 0.6 0 1.6]);  grid on;  xlabel('$\mu$');  ylabel('radio del ciclo');  title('Silla-nodo de ciclos');
