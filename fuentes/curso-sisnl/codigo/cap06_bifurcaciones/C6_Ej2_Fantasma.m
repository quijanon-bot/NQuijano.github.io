%% C6_Ej2_Fantasma -- Notas: sección 6.3 (el fantasma de la silla-nodo)
% QUÉ HACE   (1) Simula x' = mu - x^2 desde x(0) = 4 para cuatro mu < 0 y muestra la
%            pausa cerca de x = 0. (2) Mide el tiempo de tránsito de x = 1 a x = -1
%            para 25 valores de |mu| y lo compara con la fórmula exacta
%            2 atan(1/sqrt|mu|)/sqrt|mu| y con la ley asintótica pi/sqrt|mu|.
% OBSERVE    En escala log-log el tiempo es una recta de pendiente -1/2.
% ESPERADO   |mu| = 0.01: tránsito de +1 a -1 = 29.42; toda la recta, pi/0.1 = 31.42.
% EXPLORE    Mida, en x' = mu - x^2 con mu > 0, la constante de tiempo de la
%            recuperación hacia sqrt(mu). ¿Cómo escala con mu? (lentitud crítica)
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:fantasma]
mm = logspace(-3, 0, 25);                 % |mu|
Tsim = zeros(size(mm));
for k = 1:numel(mm)
    m = mm(k);
    opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'Events', @(t, x) deal(x + 1, 1, -1));
    [~, ~, te] = ode45(@(t, x) -m - x^2, [0 1e5], 1, opc);
    Tsim(k) = te(1);
end
Texacto = 2*atan(1./sqrt(mm))./sqrt(mm);
fprintf('|mu| = 0.01: simulado %.4f, exacto %.4f, pi/sqrt|mu| = %.4f\n', ...
        interp1(mm, Tsim, 0.01), 2*atan(10)/0.1, pi/0.1);
fprintf('error relativo máximo simulado vs exacto: %.1e\n', max(abs(Tsim - Texacto)./Texacto));
p = polyfit(log(mm(1:8)), log(Tsim(1:8)), 1);
fprintf('pendiente log-log cerca de mu = 0: %.4f (teoría: -1/2)\n', p(1));
% [fin:fantasma]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1);  hold on;
for m = [0.02 0.08 0.3 1]
    opc = odeset('RelTol', 1e-9, 'Events', @(t, x) deal(x + 4, 1, -1));
    [t, X] = ode45(@(t, x) -m - x^2, [0 60], 4, opc);
    plot(t, X);
end
grid on;  xlabel('$t$');  ylabel('$x$');  axis([0 26 -4.2 4.2]);
legend('$\mu=-0.02$', '$\mu=-0.08$', '$\mu=-0.3$', '$\mu=-1$');  title('El fantasma: una pausa sin equilibrio');
subplot(1, 2, 2);
loglog(mm, Tsim, 'o', mm, pi./sqrt(mm), '-');  grid on;
xlabel('$|\mu|$');  ylabel('tiempo de $+1$ a $-1$');  legend('simulado', '$\pi/\sqrt{|\mu|}$');
