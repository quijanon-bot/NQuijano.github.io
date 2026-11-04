%% C9_Ej2_Motivador -- Notas: sección 9.2 (u = -Kx estabiliza una planta inestable)
% QUÉ HACE   Para A = [-1 a; 3 -2], B = [0; 1], calcula K que lleva los polos
%            a -2 y -3, y simula desde x(0) = [1; 1] con y sin retroalimentación.
% OBSERVE    Con a = 2 la planta tiene un polo en +1 (diverge); con u = -Kx los
%            estados vuelven al origen. Pruebe a pequeño: K crece como 2/a.
% ESPERADO   a = 2: eig(A) = {1, -4}; K = [4 2]; u(0) = -6
% EXPLORE    a = 0: ¿qué polo no se puede mover? (vea C9_Ej3)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:motivador]
a = 2;
A = [-1 a; 3 -2];   B = [0; 1];
eig(A)                           % 1 y -4: equilibrio inestable
K = [3 + 2/a, 2];                % por comparación de coeficientes
eig(A - B*K)                     % -2 y -3
x0 = [1; 1];   t = linspace(0, 5, 501);
lazoAbierto  = ss(A, zeros(2,1), eye(2), 0);
lazoCerrado  = ss(A - B*K, zeros(2,1), eye(2), 0);
xa = initial(lazoAbierto, x0, t);   % x(t) sin control
xc = initial(lazoCerrado, x0, t);   % x(t) con u = -Kx
u  = -(K*xc.').';                    % esfuerzo de control
% [fin:motivador]
fig = estiloFigura(1100, 420);
subplot(1,3,1); plot(t, xa); grid on; title('Sin control'); xlabel('$t$'); legend('$x_1$','$x_2$');
subplot(1,3,2); plot(t, xc); grid on; title('$u=-\mathbb{K}x$'); xlabel('$t$');
subplot(1,3,3); plot(t, u); grid on; title('$u(t)$'); xlabel('$t$');
