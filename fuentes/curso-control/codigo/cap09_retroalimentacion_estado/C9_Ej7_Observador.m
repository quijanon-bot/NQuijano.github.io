%% C9_Ej7_Observador -- Notas: sección 9.6 (observador de Luenberger)
% QUÉ HACE   Calcula L por Ackermann (dualidad: acker(A',C',p)') para
%            A = [0 1; -10 -2], C = [1 0] y polos con zeta = 0.8, wn = 10, y
%            simula planta y observador desde condiciones iniciales distintas.
% OBSERVE    El error x - x~ obedece e' = (A - LC) e: muere con los polos del
%            observador, sin importar la entrada.
% ESPERADO   L = [14; 62]   (y L = [22; 59] para A = [2 3; -1 4])
% EXPLORE    Lleve los polos del observador a -50: converge más rápido, pero
%            agregue ruido a y y mire qué pasa con x~ (problema del capítulo).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:observador]
A = [0 1; -10 -2];   B = [0; 1];   C = [1 0];
rank(obsv(A, C))                               % 2: observable
po = roots([1 2*0.8*10 10^2]);                 % zeta = 0.8, wn = 10
L  = acker(A.', C.', po).'                     % dualidad -> [14; 62]
% planta + observador, entrada nula, x(0) = [1 0], x~(0) = [0 0]
Aobs = [A, zeros(2); L*C, A - L*C];            % estados [x; x~]
t = linspace(0, 3, 601);
X = initial(ss(Aobs, zeros(4,1), eye(4), 0), [1 0 0 0], t);
% [fin:observador]
fig = estiloFigura(1000, 420);
subplot(1,2,1); plot(t, X(:,1), t, X(:,3), '--'); grid on; legend('$x_1$', '$\tilde x_1$'); xlabel('$t$');
subplot(1,2,2); plot(t, X(:,2), t, X(:,4), '--'); grid on; legend('$x_2$', '$\tilde x_2$'); xlabel('$t$');
