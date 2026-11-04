%% C2_Ej8_PrimerOrden -- Notas: sección 2.8 (respuestas del primer orden)
% QUÉ HACE   Barre la ganancia K1 y la constante de tiempo tau de
%            K1/(tau s + 1) y dibuja las respuestas al escalón y a la rampa.
%            Reemplaza el Manipulate de Mathematica de la versión anterior.
% OBSERVE    El escalón llega a 63.2 % del final en t = tau y la pendiente
%            inicial es K1/tau. Ante la rampa la salida queda atrasada en
%            tau y el error tiende a K1 tau (con u = t y e = K1 u - y).
% ESPERADO   K1 = 10, tau = 5: y(5) = 6.32, y(20) = 9.82, pendiente 2.
% EXPLORE    Fije K1 = 1 y reduzca tau: ¿qué pasa con el error ante la rampa?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:escalon]
K1 = 10;  tau = 5;
G  = tf(K1, [tau 1]);
t  = linspace(0, 6*tau, 600);
y  = step(G, t);
fprintf('y(tau) = %.2f (63.2 %%), y(4tau) = %.2f (98.2 %%)\n', ...
        interp1(t, y, tau), interp1(t, y, 4*tau));
S  = stepinfo(G);                   % criterio por defecto: 2 %
fprintf('t_s (2 %%) = %.2f = %.2f tau\n', S.SettlingTime, S.SettlingTime/tau);
% [fin:escalon]

% [ini:rampa]
K1 = 1;
fig = estiloFigura(1100, 420);
taus = [10 1];
for k = 1:2
    G  = tf(K1, [taus(k) 1]);
    t  = linspace(0, 40, 800);
    yr = lsim(G, t, t);                % entrada u(t) = t
    e  = K1*t(:) - yr;                 % error de seguimiento
    subplot(1, 2, k); plot(t, t, '--', t, yr); grid on;
    title(sprintf('$\\tau = %g$: $e(\\infty) = K_1\\tau = %g$', taus(k), K1*taus(k)));
    fprintf('tau = %4.1f -> e(40) = %.3f\n', taus(k), e(end));
end
% [fin:rampa]

%% Barrido interactivo (en MATLAB: deslice con los controles de Live Script)
tau = 2;    % <-- cambie y vuelva a correr la sección (o use un control deslizante)
K1  = 1;
figure; step(tf(K1, [tau 1])); hold on; step(tf(K1, [tau 1])*tf(1, [1 0]), 'r'); grid on;
legend('escal\''on', 'rampa'); xlim([0 15]);
