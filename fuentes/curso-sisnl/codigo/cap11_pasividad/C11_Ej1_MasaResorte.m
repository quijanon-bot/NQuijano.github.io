%% C11_Ej1_MasaResorte -- Notas: sección 11.2 (balance de energía)
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

fig = estiloFigura(1000, 420);
subplot(1,2,1); plot(t, X(:,1), t, X(:,2)); grid on;
legend('$x_1$', '$x_2=y$'); xlabel('$t$ (s)'); title('estado');
subplot(1,2,2); plot(t, S, t, D, t, V, 'k', 'LineWidth', 2.5); grid on;
legend('$\int u\,y$', '$\int \delta y^2$', '$V$', 'Location', 'northwest');
xlabel('$t$ (s)'); title('balance: $V-V(0)=\int u\,y-\int\delta y^2$');
