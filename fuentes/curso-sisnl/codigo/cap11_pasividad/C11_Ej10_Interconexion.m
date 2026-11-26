%% C11_Ej10_Interconexion -- Notas: sección 11.8 (interconexión en retroalimentación)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
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

% ---- Figura de las notas (fig:pa-interconexion) ----------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t, X] = ode45(@(t, x) modeloOsciladores(t, x, 1, 0.5, 2), linspace(0, 25, 5001), [1.5; 0; 0; 0], opc);
V1 = X(:,1).^4/4 + X(:,2).^2/2;  V2 = X(:,3).^2 + X(:,4).^2/2;     % a = 1, b = 2
fig = estiloFigura(1200, 440);
subplot(1, 2, 1);  hold on;  plot(t, X(:,1), 'Color', az);  plot(t, X(:,3), 'Color', co);
grid on;  box on;  xlabel('$t$ (s)');  title('posiciones');  legend('$x_1$ ($H_1$)', '$x_3$ ($H_2$)');
subplot(1, 2, 2);  hold on;
plot(t, V1, 'Color', az);  plot(t, V2, 'Color', co);  plot(t, V1 + V2, 'Color', no, 'LineWidth', 2.4);
grid on;  box on;  xlabel('$t$ (s)');  title('cada una sube y baja; la suma no');
legend('$V_1$', '$V_2$', '$V=V_1+V_2$');
