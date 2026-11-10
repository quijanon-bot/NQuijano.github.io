%% C2_Ej3_Potencial -- Notas: sección 2.4 (la bolita que baja: un adelanto de Lyapunov)
% QUÉ HACE   Calcula el potencial V(x) = -int_0^x f(s) ds de x' = sin x, es decir
%            V(x) = cos x - 1, y lo evalúa a lo largo de varias soluciones.
% OBSERVE    V(x(t)) nunca crece: dV/dt = -f(x)^2 <= 0. Las soluciones bajan por
%            la gráfica de V y se detienen en sus mínimos (x = +-pi), que son los
%            equilibrios estables.
% ESPERADO   max dV/dt a lo largo de las soluciones <= 0 (salvo error numérico, < 1e-6).
%            V(pi) = -2.
% EXPLORE    Escriba el potencial del diodo túnel (C2_Ej5) y verifique que sus
%            mínimos son los dos equilibrios estables.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:potencial]
f = @(x) sin(x);  V = @(x) cos(x) - 1;
maxdV = -inf;  t = linspace(0, 8, 801)';
fig = estiloFigura(1000, 400); subplot(1, 2, 2); hold on;
for x0 = [-3 -2 -1 -0.2 0.2 1 2 3]
    [~, x] = ode45(@(t, x) f(x), t, x0, odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
    dV = gradient(V(x), t);
    maxdV = max(maxdV, max(dV));
    plot(t, V(x));
end
fprintf('max dV/dt a lo largo de las soluciones = %.1e  (debe ser <= 0)\n', maxdV);
% [fin:potencial]
grid on; xlabel('$t$'); ylabel('$V(x(t))$'); title('$V$ nunca crece');
subplot(1, 2, 1); s = linspace(-2*pi, 2*pi, 801); plot(s, V(s)); grid on;
xlabel('$x$'); ylabel('$V(x)=\cos x-1$'); title('potencial de $\dot x=\sin x$');
