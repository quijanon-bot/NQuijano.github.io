%% C2_Ej9_Escape -- Notas: sección 2.9 (escape en tiempo finito)
% QUÉ HACE   Integra x' = x^2 (x0 = 0.25, 0.5, 1, 2) y x' = x^2 - 1 (varios x0) con
%            un EVENTO que detiene ode45 cuando |x| = 1000, y compara el instante
%            del evento con el tiempo de escape exacto.
% OBSERVE    Sin el evento (comente 'Events'), ode45 reduce el paso cerca de la
%            asíntota y termina con "Unable to meet integration tolerances": no es
%            un problema numérico, es que la solución deja de existir.
% ESPERADO   x' = x^2: t(|x| = 1000) = 1/x0 - 1/1000.
%            x' = x^2 - 1: x0 = 1.5 escapa en (1/2) ln 5 = 0.8047; x0 = 3 en
%            (1/2) ln 2 = 0.3466 (el evento llega unas 0.001 antes: |x| = 1000
%            no es infinito). La región de atracción de -1 es (-inf, 1).
% EXPLORE    ¿Qué devuelve ode45 desde x0 = 1 exactamente? ¿Y desde 1 + 1e-12?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:eventos]
XMAX = 1e3;
ev = @(t, x) deal(abs(x) - XMAX, 1, 0);           % [valor, terminal, dirección]
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', ev);
fprintf('x'' = x^2\n   x0     evento      1/x0 - 1/XMAX\n');
for x0 = [0.25 0.5 1 2]
    [~, ~, te] = ode45(@(t, x) x^2, [0 6], x0, opc);
    fprintf('  %4.2f   %9.6f   %9.6f\n', x0, te, 1/x0 - 1/XMAX);
end
fprintf('x'' = x^2 - 1\n   x0     escape exacto   evento\n');
for x0 = [1.05 1.5 3]
    [~, ~, te] = ode45(@(t, x) x^2 - 1, [0 4], x0, opc);
    fprintf('  %4.2f   %10.4f    %10.4f\n', x0, 0.5*log((x0 + 1)/(x0 - 1)), te);
end
% [fin:eventos]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1); hold on;
for x0 = [0.25 0.5 1 2]
    [t, x] = ode45(@(t, x) x^2, [0 6], x0, opc); plot(t, x); plot(1/x0*[1 1], [0 20], 'k--', 'LineWidth', 0.6);
end
ylim([0 20]); xlim([0 4.5]); grid on; xlabel('$t$'); ylabel('$x(t)$'); title('$\dot x=x^2$');
subplot(1, 2, 2); hold on;
for x0 = [-3 -2 -0.5 0.5 0.95 1.05 1.5 3]
    [t, x] = ode45(@(t, x) x^2 - 1, [0 4], x0, opc); plot(t, x);
end
plot([0 4], [-1 -1], 'k', [0 4], [1 1], 'k'); ylim([-3.2 4]); grid on; xlabel('$t$'); title('$\dot x=x^2-1$');
