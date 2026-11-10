function P = parametrosLevitador()
% PARAMETROSLEVITADOR  Parámetros del levitador magnético (sección 12.1).
%   Modelo de Khalil (2002). Unidades SI. La inductancia es L(y) = L1 + L0/(1 + y/a);
%   no confundirla con la derivada de Lie L_f h (siempre lleva subíndice).
P.m  = 0.1;     % masa de la esfera [kg]
P.k  = 0.001;   % fricción viscosa [N s/m]
P.g  = 9.81;    % gravedad [m/s^2]
P.a  = 0.05;    % [m]
P.L0 = 0.01;    % [H]
P.L1 = 0.02;    % [H]
P.R  = 1.0;     % resistencia de la bobina [Ohm]
P.L  = @(y) P.L1 + P.L0./(1 + y/P.a);
end
