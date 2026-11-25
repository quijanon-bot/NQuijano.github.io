%% C9_Ej11_VanDerPol -- Notas: sección 9.7 (inestable no es no acotado)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Van der Pol con mu = 1: mide el rango de ||x|| sobre el ciclo límite y el
%            tiempo que tarda en salir de la bola unitaria la solución desde (delta, 0).
% OBSERVE    El origen es inestable y todas las soluciones están acotadas.
% ESPERADO   1.53 <= ||x|| <= 2.83 en el ciclo; salida en t = 8.90, 18.97, 27.23 para
%            delta = 1e-2, 1e-4, 1e-6 (aprox. 2 ln(1/delta)).
% EXPLORE    Cambie mu por 0.2. ¿Cómo cambia el tiempo de salida? Relaciónelo con la parte
%            real de los valores propios del origen.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-14);

% [ini:vdp]
f = @(t, x) [x(2); -x(1) + (1 - x(1)^2)*x(2)];
[t, X] = ode45(f, linspace(0, 100, 100001), [2; 0], opc);
nx = sqrt(sum(X(t > 60, :).^2, 2));
fprintf('ciclo: %.3f <= ||x|| <= %.3f\n', min(nx), max(nx));
sal = odeset(opc, 'Events', @(t, x) eventoODE(norm(x) - 1, 1, 1));
for d = [1e-2 1e-4 1e-6]
    [te, ~] = ode45(f, [0 100], [d; 0], sal);
    fprintf('delta = %.0e: sale de B_1 en t = %.2f   (2 ln(1/delta) = %.2f)\n', d, te(end), 2*log(1/d));
end
% [fin:vdp]

% ---- Figura de las notas (fig:vt-vdp) --------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
fig = estiloFigura(1200, 460);  ds = [1e-2 1e-4 1e-6];  cl3 = [az; ve; co];  t = linspace(0, 45, 9000);
subplot(1, 2, 1);  hold on;  grid on;  th = linspace(0, 2*pi, 200);  plot(cos(th), sin(th), ':', 'Color', gr);
[~, Y] = ode45(f, t, [-2.5; 2.5], opc);  plot(Y(:, 1), Y(:, 2), 'Color', gr, 'LineWidth', 0.8);    % desde fuera del ciclo
for j = 1:3
    [~, Y] = ode45(f, t, [ds(j); 0], opc);  plot(Y(:, 1), Y(:, 2), 'Color', cl3(j, :), 'LineWidth', 0.8);
    nrm{j} = sqrt(sum(Y.^2, 2));
end
plot(0, 0, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', no);
axis equal;  axis([-3 3 -3 3]);  box on;  xlabel('$x_1$');  ylabel('$x_2$');  title('inestable, y todo queda acotado');
subplot(1, 2, 2);
for j = 1:3, semilogy(t, nrm{j}, 'Color', cl3(j, :), 'LineWidth', 1.2);  hold on;  end
semilogy([0 45], [1 1], ':', 'Color', gr);  grid on;  xlabel('$t$');  ylabel('$\|x(t)\|$');
legend('$x_0=(0.01,0)$', '$x_0=(10^{-4},0)$', '$x_0=(10^{-6},0)$', 'Location', 'southeast');
title('salida de $B_1$ en $t\approx2\ln(1/\delta)$');
