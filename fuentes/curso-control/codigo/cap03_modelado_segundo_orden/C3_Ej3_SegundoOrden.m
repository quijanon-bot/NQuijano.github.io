%% C3_Ej3_SegundoOrden -- Notas: secciones 3.4 y 3.5 (segundo orden)
% QUÉ HACE   Dibuja la respuesta al escalón de wn^2/(s^2+2 zeta wn s+wn^2)
%            para varios zeta y compara las fórmulas del subamortiguado con
%            stepinfo.
% OBSERVE    stepinfo usa el tiempo de subida 10-90 %; la fórmula
%            (pi - beta)/wd es la de 0-100 %. El ts = 4/(zeta wn) es una cota
%            con la envolvente: el exacto puede ser algo menor o mayor.
% ESPERADO   zeta = 0.4, wn = 1: %OS = 25.4, tp = 3.43, tr(0-100) = 2.16,
%            ts(2 %) = 8.41 (fórmula: 10)
% EXPLORE    Fije zeta = 0.4 y duplique wn: ¿qué cambia y qué no?
clear; close all; clc;
if ~exist('segundoOrden', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:zetas]
s = tf('s');  wn = 1;
fig = estiloFigura(1000, 460);  hold on;
for zeta = [0 0.2 0.5 0.7 1 2]
    step(wn^2/(s^2 + 2*zeta*wn*s + wn^2), 12);
end
grid on; legend('$\zeta=0$', '0.2', '0.5', '0.7', '1', '2');
% [fin:zetas]

% [ini:formulas]
zeta = 0.4;  wn = 1;
F = segundoOrden(zeta, wn)                    % fórmulas de las notas
S = stepinfo(wn^2/(s^2 + 2*zeta*wn*s + wn^2)) % medido sobre la simulación
fprintf('%%OS:  fórmula %.2f   stepinfo %.2f\n', F.OS, S.Overshoot);
fprintf('tp:   fórmula %.3f  stepinfo %.3f\n', F.tp, S.PeakTime);
fprintf('ts:   fórmula %.3f  stepinfo %.3f\n', F.ts, S.SettlingTime);
fprintf('tr:   0-100 %.3f, aprox. 10-90 %.3f, stepinfo (10-90) %.3f\n', F.tr0100, F.tr1090, S.RiseTime);
% [fin:formulas]
