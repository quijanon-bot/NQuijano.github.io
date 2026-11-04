%% C2_Ej2_Laplace -- Notas: sección 2.3 (transformada de Laplace)
% QUÉ HACE   Calcula con el Symbolic Math Toolbox las transformadas de la
%            tabla y algunas propiedades, y regresa al tiempo con ilaplace.
% OBSERVE    MATLAB entiende las señales como x(t)·escalón(t): solo t >= 0.
% ESPERADO   1/s, 1/(s+a), s/(s^2+w^2), 1/s^2, 1/(s+a)^2 ...
% EXPLORE    Verifique la propiedad de corrimiento en s: laplace(exp(-2*t)*cos(3*t))
%            debe ser la de cos(3t) con s -> s+2.
clear; clc;

% [ini:transformadas]
syms t s
syms a w positive
laplace(heaviside(t), t, s)      % escalón       -> 1/s
laplace(exp(-a*t), t, s)         % exponencial   -> 1/(s+a)
laplace(cos(w*t), t, s)          % coseno        -> s/(s^2+w^2)
laplace(t, t, s)                 % rampa         -> 1/s^2
laplace(t*exp(-a*t), t, s)       % t e^{-at}     -> 1/(s+a)^2
laplace(dirac(t), t, s)          % impulso       -> 1
% y de vuelta al tiempo:
ilaplace(1/(s*(s+a)), s, t)      % -> (1 - e^{-at})/a
% [fin:transformadas]

% [ini:propiedades]
syms x(t)
laplace(diff(x(t), t), t, s)     % s X(s) - x(0)      (diferenciación)
laplace(diff(x(t), t, 2), t, s)  % s^2 X - s x(0) - x'(0)
laplace(int(x(t), t, 0, t), t, s)% X(s)/s             (integración)
simplify(laplace(exp(-2*t)*cos(3*t), t, s))   % corrimiento en s: (s+2)/((s+2)^2+9)
% [fin:propiedades]
