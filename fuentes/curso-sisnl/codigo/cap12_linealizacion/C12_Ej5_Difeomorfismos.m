%% C12_Ej5_Difeomorfismos -- Notas: sección 12.4 (difeomorfismos y cambio de coordenadas)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   (1) Phi(x) = (x1, x2 + x1^3/2): calcula su inversa y verifica que es un
%            difeomorfismo global. (2) Phi(x) = (e^x1 cos x2, e^x1 sin x2): jacobiano no
%            singular en todo punto, pero no es uno a uno. (3) Van der Pol en las
%            coordenadas z = (x1^2 + x2, x1): verifica la inversa x = (z2, z1 - z2^2).
% OBSERVE    "det(dPhi/dx) ~= 0 en todo R^n" garantiza un difeomorfismo LOCAL alrededor
%            de cada punto, no uno global: (0, 0) y (0, 2 pi) van al mismo punto.
% ESPERADO   (1) error de la inversa 0. (2) det = e^(2 x1) > 0; |Phi(0,0) - Phi(0,2pi)| = 0.
%            (3) error de la inversa 0.
% EXPLORE    ¿Es Phi(x) = (x1 + x2^3, x2) global? ¿Y Phi(x) = (sinh x1, x2 + x1)? Use el
%            criterio de Hadamard: jacobiano no singular y ||Phi(x)|| -> inf.
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:global]
Phi  = @(x) [x(1); x(2) + x(1)^3/2];
Phii = @(z) [z(1); z(2) - z(1)^3/2];
X = 4*rand(2, 1000) - 2;  err = 0;
for i = 1:1000, err = max(err, norm(Phii(Phi(X(:,i))) - X(:,i))); end
fprintf('Phi = (x1, x2 + x1^3/2): det = 1 en todo punto, error de la inversa %.1e\n', err);
% [fin:global]

% [ini:local]
Psi  = @(x) exp(x(1))*[cos(x(2)); sin(x(2))];
dPsi = @(x) exp(x(1))*[cos(x(2)) -sin(x(2)); sin(x(2)) cos(x(2))];
fprintf('det dPsi/dx en (0.3, 1) = %.4f = e^0.6 = %.4f\n', det(dPsi([0.3; 1])), exp(0.6));
fprintf('|Psi(0,0) - Psi(0,2 pi)| = %.1e: no es uno a uno\n', norm(Psi([0; 0]) - Psi([0; 2*pi])));
fprintf('Psi(-30, 0) = %.1e: Psi no es propia (x1 -> -inf lleva a 0)\n', norm(Psi([-30; 0])));
% [fin:local]

% [ini:vdp]
Phv  = @(x) [x(1)^2 + x(2); x(1)];
Phvi = @(z) [z(2); z(1) - z(2)^2];
err = 0;  for i = 1:1000, err = max(err, norm(Phvi(Phv(X(:,i))) - X(:,i))); end
fprintf('van der Pol, z = (x1^2 + x2, x1): det = -1, error de la inversa %.1e\n', err);
% [fin:vdp]



% ---- Figura de las notas (fig:fl-difeo) ------------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
fig = estiloFigura(1200, 520);  s = linspace(-2, 2, 200);
subplot(1, 2, 1);  hold on;
for c = linspace(-2, 2, 11)
    plot(c*ones(size(s)), s + c^3/2, 'Color', az, 'LineWidth', 0.9);  plot(s, c + s.^3/2, 'Color', co, 'LineWidth', 0.9);
end
axis([-2.2 2.2 -4.5 4.5]);  box on;  xlabel('$z_1$');  ylabel('$z_2$');  title('$\Phi=(x_1,\ x_2+x_1^3/2)$: global');
subplot(1, 2, 2);  hold on;  th1 = linspace(0, 2*pi, 300);  th2 = linspace(2*pi, 4*pi, 300);
for c = linspace(-0.8, 0.5, 6)
    plot(exp(c)*cos(th1), exp(c)*sin(th1), 'Color', claro(az, 0.6), 'LineWidth', 2.4);
    plot(exp(c)*cos(th2), exp(c)*sin(th2), '--', 'Color', co, 'LineWidth', 1.2);
end
plot(1, 0, 'o', 'Color', no, 'MarkerFaceColor', no, 'MarkerSize', 5);
plot([0.55 0.97], [-1.3 -0.06], 'Color', no, 'LineWidth', 0.8);  text(0.25, -1.45, '$\Psi(0,0)=\Psi(0,2\pi)$');
axis equal;  axis([-1.9 1.9 -1.9 1.9]);  box on;  title('$\Psi=e^{x_1}(\cos x_2,\sin x_2)$: dos vueltas');
