%% C7_Ej3_Energia -- Notas: sección 7.4 (método directo)
% QUÉ HACE   (1) Evalúa la energía V = a(1 - cos x1) + x2^2/2 a lo largo de soluciones del
%            péndulo con y sin fricción, y la compara con Vdot = -b x2^2.
%            (2) x' = -g(x) con g(x) = sin x + x^3 y V = int_0^x g: Vdot = -g(x)^2.
% OBSERVE    (1) Con fricción V decrece, pero con "escalones": se detiene cada vez que
%            x2 = 0. Vdot <= 0 da estabilidad, no estabilidad asintótica (eso lo arregla
%            el capítulo 8, o la V con término cruzado de la sección 7.6).
% ESPERADO   (1) b = 0: V constante (variación < 1e-8). b = 0.5: V(0) - V(20) =
%            int_0^20 b x2^2 dt.   (2) V decrece a cero desde x0 = 2.
% EXPLORE    ¿En qué instantes V deja de decrecer? Compare con los cruces x2 = 0.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:energia]
a = 1;  opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);  t = linspace(0, 20, 4001);
V = @(X) a*(1 - cos(X(:,1))) + X(:,2).^2/2;
for b = [0 0.5]
    [~, X] = ode45(@(t, x) [x(2); -a*sin(x(1)) - b*x(2)], t, [2.5; 0], opc);
    Vt = V(X);  disip = trapz(t, b*X(:,2).^2);
    fprintf('b = %.1f: V(0) = %.4f, V(20) = %.4f, int b x2^2 = %.4f, max dV = %.1e\n', ...
            b, Vt(1), Vt(end), disip, max(diff(Vt)));
end
% [fin:energia]

% [ini:gx]
g = @(x) sin(x) + x.^3;  Vg = @(x) 1 - cos(x) + x.^4/4;      % V = int_0^x g
[~, xg] = ode45(@(t, x) -g(x), t, 2, opc);
fprintf('x'' = -g(x): V(0) = %.4f, V(20) = %.2e; Vdot = -g^2 <= 0\n', Vg(2), Vg(xg(end)));
% [fin:gx]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  plot(t, Vt, t, X(:,2));  grid on;  xlabel('$t$');
legend('$V(x(t))$', '$x_2(t)$');  title('Con fricci\''on: $\dot V=-bx_2^2\le0$');
subplot(1, 2, 2);  plot(t, Vg(xg));  grid on;  xlabel('$t$');  ylabel('$V$');  title('$\dot x=-g(x)$');
