%% C4_Ej6_Estructural -- Notas: sección 4.4 (qué retratos sobreviven a una perturbación)
% QUÉ HACE   (1) Perturba el centro [0 -1; 1 0] con +-epsilon*I y compara una
%            trayectoria de cada uno. (2) Perturba el nodo impropio [-1 1; 0 -1]
%            con -epsilon en la posición (2,1).
% OBSERVE    (1) Con epsilon = 0.05 el centro se vuelve foco estable o inestable: la
%            estabilidad cambia. (2) El nodo impropio se vuelve foco (lambda = -1 +-
%            j sqrt(epsilon)) pero sigue siendo estable.
% ESPERADO   (1) Re(lambda) = +-0.05. (2) Im(lambda) = sqrt(epsilon).
% EXPLORE    Perturbe el nodo [-6 0; 0 -2] con una matriz aleatoria 0.05*randn(2).
%            ¿Cambia el tipo? Repita 1000 veces y cuente.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:perturbar]
epsilon = 0.05;
for s = [-1 1]
    A = [s*epsilon -1; 1 s*epsilon];
    fprintf('centro + (%+.2f) I: %s, lambda = %s\n', s*epsilon, clasificarEquilibrio(A), num2str(eig(A).', '%.3f  '));
end
for e = [0 epsilon 0.5]
    A = [-1 1; -e -1];
    fprintf('nodo impropio, eps = %.2f: %s, lambda = %s\n', e, clasificarEquilibrio(A), num2str(eig(A).', '%.4f  '));
end
% [fin:perturbar]

fig = estiloFigura(1000, 440);
ax = subplot(1, 2, 1);  hold on;
for s = [0 -1 1]
    A = [s*epsilon -1; 1 s*epsilon];
    [~, X] = ode45(@(t, x) A*x, [0 40*(s ~= 0) + 2*pi*(s == 0)], [0.6; 0]);
    plot(X(:, 1), X(:, 2));
end
axis equal;  grid on;  legend('centro', '$\varepsilon=-0.05$', '$\varepsilon=+0.05$');  title('Un centro no es robusto');
ax = subplot(1, 2, 2);  hold on;
for e = [0 0.5]
    for x0 = [[-1; 1], [1; -1], [-1; 0.3], [1; -0.3]]
        [~, X] = ode45(@(t, x) [-1 1; -e -1]*x, [0 20], x0);  plot(X(:, 1), X(:, 2), 'Color', [0.4 0.4 0.4]*(e == 0) + [30 90 168]/255*(e > 0));
    end
end
axis equal;  grid on;  title('Nodo impropio $\to$ foco (estable igual)');
