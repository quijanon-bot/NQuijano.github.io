%% C12_Ej1_LevitadorJacobiano -- Notas: sección 12.2 (método 1: linealización jacobiana)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% [ini:retroalimentacion]
K = ubicarPolos(A, B, [-20 -25 -30]);      % equivale a place(A, B, ...)
fprintf('K = %s,  eig(A - BK) = %s\n', mat2str(K, 5), mat2str(sort(eig(A - B*K)).', 4));
% [fin:retroalimentacion]

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



% ---- Figura de las notas (fig:fl-inestable) --------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
P = parametrosLevitador();  opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 1e-3);
[A5, B5] = jacobianoLevitador(0.05, P);  K5 = ubicarPolos(A5, B5, [-20 -25 -30]);
xs = equilibrioLevitador(0.05, P);  us = P.R*xs(3);  KFL = [6000 1100 60];
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  ys = linspace(0.005, 0.3, 150);  ev = zeros(150, 3);
for j = 1:150, Aj = jacobianoLevitador(ys(j), P);  ev(j,:) = sort(real(eig(Aj))).'; end
cs = [az; vi; co];
for j = 1:3, plot(ys, ev(:,j), 'Color', cs(j,:)); end
plot([0 0.3], [0 0], 'Color', gr, 'LineWidth', 0.7);  plot([0.05 0.05], [-45 20], ':', 'Color', gr, 'LineWidth', 0.8);
grid on;  box on;  xlabel('punto de operaci\''on $\bar y$ [m]');  ylabel('Re $\lambda(A(\bar y))$');
title('Siempre un valor propio positivo');
subplot(1, 2, 2);  hold on;  ii = linspace(-8, 8, 300);  yy = [0.03 0.05 0.1];  cs = [az; co; vi];  h = zeros(1, 3);
for j = 1:3, h(j) = plot(ii, -P.L0*P.a*ii/(P.m*(P.a + yy(j))^2*P.L(yy(j))), 'Color', cs(j,:)); end
plot([-8 8], [0 0], 'Color', gr, 'LineWidth', 0.7);  plot([0 0], [-250 250], 'Color', gr, 'LineWidth', 0.7);
[~, ~, b5] = leyExactaLevitador(xs, [0.05 0 0 0], KFL, P);  plot(xs(3), b5, 'o', 'Color', no, 'MarkerFaceColor', no, 'MarkerSize', 4);
ylim([-250 250]);  grid on;  box on;  xlabel('corriente $i=x_3$ [A]');  ylabel('$b(x)=L_gL_f^2h$');
title('$b=0$ cuando $i=0$');  legend(h, '$y=0.03$', '$y=0.05$', '$y=0.1$', 'Location', 'northeast');

% ---- Figura de las notas (fig:fl-jacobiana) --------------------------------------------------
fig2 = estiloFigura(1200, 460);  Acl = A5 - B5*K5;  te = linspace(0, 0.6, 1201);
y0s = [0.045 0.08 0.01 0.15];  cs = [ve; az; vi; co];  h = zeros(1, 4);
for j = 1:4
    x0 = [y0s(j); 0; xs(3)];
    [~, X] = ode45(@(t, x) modeloLevitador(x, us - K5*(x - xs), P), te, x0, opc);
    yl = zeros(numel(te), 1);
    for i = 1:numel(te), d = expm(Acl*te(i))*(x0 - xs);  yl(i) = d(1) + 0.05; end
    subplot(1, 2, 1);  h(j) = plot(te, 100*X(:,1), 'Color', cs(j,:));  hold on;
    plot(te, 100*yl, '--', 'Color', cs(j,:), 'LineWidth', 1.1);
    subplot(1, 2, 2);  semilogy(te(2:end), abs(X(2:end,1) - yl(2:end)) + 1e-12, 'Color', cs(j,:));  hold on;
end
subplot(1, 2, 1);  set(gca, 'YDir', 'reverse');  grid on;  box on;  xlabel('$t$ [s]');  ylabel('$y$ [cm]');
title('Planta (---) y predicci\''on lineal (- -)');
legend(h, '$y_0=0.045$', '$y_0=0.08$', '$y_0=0.01$', '$y_0=0.15$', 'NumColumns', 2);
subplot(1, 2, 2);  ylim([1e-8 0.05]);  grid on;  box on;  xlabel('$t$ [s]');  ylabel('$|y-y_{\mathrm{lin}}|$ [m]');
title('El error crece lejos de $x^*$');
