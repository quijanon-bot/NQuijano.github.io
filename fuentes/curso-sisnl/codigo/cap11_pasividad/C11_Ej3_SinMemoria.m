%% C11_Ej3_SinMemoria -- Notas: sección 11.4 (pasividad sin memoria)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Revisa la pasividad de tres no linealidades estáticas y = h(u):
%            el diodo túnel de Khalil (ej. 1.2.2), una curva en el sector
%            [0.25, 1.5] y la saturación.
% OBSERVE    El diodo túnel tiene pendiente NEGATIVA entre v1 y v2 y aun así
%            u h(u) >= 0: la pasividad mira el signo de la potencia, no la pendiente.
% ESPERADO   min u h(u) >= 0;  pendiente negativa en (0.1381, 0.6601) V;
%            h(0.6601) = 0.0683 mA > 0;  u sat(u) >= sat(u)^2 (OSP con rho(y) = y).
% EXPLORE    Desplace la curva del diodo: h(v) - 0.1. ¿Sigue siendo pasiva?
%            ¿En qué cuadrantes cae una parte de la gráfica?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:diodo]
h  = @(v) 17.76*v - 103.79*v.^2 + 229.62*v.^3 - 226.31*v.^4 + 83.72*v.^5;   % mA
dh = @(v) 17.76 - 207.58*v + 688.86*v.^2 - 905.24*v.^3 + 418.6*v.^4;
v  = linspace(-1.5, 1.5, 300001);
fprintf('min de u h(u) en [-1.5, 1.5]: %.3g  (>= 0: pasivo)\n', min(v.*h(v)));
v1 = fzero(dh, [0.1 0.4]);  v2 = fzero(dh, [0.4 0.9]);
fprintf('pendiente negativa entre v1 = %.4f y v2 = %.4f;  h(v2) = %.4f > 0\n', v1, v2, ...
        h(v2));
% [fin:diodo]

% [ini:sector]
u = linspace(-5, 5, 10001);
sat = max(min(u, 1), -1);
fprintf('min de u sat(u) - sat(u)^2: %.3g  (>= 0: OSP con rho(y) = y)\n', ...
        min(u.*sat - sat.^2));
hs = @(u) 0.9*u + 0.25*sin(2*u);                % ¿en qué sector está?
r  = hs(u(u ~= 0))./u(u ~= 0);
fprintf('h(u)/u entre %.3f y %.3f: sector [%.2f, %.2f]\n', min(r), max(r), min(r), max(r));
% [fin:sector]

% ---- Figura de las notas (fig:pa-sinmemoria) -------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
hd = @(v) 17.76*v - 103.79*v.^2 + 229.62*v.^3 - 226.31*v.^4 + 83.72*v.^5;
fig = estiloFigura(1300, 440);
lims = [-0.12 1.0 -1.2 1.0; -2 2 -2 2; -3 3 -1.4 1.4];
for j = 1:3
    subplot(1, 3, j);  hold on;
    patch([0 10 10 0], [0 0 10 10], claro(az, 0.07), 'EdgeColor', 'none');
    patch([0 -10 -10 0], [0 0 -10 -10], claro(az, 0.07), 'EdgeColor', 'none');
    plot([-10 10], [0 0], 'Color', gr, 'LineWidth', 0.6);  plot([0 0], [-10 10], 'Color', gr, 'LineWidth', 0.6);
end
subplot(1, 3, 1);  v = linspace(-0.12, 1.0, 600);
plot(v, hd(v), 'Color', co);
plot([0.45 0.42], [0.58 hd(0.42)], 'Color', gr, 'LineWidth', 0.8);
text(0.45, 0.68, {'pendiente', 'negativa'}, 'FontSize', 9, 'Color', no);
ylabel('$y=h(u)$');  title('diodo t\''unel: pasivo');
subplot(1, 3, 2);  u = linspace(-2, 2, 400);  al = 0.25;  be = 1.5;
rell(u, al*u, be*u, claro(ve, 0.18));
plot(u, al*u, 'Color', ve, 'LineWidth', 1);  plot(u, be*u, 'Color', ve, 'LineWidth', 1);
plot(u, 0.9*u + 0.25*sin(2*u), 'Color', vi);  title('sector $[\alpha,\beta]$');
subplot(1, 3, 3);  u = linspace(-3, 3, 400);
rell(u, 0*u, u, claro(ve, 0.18));
plot(u, max(min(u, 1), -1), 'Color', az);  plot(u, u, 'Color', ve, 'LineWidth', 1);
title('saturaci\''on: sector $[0,1]$');
for j = 1:3
    subplot(1, 3, j);  axis(lims(j,:));  grid on;  box on;  xlabel('$u$');
end
