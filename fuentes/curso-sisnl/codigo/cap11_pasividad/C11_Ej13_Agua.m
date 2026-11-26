%% C11_Ej13_Agua -- Notas: sección 11.10 (distribución de agua con el replicador)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Tres tanques (Torricelli) alimentados por un caudal total Q que se
%            reparte con la dinámica del replicador (modeloAgua.m). En t = 40 s la
%            demanda del tanque 3 sube de c3 = 1.4 a c3 = 2.0.
% OBSERVE    sum q_i = Q todo el tiempo (el replicador solo redistribuye).
%            V = V1 + V2 (energiaAgua.m), calculada respecto al equilibrio vigente,
%            decrece; salta en t = 40 s y vuelve a decrecer.
% ESPERADO   antes: v* = 4/9 = 0.4444, q* = (0.400, 0.667, 0.933);
%            después: v* = 0.3086, q* = (0.333, 0.556, 1.111).
% EXPLORE    Ponga r = 0.5: ¿converge más lento o más rápido? ¿Por qué?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:equilibrio]
Q = 2;  r = 2;  vm = 2;
c1 = [0.6; 1.0; 1.4];   c2 = [0.6; 1.0; 2.0];
for c = [c1 c2]
    vs = Q^2/sum(c)^2;   qs = c*Q/sum(c);
    fprintf('c = %s:  v* = %.4f   q* = %s   (v* < vm: %d)\n', mat2str(c.', 2), vs, ...
            mat2str(qs.', 3), vs < vm);
end
% [fin:equilibrio]

% [ini:simulacion]
x0  = [0.1; 0.8; 0.3; 0.9; 0.6; 0.5];           % [v; q], con sum q = Q
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t1, X1] = ode45(@(t, x) modeloAgua(x, c1, Q, r, vm), linspace(0, 40, 4001), x0, opc);
[t2, X2] = ode45(@(t, x) modeloAgua(x, c2, Q, r, vm), linspace(40, 80, 4001), ...
        X1(end,:).', opc);
[V1a, V2a] = energiaAgua(X1, c1, Q, r, vm);
[V1b, V2b] = energiaAgua(X2, c2, Q, r, vm);
t = [t1; t2];   X = [X1; X2];   V = [V1a + V2a; V1b + V2b];
fprintf('max |sum q - Q| = %.1e\n', max(abs(sum(X(:,4:6), 2) - Q)));
fprintf('¿V no creciente en cada tramo? %d %d\n', all(diff(V1a + V2a) <= 1e-9), ...
        all(diff(V1b + V2b) <= 1e-9));
fprintf('v(80) = %s   q(80) = %s\n', mat2str(X(end,1:3), 4), mat2str(X(end,4:6), 4));
% [fin:simulacion]

% ---- Figura de las notas (fig:pa-agua y fig:pa-psi) ------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
Q = 2;  r = 2;  vm = 2;  c1 = [0.6; 1.0; 1.4];  c2 = [0.6; 1.0; 2.0];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t1, X1] = ode45(@(t, x) modeloAgua(x, c1, Q, r, vm), linspace(0, 40, 4001), [0.1; 0.8; 0.3; 0.9; 0.6; 0.5], opc);
[t2, X2] = ode45(@(t, x) modeloAgua(x, c2, Q, r, vm), linspace(0, 40, 4001), X1(end,:).', opc);
[a1, b1] = energiaAgua(X1, c1, Q, r, vm);  [a2, b2] = energiaAgua(X2(2:end,:), c2, Q, r, vm);
t = [t1; 40 + t2(2:end)];  X = [X1; X2(2:end,:)];  V = [a1 + b1; a2 + b2];
fig = estiloFigura(1300, 440);  cs = [az; co; vi];
for j = 1:3, subplot(1, 3, j);  hold on;  end
hv = zeros(1, 3);  hq = hv;
for i = 1:3
    subplot(1, 3, 1);  hv(i) = plot(t, X(:,i), 'Color', cs(i,:));
    subplot(1, 3, 2);  hq(i) = plot(t, X(:,3+i), 'Color', cs(i,:));
end
subplot(1, 3, 1);  plot([0 40], [4/9 4/9], '--', 'Color', gr, 'LineWidth', 0.8);
plot([40 80], [1 1]*4/12.96, '--', 'Color', gr, 'LineWidth', 0.8);
title('vol\''umenes');  legend(hv, '$v_1$', '$v_2$', '$v_3$');
subplot(1, 3, 2);  title('caudales ($\sum q_i=Q$)');  legend(hq, '$q_1$', '$q_2$', '$q_3$');
subplot(1, 3, 3);  semilogy(t, V, 'Color', no);  set(gca, 'YScale', 'log');  title('$V=V_1+V_2$ (eq. vigente)');   % (con hold on, semilogy no cambia la escala)
for j = 1:3
    subplot(1, 3, j);  yl = ylim;  plot([40 40], yl, 'Color', am, 'LineWidth', 1.2, 'HandleVisibility', 'off');  ylim(yl);
    grid on;  box on;  xlabel('$t$ (s)');
end
fig2 = estiloFigura(620, 440);  hold on;  vs = 4/9;  vt = linspace(-vs, 1.2, 400);
for i = 1:3, plot(vt, c1(i)*vt.*(sqrt(vs) - sqrt(vt + vs)), 'Color', cs(i,:)); end
plot([-1 2], [0 0], 'Color', gr, 'LineWidth', 0.6);  plot([0 0], [-2 1], 'Color', gr, 'LineWidth', 0.6);
axis([-vs 1.2 -1.1 0.15]);  grid on;  box on;  xlabel('$\tilde v_i$');  title('$\psi_i(\tilde v_i)\leq 0$');
legend('$c_i=0.6$', '$c_i=1$', '$c_i=1.4$');
