%% C10_Ej7_SontagCos -- Notas: sección 10.4 (x' = cos x - x^3 + u)
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

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  plot(tS, XS, tF, XF);  grid on;  xlabel('$t$');  ylabel('$x$');  legend('Sontag', 'linealizaci\''on');
subplot(1, 2, 2);  plot(tS, arrayfun(uS, XS), tF, arrayfun(uF, XF));  grid on;  xlabel('$t$');  ylabel('$u$');
