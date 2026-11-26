%% C12_Ej3_PenduloExacto -- Notas: sección 12.3 (cancelar en vez de aproximar)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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



% ---- Figura de las notas (fig:fl-pendulo) ----------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
a = 10;  b = 1;  c = 10;  k1 = 4;  k2 = 3;  oo = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
pend = @(uf) @(t, x) [x(2); -a*sin(x(1)) - b*x(2) + c*uf(x)];
te = linspace(0, 6, 1201);  tm = linspace(0, 10, 1001);
[~, PL] = ode45(pend(@(x) (-(a + k1)*(x(1) - pi) - k2*x(2))/c), te, [0; 0], oo);
[~, PF] = ode45(pend(@(x) (a*sin(x(1)) - k1*(x(1) - pi) - k2*x(2))/c), te, [0; 0], oo);
[~, PE] = ode45(@(t, e) [e(2); -k1*e(1) - (b + k2)*e(2)], te, [-pi; 0], oo);
[~, PM] = ode45(pend(@(x) (8*sin(x(1)) - k1*(x(1) - pi/2) - k2*x(2))/c), tm, [0; 0], oo);
[~, PB] = ode45(pend(@(x) (10*sin(x(1)) - k1*(x(1) - pi/2) - k2*x(2))/c), tm, [0; 0], oo);
fig = estiloFigura(1300, 440);
subplot(1, 3, 1);  hold on;  plot(te, PL(:,1), 'Color', co);  plot(te, PF(:,1), 'Color', az);
plot(te, PE(:,1) + pi, '--', 'Color', no, 'LineWidth', 1.1);  plot([0 6], [pi pi], ':', 'Color', gr);
grid on;  box on;  xlabel('$t$');  ylabel('$x_1$ [rad]');  title('Hacia $\pi$');  legend('jacobiana', 'exacta', 'dise\~no');
subplot(1, 3, 2);  semilogy(te(2:end), abs(PL(2:end,1) - PE(2:end,1) - pi) + 1e-16, 'Color', co);  hold on;
semilogy(te(2:end), abs(PF(2:end,1) - PE(2:end,1) - pi) + 1e-16, 'Color', az);
ylim([1e-14 10]);  grid on;  box on;  xlabel('$t$');  title('$|x_1-$dise\~no$|$');
subplot(1, 3, 3);  hold on;  plot(tm, rad2deg(PB(:,1)), 'Color', az);  plot(tm, rad2deg(PM(:,1)), 'Color', vi);
plot([0 10], [90 90], ':', 'Color', gr);  grid on;  box on;  xlabel('$t$');  ylabel('$x_1$ [$^\circ$]');
title('Hacia $\pi/2$: modelo malo');  legend('$\hat a=a$', '$\hat a=8$', 'Location', 'southeast');
