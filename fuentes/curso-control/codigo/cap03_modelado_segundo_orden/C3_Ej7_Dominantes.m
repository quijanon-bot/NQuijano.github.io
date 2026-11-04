%% C3_Ej7_Dominantes -- Notas: sección 3.9 (orden superior y polos dominantes)
% QUÉ HACE   Compara sistemas de tercer orden con su aproximación de segundo
%            orden: un caso en el que el tercer polo se puede despreciar y
%            otro en el que no, por un cero y un polo cercanos.
% OBSERVE    La aproximación debe conservar la ganancia DC (el valor final).
% ESPERADO   20/((s+10)(s^2+2s+2)): 4.3 % vs 4.3 %;
%            62.5(s+2.5)/((s^2+6s+25)(s+6.25)): 38 % (completo),
%            54.5 % (sin el polo), 9.5 % (solo los dominantes)
% EXPLORE    Mueva el cero de -2.5 a -10: ¿cuál aproximación mejora?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:dominantes]
s  = tf('s');
T3 = 20/((s + 10)*(s^2 + 2*s + 2));
T2 = 2/(s^2 + 2*s + 2);                    % 20/10 = 2: misma ganancia DC
[stepinfo(T3).Overshoot, stepinfo(T2).Overshoot]
residue(20, conv([1 10 0], [1 2 2]))       % el residuo del polo en -10 es -1/41
% [fin:dominantes]

% [ini:cero]
Tc = 62.5*(s + 2.5)/((s^2 + 6*s + 25)*(s + 6.25));
Ta = 10*(s + 2.5)/(s^2 + 6*s + 25);         % sin el polo en -6.25
Tb = 25/(s^2 + 6*s + 25);                   % solo los polos dominantes
for T = {Tc, Ta, Tb}
    S = stepinfo(T{1});
    fprintf('%%OS = %5.1f   ts = %.2f s\n', S.Overshoot, S.SettlingTime);
end
% [fin:cero]
fig = estiloFigura(900, 420);
step(Tc, Ta, '--', Tb, ':', 3); grid on; legend('completo', 'sin el polo', 'dominantes');
