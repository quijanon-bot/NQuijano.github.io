%% C7_Ej2_Acciones -- Notas: sección 7.5 (ejemplo masa-resorte-amortiguador)
% QUÉ HACE   Cierra el lazo de 1/(s^2+10s+20) con P, PD, PI y PID (forma
%            paralelo, Kc + Ki/s + Kd s) y mide cada respuesta con stepinfo.
% OBSERVE    P: menos error y más sobrepico. D: amortigua. I: anula el error.
% ESPERADO   Lazo abierto: valor final 0.05.  P (Kc=300): ess = 0.0625, OS 40 %.
%            PD (Kd=20): OS 5.8 %.  PI (Ki=200): ess = 0, OS 36 %.
%            PID (350, 300, 50): OS 0 %, ts = 0.83 s.
% EXPLORE    Use pidTuner(P, 'PID') y compare con la sintonía a mano.
clear; close all; clc;

% [ini:planta]
s = tf('s');
M = 1;  b = 10;  k = 20;                 % kg, N s/m, N/m
P = 1/(M*s^2 + b*s + k);
stepinfo(P)                              % valor final 1/20: error del 95 %
% [fin:planta]

% [ini:p]
for Kc = [10 100 300]
    T = feedback(Kc*P, 1);
    fprintf('P  Kc = %3d: ess = %.4f\n', Kc, 1 - dcgain(T));  stepinfo(T)
end
% [fin:p]

% [ini:pd]
Kc = 300;
for Kd = [10 20]
    T = feedback(pid(Kc, 0, Kd)*P, 1);   % cero del PD en -Kc/Kd
    S = stepinfo(T);  fprintf('PD Kd = %2d: OS = %.1f %%\n', Kd, S.Overshoot);
end
% [fin:pd]

% [ini:pi]
for Ki = [70 200]                        % Routh: estable si Ki < 3200
    T = feedback(pid(Kc, Ki)*P, 1);
    S = stepinfo(T);  fprintf('PI Ki = %3d: OS = %.1f %%, ts = %.2f s\n', Ki, S.Overshoot, S.SettlingTime);
end
% [fin:pi]

% [ini:pid]
C = pid(350, 300, 50);  T = feedback(C*P, 1);
stepinfo(T)
step(T, 2); grid on;
% [fin:pid]
