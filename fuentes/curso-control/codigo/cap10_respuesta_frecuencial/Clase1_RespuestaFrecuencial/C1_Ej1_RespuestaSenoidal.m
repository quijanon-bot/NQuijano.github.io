%% C1_Ej1_RespuestaSenoidal -- Notas: sección 10.2 (ejemplo 1/(s+10) con sen t)
% QUÉ HACE   Simula G'(s) = 1/(s+10) con x(t) = sin(t) y compara la salida con
%            la predicción de estado estacionario z_ss = |G'(j1)| sin(t + fase).
% OBSERVE    Después de ~0.4 s (cuatro constantes de tiempo, polo en -10) la
%            simulación y la fórmula coinciden: solo quedan magnitud y fase.
% ESPERADO   |G'(j1)| = 0.0995 (= 1/sqrt(101)),  fase = -5.71°
% EXPLORE    Cambie w a 10 y a 100: ¿qué pasa con la amplitud y el retraso?
clear; close all; clc;
if ~exist('bodeAsintotico', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'comun')); end

% [ini:senoide]
G   = tf(1, [1 10]);                 % G'(s) = 1/(s+10)
w   = 1;                             % frecuencia de la entrada (rad/s)
Gjw = evalfr(G, 1j*w);               % G'(jw): un número complejo
M   = abs(Gjw)                       % 0.0995  -> la salida es ~10 veces menor
phi = rad2deg(angle(Gjw))            % -5.71°  -> y llega 5.71° tarde

t   = 0:0.001:12;   x = sin(w*t);
z   = lsim(G, x, t);                 % simulación completa (transitorio + ee)
zss = M*sin(w*t + deg2rad(phi));     % solo el estado estacionario, ec. (10.3)
% [fin:senoide]

fig = estiloFigura(1000, 600);
subplot(2,1,1); plot(t, x, 'Color', [.36 .40 .49]); grid on; ylabel('$x(t)$');
title('Entrada $x(t)=\sin t$');
subplot(2,1,2); plot(t, z, t, zss, ':'); grid on;
xlabel('$t$ (s)'); ylabel('$z(t)$');
legend('$z(t)$ con \texttt{lsim}', '$0.0995\sin(t-5.71^\circ)$', 'Location', 'southeast');
title('Despu\''es del transitorio solo quedan magnitud y fase');
exportgraphics(fig, 'C1_Ej1_seno.png', 'Resolution', 200);

%% El mismo cálculo con bode(): magnitud y fase en w = 1
[mag, fase] = bode(G, w);
fprintf('bode: |G| = %.4f, fase = %.2f grados\n', mag, fase);
