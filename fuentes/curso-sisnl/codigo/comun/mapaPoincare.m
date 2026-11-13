function [xr, tau] = mapaPoincare(f, x0, sigma, sentido, Tmax)
% MAPAPOINCARE  Primer retorno a una sección transversal (capítulo 6).
%   [xr, tau] = mapaPoincare(f, x0, sigma, sentido)
%     f       campo: f = @(x) [...] (vector columna, invariante en el tiempo).
%     x0      punto de partida, sobre la sección.
%     sigma   función escalar: la sección es {x : sigma(x) = 0}.
%     sentido +1 si el flujo cruza la sección con sigma creciente, -1 si decreciente.
%     Tmax    tiempo máximo de integración (100 por defecto).
%   Devuelve el punto de retorno xr = P(x0) y el tiempo de retorno tau(x0).
%   El tiempo de retorno depende de x0: por eso se usa un evento, no un tiempo fijo.
%   Para no detectar el punto de partida, primero se integra un tramo corto sin eventos.
%   Compatible con MATLAB y GNU Octave.
if nargin < 5, Tmax = 100; end
t0 = 1e-3;
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);
[~, X] = ode45(@(t, x) f(x), [0 t0/2 t0], x0(:), opc);
opc = odeset(opc, 'Events', @(t, x) deal(sigma(x), 1, sentido));
[~, ~, te, xe] = ode45(@(t, x) f(x), [t0 Tmax], X(end, :).', opc);
if isempty(te), error('mapaPoincare: no hubo retorno antes de Tmax = %g', Tmax); end
xr = xe(1, :).';  tau = te(1);
end
