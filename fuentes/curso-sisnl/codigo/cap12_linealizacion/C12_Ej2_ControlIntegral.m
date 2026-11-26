%% C12_Ej2_ControlIntegral -- Notas: sección 12.2 (método 2: control integral)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Agrega el integrador sigma' = y - yb al levitador y estabiliza el sistema
%            aumentado con u = -K1 x - K2 sigma (más el valor nominal). En t = 0.5 s la
%            masa real pasa de 0.10 a 0.12 kg; los dos controladores usan el modelo nominal.
% OBSERVE    La retroalimentación de estados queda con un error permanente de ~1 cm; con el
%            integrador el error se anula y el voltaje se reajusta solo al valor que la
%            planta REAL necesita: en el equilibrio, sigma' = 0 obliga a y = yb.
% ESPERADO   rango [A B; C 0] = 4.  Error final: 1.0329 cm (estados), < 1e-9 (integral).
%            Voltaje final con integrador: 6.8621 V = R x3* calculado con m = 0.12.
% EXPLORE    Ponga la carga en 0.15 kg. ¿Sigue funcionando el integrador? Cambie los polos
%            aumentados a [-3 -4 -5 -6]: ¿qué pasa con la región en la que funciona?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
P = parametrosLevitador();  yb = 0.05;
[xs, us] = equilibrioLevitador(yb, P);  [A, B] = jacobianoLevitador(yb, P);  C = [1 0 0];

% [ini:rango]
fprintf('rango [A B; C 0] = %d (debe ser n + p = 4)\n', rank([A B; C 0]));
Aa = [A zeros(3, 1); C 0];  Ba = [B; 0];
Ka = ubicarPolos(Aa, Ba, [-15 -20 -25 -30]);  K1 = Ka(1:3);  K2 = Ka(4);
K  = ubicarPolos(A, B, [-20 -25 -30]);
fprintf('K1 = %s,  K2 = %.2f\n', mat2str(K1, 5), K2);
% [fin:rango]

% [ini:carga]
mReal = @(t) 0.10 + 0.02*(t >= 0.5);            % la carga que el modelo no conoce
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 1e-3);
t = linspace(0, 3, 3001);
[~, X1] = ode45(@(t, x) modeloLevitador(x, us - K*(x - xs), P, mReal(t)), t, xs, opc);
lazo = @(t, z) [modeloLevitador(z(1:3), us - K1*(z(1:3) - xs) - K2*z(4), P, mReal(t)); z(1) - yb];
[~, Z2] = ode45(lazo, t, [xs; 0], opc);
U1 = us - (X1 - xs.')*K.';  U2 = us - (Z2(:,1:3) - xs.')*K1.' - K2*Z2(:,4);
fprintf('error final: estados = %.4f cm,  integral = %.1e m\n', 100*(X1(end,1) - yb), Z2(end,1) - yb);
fprintf('voltaje final con integrador = %.4f V;  R x3* con m = 0.12: %.4f V\n', U2(end), ...
        P.R*sqrt(2*P.g*0.12/(P.L0*P.a))*(P.a + yb));
% [fin:carga]



% ---- Figura de las notas (fig:fl-integral) ---------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
P = parametrosLevitador();  opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 1e-3);
[A5, B5] = jacobianoLevitador(0.05, P);  K5 = ubicarPolos(A5, B5, [-20 -25 -30]);
xs = equilibrioLevitador(0.05, P);  us = P.R*xs(3);  KFL = [6000 1100 60];
Aa = [A5 zeros(3, 1); 1 0 0 0];  Ba = [B5; 0];  Ka = ubicarPolos(Aa, Ba, [-15 -20 -25 -30]);
mt = @(t) 0.1 + 0.02*(t >= 0.5);  te = linspace(0, 2, 2001);
[~, X1] = ode45(@(t, x) modeloLevitador(x, us - K5*(x - xs), P, mt(t)), te, xs, opc);
[~, Z2] = ode45(@(t, z) [modeloLevitador(z(1:3), us - Ka(1:3)*(z(1:3) - xs) - Ka(4)*z(4), P, mt(t)); z(1) - 0.05], te, [xs; 0], opc);
u1 = us - (X1 - xs.')*K5.';  u2 = us - (Z2(:,1:3) - xs.')*Ka(1:3).' - Ka(4)*Z2(:,4);
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  h = [plot(te, 100*X1(:,1), 'Color', co), plot(te, 100*Z2(:,1), 'Color', az)];
plot([0 2], [5 5], ':', 'Color', gr);  plot([0.5 0.5], [4.6 6.2], ':', 'Color', gr, 'LineWidth', 0.8);
set(gca, 'YDir', 'reverse');  grid on;  box on;  xlabel('$t$ [s]');  ylabel('$y$ [cm]');
title('Masa real 0.12 kg desde $t=0.5$');  legend(h, 'estados', 'con integrador', 'Location', 'southeast');
subplot(1, 2, 2);  hold on;  plot(te, u1, 'Color', co);  plot(te, u2, 'Color', az);
plot([0 2], [1 1]*P.R*sqrt(2*P.g*0.12/(P.L0*P.a))*0.1, ':', 'Color', gr);
grid on;  box on;  xlabel('$t$ [s]');  ylabel('$u$ [V]');  title('El integrador encuentra el voltaje');
