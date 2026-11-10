%% C2_Ej6_Histeresis -- Notas: sección 2.6 (histéresis en el diodo túnel)
% QUÉ HACE   (1) Calcula el intervalo de voltajes de fuente E en el que el
%            circuito con diodo túnel tiene tres equilibrios: E = v + R h(v)
%            tiene un máximo y un mínimo locales. (2) Sube E lentamente de 0 a
%            1.8 V en 4000 ns y lo vuelve a bajar, y registra v(t).
% OBSERVE    Al subir, v sigue la rama baja hasta que esa rama desaparece y
%            salta a la alta; al bajar, sigue la alta hasta que desaparece. Los
%            saltos ocurren en valores distintos de E: el estado depende de la
%            historia (histéresis). Cada salto es una bifurcación silla-nodo.
% ESPERADO   Tres equilibrios para 0.6590 < E < 1.6433 V. En el barrido lento el
%            salto hacia arriba ocurre en E = 1.652 y hacia abajo en E = 0.650
%            (un poco después de los valores estáticos: cerca de la silla-nodo la
%            dinámica es lenta).
% EXPLORE    Haga el barrido diez veces más rápido. ¿Se separan más los saltos
%            de los valores estáticos? ¿Por qué?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:intervalo]
[h, dh] = diodoTunel();  R = 1.5;  C = 2;
g = @(v) v + R*h(v);  dg = @(v) 1 + R*dh(v);       % E de equilibrio en función de v
vmax = fzero(dg, [0.05 0.3]);  vmin = fzero(dg, [0.3 0.7]);
fprintf('Tres equilibrios para %.4f < E < %.4f V (v = %.4f y %.4f)\n', g(vmin), g(vmax), vmin, vmax);
% [fin:intervalo]

% [ini:barrido]
Tm = 4000;  Emax = 1.8;
E = @(t) Emax*min(t, 2*Tm - t)/Tm;               % rampa de subida y de bajada
t = linspace(0, 2*Tm, 80001)';
[t, v] = ode45(@(t, v) ((E(t) - v)/R - h(v))/C, t, 0, odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 0.5));
Et = E(t);
iu = find(v(1:end-1) < 0.5 & v(2:end) >= 0.5, 1);  id = find(v(1:end-1) > 0.5 & v(2:end) <= 0.5, 1);
fprintf('Barrido lento: salta hacia arriba en E = %.3f V y hacia abajo en E = %.3f V\n', Et(iu), Et(id));
% [fin:barrido]

fig = estiloFigura(760, 480); vv = linspace(-0.05, 1.2, 800);
plot(g(vv), vv, 'Color', [0.6 0.6 0.6], 'LineWidth', 4); hold on;
plot(Et(1:40001), v(1:40001), Et(40001:end), v(40001:end)); grid on; xlim([0 1.8]);
xlabel('$E$ [V]'); ylabel('$v$ [V]'); legend('equilibrios', 'subiendo $E$', 'bajando $E$', 'Location', 'southeast');
