%% C6_Ej5_Imperfectas -- Notas: sección 6.4 (cuáles sobreviven a una perturbación)
% QUÉ HACE   Agrega una constante pequeña al campo de las tres formas normales y
%            calcula los equilibrios con roots para una malla de mu:
%              silla-nodo    x' = mu - x^2 + eps
%              transcrítica  x' = mu x - x^2 + eps
%              horquilla     x' = mu x - x^3 + h
% OBSERVE    La silla-nodo solo se corre; la transcrítica se separa (eps > 0) o se
%            vuelve dos sillas-nodo (eps < 0); la horquilla se parte en una rama
%            continua y una silla-nodo aislada.
% ESPERADO   eps = -0.12: sillas-nodo en mu = +-0.6928.  h = 0.1: silla-nodo en
%            mu = 3 (h/2)^(2/3) = 0.4072.
% EXPLORE    Ponga h < 0. ¿Hacia qué lado queda la rama continua?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:imperfecta]
mu = linspace(-1.5, 1.5, 601);
casos = {@(m, e) [-1 0 m + e], @(m, e) [-1 m e], @(m, e) [-1 0 m e]};   % coeficientes en x
pert  = [0.4, -0.12, 0.1];
fig = estiloFigura(1300, 420);
for c = 1:3
    subplot(1, 3, c);  hold on;
    for e = [0 pert(c)]
        for m = mu
            z = roots(casos{c}(m, e));  z = real(z(abs(imag(z)) < 1e-9));
            plot(m*ones(size(z)), z, '.', 'Color', [0.55 0.55 0.55]*(e == 0) + [30 90 168]/255*(e ~= 0), 'MarkerSize', 4);
        end
    end
    grid on;  xlabel('$\mu$');  ylabel('$x^*$');
end
fprintf('transcrítica, eps = -0.12: sillas-nodo en mu = +-%.4f\n', 2*sqrt(0.12));
fprintf('horquilla, h = 0.1: silla-nodo aislada en mu = %.4f\n', 3*(0.1/2)^(2/3));
% [fin:imperfecta]
subplot(1, 3, 1);  title('Silla-nodo $+\varepsilon$');
subplot(1, 3, 2);  title('Transcr\''itica $+\varepsilon$');
subplot(1, 3, 3);  title('Horquilla $+h$');
