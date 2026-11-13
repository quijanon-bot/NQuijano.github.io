%% C10_Ej12_ISSenvolvente -- Notas: sección 10.6 (funciones ISS-Lyapunov)
% QUÉ HACE   Para x' = -x^3 + w con w = 0.5 sin 2t: ganancia gamma(r) = (r/theta)^{1/3},
%            gamma(0.5) con theta = 1/2, y el limsup simulado desde x(0) = +-3.
% OBSERVE    La ganancia no es lineal: gamma(0.01) = 0.27 >> 0.01. El limsup real queda
%            por debajo de gamma: la senoidal no es la peor entrada.
% ESPERADO   gamma(0.5) = 1; limsup |x| < 1.
% EXPLORE    Use w = 0.5 constante. ¿A qué valor converge x? Compárelo con gamma(0.5).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:envolvente]
theta = 0.5;  gam = @(r) (r/theta).^(1/3);
fprintf('gamma(0.5) = %.3f;  gamma(0.01) = %.3f\n', gam(0.5), gam(0.01));
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
for x0 = [3 -3]
    [t, X] = ode45(@(t, x) -x^3 + 0.5*sin(2*t), linspace(0, 40, 8001), x0, opc);
    fprintf('x(0) = %+d: limsup |x| = %.3f < gamma = %.3f\n', x0, max(abs(X(t >= 20))), gam(0.5));
end
fprintf('con w = 0.5 constante: x -> 0.5^(1/3) = %.3f\n', 0.5^(1/3));
% [fin:envolvente]

fig = estiloFigura(700, 420);  plot(t, X);  hold on;
plot([0 40], gam(0.5)*[1 1], '--', [0 40], -gam(0.5)*[1 1], '--');  grid on;  xlabel('$t$');  ylabel('$x$');
