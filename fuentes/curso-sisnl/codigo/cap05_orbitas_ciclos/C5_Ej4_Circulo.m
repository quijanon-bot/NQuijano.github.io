%% C5_Ej4_Circulo -- Notas: sección 5.4 (flujos en el círculo)
% QUÉ HACE   (1) theta' = sin(theta): equilibrios y estabilidad. (2) Dos corredores
%            con períodos T1 = 4 min y T2 = 5 min: tiempo para sacar una vuelta.
%            (3) Oscilador no uniforme theta' = w - a sin(theta): período para a < w
%            comparado con la fórmula T = 2 pi / sqrt(w^2 - a^2).
% OBSERVE    En el círculo los equilibrios estables e inestables se alternan.
%            En el no uniforme, el oscilador "se demora" cerca de theta = pi/2,
%            donde theta' es mínima; al acercarse a = w el período se dispara.
% ESPERADO   sin: theta* = 0 inestable (f' = 1), pi estable (f' = -1).
%            T_lap = (1/4 - 1/5)^{-1} = 20 min.
%            w = 2: a = 1 -> T = 3.6276;  a = 1.9 -> T = 10.0611;  a = 1.99 -> T = 31.4553.
% EXPLORE    Para a > w, ¿cuánto tarda en llegar al equilibrio estable desde theta = -pi/2?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:seno]
fp = @(th) cos(th);                                % derivada de f(theta) = sin(theta)
fprintf('theta* = 0: f'' = %+g (inestable);  theta* = pi: f'' = %+g (estable)\n', fp(0), fp(pi));
% [fin:seno]

% [ini:corredores]
T1 = 4;  T2 = 5;  w1 = 2*pi/T1;  w2 = 2*pi/T2;
fprintf('T_lap = 2 pi/(w1 - w2) = %.4f min\n', 2*pi/(w1 - w2));
% [fin:corredores]

% [ini:nouniforme]
w = 2;  opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
for a = [1 1.9 1.99]
    ev = odeset(opc, 'Events', @(t, th) deal(th - 2*pi, 1, 1));
    [~, ~, te] = ode45(@(t, th) w - a*sin(th), [0 200], 0, ev);
    fprintf('a = %4.2f: período simulado %.4f, fórmula %.4f\n', a, te, 2*pi/sqrt(w^2 - a^2));
end
% [fin:nouniforme]

fig = estiloFigura(1100, 380);
th = linspace(0, 2*pi, 400);
for j = 1:3
    as = [1 2 3]; a = as(j); subplot(1, 3, j); plot(th, w - a*sin(th)); hold on; plot([0 2*pi], [0 0], 'k');
    grid on; xlim([0 2*pi]); title(sprintf('$a=%g$, $\\omega=2$', a)); xlabel('$\theta$');
end
