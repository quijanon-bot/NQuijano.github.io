%% C1_Ej9_PID -- Notas: sección 1.6 (lo que se le olvida al diagrama de bloques)
% QUÉ HACE   Masa-resorte m y'' + c y' + k y = u + v (m = 1, c = 1, k = 2) con una
%            perturbación constante v = 0.5 en la entrada y un error constante
%            w = 0.1 en el sensor: se mide ym = y + w. Referencia r = 1.
%            Compara el PD u = -kP e - kD e' y el PID (con kI), e = ym - r.
% OBSERVE    El PD deja un error que depende de v y de w. El PID elimina el
%            efecto de v (principio del modelo interno), pero no el de w: el
%            controlador hace que la MEDICIÓN sea r, y la medición miente.
% ESPERADO   PD (kP = 10, kD = 3):  y(inf) = (kP (r - w) + v)/(k + kP) = 0.7917.
%            PID (kI = 5):          y(inf) = r - w = 0.9.
% EXPLORE    ¿Qué pasa con el PD si kP crece? ¿Y con el PID si w cambia de signo?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:pid]
m = 1; c = 1; k = 2;  v = 0.5;  w = 0.1;  r = 1;
kP = 10; kD = 3; kI = 5;
% estado: x = (y, y', integral de e)
dyn = @(t, x, kI) [x(2);
                   (-kD*x(2) - kP*(x(1) + w - r) - kI*x(3) + v - c*x(2) - k*x(1))/m;
                   x(1) + w - r];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t1, X1] = ode45(@(t, x) dyn(t, x, 0),  [0 40], [0; 0; 0], opc);
[t2, X2] = ode45(@(t, x) dyn(t, x, kI), [0 40], [0; 0; 0], opc);
fprintf('PD:  y(40) = %.4f   fórmula = %.4f\n', X1(end,1), (kP*(r - w) + v)/(k + kP));
fprintf('PID: y(40) = %.4f   fórmula = r - w = %.4f\n', X2(end,1), r - w);
% [fin:pid]

fig = estiloFigura(760, 380); plot(t1, X1(:,1), t2, X2(:,1)); hold on; plot([0 40], [r r], 'k--');
grid on; xlabel('$t$'); ylabel('$y$'); legend('PD', 'PID', 'referencia', 'Location', 'southeast');
