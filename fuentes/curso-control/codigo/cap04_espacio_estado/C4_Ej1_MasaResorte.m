%% C4_Ej1_MasaResorte -- Notas: sección 4.3 (el estado de un sistema)
% QUÉ HACE   Escribe la masa-resorte-amortiguador M y'' + b y' + k y = u en variables
%            de fase y simula posición y velocidad ante un pulso de 5 N durante 20 s,
%            para b = 2, 4, 8 y 16 (M = 2, k = 16).
% OBSERVE    El mismo modelo de estado; solo cambia una entrada de A. Con b = 16 los
%            valores propios se vuelven reales y desaparece la oscilación.
% ESPERADO   Valores propios -0.5 +- 2.78j, -1 +- 2.65j, -2 +- 2j, -1.17 y -6.83.
%            Posición final durante el pulso: 5/16 = 0.3125 m.
% EXPLORE    Duplique M y prediga, antes de simular, qué pasa con la oscilación.
clear; close all; clc;
if ~exist('variablesFase', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:fase]
M = 2;  k = 16;  b = 2;
A = [0 1; -k/M -b/M];  B = [0; 1/M];  C = [1 0];  D = 0;    % x1 = y, x2 = y'
sistema = ss(A, B, C, D)
eig(A)
% [fin:fase]

% [ini:simulacion]
t = 0:0.01:40;  u = 5*(t < 20);                              % pulso de 5 N durante 20 s
for b = [2 4 8 16]
    A = [0 1; -k/M -b/M];
    [~, ~, x] = lsim(ss(A, B, C, D), u, t);
    subplot(2, 2, find(b == [2 4 8 16]));
    plot(t, x(:,1), t, x(:,2), '--'); grid on; title(sprintf('b = %d', b));
    fprintf('b = %2d: valores propios %s\n', b, mat2str(eig(A).', 3));
end
legend('posición x_1', 'velocidad x_2');
% [fin:simulacion]
