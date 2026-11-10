function verificarCap01()
% VERIFICARCAP01  Pruebas automáticas de los números del capítulo 1
% (introducción y motivación).   >> verificarCap01
% (Los mismos números se verificaron de forma independiente en Python con
%  herramientas/cap01_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-50s %12.5f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-49s %12.5f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);

fprintf('1.1  Superposición\n');
F = @(P) 1.6*P.*(1 - P/32);
revisar('una isla: F(20)', F(20), 12, 1e-12);
revisar('dos islas: 2 F(10)', 2*F(10), 22, 1e-12);
revisar('mejor reparto: 2 F(10) es el máximo de F(a)+F(20-a)', max(F(0:0.01:20) + F(20 - (0:0.01:20))), 22, 1e-9);

fprintf('1.2  Reescalamiento\n');
revisar('alpha de (1,1,0.5)', 0.5/sqrt(1*1), 0.5, 0);
revisar('alpha de (2,18,3)', 3/sqrt(18*2), 0.5, 1e-12);
tau = linspace(0, 20, 401);
[~, A] = ode45(@(t, x) [x(2); -x(1) - 0.5*x(2)], tau, [1; 0], opc);
[~, B] = ode45(@(t, x) [x(2); (-18*x(1) - 3*x(2))/2], tau/3, [1; 0], opc);
revisar('misma curva en tau (2,18,3) vs normalizado', max(abs(A(:,1) - B(:,1))), 0, 1e-7);

fprintf('1.3  Fenómenos\n');
for c = [10 1.0019; 90 1.1803; 170 2.4394].'
    k = sind(c(1)/2);
    T = 4*integral(@(p) 1./sqrt(1 - k^2*sin(p).^2), 0, pi/2)/(2*pi);
    revisar(sprintf('péndulo: T/T0 con amplitud %d°', c(1)), T, c(2), 1e-4);
end
[~, X] = ode45(@(t, x) -x^2, [0 0.9], -1, opc);
revisar('x'' = -x^2, x(0) = -1: x(0.9) = 1/(0.9 - 1)', X(end), -10, 1e-6);
tv = linspace(0, 60, 60001);
[~, X] = ode45(@(t, x) [x(2); (1 - x(1)^2)*x(2) - x(1)], tv, [0.1; 0], opc);
[~, Y] = ode45(@(t, x) [x(2); (1 - x(1)^2)*x(2) - x(1)], tv, [3.5; 0], opc);
revisar('van der Pol: amplitud del ciclo desde adentro', max(abs(X(40001:end,1))), 2.0086, 1e-3);
revisar('van der Pol: amplitud del ciclo desde afuera', max(abs(Y(40001:end,1))), 2.0086, 1e-3);

fprintf('1.4  Mapa logístico\n');
P = 1; for k = 1:21, P = F(P); if k == 1, revisar('P[1]', P, 1.55, 1e-12); end, end
revisar('P[21] (R = 1.6)', P, 12, 1e-4);
revisar('punto fijo K(1 - 1/R)', 32*(1 - 1/1.6), 12, 1e-12);
G = @(p) 3.2*p.*(1 - p/32);  p = 1; for k = 1:3000, p = G(p); end
revisar('ciclo de período 2 (R = 3.2): valor bajo', min(p, G(p)), 16.4174, 1e-4);
revisar('ciclo de período 2 (R = 3.2): valor alto', max(p, G(p)), 25.5826, 1e-4);
H = @(p) 3.5*p.*(1 - p/32);  p = 1; for k = 1:4000, p = H(p); end
revisar('R = 3.5: período 4 (H^4(p) = p, H^2(p) ~= p)', double(abs(H(H(H(H(p)))) - p) < 1e-9 && abs(H(H(p)) - p) > 1), 1, 0);
Pex = @(t) 32*exp(1.6*t)./(32 + exp(1.6*t) - 1);
[t, Pn] = ode45(@(t, P) 1.6*P*(1 - P/32), [0 10], 1, opc);
revisar('logística continua: error de ode45', max(abs(Pn - Pex(t))), 0, 1e-7);

fprintf('1.5  Energía y Brockett\n');
[t, X] = ode45(@(t, x) [x(2); -4*x(1) - 0.5*x(2)], [0 5 10 20], [1; 0], opc);
E = 2*X(:,1).^2 + 0.5*X(:,2).^2;
revisar('E(0)', E(1), 2, 1e-12);  revisar('E(5)', E(2), 0.18269, 2e-5);
revisar('E(10)', E(3), 0.015329, 2e-6);  revisar('E(20)', E(4), 8.4748e-5, 2e-8);
rho = 0.5; v = @(t) rho*[-sin(t); cos(t)];
[~, Z] = ode45(@(t, z) [v(t); z(1)*[0 1]*v(t) - z(2)*[1 0]*v(t)], [0 2*pi], [0; 0; 0], opc);
revisar('vuelta: z3(2 pi) = 2 pi rho^2', Z(end,3), pi/2, 1e-8);
revisar('vuelta: (z1,z2) regresa al origen', norm(Z(end,1:2)), 0, 1e-8);
revisar('rango de controlabilidad de la linealización', rank([eye(3,2) zeros(3,4)]), 2, 0);

fprintf('1.6  Control\n');
[~, X] = ode45(@(t, x) x + (-5*x)^3, [0 10], 1, opc);
revisar('x'' = x + u^3, u = -5x: x(10) -> 5^(-3/2)', X(end), 5^(-1.5), 1e-6);
[~, X] = ode45(@(t, x) x - 5*x, [0 5], 1, odeset('RelTol', 1e-11, 'AbsTol', 1e-16));
revisar('u = -(5x)^(1/3): x(5) = exp(-20)', X(end)/exp(-20), 1, 1e-4);
k3 = @(x) 1 - 2*(x(1)*(x(1) + x(2)) > 0);
tt = linspace(0, 10, 10001)';
[~, X] = ode45(@(t, x) [x(2); k3(x)*x(1)], tt, [1; 1], odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 1e-3));
nx = sqrt(sum(X.^2, 2));
revisar('estructura variable: t(2%)', tt(find(nx > 0.02*nx(1), 1, 'last')), pi/2 + log(50), 2e-3);
revisar('estructura variable: x(pi/2) = (1,-1)', norm(X(1572,:) - [1 -1]), 0, 2e-3);
[~, X] = ode45(@(t, x) [x(2); -x(1) - x(2)], tt, [1; 1], opc);
nx = sqrt(sum(X.^2, 2));
revisar('PD: t(2%)', tt(find(nx > 0.02*nx(1), 1, 'last')), 8.91, 2e-3);
revisar('PD: sobrepico min x1', min(X(:,1)), -0.20871, 2e-5);
kP = 10; v = 0.5; w = 0.1; r = 1; k = 2;
revisar('PD: y(inf) = (kP(r-w)+v)/(k+kP)', (kP*(r - w) + v)/(k + kP), 0.79167, 1e-5);
dyn = @(t, x) [x(2); -3*x(2) - kP*(x(1) + w - r) - 5*x(3) + v - x(2) - k*x(1); x(1) + w - r];
[~, X] = ode45(dyn, [0 60], [0; 0; 0], opc);
revisar('PID: y(inf) = r - w', X(end,1), 0.9, 1e-6);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
end
