%% C11_Ej2_SenalesL2 -- Notas: sección 11.2 (señales de energía finita)
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

t = linspace(0, 40, 2001);
fig = estiloFigura(1000, 400);
subplot(1,2,1); plot(t, 1./sqrt(1 + t), t, log1p(t), '--'); grid on;
legend('$1/\sqrt{1+t}$', 'energ\''ia en $[0,t]$'); xlabel('$t$');
subplot(1,2,2); hold on; grid on;
for k = 1:6
    b = 1/k^4;  plot([k - b/2, k, k + b/2], [0 k 0]);
end
xlabel('$t$'); title('altura $k$, base $1/k^4$');
