%% C1_Ej3_Prealimentacion -- Notas: sección 1.4 (tanque de almacenamiento)
% QUÉ HACE   Tanque  A2 dh/dt = F1 - F2  (variables desviación).  F1 sube
%            0.5 m^3/min en t = 2 min.  Compara: prealimentación con un
%            transmisor de flujo que lee 10 % menos, retroalimentación
%            proporcional Kc = 1, y las dos combinadas.
% OBSERVE    La prealimentación sola deriva sin fin (nadie mira el nivel);
%            la retroalimentación sola deja 0.5 m; juntas dejan 0.05 m.
% ESPERADO   deriva 0.025 m/min; finales 0.5 y 0.05 m; tau = 2 min.
% EXPLORE    Cambie el error del sensor (eps) y Kc. ¿Qué pasa con eps = 0?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:combinada]
A2 = 2;  dF1 = 0.5;  eps = 0.10;  Kc = 1;
t   = linspace(0, 20, 2001)';
F1  = dF1*(t >= 2);                       % desviación del caudal de entrada
% dh/dt = (F1 - F2)/A2, con F2 = ff*(1-eps)*F1 + fb*Kc*h
modelo = @(ff, fb) ss(-fb*Kc/A2, (1 - ff*(1 - eps))/A2, 1, 0);
h_ff = lsim(modelo(1, 0), F1, t);
h_fb = lsim(modelo(0, 1), F1, t);
h_am = lsim(modelo(1, 1), F1, t);
fprintf('Solo prealimentación: h(20) = %.3f m (deriva %.4f m/min)\n', h_ff(end), dF1*eps/A2);
fprintf('Solo retroalimentación: h(20) = %.3f m\n', h_fb(end));
fprintf('Combinadas: h(20) = %.4f m\n', h_am(end));
% [fin:combinada]

fig = estiloFigura(800, 400);
plot(t, h_ff, t, h_fb, t, h_am, 'LineWidth', 1.8); grid on;
xlabel('t (min)'); ylabel('desviación del nivel (m)');
legend('prealimentación', 'retroalimentación', 'combinadas', 'Location', 'northwest');
