%% C11_Ej5_RLCKhalil -- Notas: sección 11.5 (el mismo circuito, cuatro tipos)
% QUÉ HACE   Simula el circuito RLC no lineal de Khalil (§6.2):
%              L x1' = u - h2(x1) - x2,   C x2' = x1 - h3(x2),   y = x1 + h1(u)
%            con V = L x1^2/2 + C x2^2/2 y verifica, sobre la solución, que
%              u y = V' + u h1(u) + x1 h2(x1) + x2 h3(x2).
% OBSERVE    El balance vale para cualquier elección de los resistores; lo que
%            cambia es DÓNDE se disipa: en la entrada (ISP), en la salida (OSP)
%            o en todo el estado (estrictamente pasivo).
% ESPERADO   residuo de la potencia ~1e-9 en los cuatro casos.
% EXPLORE    Use h2(x1) = -0.2 x1 (resistencia negativa): ¿el circuito sigue siendo pasivo?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:rlc]
L = 1;  C = 0.5;
u = @(t) cos(2*t);
casos = { 'sin pérdidas',          @(u) 0*u,          @(x) 0*x,          @(x) 0*x;
          'ISP (h1)',              @(u) u + u.^3,     @(x) 0*x,          @(x) 0*x;
          'OSP (h1 = 0, h2)',      @(u) 0*u,          @(x) x + x.^3,     @(x) 0*x;
          'estrictamente pasivo',  @(u) 0.5*u,        @(x) x,            @(x) 2*x };
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12, 'MaxStep', 0.01);
for k = 1:size(casos, 1)
    [nombre, h1, h2, h3] = casos{k, :};
    f = @(t, x) [(u(t) - h2(x(1)) - x(2))/L; (x(1) - h3(x(2)))/C];
    [t, X] = ode45(f, [0 10], [0.5; -0.5], opc);
    y  = X(:,1) + h1(u(t));
    V  = L*X(:,1).^2/2 + C*X(:,2).^2/2;
    d  = u(t).*h1(u(t)) + X(:,1).*h2(X(:,1)) + X(:,2).*h3(X(:,2));   % potencia en los resistores
    [~, D, res] = balanceEnergia(t, V, u(t).*y, d);
    fprintf('%-22s residuo %.1e   energía disipada en [0,10] = %7.3f\n', nombre, ...
            max(abs(res)), D(end));
end
% [fin:rlc]
