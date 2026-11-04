%% C11_Ej14_AguaCaras -- Notas: sección 11.10 (trampa: las caras del simplex)
% QUÉ HACE   Simula el lazo tanques-replicador desde caras del simplex:
%            q3(0) = 0 y q3(0) = 1e-2, 1e-4, 1e-6, 1e-8.
% OBSERVE    Si q3(0) = 0, q3(t) = 0 para siempre: el tanque 3 se vacía en tiempo
%            finito y el sistema converge a OTRO equilibrio. Si q3(0) > 0 converge,
%            pero el retardo crece como ln(1/q3(0)): cada factor 100 suma ~3 s.
% ESPERADO   tanque 3 vacío en t = 2 sqrt(0.4)/1.4 = 0.9035 s;
%            q3 llega a 0.5 en t = 4.52, 7.70, 10.74, 13.72 s.
% EXPLORE    ¿Contradice esto que el equilibrio sea asintóticamente estable?
%            Relea la región de atracción D del teorema.
clear; close all; clc;

% [ini:caras]
Q = 2;  r = 2;  vm = 2;  c = [0.6; 1.0; 1.4];
fprintf('tanque 3 sin caudal: se vacía en t = 2 sqrt(v3(0))/c3 = %.4f s\n', ...
        2*sqrt(0.4)/1.4);
for q30 = 10.^(-2:-2:-8)
    x0  = [0.4; 0.4; 0.4; 1 - q30/2; 1 - q30/2; q30];
    ev  = @(t, x) deal(x(6) - 0.5, 1, 1);           % q3 cruza 0.5 subiendo
    opc = odeset('RelTol', 1e-8, 'AbsTol', [1e-10*ones(5,1); 1e-3*q30], 'Events', ...
            ev);   % tolerancia a la escala de q3
    [~, ~, te] = ode45(@(t, x) modeloAgua(x, c, Q, r, vm), [0 40], x0, opc);
    fprintf('q3(0) = %.0e:  q3 llega a 0.5 en t = %.2f s\n', q30, te);
end
% [fin:caras]
