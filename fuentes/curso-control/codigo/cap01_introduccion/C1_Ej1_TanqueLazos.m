%% C1_Ej1_TanqueLazos -- Notas: sección 1.2 (lazo abierto y lazo cerrado)
% QUÉ HACE   Simula el tanque  Area dh/dt = u + d - h/R  con dos estrategias:
%            lazo abierto calibrado  u = hr/Kn  y lazo cerrado
%            u = hr/Kn + Kc (hr - h).  Dos casos: lluvia d = 0.2 m^3/min desde
%            t = 5 min, y válvula de salida obstruida (R sube 20 %).
% OBSERVE    En lazo abierto la lluvia sube el nivel 0.4 m y la obstrucción
%            0.2 m; en lazo cerrado, 1 + K Kc = 11 veces menos. El lazo
%            cerrado responde más rápido, pero pide un caudal inicial de 5.5.
% ESPERADO   Kc = 5: lluvia -> 1.40 (abierto) y 1.036 (cerrado);
%            obstrucción -> 1.20 y 1.015.  tau del lazo cerrado = 5.45 s.
% EXPLORE    Cambie Kc a 1, 10 y 20. ¿Qué Kc deja menos de 1 cm con lluvia?
%            ¿Cuánto vale entonces el caudal en t = 1 min?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:abierto]
Area = 0.5;  R = 2;         % m^2 y min/m^2  ->  K = R = 2, tau = Area*R = 1 min
Kn = 2;                     % ganancia NOMINAL con la que se calibró
t  = linspace(0, 10, 2001)';           % minutos
hr = 1.0*(t >= 1);                     % nivel deseado: 1 m desde t = 1 min
d  = 0.2*(t >= 5);                     % lluvia desde t = 5 min
% Lazo abierto: u = hr/Kn (nadie mira el nivel)
ola = ss(-1/(Area*R), [1/(Area*Kn) 1/Area], 1, 0);     % entradas [hr d]
h_ab = lsim(ola, [hr d], t);
fprintf('Lazo abierto, lluvia:  h(10) = %.3f m\n', h_ab(end));
% [fin:abierto]

% [ini:cerrado]
Kc = 5;                     % ganancia del controlador proporcional, m^2/min
% Lazo cerrado: u = hr/Kn + Kc (hr - h)
%   Area dh/dt = -(1/R + Kc) h + (1/Kn + Kc) hr + d
lc = @(Rr) ss(-(1/Rr + Kc)/Area, [(1/Kn + Kc)/Area 1/Area], 1, 0);
h_ce = lsim(lc(R), [hr d], t);
u_ce = hr/Kn + Kc*(hr - h_ce);
fprintf('Lazo cerrado, lluvia:  h(10) = %.4f m   (factor 1+K*Kc = %g)\n', h_ce(end), 1 + R*Kc);
% Válvula obstruida: R real = 2.4, sin lluvia (la calibración sigue con Kn = 2)
Rr = 2.4;
h_ab2 = lsim(ss(-1/(Area*Rr), [1/(Area*Kn) 1/Area], 1, 0), [hr 0*d], t);
h_ce2 = lsim(lc(Rr), [hr 0*d], t);
fprintf('Obstrucción: abierto %.3f m, cerrado %.4f m\n', h_ab2(end), h_ce2(end));
fprintf('tau lazo cerrado = %.2f s;  u(1+) = %.2f m^3/min\n', 60*Area*R/(1 + R*Kc), 1/Kn + Kc);   % en el instante del escalón
% [fin:cerrado]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1); plot(t, hr, ':', t, h_ab, t, h_ce, 'LineWidth', 1.6); grid on;
title('Lluvia desde t = 5 min'); xlabel('t (min)'); ylabel('h (m)');
legend('h_r', 'lazo abierto', 'lazo cerrado', 'Location', 'southeast');
subplot(1, 2, 2); plot(t, hr, ':', t, h_ab2, t, h_ce2, 'LineWidth', 1.6); grid on;
title('Válvula obstruida (R +20 %)'); xlabel('t (min)');
figure; plot(t, hr/Kn, t, u_ce, 'LineWidth', 1.6); grid on;
xlabel('t (min)'); ylabel('u (m^3/min)'); legend('lazo abierto', 'lazo cerrado');
