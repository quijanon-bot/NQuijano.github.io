%% C6_Ej1_TipoError -- Notas: sección 6.3 (tipo y constantes de error)
% QUÉ HACE   Calcula el tipo y las constantes kp, kv, ka de cuatro lazos abiertos,
%            verifica primero la estabilidad, y simula el error ante escalón y rampa.
% OBSERVE    El cuarto lazo tiene constantes "infinitas" y error "cero" en la tabla,
%            pero es inestable: la tabla no se aplica.
% ESPERADO   (i) tipo 0, kp = 8; (ii) tipo 1, kv = 5/3; (iii) tipo 2, ka = 60;
%            (iv) inestable (polinomio s^4 + 2s^3 + 5s + 5, sin término en s^2).
% EXPLORE    Multiplique (ii) por 10 y vea qué pasa con la estabilidad y con 1/kv.
clear; close all; clc;
if ~exist('constantesError', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
s = tf('s');

% [ini:tipo]
G = {20*(s+2)/((s+1)*(s+5)), 50/(s*(s+3)*(s+10)), ...
     100*(s+4)*(s+6)/(s^2*(s+5)*(s+8)), 5*(s+1)/(s^3*(s+2))};
for i = 1:4
    T = feedback(G{i}, 1);
    estable = all(real(pole(T)) < 0);
    [tipo, kp, kv, ka] = constantesError(G{i});
    fprintf('(%d) estable = %d  tipo %d  kp = %g  kv = %g  ka = %g\n', i, estable, tipo, kp, kv, ka);
    if estable                                  % error ante r = 5, 2t y 1.5 t^2
        fprintf('     ess: %g  %g  %g\n', 5/(1 + kp), 2/kv, 3/ka);
    end
end
% [fin:tipo]

% [ini:simulacion]
t = 0:0.01:20;
T = feedback(G{2}, 1);                          % tipo 1 ante rampa r = 2t
y = lsim(T, 2*t, t);
plot(t, 2*t, '--', t, y); grid on; legend('r = 2t', 'y');
eFinal = 2*t(end) - y(end)                       % 2/kv = 1.2
% [fin:simulacion]
