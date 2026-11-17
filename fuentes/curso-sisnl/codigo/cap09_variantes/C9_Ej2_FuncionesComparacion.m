%% C9_Ej2_FuncionesComparacion -- Notas: sección 9.3 (funciones de comparación)
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

fig = estiloFigura(900, 360);  r = linspace(0, 6, 400);
subplot(1, 2, 1);  hold on;  for s = [0 0.5 1 2 4], plot(r, r./(s*r + 1)); end
grid on;  title('$r/(sr+1)\in\mathcal{KL}$');  xlabel('$r$');
subplot(1, 2, 2);  hold on;  for s = [0 0.5 1 2 4], plot(r, r.*exp(-s*r)); end
grid on;  ylim([0 2]);  title('$re^{-sr}\notin\mathcal{KL}$');  xlabel('$r$');
