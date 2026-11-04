%% C2_Ej4_FraccionesParciales -- Notas: sección 2.4 (polos múltiples y complejos)
% QUÉ HACE   Expande en fracciones parciales un caso con polos repetidos y
%            otro con polos complejos conjugados, y regresa al tiempo.
% OBSERVE    residue devuelve los residuos en el orden de las potencias
%            crecientes del polo repetido; con polos complejos, los residuos
%            también son complejos y conjugados.
% ESPERADO   1/(s^2(s+1)^2) = -2/s + 1/s^2 + 2/(s+1) + 1/(s+1)^2
%            3x''+2x'+x=0, x(0)=-1, x'(0)=2: polos -1/3 ± j sqrt(2)/3
% EXPLORE    Cambie las condiciones iniciales del segundo caso y vea cómo
%            cambian la amplitud y la fase de la oscilación, NO su frecuencia.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:multiples]
num = 1;  den = conv([1 0 0], [1 2 1]);   % s^2 (s+1)^2
[r, p] = residue(num, den)
% r = [2; 1; -2; 1] con p = [-1; -1; 0; 0] (el orden puede variar):  2/(s+1) + 1/(s+1)^2 - 2/s + 1/s^2
syms s t
ilaplace(1/(s^2*(s+1)^2))                 % -> t - 2 + 2e^{-t} + t e^{-t}
% [fin:multiples]

% [ini:complejos]
X = (4 - 3*s)/(3*s^2 + 2*s + 1);          % 3x''+2x'+x = 0, x(0) = -1, x'(0) = 2
[r, p] = residue([-3 4], [3 2 1])         % residuos complejos conjugados
xt = simplify(ilaplace(X))
% -> e^{-t/3} ( -cos(sqrt(2) t/3) + (5 sqrt(2)/2) sin(sqrt(2) t/3) )
% [fin:complejos]
tt = linspace(0, 20, 600);
fig = estiloFigura(900, 420);
plot(tt, double(subs(xt, t, tt))); grid on; xlabel('$t$ (s)'); ylabel('$x(t)$');
title('Polos complejos: oscilaci\''on amortiguada');
