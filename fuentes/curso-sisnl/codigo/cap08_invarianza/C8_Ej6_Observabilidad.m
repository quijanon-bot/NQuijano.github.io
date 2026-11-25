%% C8_Ej6_Observabilidad -- Notas: sección 8.4 (M es el subespacio no observable)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Las dos masas del capítulo 7 (resortes unitarios a las paredes, acople kappa,
%            amortiguador b = 0.3 solo en la masa 1), x = (q1, v1, q2, v2), C = [0 sqrt(b) 0 0].
%            Calcula la matriz de observabilidad, su rango y su espacio nulo (= M).
% OBSERVE    Con kappa = 0, M = ker O = {q1 = v1 = 0}: la masa 2 oscila para siempre.
% ESPERADO   kappa = 0.4: rango 4, A Hurwitz. kappa = 0: rango 2, ker O = span(e3, e4).
% EXPLORE    Ponga el amortiguador en la masa 2: C = [0 0 0 sqrt(b)]. ¿Qué cambia?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:observabilidad]
b = 0.3;  C = [0 sqrt(b) 0 0];
for kappa = [0.4 0]
    A = [0 1 0 0; -(1 + kappa) -b kappa 0; 0 0 0 1; kappa 0 -(1 + kappa) 0];
    O = [C; C*A; C*A^2; C*A^3];
    fprintf('kappa = %.1f: rango(O) = %d, max Re(eig A) = %+.3f\n', kappa, rank(O), max(real(eig(A))));
    N = null(O);
    if ~isempty(N)
        fprintf('  ker O (= M), base por columnas:\n');  disp(round(N*1e6)/1e6);
        fprintf('  ||(A N)_{1:2,:}|| = %.1e  (A N sigue en {q1 = v1 = 0}: es invariante)\n', norm(A(1:2, :)*N));
    end
end
% [fin:observabilidad]
