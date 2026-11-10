%% C12_Ej7_FormaNormal -- Notas: sección 12.6 (coordenadas adaptadas y forma normal)
% QUÉ HACE   Dos ejemplos con r < n. Simula el sistema en las coordenadas originales x
%            con una entrada arbitraria u(t) = 0.5 sin t y, por separado, la forma normal en
%            las coordenadas z; compara z(t) con Phi(x(t)).
%   (1) x' = (-x1, x1 x2, x2) + (e^x2, 1, 0) u,  y = x3:   Phi = (x3, x2, 1 + x1 - e^x2)
%   (2) x' = (x3 - x2^3, -x2, x1^2 - x3) + (0, -1, 1) u,  y = x1:   Phi = (x1, x3 - x2^3, x2 + x3)
% OBSERVE    Las dos simulaciones coinciden: la forma normal es el MISMO sistema escrito
%            en otras coordenadas. La entrada solo aparece en la ecuación de z_r; la
%            ecuación de eta no tiene u porque L_g phi_i = 0.
% ESPERADO   max|z(t) - Phi(x(t))| < 1e-8 en los dos ejemplos.
% EXPLORE    En (1) escoja phi_3 = x1 (en vez de 1 + x1 - e^x2). ¿Sigue siendo un
%            difeomorfismo? ¿Aparece u en la ecuación de z_3?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);  t = linspace(0, 2, 201);  u = @(t) 0.5*sin(t);

% [ini:isidori]
fx  = @(t, x) [-x(1); x(1)*x(2); x(2)] + [exp(x(2)); 1; 0]*u(t);
Phi = @(x) [x(3); x(2); 1 + x(1) - exp(x(2))];
% forma normal: x1 = -1 + z3 + e^z2 en las coordenadas nuevas
fz  = @(t, z) [ z(2);
                (-1 + z(3) + exp(z(2)))*z(2) + u(t);
               -(-1 + z(3) + exp(z(2)))*(1 + z(2)*exp(z(2))) ];
x0 = [0.3; -0.2; 0.5];
[~, X] = ode45(fx, t, x0, opc);  [~, Z] = ode45(fz, t, Phi(x0), opc);
PX = cell2mat(arrayfun(@(i) Phi(X(i,:).').', (1:numel(t)).', 'UniformOutput', false));
fprintf('ejemplo 1: max|z(t) - Phi(x(t))| = %.1e\n', max(abs(Z(:) - PX(:))));
% [fin:isidori]

% [ini:khalil]
fx2  = @(t, x) [x(3) - x(2)^3; -x(2); x(1)^2 - x(3)] + [0; -1; 1]*u(t);
Phi2 = @(x) [x(1); x(3) - x(2)^3; x(2) + x(3)];
x2de = @(z) fzero(@(s) s + s^3 - (z(3) - z(2)), 0);          % x2 + x2^3 = z3 - z2 (única raíz)
a2 = @(z) 3*x2de(z)^3 + z(1)^2 - (z(3) - x2de(z));            % L_f^2 h en z
b2 = @(z) 1 + 3*x2de(z)^2;                                     % L_g L_f h en z
fz2 = @(t, z) [z(2); a2(z) + b2(z)*u(t); z(1)^2 - z(3)];
x0 = [0.4; 0.3; -0.2];
[~, X] = ode45(fx2, t, x0, opc);  [~, Z] = ode45(fz2, t, Phi2(x0), opc);
PX = cell2mat(arrayfun(@(i) Phi2(X(i,:).').', (1:numel(t)).', 'UniformOutput', false));
fprintf('ejemplo 2: max|z(t) - Phi(x(t))| = %.1e\n', max(abs(Z(:) - PX(:))));
% [fin:khalil]

fig = estiloFigura(900, 400);
plot(t, Z, '-', t, PX, 'k:'); grid on; xlabel('$t$'); legend('$z_1$', '$z_2$', '$z_3$', '$\Phi(x(t))$');
title('Forma normal y sistema original: la misma soluci\''on');
