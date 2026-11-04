%% C3_Ej3_AjusteGanancia -- Notas: sección 10.10 (diseño ajustando la ganancia; adaptado de Nise)
% Gp(s) = 1/(s(s+20)(s+100)), Gc = Kc, meta: %OS = 20 %
% ESPERADO  zeta = 0.456 -> PM = 48.15° -> fase objetivo -131.85° en 13.56 rad/s
%           |2000 Gp| = -24.36 dB  ->  Kc = 33 056;  %OS logrado 19.9 %
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

% [ini:ajuste]
G0   = zpk([], [0 -20 -100], 1);
zeta = zetaDeOS(0.20)                                % 0.456
PMd  = pmDeZeta(zeta)                                % 48.15°
Fdes = -180 + PMd                                    % -131.85°
wd   = fzero(@(w) faseEn(G0, w) - Fdes, [1 30])      % 13.56 rad/s (la ganancia NO cambia la fase)
Kc   = 1/abs(evalfr(G0, 1j*wd))                      % 33 056: |Kc G0(j wd)| = 1 = 0 dB
% [fin:ajuste]

L = Kc*G0;
margenesTabla(L, 'Kc ajustado');
stepinfo(feedback(L, 1))
fig = estiloFigura(1000, 600);
subplot(1,2,1); margin(L); grid on;
subplot(1,2,2); step(feedback(L, 1), 0.8); grid on; title(sprintf('K_c = %.0f', Kc));
exportgraphics(fig, 'C3_ajuste_ganancia.png', 'Resolution', 200);

%% El precio: kv = Kc/2000 = 16.5. Si se exige kv = 40 con la ganancia sola:
L40 = 80000*G0;  margenesTabla(L40, 'Kc = 80000 (kv=40)');   % PM = 25.4°
stepinfo(feedback(L40, 1))                                   % %OS ~ 49 %: hace falta un compensador
