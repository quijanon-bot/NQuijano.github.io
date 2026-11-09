%% C3_Ej10_Dependencia -- Notas: sección 3.9 (dependencia continua)
% QUÉ HACE   Compara y' = -y + 0.5 sin(y), y(0) = 1, con la versión perturbada
%            z' = -z + 0.5 sin(z) + 0.1 cos(t), z(0) = 1.05, y con la cota
%            ||y - z|| <= gamma e^{L t} + (mu/L)(e^{L t} - 1), L = 1.5.
% OBSERVE    La cota crece exponencialmente; la diferencia real no. La cota es
%            válida en todo intervalo finito, pero no dice que las soluciones
%            se separen.
% ESPERADO   max_{[0,5]} |y - z| = 0.0910;  cota en t = 5: 210.9.
% EXPLORE    Cambie el signo: y' = +y + 0.5 sin(y). ¿Qué tan conservadora es ahora la cota?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:dependencia]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
t = linspace(0, 5, 501);
[~, Y] = ode45(@(t, y) -y + 0.5*sin(y), t, 1, opc);
[~, Z] = ode45(@(t, z) -z + 0.5*sin(z) + 0.1*cos(t), t, 1.05, opc);
L = 1.5;  gam = 0.05;  mu = 0.1;
cota = gam*exp(L*t) + mu/L*(exp(L*t) - 1);
fprintf('max |y - z| = %.4f;  cota en t = 5: %.1f\n', max(abs(Y - Z)), cota(end));
% [fin:dependencia]

fig = estiloFigura(700, 420);
semilogy(t, abs(Y - Z), t, cota, '--'); grid on; xlabel('$t$'); legend('$|y(t)-z(t)|$', 'cota de Gronwall');
