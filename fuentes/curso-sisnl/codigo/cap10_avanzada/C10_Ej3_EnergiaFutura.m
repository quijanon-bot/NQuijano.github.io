%% C10_Ej3_EnergiaFutura -- Notas: sección 10.3 (la energía futura)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Para x' = A x, A = [0 1; -1 -1]: calcula V(x0) = int_0^inf ||e^{A tau} x0||^2
%            numéricamente y la compara con x0' P x0, P de A'P + PA = -I.
%            Verifica que dV(x(t))/dt = -||x(t)||^2.
% OBSERVE    La integral y la forma cuadrática coinciden: la ecuación de Lyapunov es la
%            condición de que la energía futura se pierda al ritmo ||x||^2.
% ESPERADO   P = [1.5 0.5; 0.5 1]; V(1, 0.5) = 2.25.
% EXPLORE    Repita con A = [0 1; -2 -3]. ¿Coincide con el P del problema 10.4?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:energia]
A = [0 1; -1 -1];  x0 = [1; 0.5];
P = ecuacionLyapunov(A, eye(2));
Vint = integral(@(tau) arrayfun(@(s) norm(expm(A*s)*x0)^2, tau), 0, 60);
fprintf('P = [%.3f %.3f; %.3f %.3f]\n', P);
fprintf('integral = %.6f,  x0''P x0 = %.6f\n', Vint, x0'*P*x0);
t = 1.3;  h = 1e-5;  V = @(s) (expm(A*s)*x0)'*P*(expm(A*s)*x0);
fprintf('dV/dt en t = 1.3: %.6f;  -||x||^2 = %.6f\n', (V(t + h) - V(t - h))/(2*h), -norm(expm(A*t)*x0)^2);
% [fin:energia]

% ---- Figura de las notas (fig:av-energia) ---------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
tt = linspace(0, 12, 1200);  Xt = zeros(2, numel(tt));
for j = 1:numel(tt), Xt(:, j) = expm(A*tt(j))*x0; end
n2 = sum(Xt.^2, 1);  Vt = sum((P*Xt).*Xt, 1);
fig = estiloFigura(1200, 440);
subplot(1, 2, 1);  hold on;
fill([tt fliplr(tt)], [n2 zeros(size(n2))], claro(az, 0.2), 'EdgeColor', 'none');  plot(tt, n2, 'Color', az);
text(2.0, 0.8, sprintf('\\''area $=%.2f=V(x_0)$', x0'*P*x0), 'Color', no);
xlim([0 12]);  grid on;  box on;  xlabel('$\tau$');  ylabel('$\|\phi(\tau;x_0)\|^2$');  title('energ\''ia futura');
subplot(1, 2, 2);  hold on;  tc = 2;  [~, k] = min(abs(tt - tc));  ix = k-150:k+150;
plot(tt, Vt, 'Color', no, 'LineWidth', 2);
plot(tt(ix), Vt(k) - n2(k)*(tt(ix) - tc), '--', 'Color', co, 'LineWidth', 1.3);
plot(tc, Vt(k), 'o', 'Color', co, 'MarkerFaceColor', co, 'MarkerSize', 4);
axis([0 12 0 2.4]);  grid on;  box on;  xlabel('$t$');
legend('$V(x(t))=x^\top Px$', 'pendiente $-\|x(t)\|^2$');  title('se gasta en el presente');
