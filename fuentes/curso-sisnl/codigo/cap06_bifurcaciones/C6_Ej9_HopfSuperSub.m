%% C6_Ej9_HopfSuperSub -- Notas: sección 6.6 (supercrítica o subcrítica)
% QUÉ HACE   (1) Calcula el primer coeficiente de Lyapunov (primerLyapunov, en comun/)
%            para la forma normal super y subcrítica, el circuito en mu = 0 y el modelo
%            de Rosenzweig-MacArthur en K = 3. (2) Distingue super de sub "sin
%            fórmulas": con mu = 0.05 arranca cerca del origen y mira si el estado se
%            estaciona en un ciclo o se escapa.
% OBSERVE    La jacobiana en el origen es la misma en la super y en la sub: solo l1
%            las distingue.
% ESPERADO   l1 = -1 (super), +1 (sub), -0.375 (circuito), -0.0417 (Rosenzweig-MacArthur).
%            Con mu = 0.05 la super termina en r = 0.2236; la sub escapa (r > 10).
% EXPLORE    Para la sub con mu = -0.05, integre HACIA ATRÁS desde r = 0.2: ¿qué
%            radio encuentra? ¿Qué es?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:lyapunov]
sup = @(x) [-x(2) - x(1)*(x(1)^2 + x(2)^2);  x(1) - x(2)*(x(1)^2 + x(2)^2)];
sub = @(x) [-x(2) + x(1)*(x(1)^2 + x(2)^2);  x(1) + x(2)*(x(1)^2 + x(2)^2)];
cir = @(x) [x(2) - x(1)^3;  -x(1)];
K = 3;  rm = @(x) [x(1)*(1 - x(1)/K) - x(1)*x(2)/(1 + x(1));  x(2)*(2*x(1)/(1 + x(1)) - 1)];
fprintf('l1: super %.4f, sub %.4f, circuito %.4f, Rosenzweig-MacArthur %.4f\n', ...
        primerLyapunov(sup, [0; 0]), primerLyapunov(sub, [0; 0]), ...
        primerLyapunov(cir, [0; 0]), primerLyapunov(rm, [1; 4/3]));
% [fin:lyapunov]

% [ini:supersub]
mu = 0.05;
fs = @(t, x) [mu*x(1) - x(2) - x(1)*(x(1)^2 + x(2)^2);  x(1) + mu*x(2) - x(2)*(x(1)^2 + x(2)^2)];
fb = @(t, x) [mu*x(1) - x(2) + x(1)*(x(1)^2 + x(2)^2);  x(1) + mu*x(2) + x(2)*(x(1)^2 + x(2)^2)];
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-12, 'Events', @(t, x) deal(norm(x) - 10, 1, 1));
[~, X] = ode45(fs, [0 400], [0.01; 0], opc);
fprintf('super, mu = %.2f: r final = %.4f (sqrt(mu) = %.4f)\n', mu, norm(X(end, :)), sqrt(mu));
[t, X] = ode45(fb, [0 400], [0.01; 0], opc);
fprintf('sub,   mu = %.2f: r = %.1f en t = %.1f (escapa)\n', mu, norm(X(end, :)), t(end));
% [fin:supersub]
