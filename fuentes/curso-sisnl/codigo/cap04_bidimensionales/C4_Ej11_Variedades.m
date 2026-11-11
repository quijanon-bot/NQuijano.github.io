%% C4_Ej11_Variedades -- Notas: sección 4.7 (variedades estable e inestable)
% QUÉ HACE   (1) x1' = -x1, x2' = x2 + x1^2: compara la variedad estable exacta
%            x2 = -x1^2/3 con la que calcula variedadSilla, y simula desde (1,-1/3),
%            que está en W^s, y desde (1,0), que está en E^s pero no en W^s.
%            (2) Duffing con delta = 0.5: W^s y W^u de la silla y las cuencas.
% OBSERVE    (1) La solución desde (1,0) se va a infinito aunque arranca sobre E^s.
%            (2) W^s del origen separa las cuencas de (1,0) y (-1,0) en franjas.
% ESPERADO   (1) distancia máxima entre W^s numérica y exacta < 1e-10; |x(15)| ~1e-6
%            desde (1,-1/3); x2(15) > 1e5 desde (1,0).
% EXPLORE    Integre W^s de Duffing HACIA ADELANTE desde la silla (cambie el signo en
%            variedadSilla). ¿Qué pasa y por qué?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:exacta]
f = @(x) [-x(1); x(2) + x(1)^2];
ramas = variedadSilla(f, [0; 0], 'estable', 8, 1e-6, [-2 2 -2.5 2]);
err = 0;
for r = 1:2, err = max(err, max(abs(ramas{r}(:, 2) + ramas{r}(:, 1).^2/3))); end
fprintf('W^s numérica contra x2 = -x1^2/3: error máximo %.2e\n', err);
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, X] = ode45(@(t, x) f(x), [0 15], [1; -1/3], opc);
fprintf('desde (1,-1/3) (en W^s): |x(15)| = %.2e\n', norm(X(end, :)));
[~, X] = ode45(@(t, x) f(x), [0 15], [1; 0], opc);
fprintf('desde (1, 0)   (en E^s): x2(15) = %.3e\n', X(end, 2));
% [fin:exacta]

% [ini:variedad]
delta = 0.5;  g = @(x) [x(2); x(1) - x(1)^3 - delta*x(2)];
fig = estiloFigura(700, 620);  hold on;
[X1, X2] = meshgrid(linspace(-3, 3, 201));          % pozo final de cada punto:
x = X1;  y = X2;  hpaso = 0.01;                      % RK4 de paso fijo, vectorizado
F = @(x, y) deal(y, x - x.^3 - delta*y);
for k = 1:6000                                       % t = 60
    [a1, b1] = F(x, y);  [a2, b2] = F(x + hpaso/2*a1, y + hpaso/2*b1);
    [a3, b3] = F(x + hpaso/2*a2, y + hpaso/2*b2);  [a4, b4] = F(x + hpaso*a3, y + hpaso*b3);
    x = x + hpaso/6*(a1 + 2*a2 + 2*a3 + a4);  y = y + hpaso/6*(b1 + 2*b2 + 2*b3 + b4);
end
S = sign(x);
contourf(X1, X2, S, [0 0]);  colormap([1 0.85 0.87; 0.85 0.9 1]);
for r = variedadSilla(g, [0; 0], 'estable', 40, 1e-6, [-3 3 -3 3]), plot(r{1}(:, 1), r{1}(:, 2), 'k', 'LineWidth', 2); end
for r = variedadSilla(g, [0; 0], 'inestable', 40, 1e-6), plot(r{1}(:, 1), r{1}(:, 2), 'Color', [42 157 143]/255, 'LineWidth', 2); end
axis equal;  axis([-3 3 -3 3]);  xlabel('$x_1$');  ylabel('$x_2$');  title('Duffing: $W^s$ (negro) separa las cuencas');
% [fin:variedad]
