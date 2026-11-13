function verificarCap06()
% VERIFICARCAP06  Pruebas automáticas de los números del capítulo 6
% (bifurcaciones).   >> verificarCap06
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap06_numeros.py.)
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

fprintf('6.2  Lo que se rompe\n');
revisar("x' = mu - x^3, mu = 0.3: una sola raíz real", sum(abs(imag(roots([-1 0 0 0.3]))) < 1e-9), 1, 0);

fprintf('6.3  Silla-nodo\n');
eq = lineaFase(axes('Visible', 'off'), @(x) -1 + x.^2, [-2 2]);  close all;
revisar("x' = -1 + x^2: -1 estable", strcmp(eq.tipo{1}, 'estable'), 1, 0);
x = linspace(0, 1, 11);  h = 0.2;
revisar('cosecha: forma normal exacta', max(abs(x.*(1 - x) - h - ((0.25 - h) - (x - 0.5).^2))), 0, 1e-15);
o2 = odeset(opc, 'Events', @(t, x) deal(x + 1, 1, -1));
[~, ~, te] = ode45(@(t, x) -0.01 - x^2, [0 1e3], 1, o2);
revisar('fantasma |mu| = 0.01: tránsito de +1 a -1', te(1), 2*atan(10)/0.1, 1e-5);
revisar('... = 29.42', te(1), 29.42, 5e-3);
revisar('lentitud crítica mu = 0.01: 1/(2 sqrt mu)', 1/(2*sqrt(0.01)), 5, 0);

fprintf('6.4  Transcrítica y horquilla\n');
[~, n2] = ode45(@(t, n) (1*2 - 1)*n - 0.5*n^2, [0 400], 0.01, opc);
revisar('láser G = k = 1, alpha = 0.5, N0 = 2: n* = 2', n2(end), 2, 1e-8);
revisar('quíntica: silla-nodo en mu = -1/4', min(linspace(0, 1.4, 1401).^4 - linspace(0, 1.4, 1401).^2), -0.25, 1e-6);
revisar('quíntica, mu = -0.1: rama estable 0.9420', sqrt((1 + sqrt(0.6))/2), 0.9420, 1e-4);
revisar('quíntica, mu = -0.1: rama inestable 0.3357', sqrt((1 - sqrt(0.6))/2), 0.3357, 1e-4);
z = roots([-1 0.6928 -0.12]);
revisar('transcrítica + eps = -0.12: raíz doble en mu = 0.6928', abs(z(1) - z(2)), 0, 2e-2);
revisar('horquilla + h = 0.1: silla-nodo en 0.4072', 3*(0.05)^(2/3), 0.4072, 1e-4);

fprintf('6.5  En el plano\n');
f = @(t, x) [0.1*x(1) - x(1)*x(2); -x(2) + x(1)^2];
[~, X] = ode45(f, [0 200], [0.05; 0], opc);
revisar('horquilla escondida mu = 0.1: x1 -> sqrt(0.1)', X(end, 1), sqrt(0.1), 1e-6);
J = jacobianoNumerico(@(x) f(0, x), [sqrt(0.1); 0.1]);
revisar('... tau = -1', trace(J), -1, 1e-6);
revisar('... delta = 2 mu = 0.2', det(J), 0.2, 1e-6);
b = 0.35;  a = 1;  d = 1 - 4*a^2*b^2;
revisar('Griffith b = 0.35: a_c = 1.4286', 1/(2*b), 1.4286, 1e-4);
revisar('Griffith a = 1: silla en 0.4084', (1 - sqrt(d))/(2*a*b), 0.4084, 1e-4);
revisar('Griffith a = 1: nodo en 2.4488', (1 + sqrt(d))/(2*a*b), 2.4488, 1e-4);
xs = (1 - sqrt(d))/(2*a*b);
revisar('Griffith: la intermedia es silla', strcmp(clasificarEquilibrio([-a 1; 2*xs/(1 + xs^2)^2 -b]), 'silla'), 1, 0);
F = @(a) @(t, z) [-a*z(1) + z(2); z(1)^2/(1 + z(1)^2) - b*z(2)];
z = [2; 2.6];  fin = zeros(1, 3);  as = [1.3 1.6 1.3];
for k = 1:3, [~, Z] = ode45(F(as(k)), [0 400], z, opc);  z = Z(end, :).';  fin(k) = z(1); end
revisar('Griffith a = 1.3: encendido', fin(1) > 1, 1, 0);
revisar('Griffith a = 1.6: apagado', fin(2) < 1e-3, 1, 0);
revisar('Griffith de vuelta a 1.3: sigue apagado (histéresis)', fin(3) < 1e-3, 1, 0);
b = 0.5;  a = 0.8;  d = 1 - 4*a^2*b^2;
revisar('problema: b = 0.5, a = 0.8: equilibrios 0.5 y 2', [1 1]*[(1 - sqrt(d)); (1 + sqrt(d))]/(2*a*b), 2.5, 1e-12);

fprintf('6.6  Hopf\n');
sup = @(x) [-x(2) - x(1)*(x(1)^2 + x(2)^2);  x(1) - x(2)*(x(1)^2 + x(2)^2)];
revisar('l1 forma normal supercrítica', primerLyapunov(sup, [0; 0]), -1, 1e-6);
revisar('l1 circuito', primerLyapunov(@(x) [x(2) - x(1)^3; -x(1)], [0; 0]), -0.375, 1e-6);
K = 3;  rm = @(x) [x(1)*(1 - x(1)/K) - x(1)*x(2)/(1 + x(1)); x(2)*(2*x(1)/(1 + x(1)) - 1)];
revisar('l1 Rosenzweig-MacArthur K = 3 = -1/24', primerLyapunov(rm, [1; 4/3]), -1/24, 1e-4);
revisar('Rosenzweig-MacArthur: período al nacer 2 pi sqrt 3', 2*pi*sqrt(3), 10.88, 5e-3);
mu = 0.1;  fc = @(x) [x(2) - (x(1)^3 - mu*x(1)); -x(1)];
[~, X] = ode45(@(t, x) fc(x), [0 600], [0.1; 0], opc);
xr = mapaPoincare(fc, X(end, :), @(x) x(2), -1);          % primero, llegar a Sigma
[xr, T] = mapaPoincare(fc, xr, @(x) x(2), -1);            % después, una vuelta
[~, X] = ode45(@(t, x) fc(x), linspace(0, T, 4000), xr, opc);
revisar('circuito mu = 0.1: amplitud 0.3652', max(X(:, 1)), 0.3652, 2e-4);
revisar('circuito mu = 0.1: período 6.287', T, 6.287, 2e-3);
[~, X] = ode45(@(t, x) sup(x), [0 100], [1; 0], opc);
revisar('mu = 0, r0 = 1: r(100) = 1/sqrt(201)', norm(X(end, :)), 1/sqrt(201), 1e-7);
revisar('histéresis: silla-nodo de ciclos mu = -1/4 en r = 1/sqrt2', (1/sqrt(2))^4 - (1/sqrt(2))^2, -0.25, 1e-15);

fprintf('6.7  Ciclos\n');
m = 0.1;
revisar('pliegue mu = 0.1: ciclo interior 0.8266', sqrt(1 - sqrt(tan(m))), 0.8266, 1e-4);
revisar('pliegue mu = 0.1: ciclo exterior 1.1475', sqrt(1 + sqrt(tan(m))), 1.1475, 1e-4);
fp = @(x) [-x(1)*sin(m) - x(2)*cos(m) + (1 - x(1)^2 - x(2)^2)^2*(x(1)*cos(m) - x(2)*sin(m)); ...
            x(1)*cos(m) - x(2)*sin(m) + (1 - x(1)^2 - x(2)^2)^2*(x(1)*sin(m) + x(2)*cos(m))];
[~, X] = ode45(@(t, x) fp(x), [0 200], [0.3; 0], opc);
revisar('pliegue mu = 0.1: desde r = 0.3 converge al ciclo interior', norm(X(end, :)), sqrt(1 - sqrt(tan(m))), 1e-6);

fprintf('6.8  Mapas de Poincaré\n');
mu = 0.2;  f2 = @(x) [mu*x(1) + x(2) - x(1)*norm(x); -x(1) + mu*x(2) - x(2)*norm(x)];
P2 = @(r0) mu*r0/(r0 + (mu - r0)*exp(-2*pi*mu));
[xr, tau] = mapaPoincare(f2, [0.1; 0], @(x) x(2), -1);
revisar('ejemplo 2: P(0.1) simulado = fórmula', xr(1), P2(0.1), 1e-8);
revisar('ejemplo 2: tiempo de retorno 2 pi', tau, 2*pi, 1e-7);
revisar("ejemplo 2: P'(mu) = 0.2846", (P2(mu + 1e-6) - P2(mu - 1e-6))/2e-6, 0.2846, 1e-4);
P1 = @(r0) (1 + (1/r0^2 - 1)*exp(-4*pi))^(-1/2);
[~, R] = ode45(@(t, r) r*(1 - r^2), [0 2*pi], 0.3, opc);
revisar('ejemplo 1: P(0.3) simulado = fórmula', R(end), P1(0.3), 1e-8);
fv = @(x) [x(2) - (x(1)^3 - x(1)); -x(1)];
Pq = @(q) [1 0]*mapaPoincare(fv, [q; 0], @(x) x(2), -1);
qs = fzero(@(q) Pq(q) - q, [0.5 2]);
revisar('van der Pol: punto fijo 1.1081', qs, 1.1081, 2e-4);
[~, T] = mapaPoincare(fv, [qs; 0], @(x) x(2), -1);
revisar('van der Pol: período 6.663', T, 6.663, 2e-3);
dP = (Pq(qs + 1e-5) - Pq(qs - 1e-5))/2e-5;
[~, Z] = ode45(@(t, z) [fv(z(1:2)); 1 - 3*z(1)^2], [0 T], [qs; 0; 0], opc);
revisar("van der Pol: P'(q*) = exp(int div f)", dP/exp(Z(end, 3)), 1, 1e-3);
revisar("van der Pol: P'(q*) = 8.60e-4", dP, 8.60e-4, 1e-5);

fprintf('\n%d de %d verificaciones correctas\n', n - fallas, n);
end
