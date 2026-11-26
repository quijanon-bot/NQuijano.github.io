%% C11_Ej1_MasaResorte -- Notas: sección 11.2 (balance de energía)
% TRANSPARENCIA  Escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
% QUÉ HACE   Simula x1' = x2, x2' = -F(x1) - delta x2 + u, y = x2, con el resorte
%            duro F(x1) = x1 + x1^3, delta = 0.3 y u = 0.8 sin(1.2 t) durante
%            12 s. Evalúa almacenamiento, suministro y disipación sobre la solución.
% OBSERVE    V(t) - V(0) coincide con int u y - int delta y^2 en todo instante
%            (sin resolver nada: es la desigualdad de disipación con igualdad).
%            Después de t = 12 s no entra energía y V solo puede bajar.
% ESPERADO   residuo del balance < 1e-6;  V(12) = 1.374;  V(30) = 0.006;
%            energía suministrada hasta t = 12: 4.977.
% EXPLORE    Ponga delta = -0.05 (fricción negativa): ¿qué parte del balance
%            cambia de signo? ¿Sigue valiendo V(t) <= V(0) + int u y?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:balance]
delta = 0.3;
F  = @(x1) x1 + x1.^3;                        % resorte duro: F(x1) x1 > 0
u  = @(t) 0.8*sin(1.2*t).*(t < 12);           % fuerza externa hasta t = 12 s
f  = @(t, x) [x(2); -F(x(1)) - delta*x(2) + u(t)];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.01);
[t1, X1] = ode45(f, [0 12], [0; 0], opc);     % por tramos: u es discontinua en t = 12
[t2, X2] = ode45(f, [12 30], X1(end,:).', opc);
t = [t1; t2(2:end)];  X = [X1; X2(2:end,:)];
y  = X(:,2);                                  % salida conjugada de u: la velocidad
V  = X(:,1).^2/2 + X(:,1).^4/4 + X(:,2).^2/2; % energía potencial + cinética
uu = [u(t1); zeros(numel(t2) - 1, 1)];
[S, D, res] = balanceEnergia(t, V, uu.*y, delta*y.^2);
fprintf('residuo máximo del balance: %.1e\n', max(abs(res)));
fprintf('V(12) = %.4f   V(30) = %.4f   suministrada hasta 12 s = %.4f\n', ...
        V(numel(t1)), V(end), S(numel(t1)));
% [fin:balance]

% ---- Figura de las notas (fig:pa-masa) -------------------------------------------------------
az = [30 90 168]/255;  co = [209 73 91]/255;  vi = [108 74 182]/255;  am = [224 159 62]/255;
ve = [42 157 143]/255;  no = [20 33 61]/255;  gr = [92 103 125]/255;  cl = [201 209 222]/255;
claro = @(c, a) 1 - a*(1 - c);                            % color pálido, sin transparencia
rell = @(x, y1, y2, c) patch([x(1:end-1); x(2:end); x(2:end); x(1:end-1)], ...  % relleno entre y1 y y2
    [y1(1:end-1); y1(2:end); y2(2:end); y2(1:end-1)], c, 'EdgeColor', 'none');  % (franjas convexas)
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 0.01);
uf = @(t) 0.8*sin(1.2*t).*(t < 12);
[t1, X1] = ode45(@(t, x) [x(2); -(x(1) + x(1)^3) - 0.3*x(2) + uf(t)], linspace(0, 12, 6001), [0; 0], opc);
[t2, X2] = ode45(@(t, x) [x(2); -(x(1) + x(1)^3) - 0.3*x(2)], linspace(12, 30, 9001), X1(end,:).', opc);
t = [t1; t2(2:end)];  X = [X1; X2(2:end,:)];
V = X(:,1).^2/2 + X(:,1).^4/4 + X(:,2).^2/2;
S = cumtrapz(t, uf(t).*X(:,2));  D = cumtrapz(t, 0.3*X(:,2).^2);
fig = estiloFigura(1200, 460);
subplot(1, 2, 1);  hold on;  yl = [-1.6 1.6];
patch([0 12 12 0], yl([1 1 2 2]), claro(am, 0.08), 'EdgeColor', 'none');
h = [plot(t, X(:,1), 'Color', az), plot(t, X(:,2), 'Color', co), plot(t, uf(t), '--', 'Color', gr, 'LineWidth', 1)];
ylim(yl);  grid on;  box on;  xlabel('$t$ (s)');  title('estado y entrada');
legend(h, '$x_1$ (posici\''on)', '$x_2=y$ (velocidad)', '$u$', 'Location', 'southoutside', 'Orientation', 'horizontal');
subplot(1, 2, 2);  hold on;  yl = [0 1.1*max(S)];
patch([0 12 12 0], yl([1 1 2 2]), claro(am, 0.08), 'EdgeColor', 'none');
k = 1:300:numel(t);
h = [plot(t, S, 'Color', ve), plot(t, D, 'Color', vi), plot(t, V, 'Color', no, 'LineWidth', 2.4), ...
     plot(t(k), S(k) - D(k), 'o', 'Color', am, 'MarkerFaceColor', am, 'MarkerSize', 4)];
ylim(yl);  grid on;  box on;  xlabel('$t$ (s)');  title('balance de energ\''ia');
legend(h, 'suministrada $\int u\,y$', 'disipada $\int\delta y^2$', 'almacenada $V$', '$S-D$ (puntos)', ...
       'Location', 'southoutside', 'Orientation', 'horizontal');
