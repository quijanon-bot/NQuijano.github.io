%% C10_Ej7_SontagCos -- Notas: sección 10.4 (x' = cos x - x^3 + u)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Separa lo que no se anula: u = -cos x + u_s y Sontag sobre x' = -x^3 + u_s.
%            (2) Compara con la linealización exacta u_FL = -cos x + x^3 - x desde x(0) = 2.
%            (3) Muestra el valor de u en régimen.
% OBSERVE    u_FL cancela el término -x^3, que ayudaba; Sontag casi lo conserva. Las dos
%            leyes tienden a u* = -1: f(0) = 1 no es cero.
% ESPERADO   u_S(0) = 0.17, u_FL(0) = 6.42; u(10) -> -1 en los dos casos.
% EXPLORE    Pruebe la otra opción: u = -1 + v y Sontag sobre x' = cos x - 1 - x^3 + v.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:sontag]
uS = @(x) -cos(x) + leySontag(-x^4, x);         % V = x^2/2 para x' = -x^3 + u_s
uF = @(x) -cos(x) + x^3 - x;
fprintf('u_S(0) = %.4f (cerrada: %.4f);  u_FL(0) = %.4f\n', uS(2), -cos(2) + 8 - 2*sqrt(17), uF(2));
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[tS, XS] = ode45(@(t, x) cos(x) - x^3 + uS(x), [0 10], 2, opc);
[tF, XF] = ode45(@(t, x) cos(x) - x^3 + uF(x), [0 10], 2, opc);
fprintf('u(10): Sontag %.4f, linealización %.4f  (u* = -cos 0 = -1)\n', uS(XS(end)), uF(XF(end)));
% [fin:sontag]

% ---- Figura de las notas (fig:av-sontag; el tercer panel es el de C10_Ej8) ------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
fig = estiloFigura(1300, 440);  t6 = linspace(0, 6, 600);
[~, XS6] = ode45(@(t, x) cos(x) - x^3 + uS(x), t6, 2, opc);
[~, XF6] = ode45(@(t, x) cos(x) - x^3 + uF(x), t6, 2, opc);
subplot(1, 3, 1);  plot(t6, XS6, 'Color', az);  hold on;  plot(t6, XF6, 'Color', co);
grid on;  box on;  xlabel('$t$');  ylabel('$x$');  legend('Sontag', 'linealizaci\''on');  title('$\dot x=\cos x-x^3+u$');
subplot(1, 3, 2);  plot(t6, arrayfun(uS, XS6), 'Color', az);  hold on;  plot(t6, arrayfun(uF, XF6), 'Color', co);
plot([0 6], [-1 -1], ':', 'Color', gr, 'LineWidth', 1);  text(4, -0.8, '$u^*=-1$');
grid on;  box on;  xlabel('$t$');  ylabel('$u$');  title('esfuerzo');
k8 = @(x) -(1 + sqrt(1 + x^8))/x;                         % C10_Ej8: x' = x + x^2 u
[t8, X8] = ode45(@(t, x) x + x^2*k8(x), linspace(0, 8, 400), 1, odeset('RelTol', 1e-10, 'AbsTol', 1e-14));
subplot(1, 3, 3);  semilogy(t8, X8, 'Color', az);  hold on;  semilogy(t8, abs(arrayfun(k8, X8)), 'Color', co);
grid on;  box on;  xlabel('$t$');  legend('$x(t)$', '$|u(t)|$');  title('$\dot x=x+x^2u$');
