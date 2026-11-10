%% C7_Ej9_InerciaObservabilidad -- Notas: sección 7.7 (lo que la ecuación detecta)
% QUÉ HACE   (1) A(mu) = [-1 2; 0 mu], Q = I: resuelve A'P + PA = -Q para varios mu y
%            cuenta los valores propios negativos de P.
%            (2) Dos masas unidas por un resorte kappa, con amortiguador b solo en la
%            masa 1: V = energía cumple A'P + PA = -C'C con C = [0 sqrt(b) 0 0].
%            Compara kappa = 0 y kappa = 0.4.
% OBSERVE    (1) Para mu > 0 la ecuación SÍ tiene solución, pero P es indefinida (tantos
%            valores propios negativos como valores propios inestables de A). En mu = 0
%            y mu = 1 no hay solución única.  (2) Con Q = C'C >= 0 y P > 0, A es Hurwitz
%            solo si (A, C) es observable.
% ESPERADO   (1) mu = -0.5: P > 0; mu = 0.5: un valor propio negativo.
%            (2) kappa = 0: rango 2, max Re lambda = 0; kappa = 0.4: rango 4, Hurwitz.
% EXPLORE    En (2), ¿qué pasa si el amortiguador se pone en la masa 2 y kappa = 0?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:inercia]
warning('off', 'ecuacionLyapunov:singular');
for mu = [-0.5 -0.01 0 0.5 1 1.5]
    P = ecuacionLyapunov([-1 2; 0 mu], eye(2));
    if any(isnan(P(:)))
        fprintf('mu = %5.2f: sin solución única (lambda_i + lambda_j = 0)\n', mu);
    else
        fprintf('mu = %5.2f: eig(P) = (%9.3f, %9.3f) -> %d negativo(s)\n', mu, eig(P), sum(eig(P) < 0));
    end
end
warning('on', 'ecuacionLyapunov:singular');
% [fin:inercia]

% [ini:masas]
k1 = 1;  k2 = 1;  b = 0.3;  C = [0 sqrt(b) 0 0];
for ka = [0 0.4]
    A = [0 1 0 0; -(k1 + ka) -b ka 0; 0 0 0 1; ka 0 -(k2 + ka) 0];
    P = 0.5*[k1 + ka 0 -ka 0; 0 1 0 0; -ka 0 k2 + ka 0; 0 0 0 1];
    Ob = [C; C*A; C*A^2; C*A^3];
    fprintf('kappa = %.1f: |A''P + PA + C''C| = %.1e, rango(O) = %d, max Re eig(A) = %.4f\n', ...
            ka, norm(A'*P + P*A + C'*C), rank(Ob), max(real(eig(A))));
end
% [fin:masas]
