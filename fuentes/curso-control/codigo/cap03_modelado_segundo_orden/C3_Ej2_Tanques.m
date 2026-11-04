%% C3_Ej2_Tanques -- Notas: sección 3.3 (dos tanques interactuantes)
% QUÉ HACE   Calcula el equilibrio, linealiza y arma la función de
%            transferencia Hhat2(s)/Fhat_i(s); luego compara el modelo lineal
%            con el no lineal (ode45) ante dos escalones de distinto tamaño.
% OBSERVE    zeta > 1 SIEMPRE: esta planta no puede oscilar (ejercicio del
%            capítulo). El error del modelo lineal crece con el tamaño del
%            escalón porque nos alejamos del punto de operación.
% ESPERADO   f* = 0.1 m^3/s, h1* = 5 m, C1 = 0.05, C3 = 0.0125,
%            tau1 = 40 s, tau2 = 48 s, ganancia 80 s/m^2, zeta = 2.245
% EXPLORE    Cambie las áreas y los coeficientes de válvula: ¿logra zeta < 1?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:tanques]
A1 = 2;  A2 = 3;  Cv1 = 0.1;  Cv2 = 0.05;     % m^2, m^2, m^{5/2}/s
h2e = 4;                                      % altura de operación del tanque 2 (m)
fe  = Cv2*sqrt(h2e);                          % equilibrio: f_i* = f_1* = f_2*
h1e = h2e + (fe/Cv1)^2;
C1  = Cv1/(2*sqrt(h1e - h2e));  C2 = -C1;      % df1/dh1, df1/dh2
C3  = Cv2/(2*sqrt(h2e));                       % df2/dh2
K1 = 1/C1;  tau1 = A1/C1;  K2 = C1/(C3 - C2);  tau2 = A2/(C3 - C2);
s  = tf('s');
G  = K1*K2/((tau1*s + 1)*(tau2*s + 1) + K1*K2*C2)    % Hhat2/Fhat_i
wn   = sqrt(C1*C3/(A1*A2));
zeta = ((C1 + C3)/A2 + C1/A1)/(2*wn)
dcgain(G)                                     % = 1/C3 = 80
% [fin:tanques]

% [ini:comparar]
fig = estiloFigura(1100, 420);
pasos = [0.01 0.05];
for k = 1:2
    df  = pasos(k);
    rhs = @(t, h) [(fe + df - Cv1*sqrt(max(h(1) - h(2), 0)))/A1;
                   (Cv1*sqrt(max(h(1) - h(2), 0)) - Cv2*sqrt(max(h(2), 0)))/A2];
    [t, h] = ode45(rhs, [0 4000], [h1e; h2e]);        % modelo no lineal
    yl = h2e + df*step(G, t);                         % modelo lineal + equilibrio
    subplot(1, 2, k); plot(t, h(:,2), t, yl, '--'); grid on; xlabel('$t$ (s)');
    title(sprintf('escal\\''on de %.2f m$^3$/s', df));
    fprintf('df = %.2f: h2 final no lineal %.2f m, lineal %.2f m\n', df, h(end,2), yl(end));
end
legend('no lineal', 'linealizado', 'Location', 'southeast');
% [fin:comparar]
