%% C8_Ej9_RegionLaSalle -- Notas: sección 8.5 (estimar la región de atracción con Vdot <= 0)
% QUÉ HACE   x1' = x2, x2' = -x1 + x1^3 - x2 con V = x1^2/2 - x1^4/4 + x2^2/2 (Vdot = -x2^2).
%            El nivel de las sillas es 1/4; LaSalle certifica {V < 1/4} ∩ {|x1| < 1}.
%            Muestra también nivelCritico con una Vdot ESTRICTA (van der Pol invertido, cap. 7).
% OBSERVE    (0, 0.7), con V = 0.245, converge; un punto de la otra componente escapa.
% ESPERADO   V(+-1, 0) = 0.25. nivelCritico para van der Pol invertido: c* ~ 2.30.
% EXPLORE    ¿Qué da nivelCritico con la V de este sistema? ¿Por qué no sirve aquí?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:region]
f = @(t, x) [x(2); -x(1) + x(1)^3 - x(2)];
V = @(x1, x2) x1.^2/2 - x1.^4/4 + x2.^2/2;
fprintf('V en las sillas = %.3f\n', V(1, 0));
[~, X] = ode45(f, [0 100], [0; 0.7], opc);
fprintf('desde (0, 0.7), V = %.3f: ||x(100)|| = %.1e\n', V(0, 0.7), norm(X(end, :)));
salir = odeset(opc, 'Events', @(t, x) eventoODE(abs(x(1)) - 5, 1, 0));
[te, ~] = ode45(f, [0 30], [1.1; 0.1], salir);
fprintf('desde (1.1, 0.1), V = %.3f < 1/4 pero fuera de |x1| < 1: |x1| = 5 en t = %.2f\n', V(1.1, 0.1), te(end));
% Con una Vdot estricta se usa nivelCritico (mínimo de V donde Vdot >= 0). La malla debe
% cubrir solo el dominio D donde se estudia V: puntos de otras componentes dan un c* menor.
Vq  = @(x1, x2) 1.5*x1.^2 - x1.*x2 + x2.^2;                  % x'Px del capítulo 7
Vdq = @(x1, x2) -(x1.^2 + x2.^2) - x1.^3.*x2 + 2*x1.^2.*x2.^2;
[cs, xs] = nivelCritico(Vq, Vdq, [-3 3], [-3 3], 1201);
fprintf('van der Pol invertido: c* en malla = %.3f en x = (%.2f, %.2f)\n', cs, xs);
% [fin:region]
