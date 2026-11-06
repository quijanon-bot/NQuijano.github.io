%% C6_Ej4_Estado -- Notas: sección 6.6 (error en espacio de estado)
% QUÉ HACE   Con A = [0 1; -2 -3], B = [0; 1], C = [2 0] y u = r - y, halla el
%            estado estacionario imponiendo x' = 0; luego agrega un estado
%            integrador x3' = r - y con u = r - y + Ki x3.
% OBSERVE    El mismo error que con kp, sin pasar por la función de transferencia.
% ESPERADO   kp = 1, ess = 0.5, x_ss = [0.25; 0]. Aumentado: s^3 + 3s^2 + 4s + 2Ki,
%            estable para 0 < Ki < 6; con Ki = 3, y_ss = 1 (error nulo).
% EXPLORE    ¿Qué pasa con el transitorio al acercar Ki a 6?
clear; close all; clc;
if ~exist('constantesError', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
A = [0 1; -2 -3];  B = [0; 1];  C = [2 0];

% [ini:estacionario]
Acl = A - B*C;                                  % u = r - Cx
xss = -Acl\B                                    % 0 = Acl x + B r, con r = 1
ess = 1 - C*xss                                 % 0.5 = 1/(1 + kp), kp = 1
% [fin:estacionario]

% [ini:integral]
Ki = 3;
Aa = [A - B*C, B*Ki; -C, 0];  Ba = [B; 1];  Ca = [C 0];
poly(Aa)                                        % [1 3 4 2Ki]
eig(Aa)
yss = Ca*(-Aa\Ba)                               % 1: error nulo
step(ss(Aa, Ba, Ca, 0), 15); grid on;
% [fin:integral]
