%% C1_Ej5_Reescalamiento -- Notas: sección 1.2 (menos parámetros, más entendimiento)
% QUÉ HACE   Simula tres masa-resorte con (m, k, c) = (1, 1, 0.5), (1, 4, 1) y
%            (2, 18, 3). Los tres tienen el mismo alpha = c/sqrt(k m) = 0.5,
%            pero frecuencias naturales distintas, omega = sqrt(k/m) = 1, 2, 3.
%            Grafica y(t) contra t y contra tau = omega t.
% OBSERVE    Contra t son tres curvas; contra tau son la misma curva: el
%            sistema normalizado z1' = z2, z2' = -z1 - alpha z2 tiene un solo
%            parámetro.
% ESPERADO   Diferencia máxima entre las tres curvas en la variable tau < 1e-8.
% EXPLORE    Cambie c en uno de los tres. ¿Qué número basta mirar para saber si
%            la respuesta oscila? (alpha < 2)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:reescalar]
casos = [1 1 0.5; 1 4 1; 2 18 3];            % [m k c]
tau = linspace(0, 20, 2001);
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
Y = zeros(3, numel(tau));
for i = 1:3
    m = casos(i,1); k = casos(i,2); c = casos(i,3);
    w = sqrt(k/m);  alfa = c/sqrt(k*m);
    [~, X] = ode45(@(t, x) [x(2); (-k*x(1) - c*x(2))/m], tau/w, [1; 0], opc);
    Y(i,:) = X(:,1)';
    fprintf('m = %g, k = %g, c = %g:  omega = %g,  alpha = %g\n', m, k, c, w, alfa);
end
fprintf('Diferencia máxima entre las curvas en la variable tau: %.1e\n', max(max(abs(Y - Y(1,:)))));
% [fin:reescalar]

fig = estiloFigura(1000, 400);
subplot(1, 2, 1); hold on;
for i = 1:3, w = sqrt(casos(i,2)/casos(i,1)); plot(tau/w, Y(i,:)); end
grid on; xlim([0 20]); xlabel('$t$'); ylabel('$y$'); title('tres sistemas...');
subplot(1, 2, 2); plot(tau, Y); grid on; xlabel('$\tau=\omega t$'); title('...una sola curva');
