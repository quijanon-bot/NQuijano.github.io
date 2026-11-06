%% C5_Ej8_Pade -- Notas: sección 5.6 (tiempo muerto: la aproximación de Padé)
% QUÉ HACE   Lazo K e^{-Ts}/(s+1) con retroalimentación unitaria: compara la
%            ganancia máxima que predicen Padé de orden 1 y 2 (con Routh) con la
%            exacta (margin acepta modelos con retardo).
% OBSERVE    pade(T,n) devuelve un cociente con ceros en el semiplano derecho;
%            Padé 1 SOBRESTIMA la ganancia máxima: no es conservador.
% ESPERADO   T = 1: Padé 1 -> K < 1 + 2/T = 3;  Padé 2 -> 2.292;
%            exacto -> 2.262 (w = 2.029 rad/s).
% EXPLORE    Cambie T a 0.2 y a 5: ¿cómo cambia el error de Padé 1?
clear; close all; clc;
if ~exist('tablaRouth', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:pade]
T = 1;  s = tf('s');  G = 1/(s + 1);
[n1, d1] = pade(T, 1)                    % (1 - Ts/2)/(1 + Ts/2)
[n2, d2] = pade(T, 2)                    % orden 2: c = [1 1/2 1/12]
Kmax1 = 1 + 2/T                          % Routh sobre (T/2)s^2 + (1+T/2-KT/2)s + 1+K
% Padé 2: buscamos el K en el que aparece un cambio de signo
Ks = linspace(0.1, 5, 4901);  estable = false(size(Ks));
for k = 1:numel(Ks)
    p = conv([1 1], d2) + Ks(k)*[0 n2];     % (s+1) d2(s) + K n2(s)
    [~, cambios] = tablaRouth(p);  estable(k) = (cambios == 0);
end
Kmax2 = Ks(find(estable, 1, 'last'))
% Exacto: margin con el retardo (InputDelay)
Gr = tf(1, [1 1], 'InputDelay', T);
[GM, ~, wgm] = margin(Gr)                % GM = Kmax exacto, wgm = frecuencia
% [fin:pade]

% [ini:comparar]
K = 2.5;  t = linspace(0, 30, 3001);
yExacto = step(feedback(K*Gr, 1), t);              % retardo exacto
yPade1  = step(feedback(K*tf(n1, d1)*G, 1), t);    % modelo de Padé 1
fig = estiloFigura(900, 400);
plot(t, yPade1, '--', t, yExacto);  grid on;  ylim([-2.5 5]);
legend('modelo de Pad\''e 1 (estable)', 'retardo exacto (inestable)');  xlabel('t (s)');
% [fin:comparar]
