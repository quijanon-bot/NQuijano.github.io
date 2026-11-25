%% C9_Ej2_FuncionesComparacion -- Notas: sección 9.3 (funciones de comparación)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Revisa en una malla las dos condiciones de la clase KL para las cuatro
%            funciones de la pausa: estrictamente creciente en r, decreciente a 0 en s.
% OBSERVE    r e^{-sr} decae a cero en s, pero falla en r: tiene un máximo en r = 1/s.
% ESPERADO   (a) sí, (b) no, (c) no, (d) sí.
% EXPLORE    Verifique que r e^{-sr} <= r/(1 + rs), una envolvente de clase KL.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:comparacion]
[R, S] = meshgrid(linspace(1e-3, 10, 801), linspace(0, 10, 801));
cand = {@(r, s) r.^2./(1 + s), @(r, s) r.*exp(-s.*r), ...
        @(r, s) min(r, 1).*exp(-s), @(r, s) r./(1 + s) + r.*exp(-s)};
nombre = {'(a) r^2/(1+s)', '(b) r e^{-sr}', '(c) min(r,1) e^{-s}', '(d) r/(1+s) + r e^{-s}'};
for k = 1:4
    B = cand{k}(R, S);
    enR = all(all(diff(B, 1, 2) > 0));                     % estrictamente creciente en r
    enS = all(all(diff(B, 1, 1) <= 1e-15));                % (y tiende a 0: analítico)
    fprintf('%-24s creciente en r: %d   decreciente en s: %d   =>  KL: %d\n', nombre{k}, enR, enS, enR && enS);
end
r = linspace(0, 3, 3001);  [~, i] = max(r.*exp(-2*r));
fprintf('r e^{-2r}: máximo en r = %.3f (1/s = 0.5)\n', r(i));
fprintf('max(r e^{-sr} - r/(1+rs)) en la malla = %.2e (<= 0)\n', max(max(R.*exp(-S.*R) - R./(1 + R.*S))));
% [fin:comparacion]

% ---- Figura de las notas (fig:vt-comparacion) ----------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
cols = [az; ve; am; vi; co];
fig = estiloFigura(1250, 400);  r = linspace(0, 5, 400);
subplot(1, 3, 1);  hold on;  grid on;
plot(r, atan(r), 'Color', az);  plot(r, r.^2/10, 'Color', ve);  plot(r, 0.9*min(r, 1), '--', 'Color', co);
plot([0 5], pi/2*[1 1], ':', 'Color', gr);  axis([0 5 0 2.6]);  xlabel('$r$');
legend('$\tan^{-1}r\in\mathcal{K}$', '$r^2/10\in\mathcal{K}_\infty$', '$0.9\min\{r,1\}\notin\mathcal{K}$', 'Location', 'northwest');
title('clase $\mathcal{K}$ y $\mathcal{K}_\infty$');
r = linspace(0, 6, 400);  ss = [0 0.5 1 2 4];
subplot(1, 3, 2);  hold on;  grid on;
for j = 1:5, plot(r, r./(ss(j)*r + 1), 'Color', cols(j, :), 'LineWidth', 1.3);  end
axis([0 6 0 2.2]);  xlabel('$r$');  title('$r/(sr+1)\in\mathcal{KL}$');
legend(arrayfun(@(v) sprintf('$s=%g$', v), ss, 'UniformOutput', false), 'Location', 'northwest');
subplot(1, 3, 3);  hold on;  grid on;
for j = 1:5, plot(r, r.*exp(-ss(j)*r), 'Color', cols(j, :), 'LineWidth', 1.3);  end
for s = [1 2 4], plot(1/s, exp(-1)/s, 'o', 'Color', no, 'MarkerFaceColor', no, 'MarkerSize', 3);  end
axis([0 6 0 0.5]);  xlabel('$r$');  title('$re^{-sr}\notin\mathcal{KL}$');
text(2.2, 0.40, {'m\''aximo en $r=1/s$:', 'no es creciente en $r$'});
