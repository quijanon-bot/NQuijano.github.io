%% C8_Ej10_GradienteVariable -- Notas: sección 8.6 (el gradiente variable y su barrido)
% QUÉ HACE   x1' = x2, x2' = -(x1 + x2) - sin(x1 + x2). Con g = (a11 x1 + x2, x1 + x2):
%            V = a11 x1^2/2 + x1 x2 + x2^2/2, Vdot = (a11 - 2) x1 x2 - x1^2 - y sin y, y = x1 + x2.
%            [g1] a11 = 2: c* = pi^2/2. [barrido] área del estimado contra a11.
% OBSERVE    La elección "limpia" a11 = 2 no da el mayor estimado.
% ESPERADO   a11 = 2: c* = 4.935, área = pi^3 = 31.0. Mejor a11 ~ 1.46-1.48 (según la malla) con área ~ 37.4.
%            Con a11 = 1.1 el estimado colapsa.
% EXPLORE    Simule desde (6, -2), fuera del estimado. ¿Converge? ¿Qué dice eso del estimado?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:g1]
a11 = 2;
V  = @(x1, x2) a11*x1.^2/2 + x1.*x2 + x2.^2/2;
Vd = @(x1, x2) (a11 - 2)*x1.*x2 - x1.^2 - (x1 + x2).*sin(x1 + x2);
cs = nivelCritico(V, Vd, [-8 8], [-8 8], 1601);
fprintf('a11 = 2: c* en malla = %.3f (exacto pi^2/2 = %.3f), área = %.2f (pi^3 = %.2f)\n', ...
    cs, pi^2/2, pi*cs/sqrt(a11/4 - 1/4), pi^3);
% [fin:g1]

% [ini:barrido]
aa = 1.1:0.02:3;  area = zeros(size(aa));
for i = 1:numel(aa)
    Va  = @(x1, x2) aa(i)*x1.^2/2 + x1.*x2 + x2.^2/2;
    Vda = @(x1, x2) (aa(i) - 2)*x1.*x2 - x1.^2 - (x1 + x2).*sin(x1 + x2);
    area(i) = pi*nivelCritico(Va, Vda, [-12 12], [-12 12], 801)/sqrt(aa(i)/4 - 1/4);  % elipse {V <= c}
end
[amax, imax] = max(area);
fprintf('mejor a11 = %.2f con área %.1f; con a11 = 1.1 el área es %.3f\n', aa(imax), amax, area(1));
% [fin:barrido]

fig = estiloFigura(600, 420);  plot(aa, area, 2, pi^3, 'o', aa(imax), amax, 'p');  grid on;
xlabel('$a_{11}$');  ylabel('área de $\Omega_{c^*}$');
