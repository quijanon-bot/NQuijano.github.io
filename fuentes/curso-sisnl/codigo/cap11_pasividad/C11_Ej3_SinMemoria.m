%% C11_Ej3_SinMemoria -- Notas: sección 11.4 (pasividad sin memoria)
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

fig = estiloFigura(1100, 380);
vv = linspace(-0.12, 1, 600);
subplot(1,3,1); plot(vv, h(vv)); grid on; xlabel('$u$'); ylabel('$h(u)$'); title('diodo t\''unel');
subplot(1,3,2); plot(u, hs(u), u, 0.25*u, '--', u, 1.5*u, '--'); xlim([-2 2]); ylim([-2 2]); grid on; title('sector');
subplot(1,3,3); plot(u, sat, u, u, '--'); xlim([-3 3]); ylim([-1.5 1.5]); grid on; title('saturaci\''on');
