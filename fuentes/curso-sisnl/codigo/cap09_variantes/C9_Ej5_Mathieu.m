%% C9_Ej5_Mathieu -- Notas: sección 9.5 (Mathieu amortiguada)
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

[t, X] = ode45(@(t, x) A(t)*x, linspace(0, 14, 2000), [1.5; 0], opc);
Vt = X(:, 1).^2 + X(:, 2).^2./(2 + sin(t));
fig = estiloFigura(900, 380);
subplot(1, 2, 1);  plot(X(:, 1), X(:, 2), 'k');  hold on;  th = linspace(0, 2*pi, 200);
for ts = [0 pi/2 3*pi/2], plot(1.5*cos(th), 1.5*sqrt(2 + sin(ts))*sin(th), '--'); end
axis equal;  grid on;  xlabel('$x_1$');  ylabel('$x_2$');  title('los niveles respiran');
subplot(1, 2, 2);  semilogy(t, Vt, t, 2.25*exp(-t), 'k--');  grid on;  xlabel('$t$');  title('$V(t,x(t))$');
