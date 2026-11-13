%% C6_Ej12_PoincareVanDerPol -- Notas: sección 6.8 (el multiplicador sin resolver la ecuación)
% QUÉ HACE   Para van der Pol en forma de Liénard, x1' = x2 - (x1^3 - x1), x2' = -x1,
%            con Sigma = {x2 = 0, x1 > 0}:
%            (1) calcula P(q) y el tiempo de retorno tau(q) para una malla de q;
%            (2) encuentra el punto fijo q* con fzero y el multiplicador P'(q*) por
%            diferencias finitas;
%            (3) lo compara con exp(integral de div f a lo largo del ciclo), integrando
%            la divergencia 1 - 3 x1^2 junto con el estado.
% OBSERVE    tau(q) no es constante: solo en q* vale el período.
% ESPERADO   q* = 1.1081, tau(q*) = 6.663, P'(q*) = 8.60e-4 por los dos caminos.
% EXPLORE    Repita con el circuito x1' = x2 - (x1^3 - mu x1) para mu = 0.1 y 0.5, y
%            compare P'(q*) con la predicción e^{-2 pi mu} de la forma normal de Hopf.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:vdp]
f = @(x) [x(2) - (x(1)^3 - x(1));  -x(1)];
sigma = @(x) x(2);                         % en x1 > 0, x2' = -x1 < 0: cruza bajando
Pq = @(q) [1 0]*mapaPoincare(f, [q; 0], sigma, -1);
qs = fzero(@(q) Pq(q) - q, [0.5 2]);
[~, T] = mapaPoincare(f, [qs; 0], sigma, -1);
dP = (Pq(qs + 1e-5) - Pq(qs - 1e-5))/2e-5;
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
[~, Z] = ode45(@(t, z) [f(z(1:2)); 1 - 3*z(1)^2], [0 T], [qs; 0; 0], opc);
fprintf('q* = %.4f, período = %.4f\n', qs, T);
fprintf("P'(q*) por diferencias = %.4e;  exp(int div f) = %.4e\n", dP, exp(Z(end, 3)));
qq = linspace(0.2, 3, 15);  PP = zeros(size(qq));  tt = PP;
for k = 1:numel(qq), [xr, tt(k)] = mapaPoincare(f, [qq(k); 0], sigma, -1);  PP(k) = xr(1); end
fprintf('tau(0.5) = %.4f,  tau(2.5) = %.4f\n', interp1(qq, tt, 0.5, 'spline'), interp1(qq, tt, 2.5, 'spline'));
% [fin:vdp]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  plot(qq, PP, 'o-', qq, qq, '--');  grid on;  xlabel('$q$');  ylabel('$P(q)$');
title(sprintf('Punto fijo $q^*=%.4f$', qs));
subplot(1, 2, 2);  plot(qq, tt, 'o-');  grid on;  xlabel('$q$');  ylabel('$\tau(q)$');  title('El tiempo de retorno no es constante');
