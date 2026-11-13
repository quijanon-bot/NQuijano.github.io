function verificarCap10()
% VERIFICARCAP10  Pruebas automáticas de los números del capítulo 10
% (UUB, conversos, CLF, Barbalat, ISS).   >> verificarCap10
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap10_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));  addpath(raiz);
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-58s %12.5g\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-57s %12.5g  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
pasado = @(t, X, t1) X(t >= t1, :);

fprintf('10.2  UUB\n');
revisar('escalar: T(14, 1.05) = ln 260', log(13/0.05), 5.56, 5e-3);
revisar('escalar: T(4, 1.5) = ln 6', log(3/0.5), 1.79, 5e-3);
[t, X] = ode45(@(t, x) -x + sin(t), linspace(0, 60, 6001), 4, opc);
revisar('escalar: amplitud final = 1/sqrt2', max(abs(pasado(t, X, 30))), 1/sqrt(2), 1e-4);
revisar('escalar: cota de Lyapunov T <= 1856', (98 - 1.05^2/2)/(1.05^2 - 1.05), 1856, 0.5);
A = [0 1; -4 -0.2];  B = [0; 1];  P = ecuacionLyapunov(A, eye(2));  l = eig(P);
revisar('oscilador: lambda_min(P) = 3.123', min(l), 3.123, 1e-3);
revisar('oscilador: lambda_max(P) = 12.527', max(l), 12.527, 1e-3);
mu = 2*norm(P*B)*0.2/0.5;
revisar('oscilador: mu = 2.50', mu, 2.50, 5e-3);
revisar('oscilador: b = 5.01', mu*sqrt(max(l)/min(l)), 5.01, 5e-3);
[t, X] = ode45(@(t, x) A*x + B*0.2*sin(1.3*t), linspace(0, 40, 8001), [2.45; 0], opc);
revisar('oscilador: max ||x|| = 4.50', max(sqrt(sum(X.^2, 2))), 4.50, 5e-3);
revisar('oscilador: max V/eta < 1', max(sum((X*P).*X, 2))/(max(l)*mu^2) < 1, 1, 0);
Pr = [1.5 0.5; 0.5 1];  lr = eig(Pr);  mur = sqrt(5)*0.3/0.9;
revisar('resorte: mu = 0.745', mur, 0.745, 1e-3);
revisar('resorte: b = 1.30', sqrt((max(lr)*mur^2 + mur^4/2)/min(lr)), 1.30, 5e-3);
[t, X] = ode45(@(t, x) [x(2); -(1 + x(1)^2)*x(1) - x(2) + 0.3*cos(t)], linspace(0, 80, 16001), [2; 0], opc);
revisar('resorte: limsup con 0.3 cos t = 0.30', max(sqrt(sum(pasado(t, X, 50).^2, 2))), 0.30, 5e-3);

fprintf('10.3  Conversos\n');
A1 = [0 1; -1 -1];  P1 = ecuacionLyapunov(A1, eye(2));
revisar('P = [1.5 0.5; 0.5 1]', norm(P1 - [1.5 0.5; 0.5 1]), 0, 1e-12);
revisar('V(1, 0.5) = 2.25', [1 0.5]*P1*[1; 0.5], 2.25, 1e-12);
revisar('integral de la energía futura = 2.25', integral(@(s) arrayfun(@(q) norm(expm(A1*q)*[1; 0.5])^2, s), 0, 60), 2.25, 1e-7);
revisar('c4 = 2 lambda_max = 3.62', 2*max(eig(P1)), 3.62, 5e-3);
revisar('nu* = 0.276', 1/(2*max(eig(P1))), 0.276, 1e-3);
revisar('margen real: Hurwitz con nu = 0.99', max(real(eig(A1 + 0.99*[0 0; 1 0]))) < 0, 1, 0);
revisar('margen real: no Hurwitz con nu = 1.01', max(real(eig(A1 + 1.01*[0 0; 1 0]))) > 0, 1, 0);
revisar('E5 / P10.4: nu* = 0.382', 1/(2*max(eig(ecuacionLyapunov([0 1; -2 -3], eye(2))))), 0.382, 1e-3);
f = @(t, x) [x(2); sin(pi/max(x'*x, 1e-12))^2*x(2) - x(1)];
[~, X] = ode45(f, [0 400], [0.6; 0], odeset(opc, 'RelTol', 1e-11));
revisar('sin V(x): desde 0.6 espirala a Gamma_2 = 0.7071', norm(X(end, :)), 1/sqrt(2), 1e-4);

fprintf('10.4  CLF y Sontag\n');
revisar('lineal: ganancia -(1 + sqrt2)', leySontag(1, 1), -(1 + sqrt(2)), 1e-12);
revisar('lineal: u(0) = -4.83 desde x = 2', leySontag(4, 2), -4.83, 5e-3);
revisar('cos: u_S(0) = 0.17', -cos(2) + leySontag(-16, 2), 0.17, 5e-3);
revisar('cos: u_FL(0) = 6.42', -cos(2) + 8 - 2, 6.42, 5e-3);
k8 = @(x) leySontag(x^2, x^3);
[~, X] = ode45(@(t, x) x + x^2*k8(x), [0 8], 1, odeset('RelTol', 1e-10, 'AbsTol', 1e-14));
revisar('control pequeño: |u(8)| = 6249', abs(k8(X(end))), 6249, 2);
k9 = @(x) leySontag(x^4, x^3);
revisar('x^3 + x^2 u: Sontag linealizado = -2x', (k9(1e-3) - k9(-1e-3))/2e-3, -2, 1e-5);
revisar('E10: k(10) = -10/198 (aprox.)', leySontag(100 - 1e4, 10), -10/198, 2e-5);
revisar('variante con lg^4: k -> 0 si lf = 0', leySontag(0, 1e-3), -1e-3, 1e-12);

fprintf('10.5  Barbalat\n');
revisar('pulsos: área = pi^2/12', sum(1./(2*(1:200000).^2)), pi^2/12, 1e-5);
[~, Z] = ode45(@(t, z) [-z(1) + z(2)*sin(t); -z(1)*sin(t)], [0 40], [1; 1], opc);
revisar('adaptativo sin t: theta -> 0', abs(Z(end, 2)) < 0.05, 1, 0);
[~, Z] = ode45(@(t, z) [-z(1) + z(2)*exp(-0.3*t); -z(1)*exp(-0.3*t)], [0 40], [1; 1], opc);
revisar('adaptativo e^{-0.3t}: theta -> -0.11', Z(end, 2), -0.11, 5e-3);

fprintf('10.6  ISS\n');
o2 = odeset(opc, 'Events', @(t, x) deal(x - 1e6, 1, 1));
[~, ~, te] = ode45(@(t, x) -3*x + 1 + 2*x^2, [0 1], 2, o2);
revisar('Riccati: escape en ln 1.5 = 0.405', te(1), log(1.5), 1e-5);
revisar('-x^3 + w: gamma(0.5) = 1 con theta = 1/2', (0.5/0.5)^(1/3), 1, 0);
k = @(x) -2*x/(x^2 + 1);  k1 = @(x) k(x) - x*(x^2 + 1);
[~, ~, te] = ode45(@(t, x) x + (x^2 + 1)*(k(x) + 1), [0 5], 0, o2);
revisar('rediseño: escape en 4 pi/(3 sqrt3) = 2.42', te(1), 4*pi/(3*sqrt(3)), 1e-4);
[~, X] = ode45(@(t, x) x + (x^2 + 1)*(k1(x) + 1), [0 10], 0, opc);
revisar('rediseño con -L_gV: x -> 0.4887', X(end), 0.4887, 2e-4);
[~, X] = ode45(@(t, x) x + (x^2 + 1)*(leySontag(x^2, x*(x^2 + 1), 1) + 1), [0 10], 0, opc);
revisar('Sontag kappa = 1: x -> 0.386', X(end), 0.386, 1e-3);
revisar('w = 0.1: x_+ = 9.90', (1 + sqrt(1 - 0.04))/0.2, 9.90, 1e-2);

fprintf('10.7  Interconexiones\n');
o3 = odeset(opc, 'Events', @(t, x) deal(abs(x(1)) - 1e8, 1, 1));
[~, ~, te] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -x(2)], [0 2], [2; 2], o3);
revisar('cascada x1^2 x2: escape en ln(2)/2 = 0.347', te(1), log(2)/2, 1e-5);
revisar('cascada x1 x2^2 desde (1, 3): pico 18.2', exp(-log(3) + 4), 18.2, 5e-3);
revisar('Young: 27/32', 1/(4*8/27), 27/32, 1e-15);
xs = fzero(@(x) x - 1.2*sin(x), [0.5 2]);
revisar('pequeña ganancia: x* = 1.027', xs, 1.027, 1e-3);
revisar('... ab cos x* = 0.62', 1.2*cos(xs), 0.62, 5e-3);
revisar('ab = -3: Im(lambda) = sqrt3', max(imag(eig([-1 1; -3 -1]))), sqrt(3), 1e-12);
revisar('E24: -1 + sqrt2', max(real(eig([-1 2; 1 -1]))), -1 + sqrt(2), 1e-12);

fprintf('\n%d/%d verificaciones correctas\n', n - fallas, n);
end
