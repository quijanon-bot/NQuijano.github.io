%% C4_Ej3_Comparacion -- Notas: sección 10.11 (adelanto vs. atraso) + video V8
% Escalón, error ante rampa, esfuerzo de control y ancho de banda.
% ESPERADO  BW: sin compensar 9.8, adelanto 14.5, atraso 2.8 rad/s
%           u(0+) ante escalón: adelanto 4.03 (= alpha), atraso 0.11 (= 1/alpha)
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end
Gp  = zpk([], [0 -2], 40);
Gld = disenoAdelanto(Gp, 45, 10);  Glg = disenoAtraso(Gp, 45, 5);
nombres = {'sin compensar', 'adelanto', 'atraso'};  C = {tf(1), Gld, Glg};
fig = estiloFigura(1300, 450);
t = linspace(0, 12, 3000);  t2 = linspace(0, 60, 6000);
% [ini:comparacion]
for i = 1:3
    L = C{i}*Gp;
    T = feedback(L, 1);                     % y/r
    U = feedback(C{i}, Gp);                 % u/r = Gc/(1 + Gc Gp): el esfuerzo
    subplot(1,3,1); hold on; plot(t, step(T, t));
    subplot(1,3,2); hold on; plot(t2, t2(:) - lsim(T, t2, t2));      % error ante rampa
    subplot(1,3,3); hold on; plot(t(t<3), step(U, t(t<3)));
    u0 = evalfr(U, 1e8);                    % teorema del valor inicial: u(0+) = U(s -> inf)
    fprintf('%-14s BW = %6.2f rad/s   u(0+) = %.2f\n', nombres{i}, bandwidth(T), u0);
end
% [fin:comparacion]
subplot(1,3,1); grid on; title('escal\''on'); legend(nombres);
subplot(1,3,2); grid on; ylim([0 0.35]); yline(0.05, '--'); title('error ante rampa');
subplot(1,3,3); grid on; title('esfuerzo $u(t)$');
exportgraphics(fig, 'C4_comparacion.png', 'Resolution', 200);

%% Video V8: seguimiento de rampa
t = linspace(0, 20, 2400);  r = t(:);
y1 = lsim(feedback(Gld*Gp, 1), r, t);  y2 = lsim(feedback(Glg*Gp, 1), r, t);
fig = estiloFigura(1280, 720);
subplot(1,2,1); hold on; grid on; axis([0 4 0 4]); plot(t, r, 'k--');
h1 = plot(NaN, NaN);  h2 = plot(NaN, NaN);
legend('r = t', 'adelanto', 'atraso', 'Location', 'northwest'); title('zoom: primeros 4 s');
subplot(1,2,2); hold on; grid on; axis([0 20 0 0.4]); yline(0.05, '--');
e1 = plot(NaN, NaN);  e2 = plot(NaN, NaN);  title('error r - y');
v = abrirVideo('V8_adelanto_vs_atraso', 30);
n = 360;
for k = 1:n
    i = min(numel(t), round(numel(t)*k/(n-30)));
    set(h1, 'XData', t(1:i), 'YData', y1(1:i));  set(h2, 'XData', t(1:i), 'YData', y2(1:i));
    set(e1, 'XData', t(1:i), 'YData', r(1:i)-y1(1:i));  set(e2, 'XData', t(1:i), 'YData', r(1:i)-y2(1:i));
    sgtitle(sprintf('t = %4.1f s   error adelanto = %.3f   error atraso = %.3f', t(i), r(i)-y1(i), r(i)-y2(i)));
    drawnow;  writeVideo(v, getframe(fig));
end
close(v);
