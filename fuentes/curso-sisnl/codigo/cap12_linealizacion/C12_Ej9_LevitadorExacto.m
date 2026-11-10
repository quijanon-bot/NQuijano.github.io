%% C12_Ej9_LevitadorExacto -- Notas: sección 12.8 (el levitador, exacto)
% QUÉ HACE   Linealización exacta del levitador (r = n = 3, leyExactaLevitador.m) con
%            K = [6000 1100 60] (polos en -10, -20, -30):
%            (1) seguimiento de y_d = 0.08 + 0.03 sin(2 pi t), contra la jacobiana con
%                ganancia fija (diseñada en 0.05) y prealimentación u*(y_d(t));
%            (2) escalón 0.05 -> 0.2 m: la corriente se anula y la ley explota;
%            (3) la misma maniobra con una referencia suave (filtro p^4/(s + p)^4, p = 6);
%            (4) masa real 0.12 kg desde t = 0.5 s: exacta sola y exacta + integrador.
% OBSERVE    (1) La exacta conserva la respuesta diseñada en todo el rango. (2) La fuerza
%            magnética solo atrae: para caer más rápido que g hay que apagar la corriente,
%            y b(x) = L_g L_f^2 h es proporcional a ella. (4) Exacta no es robusta.
% ESPERADO   (1) error máximo para t > 1: jacobiana 2.36 cm, exacta 2.1e-6 m.
%            (2) i = 0.02 A en t = 0.0205 s.  (3) y(2) = 0.19966 m, i_min = 6.154 A,
%            max y_d'' = 0.705 m/s^2 < g.  (4) error final 1.96 cm sola; 2e-10 con integrador.
% EXPLORE    En (3) suba p a 12, 20, 22 y 23. ¿Desde qué p vuelve a anularse la corriente?
%            Compare con la estimación del problema del filtro (sección 12.12).
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
P = parametrosLevitador();  KFL = [6000 1100 60];        % s^3 + 60 s^2 + 1100 s + 6000
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 1e-3);

% [ini:seguimiento]
[A, B] = jacobianoLevitador(0.05, P);  K = ubicarPolos(A, B, [-20 -25 -30]);
Am = 0.03;  w = 2*pi;
yd = @(t) [0.08 + Am*sin(w*t), Am*w*cos(w*t), -Am*w^2*sin(w*t), -Am*w^3*cos(w*t)];
c3 = sqrt(2*P.g*P.m/(P.L0*P.a));                       % x3* = c3 (a + y)
xsRef = @(t) [0.08 + Am*sin(w*t); 0; c3*(P.a + 0.08 + Am*sin(w*t))];   % equilibrio en y_d(t)
uJac = @(t, x) P.R*[0 0 1]*xsRef(t) - K*(x - xsRef(t));         % u*(y_d) - K (x - x*(y_d))
t = linspace(0, 3, 3001);  x0 = equilibrioLevitador(0.08, P);
[~, X1] = ode45(@(t, x) modeloLevitador(x, uJac(t, x), P), t, x0, opc);
[~, X2] = ode45(@(t, x) modeloLevitador(x, leyExactaLevitador(x, yd(t), KFL, P), P), t, x0, opc);
Yd = 0.08 + Am*sin(w*t(:));  k = t > 1;
fprintf('seguimiento, error máximo (t > 1): jacobiana %.2f cm, exacta %.1e m\n', ...
        100*max(abs(X1(k,1) - Yd(k))), max(abs(X2(k,1) - Yd(k))));
% [fin:seguimiento]

% [ini:singularidad]
x0 = equilibrioLevitador(0.05, P);
ev = odeset(opc, 'MaxStep', 2e-4, 'Events', @(t, x) deal(x(3) - 0.02, 1, -1));
[ts, S1] = ode45(@(t, x) modeloLevitador(x, leyExactaLevitador(x, [0.2 0 0 0], KFL, P), P), [0 1.2], x0, ev);
fprintf('escalón 0.05 -> 0.2: la corriente llega a 0.02 A en t = %.4f s (y = %.4f m)\n', ts(end), S1(end,1));
% [fin:singularidad]

% [ini:suave]
p = 6;  cf = poly(-p*ones(1, 4));                       % filtro p^4/(s + p)^4 en forma de estados
Af = [zeros(3, 1) eye(3); -fliplr(cf(2:end))];  Bf = [0; 0; 0; p^4];
lazo = @(t, z) [modeloLevitador(z(1:3), leyExactaLevitador(z(1:3), z(4:7), KFL, P), P); Af*z(4:7) + Bf*0.2];
[t2, S2] = ode45(lazo, [0 2], [x0; 0.05; 0; 0; 0], odeset(opc, 'MaxStep', 2e-4));
fprintf('referencia suave: y(2) = %.5f m, corriente mínima %.3f A, max y_d'''' = %.3f m/s^2\n', ...
        S2(end,1), min(S2(:,3)), max(S2(:,6)));
% [fin:suave]

% [ini:robustez]
yb = 0.05;  xs = equilibrioLevitador(yb, P);  mReal = @(t) 0.10 + 0.02*(t >= 0.5);
kI = poly([-10 -15 -20 -30]);                          % [1 k3 k2 k1 k0]
xi3 = @(x) P.g - P.k/P.m*x(2) - P.L0*P.a*x(3)^2/(2*P.m*(P.a + x(1))^2);
vI  = @(x, s) -(kI(5)*s + kI(4)*(x(1) - yb) + kI(3)*x(2) + kI(2)*xi3(x));
uI  = @(x, s) leyExactaLevitador(x, [0 0 0 vI(x, s)], [0 0 0], P);     % con K = 0: u = (v - Lf3)/b
t = linspace(0, 3, 3001);
[~, X3] = ode45(@(t, x) modeloLevitador(x, leyExactaLevitador(x, [yb 0 0 0], KFL, P), P, mReal(t)), t, xs, opc);
[~, Z4] = ode45(@(t, z) [modeloLevitador(z(1:3), uI(z(1:3), z(4)), P, mReal(t)); z(1) - yb], t, [xs; 0], opc);
fprintf('masa real 0.12 kg: error final %.2f cm (exacta sola), %.0e m (con integrador)\n', ...
        100*(X3(end,1) - yb), Z4(end,1) - yb);
% [fin:robustez]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1); plot(t, X1(:,1), t, X2(:,1), t, Yd, 'k--'); set(gca, 'YDir', 'reverse'); grid on;
xlabel('$t$ [s]'); ylabel('$y$ [m]'); legend('jacobiana', 'exacta', '$y_d$'); title('Seguimiento');
subplot(1, 2, 2); plot(ts, S1(:,3)); hold on; plot(t2, S2(:,3)); grid on;
xlabel('$t$ [s]'); ylabel('$i$ [A]'); legend('escal\''on', 'referencia suave'); title('Corriente');
