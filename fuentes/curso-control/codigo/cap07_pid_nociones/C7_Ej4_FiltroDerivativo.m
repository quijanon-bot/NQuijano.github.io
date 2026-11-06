%% C7_Ej4_FiltroDerivativo -- Notas: sección 7.6 (problemas de la acción derivativa)
% QUÉ HACE   Compara |Gc(jw)| del PID ideal (Kc=3, Ti=8, Td=2) sin filtro y con el
%            filtro derivativo Td s/(Td s/N + 1) para N = 5, 10, 20.
% OBSERVE    Sin filtro, la ganancia crece sin límite con la frecuencia: el ruido
%            de medida se amplifica. Con filtro, la ganancia se aplana en Kc(1+N).
% ESPERADO   Ruido 0.01 sin(100 t): amplitud en u de 6 sin filtro; 0.15, 0.30 y
%            0.60 con N = 5, 10 y 20.
% EXPLORE    Agregue a la medida ruido blanco y mida std(u) para cada N.
clear; close all; clc;

% [ini:filtro]
s = tf('s');  Kc = 3;  Ti = 8;  Td = 2;
C0 = Kc*(1 + 1/(Ti*s) + Td*s);                     % impropio: no se puede simular solo
w = logspace(-2, 3, 500);
loglog(w, squeeze(abs(freqresp(C0, w)))); hold on;
for N = [5 10 20]
    CN = Kc*(1 + 1/(Ti*s) + Td*s/(Td*s/N + 1));    % propio
    loglog(w, squeeze(abs(freqresp(CN, w))));
    fprintf('N = %2d: |Gc(j100)| x 0.01 = %.3f   (cota Kc(1+N) = %d)\n', N, 0.01*abs(evalfr(CN, 100j)), Kc*(1+N));
end
grid on; xlabel('\omega (rad/s)'); legend('sin filtro', 'N = 5', 'N = 10', 'N = 20');
% [fin:filtro]
