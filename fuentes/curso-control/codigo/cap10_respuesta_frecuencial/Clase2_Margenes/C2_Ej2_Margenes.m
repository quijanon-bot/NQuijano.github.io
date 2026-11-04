%% C2_Ej2_Margenes -- Notas: sección 10.7 (márgenes, asintótico contra exacto) + video V3
% G'(s) = 10000/((s+1)(s+10)(s+100)) = 10/((s+1)(s/10+1)(s/100+1))
% ESPERADO  asintótico: PM ~ 45° (w = 10), GM ~ 20 dB (w = 31.6)
%           exacto:     PM = 54.9° (w = 7.80), GM = 21.7 dB (w = 33.3)
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

% [ini:margenes]
G = zpk([], [-1 -10 -100], 1e4);
[Gm, Pm, Wcg, Wcp] = margin(G);          % OJO: Gm en VECES; Wcg = w_GM; Wcp = w_PM
GMdB = 20*log10(Gm)                      % 21.74 dB
fprintf('GM = %.2f dB en w_GM = %.2f;  PM = %.2f° en w_PM = %.2f\n', GMdB, Wcg, Pm, Wcp);
% [fin:margenes]

% Asintótico (forma de Bode)
w = logspace(-1, 3.5, 800);
[mA, fA] = bodeAsintotico(w, 10, 0, [1 -1; 10 -1; 100 -1]);
PM_a = 180 + interp1(w, fA, 10)          % ~45
GM_a = -interp1(w, mA, 10^1.5)           % ~20 dB
fig = estiloFigura(1000, 650);  margin(G);  grid on;
exportgraphics(fig, 'C2_Ej2_margin.png', 'Resolution', 200);
allmargin(G)

%% Video V3: construcción asintótica término a término
fig = estiloFigura(1280, 720);
ax1 = subplot(2,1,1); hold on; grid on; set(ax1, 'XScale', 'log'); ylim([-110 35]); ylabel('dB'); xlim([0.1 3000]);
ax2 = subplot(2,1,2); hold on; grid on; set(ax2, 'XScale', 'log'); ylim([-280 15]); ylabel('fase ($^\circ$)'); xlabel('$\omega$ (rad/s)'); xlim([0.1 3000]);
terms = {10, [1 -1], [10 -1], [100 -1]};
cols  = {[224 159 62]/255, [209 73 91]/255, [30 90 168]/255, [108 74 182]/255};
[mR, fR] = bode(G, w);  mR = 20*log10(squeeze(mR));  fR = squeeze(fR);
v = abrirVideo('V3_asintotico_margenes', 30);
for st = 1:6
    switch st
        case 1,       [m, f] = bodeAsintotico(w, 10, 0);             c = cols{1}; lw = 1.5;
        case {2,3,4}, [m, f] = bodeAsintotico(w, 1, 0, terms{st});   c = cols{st}; lw = 1.5;
        case 5,       m = mA; f = fA; c = [20 33 61]/255; lw = 3;
        case 6,       m = mR; f = fR; c = [42 157 143]/255; lw = 2;
    end
    h1 = plot(ax1, w, m, 'Color', c, 'LineWidth', lw);  h2 = plot(ax2, w, f, 'Color', c, 'LineWidth', lw);
    if st == 6, set([h1 h2], 'LineStyle', '--'); end
    for k = 1:45, drawnow; writeVideo(v, getframe(fig)); end
end
plot(ax1, 10, 0, 'go', 'MarkerFaceColor', 'g');     plot(ax2, 10, -135, 'go', 'MarkerFaceColor', 'g');
plot(ax1, 31.6, -20, 'ro', 'MarkerFaceColor', 'r');  plot(ax2, 31.6, -180, 'ro', 'MarkerFaceColor', 'r');
sgtitle('Asint\''otico: PM $\approx 45^\circ$, GM $\approx 20$ dB  |  real: $54.9^\circ$, 21.7 dB', 'Interpreter', 'latex');
for k = 1:60, drawnow; writeVideo(v, getframe(fig)); end
close(v);
