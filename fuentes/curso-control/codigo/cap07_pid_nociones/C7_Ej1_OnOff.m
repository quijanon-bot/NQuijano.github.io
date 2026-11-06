%% C7_Ej1_OnOff -- Notas: sección 7.2 (control on/off)
% QUÉ HACE   Controlador on/off (u = 90 % si e > 0, 10 % si e < 0) sobre el
%            proceso e^{-2s}/(10s+1), con referencia de 50 %.
% OBSERVE    La PV oscila alrededor de la referencia sin asentarse: el
%            controlador solo conoce el signo del error.
% ESPERADO   Oscilación sostenida entre unos 42 % y 58 % (periodo ~ 8 s).
% EXPLORE    Quite el retardo (L = 0) y reduzca dt: ¿qué pasa con la oscilación?
%            Agregue una histéresis de ±2 % y compare la frecuencia de conmutación.
clear; close all; clc;

% [ini:onoff]
dt = 0.01;  t = 0:dt:80;  L = 2;  nL = round(L/dt);
r = 50;  y = zeros(size(t));  u = y;  buf = zeros(1, nL);  yk = 0;
for k = 1:numel(t)
    y(k) = yk;
    if r - yk > 0, u(k) = 90; else, u(k) = 10; end   % on/off
    sal = buf(1);  buf = [buf(2:end) u(k)];          % retardo de 2 s
    yk = yk + dt*(-yk + sal)/10;                     % proceso 1/(10s+1)
end
subplot(2,1,1); plot(t, r*ones(size(t)), '--', t, y); grid on; ylabel('%'); legend('r', 'y');
subplot(2,1,2); plot(t, u, t, r - y, '--'); grid on; xlabel('t (s)'); legend('u', 'e');
% [fin:onoff]
