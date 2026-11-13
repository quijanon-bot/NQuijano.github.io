%% C6_Ej3_Transcritica -- Notas: sección 6.4 (transcrítica y el umbral del láser)
% QUÉ HACE   (1) Diagrama de x' = mu x - x^2: ramas 0 y mu que intercambian la
%            estabilidad. (2) El láser n' = (G N0 - k) n - alpha G n^2: simula hasta
%            el régimen permanente para varios bombeos N0 y compara con n* = (G N0 - k)/(alpha G).
% OBSERVE    Por debajo del umbral N0 = k/G la salida es cero (lámpara); por encima
%            crece linealmente con N0.
% ESPERADO   G = k = 1, alpha = 0.5: umbral N0 = 1; con N0 = 2, n* = 2.
% EXPLORE    Agregue emisión espontánea (+eps al campo). ¿Sigue habiendo un umbral nítido?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:laser]
G = 1;  k = 1;  alfa = 0.5;  eps0 = 0;          % eps0 > 0: emisión espontánea
N0s = linspace(0, 3, 31);  nss = zeros(size(N0s));
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
for i = 1:numel(N0s)
    N0 = N0s(i);
    [~, n] = ode45(@(t, n) (G*N0 - k)*n - alfa*G*n^2 + eps0, [0 400], 0.01, opc);
    nss(i) = n(end);
end
nteo = max(0, (G*N0s - k)/(alfa*G));
fprintf('umbral N0 = k/G = %g;  N0 = 2: n simulado = %.4f, n* = %.4f\n', k/G, nss(N0s == 2), (2*G - k)/(alfa*G));
fprintf('max |n simulado - n*| = %.1e\n', max(abs(nss - nteo)));
% [fin:laser]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  m = linspace(-1, 1, 101);  hold on;
plot(m(m <= 0), 0*m(m <= 0), '-k', m(m >= 0), 0*m(m >= 0), '--r', m(m <= 0), m(m <= 0), '--r', m(m >= 0), m(m >= 0), '-k');
grid on;  xlabel('$\mu$');  ylabel('$x^*$');  title('$\dot x=\mu x-x^2$');
subplot(1, 2, 2);  plot(N0s, nss, 'o', N0s, nteo, '-');  grid on;
xlabel('$N_0$');  ylabel('$n$ en r\''egimen permanente');  title('Umbral del l\''aser');
