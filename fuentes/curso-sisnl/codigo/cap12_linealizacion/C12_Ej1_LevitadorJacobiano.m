%% C12_Ej1_LevitadorJacobiano -- Notas: sección 12.2 (método 1: linealización jacobiana)
% QUÉ HACE   Calcula el equilibrio del levitador en y = 0.05 m, muestra que es inestable
%            para todo punto de operación, diseña u = u* - K (x - x*) sobre la
%            linealización jacobiana y compara la planta no lineal con la predicción
%            del modelo lineal para cuatro condiciones iniciales.
% OBSERVE    Cerca del equilibrio la predicción lineal es casi exacta; lejos, el error
%            crece y el voltaje pedido también. El teorema (método indirecto) garantiza
%            estabilidad LOCAL y no dice cuán grande es la región de atracción.
% ESPERADO   x3* = u* = 6.2642. Valores propios de A: 13.641, -14.813, -38.838.
%            K = [-237.17  -16.013  0.87475]. Error máximo de y frente a la predicción:
%            2.8e-5 m (y0 = 0.045), 1.0 mm (0.08), 1.3 mm (0.01), 1.07 cm (0.15);
%            voltaje máximo con y0 = 0.15: 29.98 V.
% EXPLORE    Suba y0 a 0.2 y a 0.25. ¿Sigue siendo estable el lazo? Cambie los polos a
%            [-5 -6 -7]: ¿crece o se achica el error de la aproximación?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
P = parametrosLevitador();

% [ini:equilibrio]
yb = 0.05;                                  % punto de operación [m]
[xs, us] = equilibrioLevitador(yb, P);
[A, B] = jacobianoLevitador(yb, P);
fprintf('equilibrio: x* = (%.3f, %g, %.4f),  u* = %.4f V\n', xs, us);
fprintf('valores propios de A: %s\n', mat2str(eig(A).', 5));
% [fin:equilibrio]

% [ini:inestable]
ys = linspace(0.005, 0.3, 60);  lmax = zeros(size(ys));
for i = 1:numel(ys), lmax(i) = max(real(eig(jacobianoLevitador(ys(i), P)))); end
fprintf('mayor parte real en [0.005, 0.3]: entre %.2f y %.2f (siempre > 0)\n', min(lmax), max(lmax));
% [fin:inestable]

% [ini:realimentacion]
K = ubicarPolos(A, B, [-20 -25 -30]);      % equivale a place(A, B, ...)
fprintf('K = %s,  eig(A - BK) = %s\n', mat2str(K, 5), mat2str(sort(eig(A - B*K)).', 4));
% [fin:realimentacion]

% [ini:comparacion]
Acl = A - B*K;  t = linspace(0, 0.6, 1201);
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 1e-3);
y0s = [0.045 0.08 0.01 0.15];  Y = zeros(numel(t), 4);  YL = Y;
for j = 1:4
    x0 = [y0s(j); 0; xs(3)];
    [~, X] = ode45(@(t, x) modeloLevitador(x, us - K*(x - xs), P), t, x0, opc);
    U = us - (X - xs.')*K.';
    for i = 1:numel(t), d = expm(Acl*t(i))*(x0 - xs); YL(i, j) = d(1) + yb; end
    Y(:, j) = X(:, 1);
    fprintf('y0 = %.3f:  max|y - y_lin| = %.2e m,  max u = %5.2f V\n', y0s(j), max(abs(Y(:,j) - YL(:,j))), max(U));
end
% [fin:comparacion]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1); plot(ys, lmax); grid on; xlabel('$\bar y$ [m]'); ylabel('$\max\,\mathrm{Re}\,\lambda(A)$');
title('El equilibrio es inestable en todo punto');
subplot(1, 2, 2); hold on;
for j = 1:4, h = plot(t, Y(:, j)); plot(t, YL(:, j), '--', 'Color', get(h, 'Color')); end
set(gca, 'YDir', 'reverse'); grid on; xlabel('$t$ [s]'); ylabel('$y$ [m]');
title('Planta (---) y predicci\''on lineal (- -)');
