%% C3_Ej8_Reduccion -- Notas: sección 3.10 (simplificación de sistemas)
% QUÉ HACE   Reduce el orden de dos maneras: despreciando un polo lejano
%            (conservando la ganancia DC) y por igualación de momentos.
% OBSERVE    reduccionMomentos devuelve 1/(1 + d1 s + d2 s^2) con la misma
%            ganancia DC; elige las raíces positivas para que sea estable.
% ESPERADO   6/(s^3+6s^2+11s+6): d1 = 1.615, d2 = 0.6236,
%            G_L = 1.604/(s^2 + 2.590 s + 1.604), polos -1.024 y -1.565
% EXPLORE    Suba K de 60 a 300 en el primer caso: ¿sigue siendo buena la
%            aproximación? (compare los %OS)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:despreciar]
s = tf('s');  K = 60;
G1 = K/(s*(s + 2)*(s + 30));
G2 = (K/30)/(s*(s + 2));                   % se conserva la "ganancia" en baja frecuencia
fig = estiloFigura(900, 420);
step(feedback(G1, 1), feedback(G2, 1), '--', 8); grid on;
legend('$K/(s(s+2)(s+30))$', '$(K/30)/(s(s+2))$', 'Location', 'southeast');
% [fin:despreciar]

% [ini:momentos]
GH = 6/(s^3 + 6*s^2 + 11*s + 6);
[GL, d] = reduccionMomentos(GH)            % d = [d1 d2]
pole(GL)
figure; step(GH, GL, '--', 8); grid on; legend('$G_H$', '$G_L$', 'Location', 'southeast');
% [fin:momentos]
