%% C11_Ej14_AguaCaras -- Notas: sección 11.10 (trampa: las caras del simplex)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Simula el lazo tanques-replicador desde caras del simplex:
%            q3(0) = 0 y q3(0) = 1e-2, 1e-4, 1e-6, 1e-8.
% OBSERVE    Si q3(0) = 0, q3(t) = 0 para siempre: el tanque 3 se vacía en tiempo
%            finito y el sistema converge a OTRO equilibrio. Si q3(0) > 0 converge,
%            pero el retardo crece como ln(1/q3(0)): cada factor 100 suma ~3 s.
% ESPERADO   tanque 3 vacío en t = 2 sqrt(0.4)/1.4 = 0.9035 s;
%            q3 llega a 0.5 en t = 4.52, 7.70, 10.74, 13.72 s.
% EXPLORE    ¿Contradice esto que el equilibrio sea asintóticamente estable?
%            Relea la región de atracción D del teorema.
clear; close all; clc;
if ~exist('eventoODE', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:caras]
Q = 2;  r = 2;  vm = 2;  c = [0.6; 1.0; 1.4];
fprintf('tanque 3 sin caudal: se vacía en t = 2 sqrt(v3(0))/c3 = %.4f s\n', ...
        2*sqrt(0.4)/1.4);
for q30 = 10.^(-2:-2:-8)
    x0  = [0.4; 0.4; 0.4; 1 - q30/2; 1 - q30/2; q30];
    ev  = @(t, x) eventoODE(x(6) - 0.5, 1, 1);           % q3 cruza 0.5 subiendo
    opc = odeset('RelTol', 1e-8, 'AbsTol', [1e-10*ones(5,1); 1e-3*q30], 'Events', ...
            ev);   % tolerancia a la escala de q3
    [~, ~, te] = ode45(@(t, x) modeloAgua(x, c, Q, r, vm), [0 40], x0, opc);
    fprintf('q3(0) = %.0e:  q3 llega a 0.5 en t = %.2f s\n', q30, te);
end
% [fin:caras]

% ---- Figura de las notas (fig:pa-caras) ------------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
Q = 2;  r = 2;  vm = 2;  c = [0.6; 1.0; 1.4];
fig = estiloFigura(1200, 440);  cs = [az; co; vi];
[t, X] = ode45(@(t, x) modeloAgua(x, c, Q, r, vm), linspace(0, 25, 5001), [0.4; 0.4; 0.4; 1; 1; 0], ...
               odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
subplot(1, 2, 1);  hold on;
for i = 1:3, plot(t, max(X(:,i), 0), 'Color', cs(i,:)); end
grid on;  box on;  xlabel('$t$ (s)');  title('$q_3(0)=0$: el tanque 3 se vac\''ia');  legend('$v_1$', '$v_2$', '$v_3$');
subplot(1, 2, 2);  hold on;  ks = [2 4 6 8];  cs = [ve; az; vi; co];
for j = 1:4
    e = 10^-ks(j);
    [t, X] = ode45(@(t, x) modeloAgua(x, c, Q, r, vm), linspace(0, 30, 6001), [0.4; 0.4; 0.4; 1 - e/2; 1 - e/2; e], ...
                   odeset('RelTol', 1e-8, 'AbsTol', [1e-10*ones(5,1); 1e-3*e]));
    plot(t, X(:,6), 'Color', cs(j,:));
end
plot([0 30], [14/15 14/15], '--', 'Color', gr, 'LineWidth', 0.8);
grid on;  box on;  xlabel('$t$ (s)');  title('converge, con retardo $\sim\ln(1/q_3(0))$');
legend('$q_3(0)=10^{-2}$', '$q_3(0)=10^{-4}$', '$q_3(0)=10^{-6}$', '$q_3(0)=10^{-8}$', 'Location', 'southeast');
