%% C7_Ej5_Kicks -- Notas: sección 7.6 (proportional y derivative kick)
% QUÉ HACE   Simula el PID 350/300/50 sobre 1/(s^2+10s+20) con tres estructuras:
%            estándar (b=1, c=1), PI-D (b=1, c=0) e I-PD (b=0, c=0), con filtro
%            derivativo Tf = Td/N = 0.01 s.
% OBSERVE    El salto de la referencia pasa por P y por D: la señal de control
%            tiene un pico enorme. Al sacar D (y luego P) del camino de la
%            referencia, el pico desaparece; la respuesta se vuelve más lenta.
% ESPERADO   |u|max: ~5300 (estándar), 350 (PI-D), 20 (I-PD).
% EXPLORE    Repita con Tf = 0.05 y 0.1 s: u(0+) = Kc + Kd/Tf.
clear; close all; clc;
if ~exist('simularPID', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:kicks]
s = tf('s');  P = 1/(s^2 + 10*s + 20);
Kc = 350;  Ti = 350/300;  Td = 50/350;  N = Td/0.01;
casos = {'estándar', 1, 1; 'PI-D', 1, 0; 'I-PD', 0, 0};
for k = 1:3
    [t, y, u] = simularPID(P, Kc, Ti, Td, 'tf', 3, 'dt', 1e-4, 'N', N, 'b', casos{k,2}, 'c', casos{k,3});
    fprintf('%-9s |u|max = %7.1f\n', casos{k,1}, max(abs(u)));
    subplot(1,2,1); plot(t, y); hold on;  subplot(1,2,2); plot(t, u); hold on;
end
subplot(1,2,1); grid on; title('y'); legend(casos{:,1});
subplot(1,2,2); grid on; title('u'); ylim([-100 600]);
% [fin:kicks]
