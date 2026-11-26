%% C10_Ej10_Adaptativo -- Notas: sección 10.5 (control adaptativo y Barbalat)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Simula e' = -e + theta w(t), theta' = -e w(t) desde (1, 1) con
%            w = sin t (excitación persistente) y w = e^{-0.3t} (se apaga).
%            Verifica V = e^2 + theta^2 no creciente y la cota de ddot V.
% OBSERVE    En los dos casos e -> 0 (Barbalat). theta -> 0 solo con w = sin t.
% ESPERADO   w = sin t: |e(40)| < 1e-3, |theta(40)| < 0.05. w = e^{-0.3t}: theta -> -0.11.
% EXPLORE    Pruebe w = 1 (constante). ¿Es persistentemente excitante? ¿Qué pasa con theta?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:adaptativo]
ws = {@(t) sin(t), @(t) exp(-0.3*t)};  nom = {'sin t', 'e^{-0.3t}'};
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
fig = estiloFigura(1100, 420);
for i = 1:2
    w = ws{i};
    [t, Z] = ode45(@(t, z) [-z(1) + z(2)*w(t); -z(1)*w(t)], [0 40], [1; 1], opc);
    V = sum(Z.^2, 2);
    fprintf('w = %-9s e(40) = %+.2e, theta(40) = %+.4f, ¿V no crece? %d\n', nom{i}, Z(end, 1), Z(end, 2), all(diff(V) < 1e-9));
    subplot(1, 2, i);  plot(t, Z);  grid on;  xlabel('$t$');  legend('$e$', '$\theta$');  title(['$\omega=' nom{i} '$']);
end
% [fin:adaptativo]

% ---- Figura de las notas (fig:av-adaptativo) ------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
clf(fig);  set(fig, 'Position', [80 80 1200 440]);         % reemplaza la gráfica del bloque
for i = 1:2
    w = ws{i};  [t, Z] = ode45(@(t, z) [-z(1) + z(2)*w(t); -z(1)*w(t)], [0 40], [1; 1], opc);  ts{i} = t;  Zs{i} = Z;
    subplot(1, 2, i);  plot(ts{i}, Zs{i}(:, 1), 'Color', az);  hold on;  plot(ts{i}, Zs{i}(:, 2), 'Color', co);
    ylim([-1 1.2]);  grid on;  box on;  xlabel('$t$');  legend('$e$', '$\theta$');
    title(sprintf('$\\omega=%s$,  $\\theta(40)=%.2f$', strrep(nom{i}, 'sin t', '\sin t'), Zs{i}(end, 2)));
end
