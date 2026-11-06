%% C5_Ej5_RegionPI -- Notas: sección 5.5 (región de estabilidad de un PI)
% QUÉ HACE   Dibuja la región del plano (Kc, Ki) en la que el lazo con
%            Gc = Kc + Ki/s y Gp = 2/(s^3+4s^2+5s+2) es estable, y simula
%            tres puntos: adentro, sobre la frontera y afuera.
% OBSERVE    La frontera Ki = (1+Kc)(9-Kc)/8 sale de la fila s^1 de la tabla.
%            Sobre ella el lazo oscila con w = sqrt(2Ki/b1), b1 = (9-Kc)/2.
% ESPERADO   Ki > 0, Kc < 9, Ki < (1+Kc)(9-Kc)/8; máximo Ki = 25/8 en Kc = 4.
%            Con Kc = 5, Ki = 3 (frontera): w = 1.732 rad/s, periodo 3.63 s.
% EXPLORE    Agregue la exigencia "todos los polos con parte real < -0.1" con
%            el cambio s = z - 0.1 y compare las regiones.
clear; close all; clc;
if ~exist('tablaRouth', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:region]
Kc = linspace(-1, 9, 201);
Kimax = (1 + Kc).*(9 - Kc)/8;               % frontera de la fila s^1
fig = estiloFigura(1000, 440);
subplot(1, 2, 1);
fill([Kc fliplr(Kc)], [Kimax zeros(size(Kc))], [0.85 0.9 1]);  hold on;
plot([5 5 5], [1 3 4], 'o', 'MarkerFaceColor', 'auto');
xlabel('K_c');  ylabel('K_i');  title('región estable');  grid on;
% [fin:region]

% [ini:tres]
s = tf('s');  Gp = 2/(s^3 + 4*s^2 + 5*s + 2);  t = linspace(0, 40, 4001);
subplot(1, 2, 2);  hold on;
for Ki = [1 3 4]
    T = feedback((5 + Ki/s)*Gp, 1);
    plot(t, step(T, t));
    fprintf('Kc = 5, Ki = %d: max Re(polos) = %+.4f\n', Ki, max(real(pole(T))));
end
grid on;  xlabel('t (s)');  legend('K_i = 1', 'K_i = 3 (frontera)', 'K_i = 4');  ylim([0 2.5]);
w = sqrt(2*3/((9 - 5)/2))                  % frecuencia sobre la frontera
% [fin:tres]
