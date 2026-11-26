%% C11_Ej2_SenalesL2 -- Notas: sección 11.2 (señales de energía finita)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Compara la norma L-infinito (amplitud) con la norma L2 (energía)
%            para tres señales: 1/sqrt(1+t), exp(-t/4) y un tren de pulsos
%            triangulares de altura k y base 1/k^4.
% OBSERVE    1/sqrt(1+t) -> 0 pero su energía en [0,T] es ln(1+T): crece sin
%            límite. Los pulsos no están acotados y su energía total es pi^2/18.
% ESPERADO   energía de 1/sqrt(1+t) en [0, 1e6]: 13.8155;  de exp(-t/4): 2;
%            energía de los pulsos: sum 1/(3k^2) = pi^2/18 = 0.5483.
% EXPLORE    Cambie la base de los pulsos a 1/k^2: ¿siguen teniendo energía finita?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:energia]
energia = @(w, T) integral(@(t) w(t).^2, 0, T);     % ||w||^2 en L2[0,T]
fprintf('1/sqrt(1+t):  energía en [0, 1e6] = %.4f  (= ln(1+1e6))\n', ...
        log1p(1e6));
fprintf('exp(-t/4):    energía en [0, inf) = %.4f\n', energia(@(t) exp(-t/4), Inf));
% pulso triangular de altura k y base 1/k^4: energía k^2 (1/k^4)/3 = 1/(3 k^2)
Ek = arrayfun(@(k) energia(@(t) k*max(1 - abs(t - 1/(2*k^4))*2*k^4, 0), 1/k^4), 1:6);
fprintf('pulsos: energía de los 6 primeros = %s\n', mat2str(Ek, 4));
fprintf('suma infinita = pi^2/18 = %.4f\n', pi^2/18);
% [fin:energia]

% ---- Figura de las notas (fig:pa-senales) ----------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
t = linspace(0, 40, 2001);
fig = estiloFigura(1200, 440);
subplot(1, 2, 1);  hold on;
h = [plot(t, 1./sqrt(1 + t), 'Color', az), plot(t, exp(-t/4), 'Color', ve)];
try, yyaxis right; set(gca, 'YColor', co); catch, end   % eje derecho en coral (Octave no tiene yyaxis: mismo eje)
h = [h, plot(t, log1p(t), '--', 'Color', co)];
plot(t, 2*(1 - exp(-t/2)), ':', 'Color', ve, 'LineWidth', 1.4);
ylabel('energ\''ia acumulada');
grid on;  box on;  xlabel('$t$');  title('se apaga, pero no tiene energ\''ia finita');
legend(h, '$(1+t)^{-1/2}$', '$e^{-t/4}$', 'energ\''ia en $[0,t]$: $\ln(1+t)$', 'Location', 'southoutside', 'Orientation', 'horizontal');
subplot(1, 2, 2);  hold on;
tt = linspace(0, 6.5, 40001);  yy = zeros(size(tt));
for k = 1:6                                   % triángulos de altura k y base 1/k^4 centrados en t = k
    yy = max(yy, k*max(1 - abs(tt - k)/(1/(2*k^4)), 0));
end
plot(tt, yy, 'Color', vi, 'LineWidth', 1.2);
grid on;  box on;  xlabel('$t$');  title('no acotada, energ\''ia $\pi^2/18$');
