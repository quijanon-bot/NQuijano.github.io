%% C10_Ej13_RedisenoISS -- Notas: sección 10.6 (estabilizar no es robustecer)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Para x' = x + (x^2 + 1)(u + w), con w un error aditivo en el actuador:
%            (1) cancelación exacta k = -2x/(x^2+1), con w = 1 desde x(0) = 0;
%            (2) rediseño k1 = k - L_gV, V = x^2/2, con w = 1;
%            (3) Sontag con kappa = 1, con w = 1;
%            (4) cancelación con w = 0.1: equilibrios x_- y x_+ y escape desde 10.5.
% OBSERVE    La cancelación escapa aun desde el equilibrio; las otras dos leyes quedan
%            acotadas. Con w pequeño, la cancelación tiene un umbral x_+ ~ 1/w.
% ESPERADO   Escape en 4 pi/(3 sqrt 3) = 2.418; k1: x -> 0.4887; Sontag: x -> 0.386;
%            w = 0.1: x_- = 0.101, x_+ = 9.90.
% EXPLORE    Repita (2) con V2 = ln(1 + x^2)/2, para la cual L_gV2 = x. ¿Dónde se asienta x?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:rediseno]
k  = @(x) -2*x/(x^2 + 1);
k1 = @(x) k(x) - x*(x^2 + 1);                            % - L_gV con V = x^2/2
kS = @(x) leySontag(x^2, x*(x^2 + 1), 1);                % Sontag con kappa = 1
planta = @(x, u, w) x + (x^2 + 1)*(u + w);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, x) eventoODE(x - 1e6, 1, 1));
[~, ~, te] = ode45(@(t, x) planta(x, k(x), 1), [0 5], 0, opc);
fprintf('cancelación, w = 1: escapa en t = %.4f (4 pi/(3 sqrt3) = %.4f)\n', te, 4*pi/(3*sqrt(3)));
[~, X1] = ode45(@(t, x) planta(x, k1(x), 1), [0 10], 0, opc);
[~, XS] = ode45(@(t, x) planta(x, kS(x), 1), [0 10], 0, opc);
fprintf('con -L_gV, w = 1: x(10) = %.4f;  Sontag kappa = 1: x(10) = %.4f\n', X1(end), XS(end));
e = 0.1;  xm = (1 - sqrt(1 - 4*e^2))/(2*e);  xp = (1 + sqrt(1 - 4*e^2))/(2*e);
[~, ~, te2] = ode45(@(t, x) planta(x, k(x), e), [0 5], 10.5, opc);
fprintf('cancelación, w = 0.1: x_- = %.4f, x_+ = %.4f; desde 10.5 escapa en t = %.3f\n', xm, xp, te2);
% [fin:rediseno]

% ---- Figura de las notas (fig:av-rediseno) --------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
o30 = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.01, 'Events', @(t, x) eventoODE(x - 30, 1, 1));
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;
[tc, Xc] = ode45(@(t, x) planta(x, k(x), 1), [0 6], 0, o30);  plot(tc, Xc, 'Color', co);
[t1, X1f] = ode45(@(t, x) planta(x, k1(x), 1), [0 6], 0, o30);  plot(t1, X1f, 'Color', az);
plot(4*pi/(3*sqrt(3))*[1 1], [-0.5 10], ':', 'Color', co, 'LineWidth', 1);
text(2.5, 8, '$t_e=2.42$', 'Color', co);  text(3.3, 1.2, sprintf('$x\\to%.4f$', X1f(end)), 'Color', az);
axis([0 6 -0.5 10]);  grid on;  box on;  xlabel('$t$');  ylabel('$x$');
legend('cancelaci\''on', 'con $-L_gV$', 'Location', 'northwest');  title('$w\equiv1$, $x(0)=0$');
subplot(1, 2, 2);  hold on;
for x0 = [0 5 9.5 10.3 12]
    [tq, Xq] = ode45(@(t, x) planta(x, k(x), e), [0 8], x0, o30);
    if x0 < xp, c = az; else, c = co; end
    plot(tq, Xq, 'Color', c, 'LineWidth', 1.2);
end
plot([0 8], [xm xm], '--', 'Color', ve, 'LineWidth', 1);  plot([0 8], [xp xp], '--', 'Color', no, 'LineWidth', 1);
text(5.5, xm + 0.5, sprintf('$x_-=%.3f$', xm), 'Color', ve);  text(5.5, xp + 0.5, sprintf('$x_+=%.2f$', xp));
axis([0 8 -0.5 16]);  grid on;  box on;  xlabel('$t$');  title('cancelaci\''on, $w\equiv0.1$');
