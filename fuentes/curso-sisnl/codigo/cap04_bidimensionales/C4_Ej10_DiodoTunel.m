%% C4_Ej10_DiodoTunel -- Notas: sección 4.6 (el diodo túnel con su inductancia)
% QUÉ HACE   Circuito de Khalil (sec. 1.2.2): x1 = vC (V), x2 = iL (mA), t en ns,
%              x1' = (-h(x1) + x2)/C,   x2' = (-x1 - R x2 + E)/L,
%            con E = 1.2, R = 1.5, C = 2, L = 5. Equilibrios, jacobianas, la variedad
%            estable de la silla Q2 y el retrato.
% OBSERVE    La silla aparece donde h'(v) < -1/R, como en el capítulo 2. La variedad
%            estable de Q2 (negro) separa las cuencas de Q1 y Q3: desde vC = 0.4 V el
%            final depende de iL(0).
% ESPERADO   Q1 = (0.063, 0.758) nodo estable (-3.59, -0.33); Q2 = (0.285, 0.610)
%            silla (1.77, -0.25); Q3 = (0.884, 0.210) nodo estable (-1.34, -0.40).
%            Desde (0.4, 0) -> Q1;  desde (0.4, 0.3) -> Q3.
% EXPLORE    Cambie L a 50 y a 0.5. ¿Cambian los equilibrios? ¿Y la variedad estable?
%            ¿Qué pasa cuando L -> 0? (Compare con el modelo de primer orden.)
clear; close all; clc;
raiz = fileparts(mfilename('fullpath'));
if ~exist('estiloFigura', 'file'), addpath(fullfile(raiz, '..', 'comun')); end
if ~exist('diodoTunel', 'file'), addpath(fullfile(raiz, '..', 'cap02_unidimensionales')); end

% [ini:diodo]
[h, dh] = diodoTunel();
E = 1.2;  R = 1.5;  C = 2;  L = 5;
f = @(x) [(-h(x(1)) + x(2))/C; (-x(1) - R*x(2) + E)/L];
Q = zeros(2, 3);  semillas = [0.06 0.28 0.88];
for k = 1:3
    v = fzero(@(v) h(v) - (E - v)/R, semillas(k));  Q(:, k) = [v; (E - v)/R];
    A = [-dh(v)/C, 1/C; -1/L, -R/L];
    fprintf('Q%d = (%.4f, %.4f): h''(v) = %6.3f, %-14s lambda = %s\n', k, Q(:, k), dh(v), ...
            clasificarEquilibrio(A), num2str(eig(A).', '%.3f  '));
end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
for i0 = [0 0.3]
    [~, X] = ode45(@(t, x) f(x), [0 300], [0.4; i0], opc);
    fprintf('desde (0.4, %.1f): termina en (%.3f, %.3f)\n', i0, X(end, :));
end
% [fin:diodo]

fig = estiloFigura(800, 600);  ax = gca;
retratoFase(ax, f, [-0.4 1.6], [-0.4 1.5], 'T', 80, 'Equilibrios', Q);
vv = linspace(-0.4, 1.6, 400);
plot(ax, vv, h(vv), '--', 'Color', [209 73 91]/255);  plot(ax, vv, (E - vv)/R, '--', 'Color', [224 159 62]/255);
ramas = variedadSilla(f, Q(:, 2), 'estable', 60, 1e-5, [-0.4 1.6 -0.4 1.5]);
for r = 1:2, plot(ax, ramas{r}(:, 1), ramas{r}(:, 2), 'k', 'LineWidth', 2.5); end
xlabel('$x_1=v_C$ (V)');  ylabel('$x_2=i_L$ (mA)');  title('Diodo t\''unel con inductancia');
