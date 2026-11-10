%% C12_Ej3_PenduloExacto -- Notas: sección 12.3 (cancelar en vez de aproximar)
% QUÉ HACE   Péndulo x1' = x2, x2' = -a sin x1 - b x2 + c u. Lleva el péndulo de la
%            posición colgante (0, 0) a la invertida (pi, 0) con dos leyes que apuntan
%            al mismo lazo e'' + (b + k2) e' + k1 e = 0 (polos en -2, -2):
%              jacobiana:  c u = -(a + k1)(x1 - pi) - k2 x2
%              exacta:     c u =  a sin x1 - k1 (x1 - pi) - k2 x2
%            Luego repite la exacta hacia pi/2 con un modelo equivocado (a_hat = 8).
% OBSERVE    La exacta reproduce la respuesta lineal diseñada hasta la precisión del
%            integrador, desde una condición inicial lejana; la jacobiana no. Pero la
%            exacta usa a: con a mal conocido queda un error permanente.
% ESPERADO   max|x1 - predicción|: exacta 1e-11, jacobiana 1.418 rad.
%            Hacia pi/2 con a_hat = 8: x1 -> 1.1206 rad, error -25.79 grados.
% EXPLORE    ¿Por qué hacia pi el error de modelo no deja error permanente? (Mire
%            sin(pi).) Pruebe a_hat = 12 hacia pi/2.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:disenos]
a = 10;  b = 1;  c = 10;  k1 = 4;  k2 = 3;  d = pi;       % a = g/l, b = k/m, c = 1/(m l^2)
uJac = @(x) (-(a + k1)*(x(1) - d) - k2*x(2))/c;
uExa = @(x) ( a*sin(x(1)) - k1*(x(1) - d) - k2*x(2))/c;
pend = @(u) @(t, x) [x(2); -a*sin(x(1)) - b*x(2) + c*u(x)];
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);  t = linspace(0, 6, 1201);
[~, XJ] = ode45(pend(uJac), t, [0; 0], opc);
[~, XE] = ode45(pend(uExa), t, [0; 0], opc);
[~, E]  = ode45(@(t, e) [e(2); -k1*e(1) - (b + k2)*e(2)], t, [-d; 0], opc);
pred = E(:, 1) + d;
fprintf('max|x1 - predicción|: exacta %.1e rad, jacobiana %.3f rad\n', ...
        max(abs(XE(:,1) - pred)), max(abs(XJ(:,1) - pred)));
% [fin:disenos]

% [ini:robustez]
aHat = 8;  d2 = pi/2;                         % el modelo cree que a = 8
uMal = @(x) (aHat*sin(x(1)) - k1*(x(1) - d2) - k2*x(2))/c;
[~, XM] = ode45(pend(uMal), [0 20], [0; 0], opc);
fprintf('hacia pi/2 con a_hat = %g: x1 -> %.4f rad (error %.2f grados)\n', aHat, XM(end,1), ...
        rad2deg(XM(end,1) - d2));
% [fin:robustez]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1); plot(t, XJ(:,1), t, XE(:,1), t, pred, 'k--'); grid on;
xlabel('$t$ [s]'); ylabel('$x_1$ [rad]'); legend('jacobiana', 'exacta', 'predicci\''on', 'Location', 'southeast');
subplot(1, 2, 2); semilogy(t, abs(XJ(:,1) - pred) + 1e-16, t, abs(XE(:,1) - pred) + 1e-16); grid on;
xlabel('$t$ [s]'); ylabel('$|x_1 - $predicci\''on$|$');
