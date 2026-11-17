%% C9_Ej6_GananciaVariable -- Notas: sección 9.5 (una ganancia variable)
% QUÉ HACE   x1' = -x1 - g(t) x2, x2' = x1 - x2 con V = x1^2 + (1 + g) x2^2. Compara
%            ||x(t)|| con la cota sqrt(1 + k) exp(-(t - t0)/(2(1 + k))) y grafica el
%            coeficiente 2 + 2g - g' para una g lenta y una rápida.
% OBSERVE    Con g' <= g la cota se cumple con holgura; con la g rápida el coeficiente se
%            vuelve negativo y V deja de ser certificado (no por eso el sistema es inestable).
% ESPERADO   Peor cociente ||x||/cota = 0.63; coeficiente -2 en t = 0 con la g rápida.
% EXPLORE    Calcule los multiplicadores de Floquet con la g rápida (problema de la ganancia rápida).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:ganancia]
k = 1.5;  g = @(t) 1 + 0.5*sin(t);  gp = @(t) 0.5*cos(t);
fprintf('min (g - g'') = %.3f  (>= 0)\n', min(g(linspace(0, 2*pi, 1e5)) - gp(linspace(0, 2*pi, 1e5))));
peor = 0;
for t0 = [0 3 7]
    for th = linspace(0, pi, 7)
        q = linspace(t0, t0 + 20, 2001);
        [~, X] = ode45(@(t, x) [-x(1) - g(t)*x(2); x(1) - x(2)], q, [cos(th); sin(th)], opc);
        cota = sqrt(1 + k)*exp(-(q' - t0)/(2*(1 + k)));
        peor = max(peor, max(sqrt(sum(X.^2, 2))./cota));
    end
end
fprintf('peor ||x(t)||/cota = %.3f  (<= 1)\n', peor);
gr = @(t) (1 + sin(10*t))/2;  grp = @(t) 5*cos(10*t);
fprintf('g rápida: 2 + 2g - g'' en t = 0 vale %.1f\n', 2 + 2*gr(0) - grp(0));
% [fin:ganancia]

t = linspace(0, 2*pi, 2000);
fig = estiloFigura(700, 360);  plot(t, 2 + 2*g(t) - gp(t), t, 2 + 2*gr(t) - grp(t), [0 2*pi], [2 2], 'k--');
grid on;  xlabel('$t$');  title('$2+2g-\dot g$');  legend('$g$ lenta', '$g$ r\''apida');
