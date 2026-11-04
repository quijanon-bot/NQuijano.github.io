%% C2_Ej5_dsolve -- Notas: sección 2.4 (resolver la ODE sin transformar)
% QUÉ HACE   Resuelve problemas de valor inicial con dsolve (simbólico) y con
%            ode45 (numérico), y compara.
% OBSERVE    dsolve hace internamente el trabajo de Laplace; ode45 no necesita
%            que la ecuación sea lineal.
% ESPERADO   y' = -2y + t, y(0)=1:  y = t/2 - 1/4 + (5/4)e^{-2t}
%            y'' + y' + y = sin t, y(0)=1, y'(0)=0: y -> -cos t (estado estacionario)
% EXPLORE    Cambie y'(0) del segundo problema a -3: ¿cambia el estado
%            estacionario? ¿Por qué no?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:dsolve]
syms y(t)
y1 = dsolve(diff(y) == -2*y + t, y(0) == 1)           % primer orden
Dy = diff(y);
y2 = dsolve(diff(y, 2) + Dy + y == sin(t), y(0) == 1, Dy(0) == 0)
fplot(y2, [0 10]); grid on;                          % gráfica de la solución
% [fin:dsolve]

% [ini:ode45]
f = @(t, z) [z(2); sin(t) - z(2) - z(1)];            % z = [y; y']
[tn, zn] = ode45(f, [0 10], [1; 0]);
hold on; plot(tn, zn(:,1), 'o', 'MarkerSize', 4);
legend('dsolve', 'ode45'); xlabel('$t$');
% [fin:ode45]
