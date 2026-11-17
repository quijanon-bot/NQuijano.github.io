%% C9_Ej10_Inestabilidad -- Notas: sección 9.7 (inestabilidad)
% QUÉ HACE   Verifica en mallas las derivadas de los tres ejemplos de inestabilidad:
%            primer teorema (Vdot definida positiva), segundo teorema (Vdot - 2V >= 0
%            aunque Vdot < 0 en algunos puntos) y Cetaev (Vdot >= ||x||^2/2 en B_{1/2}).
% OBSERVE    En el segundo ejemplo, Vdot es negativa en (0, 0.5); el teorema no la necesita
%            positiva. Con V = x1 en el ejemplo de Cetaev, Vdot < 0 en (delta^2, -delta).
% ESPERADO   min Vdot/||x||^2 en B_{1/2} = 0.50 (la versión anterior daba 3/8).
% EXPLORE    Agrande la bola a r = 0.9 y a r = 1.1. ¿Dónde deja de valer la cota?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:inestabilidad]
[TH, RR] = meshgrid(linspace(0, 2*pi, 721), linspace(1e-3, 0.5, 400));
X1 = RR.*cos(TH);  X2 = RR.*sin(TH);
% primer teorema: V = ||x||^2/2
F1 = 2*X2 + X1.*(X1.^2 + 2*X2.^4);  F2 = -2*X1 + X2.*(X1.^2 + X2.^4);
Vd = X1.*F1 + X2.*F2;
fprintf('1er teorema: max |Vdot - (x1^4 + x1^2x2^2 + 2x1^2x2^4 + x2^6)| = %.1e;  min Vdot = %.1e (> 0)\n', ...
    max(abs(Vd(:) - (X1(:).^4 + X1(:).^2.*X2(:).^2 + 2*X1(:).^2.*X2(:).^4 + X2(:).^6))), min(Vd(:)));
% segundo teorema: V = (x1^2 - x2^2)/2
F1 = X1 + 3*X2.*sin(X2).^2 + 5*X1.*X2.^2.*sin(X1).^2;  F2 = 3*X1.*sin(X2).^2 + X2 - 5*X1.^2.*X2.*cos(X1).^2;
V = (X1.^2 - X2.^2)/2;  Vd = X1.*F1 - X2.*F2;
fprintf('2o teorema: min(Vdot - 2V) = %.1e (>= 0);  min Vdot = %.3f (< 0)\n', min(Vd(:) - 2*V(:)), min(Vd(:)));
f2 = @(x) [x(1) + 3*x(2)*sin(x(2))^2 + 5*x(1)*x(2)^2*sin(x(1))^2; 3*x(1)*sin(x(2))^2 + x(2) - 5*x(1)^2*x(2)*cos(x(1))^2];
p = [0; 0.5];  F = f2(p);
fprintf('            en (0, 0.5): V = %.3f, Vdot = %.3f\n', (p(1)^2 - p(2)^2)/2, p(1)*F(1) - p(2)*F(2));
% Cetaev: V = x1 - x2^2/2
Vd = X1.^2 + X2.^2 + X2.^3 - X1.^3.*X2;
fprintf('Cetaev: min Vdot/||x||^2 en B_{1/2} = %.3f\n', min(Vd(:)./RR(:).^2));
d = 0.1;  fprintf('con V = x1, en (delta^2, -delta), delta = 0.1: V = %.2f, Vdot = %.1e\n', d^2, d^4 - d^3);
% [fin:inestabilidad]

fig = estiloFigura(600, 520);  fC = @(t, x) [x(1)^2 + x(2)^3; -x(2) + x(1)^3];
th = linspace(0, 2*pi, 300);  plot(0.5*cos(th), 0.5*sin(th), 'k:');  hold on;
s = linspace(-1, 1, 200);  plot(s.^2/2, s, 'g', 'LineWidth', 2);
opc = odeset('RelTol', 1e-9, 'Events', @(t, x) deal(norm(x) - 0.6, 1, 0));
for x0 = [[0.02; 0.15], [0.03; -0.18], [0.01; 0]]
    [~, X] = ode45(fC, [0 200], x0, opc);  plot(X(:, 1), X(:, 2), 'k');
end
axis equal;  axis([-0.6 0.6 -0.6 0.6]);  grid on;  title('Cetaev: $U=\{x_1>x_2^2/2\}$');
