%% C10_Ej1_UUBescalar -- Notas: sección 10.2 (un ejemplo que se puede resolver)
% QUÉ HACE   Para x' = -x + delta sin t, x(t0) = a:
%            (1) compara la solución exacta con la envolvente e^{-t} a + delta (1 - e^{-t});
%            (2) calcula el tiempo de espera T(a, b) = ln((a - delta)/(b - delta));
%            (3) compara con la cota de Lyapunov T <= (c - eps)/k, con V = x^2/2.
% OBSERVE    La envolvente nunca se cruza; desde T la solución queda en |x| <= b. La
%            amplitud final es delta/sqrt(2), menor que la cota delta.
% ESPERADO   T(4, 1.5) = ln 6 = 1.79; T(14, 1.05) = ln 260 = 5.56; Lyapunov: T <= 1856.
% EXPLORE    Haga b = 1.001. ¿Cuánto vale T? ¿Qué pasa con la cota de Lyapunov?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:escalar]
d = 1;  a = 4;  b = 1.5;
T = @(a, b) log((a - d)./(b - d));
fprintf('T(4, 1.5) = %.4f;  T(14, 1.05) = %.4f\n', T(a, b), T(14, 1.05));
t = linspace(0, 12, 1200);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, X] = ode45(@(t, x) -x + d*sin(t), t, a, opc);
env = exp(-t)*a + d*(1 - exp(-t));
fprintf('¿la solución cruza la envolvente? %d\n', any(abs(X') > env + 1e-9));
[tl, Xl] = ode45(@(t, x) -x + d*sin(t), linspace(0, 60, 6001), a, opc);
fprintf('max |x| en t >= 30: %.4f  (delta/sqrt 2 = %.4f)\n', max(abs(Xl(tl >= 30))), d/sqrt(2));
% cota de Lyapunov con V = x^2/2: a = 14, b = 1.05
c = 14^2/2;  ep = 1.05^2/2;  k = 1.05^2 - d*1.05;
fprintf('Lyapunov: T <= (c - eps)/k = %.0f\n', (c - ep)/k);
% [fin:escalar]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  plot(t, X, t, env, '--', t, -env, '--');  hold on;
plot([T(a, b) T(a, b)], [-4 4], 'k:');  grid on;  xlabel('$t$');  ylabel('$x$');
title(sprintf('$T(4,1.5)=%.2f$', T(a, b)));
subplot(1, 2, 2);  bb = linspace(1.01, 3.5, 200);  plot(bb, T(4, bb), bb, T(14, bb));
grid on;  xlabel('$b$');  ylabel('$T(a,b)$');  legend('$a=4$', '$a=14$');  title('Afinar la cota cuesta tiempo');
