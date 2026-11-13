%% C10_Ej5_Robustez -- Notas: sección 10.3 (robustez frente a perturbaciones que se anulan)
% QUÉ HACE   Para x' = A x + g_p, A = [0 1; -1 -1]: calcula c3 = 1, c4 = 2 lmax(P) y el
%            margen nu* = c3/c4 del lema de Khalil 9.1. Simula la perturbación particular
%            g_p = nu [0; x1] con nu = 0.27, 0.9 y 1.05.
% OBSERVE    El margen garantizado (0.276) es mucho menor que el real para esta g_p (1):
%            la garantía cubre todas las perturbaciones con ||g_p|| <= nu ||x||.
% ESPERADO   c4 = 3.62, nu* = 0.276; ||x(40)||: converge, converge lento, diverge.
% EXPLORE    Pruebe g_p = nu [x2; -x1] (una rotación). ¿Para qué nu deja de ser estable?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:robustez]
A = [0 1; -1 -1];  P = ecuacionLyapunov(A, eye(2));
c3 = 1;  c4 = 2*max(eig(P));
fprintf('c4 = %.3f, nu* = c3/c4 = %.3f\n', c4, c3/c4);
for nu = [0.27 0.9 1.05]
    An = A + nu*[0 0; 1 0];
    fprintf('nu = %.2f: max Re(lambda) = %+.4f, ||x(40)|| = %.3g\n', nu, max(real(eig(An))), norm(expm(An*40)*[1; 0]));
end
% [fin:robustez]

fig = estiloFigura(900, 420);  t = linspace(0, 40, 800);  hold on;
for nu = [0.27 0.9 1.05]
    An = A + nu*[0 0; 1 0];  plot(t, arrayfun(@(s) norm(expm(An*s)*[1; 0]), t));
end
set(gca, 'YScale', 'log');  grid on;  xlabel('$t$');  ylabel('$\|x\|$');  legend('$\nu=0.27$', '$\nu=0.9$', '$\nu=1.05$');
