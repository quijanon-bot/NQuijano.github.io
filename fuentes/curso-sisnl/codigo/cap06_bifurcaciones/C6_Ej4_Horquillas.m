%% C6_Ej4_Horquillas -- Notas: sección 6.4 (horquillas y la histéresis)
% QUÉ HACE   (1) Diagramas de las horquillas supercrítica x' = mu x - x^3 y
%            subcrítica x' = mu x + x^3. (2) Con el término quíntico,
%            x' = mu x + x^3 - x^5, barre mu lentamente de -0.5 a 0.3 y de vuelta,
%            y grafica x contra mu: el ciclo de histéresis.
% OBSERVE    Al subir, el estado deja el origen cerca de mu = 0 (un poco después: hay
%            retardo); al bajar, se queda en la rama grande hasta mu = -1/4.
% ESPERADO   Sillas-nodo en mu = -1/4, x = +-0.7071. Con mu = -0.1: rama estable
%            x = 0.9420, inestable x = 0.3357.
% EXPLORE    Cambie la velocidad de la rampa (T). ¿Cambia el punto de caída? ¿Y el de
%            subida? ¿Por qué uno depende de la velocidad y el otro casi no?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:horquillas]
r = linspace(0, 1.4, 400);
musn = -r.^2 + r.^4;                  % ramas de x' = mu x + x^3 - x^5: mu = x^4 - x^2
estable = (2*r.^2 - 4*r.^4) < 0;      % f_x en la rama = mu + 3x^2 - 5x^4 = 2x^2 - 4x^4
fprintf('silla-nodo: mu = %.4f en x = %.4f\n', min(musn), r(musn == min(musn)));
fprintf('mu = -0.1: x estable = %.4f, inestable = %.4f\n', sqrt((1 + sqrt(0.6))/2), sqrt((1 - sqrt(0.6))/2));
% [fin:horquillas]

% [ini:quintica]
T = 4000;  ruido = 1e-6;                       % rampa: 0.8 en T unidades de tiempo
f = @(t, x, m0, m1) (m0 + (m1 - m0)*t/T)*x + x^3 - x^5 + ruido;
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-12, 'MaxStep', 2);
[t1, X1] = ode45(@(t, x) f(t, x, -0.5, 0.3), [0 T], 0.01, opc);
[t2, X2] = ode45(@(t, x) f(t, x, 0.3, -0.5), [0 T], X1(end), opc);
m1 = -0.5 + 0.8*t1/T;  m2 = 0.3 - 0.8*t2/T;
fprintf('subiendo: salta en mu = %.3f;  bajando: cae en mu = %.3f\n', ...
        m1(find(X1 > 0.5, 1)), m2(find(X2 < 0.5, 1)));
% [fin:quintica]

fig = estiloFigura(1200, 420);
subplot(1, 3, 1);  m = linspace(-1, 1, 200);  hold on;
plot(m(m <= 0), 0*m(m <= 0), 'k', m(m >= 0), 0*m(m >= 0), 'r--', m(m >= 0), sqrt(m(m >= 0)), 'k', m(m >= 0), -sqrt(m(m >= 0)), 'k');
grid on;  title('Supercr\''itica');  xlabel('$\mu$');  ylabel('$x^*$');
subplot(1, 3, 2);  hold on;
plot(m(m <= 0), 0*m(m <= 0), 'k', m(m >= 0), 0*m(m >= 0), 'r--', m(m <= 0), sqrt(-m(m <= 0)), 'r--', m(m <= 0), -sqrt(-m(m <= 0)), 'r--');
grid on;  title('Subcr\''itica');  xlabel('$\mu$');
subplot(1, 3, 3);  hold on;
plot(musn(estable), r(estable), 'k.', musn(~estable), r(~estable), 'r.', 'MarkerSize', 6);
plot(m1, X1, 'Color', [30 90 168]/255);  plot(m2, X2, 'Color', [224 159 62]/255);
grid on;  xlim([-0.5 0.3]);  title('Con $-x^5$: hist\''eresis');  xlabel('$\mu$');
