function [l1, w0, P] = primerLyapunov(f, xs, h)
% PRIMERLYAPUNOV  Primer coeficiente de Lyapunov de una bifurcación de Hopf (cap. 6).
%   [l1, w0] = primerLyapunov(f, xs)   f = @(x) campo en R^2 (vector columna),
%   xs = equilibrio cuya jacobiana tiene valores propios +-j w0 (en el valor crítico).
%   Lleva el sistema a  u' = -w0 v + F(u,v),  v' = w0 u + G(u,v)  con el cambio
%   x = xs + P [u; v],  P = [e1, A e1/w0]  (A = jacobiana), y aplica la fórmula de
%   Guckenheimer y Holmes (ec. 3.4.11) con derivadas por diferencias centradas
%   (exactas, salvo redondeo, si F y G son polinomios de grado <= 3).
%   l1 < 0: Hopf supercrítica (ciclo estable);  l1 > 0: subcrítica.
%   La magnitud de l1 depende de la escala de las coordenadas; el signo no.
%   Compatible con MATLAB y GNU Octave.
if nargin < 3, h = 1e-2; end
A = jacobianoNumerico(f, xs(:), 1e-6);
w0 = sqrt(det(A));
if abs(trace(A)) > 1e-6*w0 || ~isreal(w0)
    warning('primerLyapunov: la jacobiana no tiene valores propios +-j w0 (tr = %g, det = %g)', trace(A), det(A));
end
P = [[1; 0], A*[1; 0]/w0];
B = P\A*P;                                    % [0 -w0; w0 0]
g = @(u, v) P\f(xs(:) + P*[u; v]) - B*[u; v]; % parte no lineal [F; G]
F = @(u, v) [1 0]*g(u, v);   G = @(u, v) [0 1]*g(u, v);
d_uu  = @(K) (K(h, 0) - 2*K(0, 0) + K(-h, 0))/h^2;
d_vv  = @(K) (K(0, h) - 2*K(0, 0) + K(0, -h))/h^2;
d_uv  = @(K) (K(h, h) - K(h, -h) - K(-h, h) + K(-h, -h))/(4*h^2);
d_uuu = @(K) (K(2*h, 0) - 2*K(h, 0) + 2*K(-h, 0) - K(-2*h, 0))/(2*h^3);
d_vvv = @(K) (K(0, 2*h) - 2*K(0, h) + 2*K(0, -h) - K(0, -2*h))/(2*h^3);
d_uvv = @(K) ((K(h, h) - K(-h, h)) - 2*(K(h, 0) - K(-h, 0)) + (K(h, -h) - K(-h, -h)))/(2*h^3);
d_uuv = @(K) ((K(h, h) - K(h, -h)) - 2*(K(0, h) - K(0, -h)) + (K(-h, h) - K(-h, -h)))/(2*h^3);
l1 = (d_uuu(F) + d_uvv(F) + d_uuv(G) + d_vvv(G))/16 + ...
     (d_uv(F)*(d_uu(F) + d_vv(F)) - d_uv(G)*(d_uu(G) + d_vv(G)) - d_uu(F)*d_uu(G) + d_vv(F)*d_vv(G))/(16*w0);
end
