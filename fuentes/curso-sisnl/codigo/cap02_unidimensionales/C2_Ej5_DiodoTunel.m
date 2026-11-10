%% C2_Ej5_DiodoTunel -- Notas: sección 2.6 (un circuito con memoria)
% QUÉ HACE   Circuito RC con diodo túnel, C v' = (E - v)/R - h(v), con E = 1.2 V,
%            R = 1.5 kOhm, C = 2 pF (t en ns). Halla los equilibrios como
%            intersecciones de la característica con la recta de carga, los
%            clasifica y simula desde v(0) = 0, 0.1, ..., 1 V.
% OBSERVE    Hay tres equilibrios: dos estables y uno inestable en medio. El del
%            medio es la frontera entre las dos regiones de atracción: el
%            circuito "recuerda" de qué lado del umbral se dejó.
% ESPERADO   v* = 0.0626, 0.2854, 0.8844 V;  f'(v*) = -3.956, +1.487, -1.770 1/ns;
%            tau = 0.253, 0.673, 0.565 ns.
% EXPLORE    Busque el intervalo de E con tres equilibrios (C2_Ej6). ¿Qué pasa
%            si R = 0.5 kOhm?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:equilibrios]
[h, dh] = diodoTunel();
E = 1.2;  R = 1.5;  C = 2;
f = @(v) ((E - v)/R - h(v))/C;                       % V/ns
vs = [fzero(f, [0 0.15]), fzero(f, [0.15 0.5]), fzero(f, [0.5 1.2])];
fprintf('   v* [V]   i* [mA]   f''(v*) [1/ns]   tau [ns]\n');
for v = vs
    lam = -(1/R + dh(v))/C;
    tipos = {'inestable', 'estable'};
    fprintf('  %7.4f  %7.4f   %+10.3f   %8.3f   %s\n', v, h(v), lam, 1/abs(lam), tipos{1 + (lam < 0)});
end
% [fin:equilibrios]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1); vv = linspace(-0.05, 1.15, 600);
plot(vv, h(vv), vv, (E - vv)/R, '--'); hold on; plot(vs, h(vs), 'ko', 'MarkerFaceColor', 'w');
grid on; ylim([-0.2 1.4]); xlabel('$v$ [V]'); ylabel('$i$ [mA]'); legend('$h(v)$', '$(E-v)/R$');
subplot(1, 2, 2); hold on;
for v0 = 0:0.1:1
    [t, v] = ode45(@(t, v) f(v), [0 6], v0, odeset('RelTol', 1e-9, 'AbsTol', 1e-11)); plot(t, v);
end
for v = vs, plot([0 6], [v v], 'k--', 'LineWidth', 0.7); end
grid on; xlabel('$t$ [ns]'); ylabel('$v(t)$ [V]'); title('dos estados finales');

