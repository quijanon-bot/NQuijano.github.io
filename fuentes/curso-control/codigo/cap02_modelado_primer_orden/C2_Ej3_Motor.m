%% C2_Ej3_Motor -- Notas: sección 2.4 (resolver una ODE con Laplace)
% QUÉ HACE   Resuelve x'' + 5x' + 6x = 0, x(0) = 1, x'(0) = 0 (calibrador
%            óptico de Chrysler) de tres maneras: con Laplace simbólico, con
%            fracciones parciales (residue) y simulando (initial).
% OBSERVE    Cada polo de X(s) aporta un modo e^{pt}; el residuo es su "peso".
% ESPERADO   X(s) = (s+5)/((s+2)(s+3)) = 3/(s+2) - 2/(s+3);
%            x(t) = 3e^{-2t} - 2e^{-3t}
% EXPLORE    Cambie x'(0) a -3. ¿Qué residuo se anula? ¿Qué modo desaparece?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:simbolico]
syms s t X
syms x(t)
ode = diff(x, t, 2) + 5*diff(x, t) + 6*x == 0;
F   = laplace(ode, t, s);                          % transforma toda la ecuación
F   = subs(F, [x(0), subs(diff(x, t), t, 0)], [1, 0]);  % condiciones iniciales
F   = subs(F, laplace(x(t), t, s), X);             % llama X a L{x(t)}
Xs  = solve(F, X)                                  % -> (s+5)/(s^2+5s+6)
xt  = ilaplace(Xs, s, t)                           % -> 3e^{-2t} - 2e^{-3t}
% [fin:simbolico]

% [ini:residue]
[r, p, k] = residue([1 5], [1 5 6])   % r = [-2; 3], p = [-3; -2], k = []
% Lectura: X(s) = -2/(s+3) + 3/(s+2)   =>   x(t) = -2e^{-3t} + 3e^{-2t}
roots([1 5 6])                        % los polos son las raíces del denominador
pzplot(tf([1 5], [1 5 6])); grid on    % polos (x) y ceros (o) en el plano s
% [fin:residue]

tt  = linspace(0, 4, 400);
fig = estiloFigura(900, 420);
plot(tt, 3*exp(-2*tt), '--', tt, -2*exp(-3*tt), '--', tt, 3*exp(-2*tt) - 2*exp(-3*tt));
grid on; legend('$3e^{-2t}$', '$-2e^{-3t}$', '$x(t)$'); xlabel('$t$ (s)');
title('Cada polo aporta un modo');
