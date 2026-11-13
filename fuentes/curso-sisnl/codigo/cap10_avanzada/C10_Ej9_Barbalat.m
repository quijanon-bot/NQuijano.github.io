%% C10_Ej9_Barbalat -- Notas: sección 10.5 (tres trampas sobre señales)
% QUÉ HACE   (1) Pulsos de altura k y base 1/k^3: área parcial contra pi^2/12.
%            (2) h = sin(ln t): dh/dt -> 0 y h no converge.
%            (3) h = e^{-t} sin(e^{2t}): h -> 0 y dh/dt no está acotada.
%            (4) sin(t^2) no es uniformemente continua: distancia entre un cero y un 1.
% OBSERVE    En las tres falla una hipótesis de regularidad, no la convergencia.
% ESPERADO   área (200000 pulsos) = 0.8225 = pi^2/12; s_n - t_n (n = 1000) = 0.0099.
% EXPLORE    Cambie la base a 1/k^2. ¿Sigue siendo finita el área?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:pulsos]
k = 1:200000;
fprintf('área de los pulsos = %.6f;  pi^2/12 = %.6f;  pendiente del pulso 6 = %d\n', ...
        sum(1./(2*k.^2)), pi^2/12, 2*6^4);
t = [1e2 1e4 1e6];
fprintf('sin(ln t): dh/dt = %s (-> 0), h = %s\n', mat2str(cos(log(t))./t, 2), mat2str(sin(log(t)), 2));
t = [1 2 3];
fprintf('e^{-t} sin(e^{2t}): |h| <= %s, amplitud de dh/dt ~ 2e^t = %s\n', mat2str(exp(-t), 2), mat2str(2*exp(t), 3));
n = 1000;  fprintf('sin(t^2): s_n - t_n = %.4f con |sin(s_n^2) - sin(t_n^2)| = 1\n', ...
                     sqrt(2*pi*n + pi/2) - sqrt(2*pi*n));
% [fin:pulsos]

fig = estiloFigura(1000, 380);  xs = 0;  ys = 0;
for j = 1:6, w = 1/j^3;  xs = [xs, j - w/2, j, j + w/2];  ys = [ys, 0, j, 0]; end
plot([xs 6.6], [ys 0]);  grid on;  xlabel('$t$');  ylabel('$\psi$');  title('\''area $\pi^2/12$, pero $\psi(k)=k$');
