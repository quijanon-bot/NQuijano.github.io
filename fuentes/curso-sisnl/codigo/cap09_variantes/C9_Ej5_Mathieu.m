%% C9_Ej5_Mathieu -- Notas: sección 9.5 (Mathieu amortiguada)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   y'' + y' + (2 + sin t) y = 0 con V = x1^2 + x2^2/(2 + sin t). Verifica la
%            fórmula de Vdot en una malla, calcula la constante c de Vdot <= -c x2^2 y
%            los multiplicadores de Floquet (matriz de monodromía en un periodo 2 pi).
% OBSERVE    Vdot solo es semidefinida (cero en x2 = 0): el teorema da US. Floquet da más.
% ESPERADO   c = 0.637 (a mano, 0.196); mu = -0.0099 +- 0.0421j, |mu| = e^{-pi} = 0.0432.
% EXPLORE    Cambie el amortiguamiento 1 por 0.1. ¿Siguen los multiplicadores dentro?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-13);

% [ini:mathieu]
A = @(t) [0 1; -(2 + sin(t)) -1];
V = @(t, x) x(1)^2 + x(2)^2/(2 + sin(t));
Vdot = @(t, x) -(4 + 2*sin(t) + cos(t))/(2 + sin(t))^2*x(2)^2;
h = 1e-6;  err = 0;                                       % chequeo con diferencias finitas
for t = linspace(0, 2*pi, 13)
    for x = [[1; 0.5], [-0.3; 2], [0.7; -1.1]]
        F = A(t)*x;  Vd = (V(t + h, x) - V(t - h, x))/(2*h) ...
            + (V(t, x + [h; 0]) - V(t, x - [h; 0]))/(2*h)*F(1) + (V(t, x + [0; h]) - V(t, x - [0; h]))/(2*h)*F(2);
        err = max(err, abs(Vd - Vdot(t, x)));
    end
end
fprintf('max |Vdot numérica - fórmula| = %.1e\n', err);
tt = linspace(0, 2*pi, 100001);
fprintf('c = min (4 + 2 sin t + cos t)/(2 + sin t)^2 = %.3f;  a mano (4 - sqrt5)/9 = %.3f\n', ...
    min((4 + 2*sin(tt) + cos(tt))./(2 + sin(tt)).^2), (4 - sqrt(5))/9);
M = zeros(2);  E = eye(2);                                % monodromía Phi(2 pi, 0)
for k = 1:2, [~, X] = ode45(@(t, x) A(t)*x, [0 2*pi], E(:, k), opc);  M(:, k) = X(end, :)'; end
mu = eig(M);
fprintf('multiplicadores: %.4f %+.4fj,  |mu| = %.4f,  e^{-pi} = %.4f,  det M = %.3e\n', ...
    real(mu(1)), abs(imag(mu(1))), abs(mu(1)), exp(-pi), det(M));
% [fin:mathieu]

% ---- Figura de las notas (fig:vt-mathieu) ---------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
[t, X] = ode45(@(t, x) A(t)*x, linspace(0, 14, 3000), [1.5; 0], opc);
Vt = X(:, 1).^2 + X(:, 2).^2./(2 + sin(t));
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  grid on;  th = linspace(0, 2*pi, 300);  ts = [0 pi/2 3*pi/2];  cl3 = [az; ve; co];
for j = 1:3, plot(1.5*cos(th), 1.5*sqrt(2 + sin(ts(j)))*sin(th), '--', 'Color', cl3(j, :));  end   % V(t,x) = 2.25; t = 1.57 y 4.71 dan W1 y W2
plot(X(:, 1), X(:, 2), 'Color', no, 'LineWidth', 1.1);
axis([-1.8 1.8 -2.8 2.8]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');
legend('$V(t,x)=2.25$, $t=0$', '$t=1.57$', '$t=4.71$', 'Location', 'southwest');
title('los niveles respiran con $t$');
subplot(1, 2, 2);  semilogy(t, Vt, 'Color', az);  hold on;  semilogy(t, 2.25*exp(-t), '--', 'Color', gr);
grid on;  xlabel('$t$');  legend('$V(t,x(t))$', '$2.25\,e^{-t}$');
title('$\dot V\le0$ y, de hecho, decae como $e^{-t}$');
