%% C7_Ej5_Cuadraticas -- Notas: sección 7.6 (formas cuadráticas)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Clasifica P(a) = [a 0 1; 0 a 2; 1 2 a] (la forma
%            V = a x1^2 + 2 x1 x3 + a x2^2 + 4 x2 x3 + a x3^2) con los menores
%            principales líderes y con los valores propios.
%            (2) La trampa: P = diag(0, -1) tiene menores líderes Delta1 = Delta2 = 0 >= 0
%            y no es semidefinida positiva.
% OBSERVE    Sylvester (menores líderes) vale para "> 0"; para ">= 0" hay que mirar TODOS
%            los menores principales, o los valores propios.
% ESPERADO   (1) Delta = (a, a^2, a(a^2 - 5)); eig = a, a +- sqrt(5): P > 0 sii a > sqrt(5).
%            (2) menores líderes 0, 0; menores principales 0, -1, 0.
% EXPLORE    Encuentre una P de 3 x 3 con menores líderes > 0, > 0, = 0 que sea indefinida.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:sylvester]
Pa = @(a) [a 0 1; 0 a 2; 1 2 a];
for a = [1 sqrt(5) 3]
    P = Pa(a);  D = [P(1,1) det(P(1:2,1:2)) det(P)];
    fprintf('a = %.4f: menores líderes = (%7.3f, %7.3f, %7.3f), eig = (%s)\n', ...
            a, D, num2str(sort(eig(P)).', '%7.3f '));
end
% [fin:sylvester]

% [ini:trampa]
P = diag([0 -1]);
lideres = [P(1,1) det(P)];
principales = [P(1,1) P(2,2) det(P)];
fprintf('P = diag(0,-1): líderes = (%g, %g), todos los principales = (%g, %g, %g), eig = (%g, %g)\n', ...
        lideres, principales, eig(P));
% [fin:trampa]

% ---- Figura de las notas (fig:ly-formas) ------------------------------------
% Niveles de x'Px con los mismos vectores propios, lambda1 = 2 y lambda2 = 0.5, 0, -0.8
az = [30 90 168]/255;  co = [209 73 91]/255;  ve = [42 157 143]/255;
th = pi/6;  R = [cos(th) -sin(th); sin(th) cos(th)];
[X1, X2] = meshgrid(linspace(-2, 2, 241));
l2 = [0.5 0 -0.8];
tit = {'$P>0$: elipses', '$P\geq0$ singular: franjas', '$P$ indefinida: hip\''erbolas'};
fig = estiloFigura(1200, 420);
for k = 1:3
    P = R*diag([2 l2(k)])*R';
    V = P(1,1)*X1.^2 + 2*P(1,2)*X1.*X2 + P(2,2)*X2.^2;
    subplot(1, 3, k);  hold on;
    contour(X1, X2, V, [0.25 0.5 1 2 3], 'LineColor', az, 'LineWidth', 1);
    if l2(k) < 0
        contour(X1, X2, V, [-3 -2 -1 -0.5 -0.25], 'LineColor', co, 'LineWidth', 1);
        contour(X1, X2, V, [0 0], 'LineColor', [0.6 0.6 0.6], 'LineStyle', '--', 'LineWidth', 0.8);
    end
    v = 1.8*R(:, 1);  plot([-v(1) v(1)], [-v(2) v(2)], 'k:', 'LineWidth', 0.8);   % vectores propios
    v = 1.8*R(:, 2);  plot([-v(1) v(1)], [-v(2) v(2)], ':', 'Color', ve, 'LineWidth', 0.8);
    axis equal;  axis([-2 2 -2 2]);  set(gca, 'XTick', [], 'YTick', []);  title(tit{k});
end
