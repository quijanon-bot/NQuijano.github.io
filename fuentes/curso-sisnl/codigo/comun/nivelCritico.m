function [cs, xs] = nivelCritico(V, Vd, xl, yl, n, rmin)
% NIVELCRITICO  Estimado en malla de c* = inf{ V(x) : x ~= 0, Vdot(x) >= 0 } (capítulos 7 y 8).
%   [cs, xs] = nivelCritico(V, Vd, [x1min x1max], [x2min x2max])
%   V y Vd son funciones vectorizadas de (X1, X2):  V = @(X1, X2) ...,  Vd = @(X1, X2) ...
%   Devuelve el mínimo de V sobre los puntos de la malla (n x n, 801 por defecto) con
%   Vd >= 0 y ||x|| >= rmin (1e-2 por defecto), y el punto xs donde se alcanza.
%   Todo conjunto de nivel {V <= c} con c < cs (la componente que contiene al origen)
%   es un estimado de la región de atracción (Proposición de la sección 8.5 de las notas).
%   OJO: es un estimado en malla; refine la malla cerca de xs para más cifras.
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
if nargin < 5 || isempty(n), n = 801; end
if nargin < 6, rmin = 1e-2; end
[X1, X2] = meshgrid(linspace(xl(1), xl(2), n), linspace(yl(1), yl(2), n));
VV = V(X1, X2);  DD = Vd(X1, X2);
m = (DD >= 0) & (X1.^2 + X2.^2 >= rmin^2);
if ~any(m(:)), cs = Inf; xs = [NaN; NaN]; return; end
VV(~m) = Inf;
[cs, k] = min(VV(:));
xs = [X1(k); X2(k)];
end
