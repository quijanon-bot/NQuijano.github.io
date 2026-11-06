%% C8_Ej5_IMC -- Notas: sección 8.6 (control por modelo interno)
% QUÉ HACE   (a) Estabilidad interna: Q que invierte un cero de fase no mínima.
%            (b) Ejemplo de Bequette: proceso 1.5(1-s)/((s+1)(4s+1)), modelo 2/(5s+1).
%            (c) IMC-PID para Kp e^{-theta s}/(tau s+1) con el retardo exacto.
% OBSERVE    En (a) la salida es impecable mientras u diverge.  En (b) el lazo es
%            estable solo si lambda > 0.887.  En (c) lambda pequeño = lazo agresivo.
% ESPERADO   (a) |u| > 50 en t = 27.95 s.  (b) 8 lambda s^3 + (10 lambda - 7.5)s^2 +
%            (2 lambda + 6)s + 1.5.  (c) lambda = 3.2 / 6.7 / 10: OS 16 / 0 / 0 %.
% EXPLORE    En (c) baje lambda hasta perder la estabilidad (cerca de 0.75 s).
clear; close all; clc;
if ~exist('reglasPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
s = tf('s');

% [ini:interna]
Gp = (1 - 9*s)/((15*s + 1)*(3*s + 1));  lambda = 5;
Q1 = (15*s + 1)*(3*s + 1)/((1 - 9*s)*(lambda*s + 1));   % invierte el cero: polo en +1/9
Q2 = (15*s + 1)*(3*s + 1)/(lambda*s + 1)^2;             % deja el cero en la salida
t = linspace(0, 200, 20001);
subplot(1,2,1); plot(t, step(minreal(Gp*Q1), t), t, step(Gp*Q2, t)); grid on; title('y');
u1 = step(Q1, t);  subplot(1,2,2); plot(t, u1, t, step(Q2, t)); ylim([-60 20]); grid on; title('u');
tLimite = t(find(abs(u1) > 50, 1))
% [fin:interna]

% [ini:robusto]
Gp = 1.5*(1 - s)/((s + 1)*(4*s + 1));  Gm = 2/(5*s + 1);
syms l x
car = expand(8*l*x^3 + (10*l - 7.5)*x^2 + (2*l + 6)*x + 1.5);   % 1 + Q(Gp - Gm) = 0
lmin = double(max(solve(20*l^2 + 33*l - 45 == 0, l)))           % fila s^1 de Routh
figure; hold on;
for lambda = [0.85 1.5 3]
    Q = (5*s + 1)/(2*(lambda*s + 1));  Gc = minreal(Q/(1 - Gm*Q));
    step(feedback(Gc*Gp, 1), 40);
end
grid on; legend('\lambda = 0.85', '\lambda = 1.5', '\lambda = 3'); ylim([-1 2.5]);
% [fin:robusto]

% [ini:fopdt]
Kp = 1.2;  tau = 20;  th = 4;
figure; hold on;
for lambda = [3.2 6.7 10]
    Kc = (tau + th/2)/(Kp*(lambda + th/2));  Ti = tau + th/2;  Td = tau*th/(2*tau + th);
    [t, y] = simularPID(Kp/(tau*s + 1), Kc, Ti, Td, 'tf', 100, 'dt', 0.005, 'L', th, 'N', 10);
    plot(t, y);  fprintf('lambda = %4.1f: Kc = %.3f  OS = %4.1f %%\n', lambda, Kc, 100*(max(y) - 1));
end
grid on; legend('\lambda = 3.2', '\lambda = 6.7', '\lambda = 10');
% [fin:fopdt]
