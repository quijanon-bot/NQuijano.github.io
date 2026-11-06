%% C7_Ej8_Digital -- Notas: sección 7.7 (implementación digital)
% QUÉ HACE   Implementa el PID (Kc=3, Ti=8, Td=2) en forma posicional y en forma
%            incremental con Ts = 0.1 s sobre 1/(10s+1), y compara las dos.
% OBSERVE    Las dos leyes dan exactamente la misma señal de control: la
%            incremental es la diferencia de la posicional en k y k-1.
% ESPERADO   Coeficientes incrementales: 63.04, -123, 60.  max|u1 - u2| ~ 1e-12.
% EXPLORE    Repita con Ts = 0.01, 0.5 y 1 s y compare con el PID continuo.
clear; close all; clc;

% [ini:digital]
Kc = 3;  Ti = 8;  Td = 2;  Ts = 0.1;  n = 400;
Gd = c2d(tf(1, [10 1]), Ts, 'zoh');  [nd, dd] = tfdata(Gd, 'v');
a = -dd(end);  bb = nd(end);                          % y[k+1] = a y[k] + bb u[k]
q = Kc*[1 + Ts/Ti + Td/Ts, -1 - 2*Td/Ts, Td/Ts]       % coeficientes incrementales
y1 = 0; y2 = 0; S = 0; e1 = 0; e2 = 0; up = 0; u1 = zeros(1,n); u2 = u1;
for k = 1:n
    e = 1 - y1;  S = S + e;
    u1(k) = Kc*(e + Ts/Ti*S + Td/Ts*(e - e1));       % posicional
    u2(k) = up + q*[e; e1; e2];  up = u2(k);          % incremental
    e2 = e1;  e1 = e;
    y1 = a*y1 + bb*u1(k);                             % planta discreta
end
max(abs(u1 - u2))
stairs((0:n-1)*Ts, u1); grid on; xlabel('t (s)'); ylabel('u');
% [fin:digital]
