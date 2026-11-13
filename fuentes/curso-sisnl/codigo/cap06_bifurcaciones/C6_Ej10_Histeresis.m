%% C6_Ej10_Histeresis -- Notas: sección 6.6 (histéresis: Hopf subcrítica + silla-nodo de ciclos)
% QUÉ HACE   Para r' = r(mu + r^2 - r^4) (en cartesianas, theta' = 1):
%            (1) diagrama de bifurcación de los ciclos, mu = r^4 - r^2;
%            (2) rampa lenta de mu de -0.4 a 0.1 y de vuelta, con un piso de ruido.
% OBSERVE    Al subir, el estado deja el origen después de mu = 0 (retardo); al bajar,
%            el ciclo grande se apaga cerca de mu = -1/4.
% ESPERADO   Silla-nodo de ciclos en mu = -0.25, r = 0.7071. Con T = 3000 y ruido
%            1e-6: salto en mu = 0.048, caída en mu = -0.258.
% EXPLORE    Reduzca el ruido a 1e-10. ¿Qué pasa con el retardo al subir? ¿Y al bajar?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:rampa]
r = linspace(0, 1.3, 600);  m = r.^4 - r.^2;  est = (2*r - 4*r.^3) < 0;
fprintf('silla-nodo de ciclos: mu = %.4f, r = %.4f\n', min(m), r(m == min(m)));
T = 3000;  ruido = 1e-6;
g = @(t, r, m0, m1) r*((m0 + (m1 - m0)*t/T) + r^2 - r^4) + ruido;
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 1);
[t1, R1] = ode45(@(t, r) g(t, r, -0.4, 0.1), [0 T], 1e-3, opc);
[t2, R2] = ode45(@(t, r) g(t, r, 0.1, -0.4), [0 T], R1(end), opc);
m1 = -0.4 + 0.5*t1/T;  m2 = 0.1 - 0.5*t2/T;
fprintf('subiendo: salta en mu = %.4f;  bajando: se apaga en mu = %.4f\n', ...
        m1(find(R1 > 0.5, 1)), m2(find(R2 < 0.3, 1)));
% [fin:rampa]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  hold on;
plot(m(est), r(est), '.', 'Color', [42 157 143]/255);  plot(m(~est), r(~est), '.', 'Color', [209 73 91]/255);
plot([-0.5 0], [0 0], 'k', [0 0.2], [0 0], 'r--');  grid on;  xlabel('$\mu$');  ylabel('$r$');
title('Ciclos: estables (verde), inestables (coral)');
subplot(1, 2, 2);  plot(m1, R1, m2, R2);  grid on;  xlabel('$\mu$');  ylabel('$r$');
legend('subiendo', 'bajando', 'Location', 'northwest');  title('Rampa lenta');
