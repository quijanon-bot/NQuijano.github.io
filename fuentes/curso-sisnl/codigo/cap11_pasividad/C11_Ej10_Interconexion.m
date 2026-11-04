%% C11_Ej10_Interconexion -- Notas: sección 11.8 (interconexión en retroalimentación)
% QUÉ HACE   Conecta en la forma estándar (e1 = u1 - y2, e2 = u2 + y1) dos
%            osciladores OSP y ZSO (modeloOsciladores.m) con a = 1, k = 0.5,
%            b = 2, u = 0, toda la energía inicial en H1, y grafica V1, V2, V.
% OBSERVE    V1 y V2 suben y bajan: cada uno recibe la energía que el otro
%            entrega. Solo la suma decrece, con V' = -k y1^2 - y2^4.
% ESPERADO   V(0) = 1.2656;  V no creciente;  max V2 = 0.4922;  V(40) ~ 1e-4.
% EXPLORE    Cambie el signo de la retroalimentación (e1 = u1 + y2) y simule
%            desde x0 = [0.1 0 0 0]. ¿Sigue decreciendo V?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:lazo]
a = 1;  k = 0.5;  b = 2;
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) modeloOsciladores(t, x, a, k, b), linspace(0, 40, 8001), ...
        [1.5; 0; 0; 0], opc);
V1 = a*X(:,1).^4/4 + X(:,2).^2/2;            % H1: resorte duro + masa
V2 = b*X(:,3).^2/2 + X(:,4).^2/2;            % H2: resorte lineal + masa
V  = V1 + V2;
fprintf('V(0) = %.4f   max V2 = %.4f   V(40) = %.1e\n', V(1), max(V2), V(end));
fprintf('¿V no creciente? %d    ¿V1 sube en algún momento? %d\n', all(diff(V) <= 1e-10), ...
        any(diff(V1) > 1e-6));
dVteo = -k*X(:,2).^2 - X(:,4).^4;            % V' = -k y1^2 - y2^4
dVnum = gradient(V, t);
fprintf('max |V''(numérica) - (-k y1^2 - y2^4)| = %.1e\n', ...
        max(abs(dVnum(3:end-2) - dVteo(3:end-2))));
% [fin:lazo]

fig = estiloFigura(1000, 420);
subplot(1,2,1); plot(t, X(:,1), t, X(:,3)); grid on; legend('$x_1$', '$x_3$'); xlabel('$t$');
subplot(1,2,2); plot(t, V1, t, V2, t, V, 'k', 'LineWidth', 2.5); grid on; xlim([0 25]);
legend('$V_1$', '$V_2$', '$V_1+V_2$'); xlabel('$t$');
