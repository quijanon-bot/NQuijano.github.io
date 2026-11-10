%% C12_Ej2_ControlIntegral -- Notas: sección 12.2 (método 2: control integral)
% QUÉ HACE   Agrega el integrador sigma' = y - yb al levitador y estabiliza el sistema
%            aumentado con u = -K1 x - K2 sigma (más el valor nominal). En t = 0.5 s la
%            masa real pasa de 0.10 a 0.12 kg; los dos controladores usan el modelo nominal.
% OBSERVE    La realimentación de estados queda con un error permanente de ~1 cm; con el
%            integrador el error se anula y el voltaje se reajusta solo al valor que la
%            planta REAL necesita: en el equilibrio, sigma' = 0 obliga a y = yb.
% ESPERADO   rango [A B; C 0] = 4.  Error final: 1.0329 cm (estados), < 1e-9 (integral).
%            Voltaje final con integrador: 6.8621 V = R x3* calculado con m = 0.12.
% EXPLORE    Ponga la carga en 0.15 kg. ¿Sigue funcionando el integrador? Cambie los polos
%            aumentados a [-3 -4 -5 -6]: ¿qué pasa con la región en la que funciona?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
P = parametrosLevitador();  yb = 0.05;
[xs, us] = equilibrioLevitador(yb, P);  [A, B] = jacobianoLevitador(yb, P);  C = [1 0 0];

% [ini:rango]
fprintf('rango [A B; C 0] = %d (debe ser n + p = 4)\n', rank([A B; C 0]));
Aa = [A zeros(3, 1); C 0];  Ba = [B; 0];
Ka = ubicarPolos(Aa, Ba, [-15 -20 -25 -30]);  K1 = Ka(1:3);  K2 = Ka(4);
K  = ubicarPolos(A, B, [-20 -25 -30]);
fprintf('K1 = %s,  K2 = %.2f\n', mat2str(K1, 5), K2);
% [fin:rango]

% [ini:carga]
mReal = @(t) 0.10 + 0.02*(t >= 0.5);            % la carga que el modelo no conoce
opc = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 1e-3);
t = linspace(0, 3, 3001);
[~, X1] = ode45(@(t, x) modeloLevitador(x, us - K*(x - xs), P, mReal(t)), t, xs, opc);
lazo = @(t, z) [modeloLevitador(z(1:3), us - K1*(z(1:3) - xs) - K2*z(4), P, mReal(t)); z(1) - yb];
[~, Z2] = ode45(lazo, t, [xs; 0], opc);
U1 = us - (X1 - xs.')*K.';  U2 = us - (Z2(:,1:3) - xs.')*K1.' - K2*Z2(:,4);
fprintf('error final: estados = %.4f cm,  integral = %.1e m\n', 100*(X1(end,1) - yb), Z2(end,1) - yb);
fprintf('voltaje final con integrador = %.4f V;  R x3* con m = 0.12: %.4f V\n', U2(end), ...
        P.R*sqrt(2*P.g*0.12/(P.L0*P.a))*(P.a + yb));
% [fin:carga]

fig = estiloFigura(1100, 420);
subplot(1, 2, 1); plot(t, 100*X1(:,1), t, 100*Z2(:,1)); hold on; plot(t, 100*yb*ones(size(t)), 'k:');
set(gca, 'YDir', 'reverse'); grid on; xlabel('$t$ [s]'); ylabel('$y$ [cm]');
legend('estados', 'con integrador', 'Location', 'southeast'); title('Masa real 0.12 kg desde $t=0.5$ s');
subplot(1, 2, 2); plot(t, U1, t, U2); grid on; xlabel('$t$ [s]'); ylabel('$u$ [V]'); title('Voltaje');
