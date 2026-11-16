%% C8_Ej1_ConjuntosLimite -- Notas: sección 8.2 (tres conjuntos omega-límite)
% QUÉ HACE   Simula (a) el oscilador amortiguado, (b) van der Pol con mu = 1 desde (0.1, 0)
%            y (c) x1' = 0.5, x2' = -x2; marca las muestras phi_n(x0), n = 1, 2, ...
% OBSERVE    En (b) las muestras se reparten por todo el ciclo: la solución tiende al
%            CONJUNTO Gamma sin tender a ningún punto. En (c) no hay muestras acotadas.
% ESPERADO   (a) omega = {0}. (b) amplitud del ciclo 2.009 en x1. (c) omega vacío.
% EXPLORE    En (b) arranque en (4, 0), fuera del ciclo. ¿Cambia omega(x0)?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:limite]
fa = @(t, x) [x(2); -x(1) - 0.4*x(2)];                    % (a) oscilador amortiguado
fv = @(t, x) [x(2); -x(1) + (1 - x(1)^2)*x(2)];           % (b) van der Pol, mu = 1
fc = @(t, x) [0.5; -x(2)];                                % (c) sin acotación
[~, Xa] = ode45(fa, [0 30], [2; 0], opc);
[tv, Xv] = ode45(fv, [0 80], [0.1; 0], opc);
[~, Xn] = ode45(fv, 0:60, [0.1; 0], opc);                 % muestras phi_n(x0)
[~, Xc] = ode45(fc, [0 12], [-2.5; 2], opc);
fprintf('(a) x(30) = (%.1e, %.1e): omega = {0}\n', Xa(end, :));
fprintf('(b) amplitud en t in [60, 80]: max x1 = %.3f, min x1 = %.3f\n', max(Xv(tv > 60, 1)), min(Xv(tv > 60, 1)));
fprintf('(c) x1(12) = %.1f -> infinito: omega vacío\n', Xc(end, 1));
% [fin:limite]

fig = estiloFigura(1100, 380);
subplot(1, 3, 1);  plot(Xa(:, 1), Xa(:, 2));  axis equal;  grid on;  title('(a) $\omega(x_0)=\{0\}$');
subplot(1, 3, 2);  plot(Xv(:, 1), Xv(:, 2), 'Color', [0.8 0.8 0.8]);  hold on;
scatter(Xn(2:end, 1), Xn(2:end, 2), 18, 1:60, 'filled');  axis equal;  grid on;  title('(b) $\omega(x_0)=\Gamma$');
subplot(1, 3, 3);  plot(Xc(:, 1), Xc(:, 2));  grid on;  title('(c) $\omega(x_0)=\emptyset$');
