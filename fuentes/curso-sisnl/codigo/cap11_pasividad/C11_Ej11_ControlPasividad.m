%% C11_Ej11_ControlPasividad -- Notas: sección 11.9 (control basado en pasividad)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Inyección de amortiguamiento: x1' = x2, x2' = -x1^3 + u, y = x2,
%            V = x1^4/4 + x2^2/2 (pasivo, ZSO) con u = -k y y con u = -(2k/pi) atan(y).
%            (2) Péndulo m l^2 q'' + b q' + m g l sin q = u llevado a q_r = 60°
%            con PD + compensación de gravedad y con PD solo.
% OBSERVE    (1) Las dos leyes estabilizan globalmente; la saturada nunca pide más
%            de 2k/pi. La convergencia es lenta: el resorte x1^3 no tiene parte lineal.
%            (2) Sin compensar la gravedad, el PD deja un error en estado estacionario.
% ESPERADO   |u| <= 0.6366 con atan (k = 1);  PD solo: q -> 0.7228 rad (error 18.59°);
%            PD + gravedad: q -> pi/3.
% EXPLORE    Duplique Kp en el PD sin compensación: ¿cuánto baja el error?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:amortiguamiento]
k = 1;
leyes = {@(y) -k*y, @(y) -(2*k/pi)*atan(y)};
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11);
for i = 1:2
    phi = leyes{i};
    [t, X] = ode45(@(t, x) [x(2); -x(1)^3 + phi(x(2))], [0 60], [2; 0], opc);
    fprintf('ley %d: |x(60)| = %.4f   max |u| = %.4f\n', i, norm(X(end,:)), ...
            max(abs(phi(X(:,2)))));
end
% [fin:amortiguamiento]

% [ini:pendulo]
m = 1;  l = 1;  g = 9.81;  bf = 0.5;  Kp = 20;  Kd = 5;  qr = pi/3;
for compensa = [true false]
    ley = @(q, dq) compensa*m*g*l*sin(q) - Kp*(q - qr) - Kd*dq;
    f = @(t, x) [x(2); (ley(x(1), x(2)) - bf*x(2) - m*g*l*sin(x(1)))/(m*l^2)];
    [t, X] = ode45(f, [0 10], [0; 0], opc);
    fprintf('compensación = %d:  q(10) = %.4f rad = %.2f°\n', compensa, X(end,1), ...
            rad2deg(X(end,1)));
end
qss = fzero(@(q) Kp*(qr - q) - m*g*l*sin(q), [0 qr]);    % equilibrio del PD solo
fprintf('PD solo: equilibrio q = %.4f rad; error = %.2f°\n', qss, rad2deg(qr - qss));
% [fin:pendulo]

% ---- Figura de las notas (fig:pa-control) ----------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
fig = estiloFigura(1300, 440);
leyes = {@(y) -y, @(y) -(2/pi)*atan(y)};  cs = [az; co];
for j = 1:2
    [t, X] = ode45(@(t, x) [x(2); -x(1)^3 + leyes{j}(x(2))], linspace(0, 30, 6001), [2; 0], opc);
    subplot(1, 3, 1);  plot(t, X(:,1), 'Color', cs(j,:));  hold on;
    subplot(1, 3, 2);  plot(t, leyes{j}(X(:,2)), 'Color', cs(j,:));  hold on;
end
subplot(1, 3, 1);  grid on;  box on;  xlabel('$t$ (s)');  title('$x_1(t)$, $k=1$');
legend('$u=-k\,y$', '$u=-\frac{2k}{\pi}\arctan y$');
subplot(1, 3, 2);  plot([0 30], [1 1]*2/pi, ':', 'Color', gr, 'LineWidth', 0.8);
plot([0 30], -[1 1]*2/pi, ':', 'Color', gr, 'LineWidth', 0.8);  grid on;  box on;  xlabel('$t$ (s)');  title('$u(t)$');
m = 1;  l = 1;  g = 9.81;  b = 0.5;  Kp = 20;  Kd = 5;  qr = pi/3;  cs = [ve; vi];
subplot(1, 3, 3);  hold on;
for comp = [1 0]
    ley = @(q, dq) comp*m*g*l*sin(q) - Kp*(q - qr) - Kd*dq;
    [t, X] = ode45(@(t, x) [x(2); (ley(x(1), x(2)) - b*x(2) - m*g*l*sin(x(1)))/(m*l^2)], linspace(0, 6, 1201), [0; 0], opc);
    plot(t, rad2deg(X(:,1)), 'Color', cs(2 - comp,:));
end
plot([0 6], [60 60], '--', 'Color', gr, 'LineWidth', 0.8);
grid on;  box on;  xlabel('$t$ (s)');  ylabel('$q$ ($^\circ$)');  title('p\''endulo, $q_r=60^\circ$');
legend('PD + gravedad', 'PD solo', 'Location', 'southeast');
