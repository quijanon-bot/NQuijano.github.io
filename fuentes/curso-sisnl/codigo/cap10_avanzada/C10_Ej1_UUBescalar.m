%% C10_Ej1_UUBescalar -- Notas: sección 10.2 (un ejemplo que se puede resolver)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% ---- Figura de las notas (fig:av-escalar) ---------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  T4 = T(4, 1.5);
patch([T4 12 12 T4], [-b -b b b], claro(ve, 0.12), 'EdgeColor', 'none');
x0s = [4 2 -4];  cs = [az; vi; ve];  h = zeros(1, 3);
for j = 1:3
    [~, Xj] = ode45(@(t, x) -x + d*sin(t), t, x0s(j), opc);
    h(j) = plot(t, Xj, 'Color', cs(j, :), 'LineWidth', 1.5);
end
plot(t, env, '--', 'Color', co, 'LineWidth', 1.2);  plot(t, -env, '--', 'Color', co, 'LineWidth', 1.2);
plot([T4 T4], [-4.3 4.3], ':', 'Color', gr, 'LineWidth', 0.8);
text(T4 + 0.15, 3.3, sprintf('$T(4,1.5)=\\ln 6=%.2f$', T4));
for sg = [1 -1], plot([0 12], sg*[1 1]*d/sqrt(2), ':', 'Color', no, 'LineWidth', 0.8); end
axis([0 12 -4.3 4.3]);  grid on;  box on;  xlabel('$t$');  ylabel('$x$');  title('$\dot x=-x+\sin t$');
legend(h, '$x(0)=4$', '$x(0)=2$', '$x(0)=-4$', 'Location', 'southeast', 'Orientation', 'horizontal');
subplot(1, 2, 2);  hold on;  bb = linspace(1.01, 3.5, 300);
plot(bb, T(4, bb), 'Color', az);  plot(bb, T(14, bb), 'Color', vi);
plot([d d], [0 6.5], '--', 'Color', co, 'LineWidth', 1);  text(1.05, 5.5, '$b\to\delta$', 'Color', co);
ylim([0 6.5]);  grid on;  box on;  xlabel('cota \''ultima $b$');  ylabel('$T(a,b)$');
legend('$a=4$', '$a=14$');  title('el precio de afinar la cota');
