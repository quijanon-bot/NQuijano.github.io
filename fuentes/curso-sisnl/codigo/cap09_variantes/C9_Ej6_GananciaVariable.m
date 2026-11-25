%% C9_Ej6_GananciaVariable -- Notas: sección 9.5 (una ganancia variable)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   x1' = -x1 - g(t) x2, x2' = x1 - x2 con V = x1^2 + (1 + g) x2^2. Compara
%            ||x(t)|| con la cota sqrt(1 + k) exp(-(t - t0)/(2(1 + k))) y grafica el
%            coeficiente 2 + 2g - g' para una g lenta y una rápida.
% OBSERVE    Con g' <= g la cota se cumple con holgura; con la g rápida el coeficiente se
%            vuelve negativo y V deja de ser certificado (no por eso el sistema es inestable).
% ESPERADO   Peor cociente ||x||/cota = 0.63; coeficiente -2 en t = 0 con la g rápida.
% EXPLORE    Calcule los multiplicadores de Floquet con la g rápida (problema de la ganancia rápida).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:ganancia]
k = 1.5;  g = @(t) 1 + 0.5*sin(t);  gp = @(t) 0.5*cos(t);
fprintf('min (g - g'') = %.3f  (>= 0)\n', min(g(linspace(0, 2*pi, 1e5)) - gp(linspace(0, 2*pi, 1e5))));
peor = 0;
for t0 = [0 3 7]
    for th = linspace(0, pi, 7)
        q = linspace(t0, t0 + 20, 2001);
        [~, X] = ode45(@(t, x) [-x(1) - g(t)*x(2); x(1) - x(2)], q, [cos(th); sin(th)], opc);
        cota = sqrt(1 + k)*exp(-(q' - t0)/(2*(1 + k)));
        peor = max(peor, max(sqrt(sum(X.^2, 2))./cota));
    end
end
fprintf('peor ||x(t)||/cota = %.3f  (<= 1)\n', peor);
gr = @(t) (1 + sin(10*t))/2;  grp = @(t) 5*cos(10*t);
fprintf('g rápida: 2 + 2g - g'' en t = 0 vale %.1f\n', 2 + 2*gr(0) - grp(0));
% [fin:ganancia]

% ---- Figura de las notas (fig:vt-ganancia) --------------------------------------
gRap = gr;  gRapp = grp;                                   % la paleta usa el nombre gr (gris)
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
cols = [az; ve; am; vi; co];
fig = estiloFigura(1200, 450);
subplot(1, 2, 1);  ths = linspace(0, pi, 6);  ths = ths(1:5);  t = linspace(0, 20, 2000);
for j = 1:5
    [~, X] = ode45(@(t, x) [-x(1) - g(t)*x(2); x(1) - x(2)], t, [cos(ths(j)); sin(ths(j))], opc);
    semilogy(t, sqrt(sum(X.^2, 2)), 'Color', cols(j, :), 'LineWidth', 1.2);  hold on;
end
hc = semilogy(t, sqrt(1 + k)*exp(-t/(2*(1 + k))), '--', 'Color', no, 'LineWidth', 1.4);
grid on;  xlabel('$t$');  ylabel('$\|x(t)\|$');  title('$g=1+0.5\sin t$, $k=1.5$');
legend(hc, 'cota $\sqrt{1+k}\,e^{-t/(2(1+k))}$', 'Location', 'southwest');
subplot(1, 2, 2);  hold on;  grid on;  t = linspace(0, 2*pi, 1000);
plot(t, 2 + 2*g(t) - gp(t), 'Color', az);  plot(t, 2 + 2*gRap(t) - gRapp(t), 'Color', co, 'LineWidth', 1);
plot([0 2*pi], [2 2], '--', 'Color', gr);  plot([0 2*pi], [0 0], 'Color', no, 'LineWidth', 0.6);
xlim([0 2*pi]);  xlabel('$t$');  ylabel('$2+2g-\dot g$');
legend('$g=1+0.5\sin t$', '$g=(1+\sin 10t)/2$', 'Location', 'southeast');
title('si $g$ oscila r\''apido, el certificado se cae');
