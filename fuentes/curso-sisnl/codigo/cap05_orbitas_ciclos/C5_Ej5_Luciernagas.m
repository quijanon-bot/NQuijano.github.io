%% C5_Ej5_Luciernagas -- Notas: sección 5.5 (arrastre y deriva de fase)
% QUÉ HACE   Luciérnaga theta' = w + A sin(psi - theta) frente a un estímulo
%            psi' = Omega. La diferencia phi = psi - theta cumple
%            phi' = Omega - w - A sin(phi). Simula tres frecuencias de estímulo.
% OBSERVE    Si |Omega - w| <= A la diferencia de fase se queda quieta (arrastre,
%            phase locking) en phi* = arcsin((Omega - w)/A), que NO es cero: la
%            luciérnaga sigue al estímulo con un retraso fijo. Si |Omega - w| > A
%            la fase deriva, lento cerca de phi = pi/2 y rápido en el resto.
% ESPERADO   w = 1, A = 0.5:  Omega = 1.3 -> phi* = 0.6435;  Omega = 1.6 ->
%            T_deriva = 18.9445;  Omega = 2 -> T_deriva = 7.2552.
%            Rango de arrastre: 0.5 <= Omega <= 1.5.
% EXPLORE    Grafique el período de deriva en función de Omega cerca de 1.5.
%            ¿Cómo crece? (Compárelo con la bifurcación silla-nodo del capítulo 6.)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:arrastre]
w = 1;  A = 0.5;  opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
fprintf('rango de arrastre: %.2f <= Omega <= %.2f\n', w - A, w + A);
for Om = [1.3 1.6 2]
    mu = (Om - w)/A;
    if abs(mu) <= 1
        [~, P] = ode45(@(t, p) Om - w - A*sin(p), [0 60], 0, opc);
        fprintf('Omega = %.1f: arrastre, phi(60) = %.4f, arcsin(mu) = %.4f\n', Om, P(end), asin(mu));
    else
        ev = odeset(opc, 'Events', @(t, p) deal(p - 2*pi, 1, 1));
        [~, ~, te] = ode45(@(t, p) Om - w - A*sin(p), [0 500], 0, ev);
        fprintf('Omega = %.1f: deriva, período %.4f, fórmula %.4f\n', Om, te, ...
                2*pi/sqrt((Om - w)^2 - A^2));
    end
end
% [fin:arrastre]

fig = estiloFigura(800, 420); hold on;
for Om = [1.3 1.6 2]
    [t, P] = ode45(@(t, p) Om - w - A*sin(p), linspace(0, 40, 801), 0, opc);
    plot(t, P);
end
grid on; xlabel('$t$'); ylabel('$\varphi=\psi-\theta$');
legend('$\Omega=1.3$ (arrastre)', '$\Omega=1.6$ (deriva)', '$\Omega=2$ (deriva)', 'Location', 'northwest');
