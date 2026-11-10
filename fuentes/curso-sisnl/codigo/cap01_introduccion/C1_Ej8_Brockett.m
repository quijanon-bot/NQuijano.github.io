%% C1_Ej8_Brockett -- Notas: sección 1.5 (controlable pero no estabilizable)
% QUÉ HACE   Integrador no holonómico z1' = v1, z2' = v2, z3' = z1 v2 - z2 v1.
%            (1) Muestra que es controlable: recorriendo un círculo de radio
%            rho en (z1, z2) se vuelve al punto de partida con z3 = 2 pi rho^2.
%            (2) Muestra que falla la condición de Brockett: el punto
%            (0, 0, delta) no es f(z, v) para ningún (z, v) pequeño.
%            (3) Calcula el rango de la matriz de controlabilidad de la
%            linealización en el origen.
% OBSERVE    El sistema se puede llevar a (0, 0, z3) aunque ninguna velocidad
%            instantánea apunte en esa dirección: hay que dar una vuelta. Por eso
%            ninguna realimentación continua u = k(z) lo estabiliza.
% ESPERADO   rho = 0.5:  z3(2 pi) = pi/2 = 1.5708, (z1, z2) vuelve a (0, 0).
%            Distancia mínima de (0, 0, delta) a f(z, v) con |z|, |v| <= eps:
%            delta (no se puede acercar).  Rango de [B AB AAB] = 2 < 3.
% EXPLORE    Recorra el círculo al revés. ¿Qué signo tiene z3? ¿Cómo llegaría a
%            (0, 0, 1) con dos vueltas?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:vuelta]
rho = 0.5;
v = @(t) rho*[-sin(t); cos(t)];               % entrada en lazo abierto
f = @(t, z) [v(t); z(1)*[0 1]*v(t) - z(2)*[1 0]*v(t)];
[t, Z] = ode45(f, linspace(0, 2*pi, 801), [0; 0; 0], odeset('RelTol', 1e-11, 'AbsTol', 1e-12));
fprintf('Después de una vuelta: z = (%.2e, %.2e, %.4f);  2 pi rho^2 = %.4f\n', Z(end,:), 2*pi*rho^2);
% [fin:vuelta]

% [ini:brockett]
% ¿Es (0, 0, delta) = f(z, v) para algún z, v pequeños? Las dos primeras
% componentes obligan v = 0, y entonces la tercera vale 0. Muestreo aleatorio:
delta = 1e-3;  epsi = 0.1;  dmin = inf;
for j = 1:20000
    z = epsi*(2*rand(3,1) - 1);  w = epsi*(2*rand(2,1) - 1);
    fz = [w; z(1)*w(2) - z(2)*w(1)];
    dmin = min(dmin, norm(fz - [0; 0; delta]));
end
fprintf('Distancia mínima a (0, 0, %g) con |z|,|v| <= %g: %.2e (no baja de delta)\n', delta, epsi, dmin);
A = zeros(3);  B = [1 0; 0 1; 0 0];          % linealización en z = 0, v = 0
fprintf('Rango de [B AB A^2B] = %d de 3\n', rank([B A*B A*A*B]));
% [fin:brockett]

fig = estiloFigura(560, 480); plot3(Z(:,1), Z(:,2), Z(:,3)); grid on; view(-35, 25);
xlabel('$z_1$'); ylabel('$z_2$'); zlabel('$z_3$'); title('una vuelta en $(z_1,z_2)$ sube $z_3$');
