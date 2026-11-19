function verificarCap08()
% VERIFICARCAP08  Pruebas automáticas de los números del capítulo 8
% (principio de invarianza y construcción de funciones de Lyapunov).   >> verificarCap08
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap08_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));  addpath(raiz);
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-60s %12.5g\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-59s %12.5g  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
escape = @(L) odeset(opc, 'Events', @(t, x) eventoODE(abs(x(1)) - L, 1, 0));

fprintf('8.2-8.3  Conjuntos límite y péndulo\n');
[t, X] = ode45(@(t, x) [x(2); -x(1) + (1 - x(1)^2)*x(2)], [0 80], [0.1; 0], opc);
revisar('van der Pol: amplitud del ciclo = 2.009', max(X(t > 60, 1)), 2.009, 1e-3);
revisar('péndulo: borde de E = arccos(-0.8) = 2.498', acos(1 - 1.8), 2.498, 1e-3);
b = 0.3;  V = @(x) 1 - cos(x(1)) + x(2)^2/2;
[t, Z] = ode45(@(t, z) [z(2); -sin(z(1)) - b*z(2); z(2)^2], linspace(0, 40, 40001), [2; 0.8; 0], opc);
revisar('péndulo: V(2, 0.8) = 1.736', V([2 0.8]), 1.736, 1e-3);
revisar('péndulo: 12 cruces de x2 = 0 en [0, 40]', sum(diff(sign(Z(:, 2))) ~= 0), 12, 0);
revisar('péndulo: b int x2^2 = V(x0) - V(x(40))', b*Z(end, 3) - (V([2 0.8]) - V(Z(end, 1:2))), 0, 1e-7);

fprintf('8.4  Qué puede ser M\n');
fb = @(t, x) [x(2); -(x(1) - x(1)^3) - 0.4*x(2)*abs(x(2))];
revisar('blando: V(1.2, 0) = 0.2016', 1.2^2/2 - 1.2^4/4, 0.2016, 1e-12);
[te, ~] = ode45(fb, [0 100], [1.2; 0], escape(50));
revisar('blando: desde (1.2, 0) escapa en t = 2.40', te(end), 2.40, 0.01);
[~, X] = ode45(fb, [0 300], [0.9; 0], opc);
revisar('blando: desde (0.9, 0) converge', norm(X(end, :)) < 0.05, 1, 0);
fd = @(t, x) [x(2); -(x(1) + x(1)^3) - 0.4*x(2)*abs(x(2))];
[t, X] = ode45(fd, linspace(0, 400, 400001), [2; 0], opc);
revisar('duro: amplitud(400) x 400 = 5.95', max(abs(X(t >= 390, 1)))*400, 5.95, 0.1);
revisar('anillo c = 0.2: r_min = 0.325', sqrt(1 - 2*sqrt(0.2)), 0.325, 1e-3);
revisar('anillo c = 0.2: r_max = 1.376', sqrt(1 + 2*sqrt(0.2)), 1.376, 1e-3);
fa = @(t, z) [-(z(2) - 1)*z(1); z(1)^2];
[~, Z] = ode45(fa, [0 60], [2; -1], opc);
revisar('adaptativo: k_inf = 1 + 2 sqrt2 = 3.828', Z(end, 2), 1 + 2*sqrt(2), 1e-6);
[~, Z] = ode45(fa, [0 60], [0.5; 3], opc);
revisar('adaptativo: desde (0.5, 3), k_inf = 3.062', Z(end, 2), 1 + sqrt(4.25), 1e-6);
C = [0 sqrt(0.3) 0 0];
for kap = [0.4 0]
    A = [0 1 0 0; -(1 + kap) -0.3 kap 0; 0 0 0 1; kap 0 -(1 + kap) 0];
    revisar(sprintf('masas kappa = %.1f: rango de observabilidad', kap), rank([C; C*A; C*A^2; C*A^3]), 4 - 2*(kap == 0), 0);
end
[~, Z] = ode45(@(t, z) [z(1)*(1 - 0.2*z(1) - z(2)); z(2)*(-0.5 + z(1))], [0 300], [2; 0.2], opc);
revisar('Lotka--Volterra: converge a (0.5, 0.9)', norm(Z(end, :) - [0.5 0.9]), 0, 1e-4);
fi = @(t, x) [x(1)*(1 - norm(x)) - x(2)*(1 - x(1)/norm(x)); x(2)*(1 - norm(x)) + x(1)*(1 - x(1)/norm(x))];
[~, X] = ode45(fi, linspace(0, 400, 40001), [cos(0.15); sin(0.15)], opc);
d = sqrt((X(:, 1) - 1).^2 + X(:, 2).^2);
revisar('atractivo inestable: excursión máxima = 2', max(d), 2, 1e-4);
revisar('atractivo inestable: distancia final < 0.01', d(end) < 0.01, 1, 0);

fprintf('8.5  Región de atracción\n');
revisar('V en las sillas = 1/4', 1/2 - 1/4, 0.25, 1e-12);
[~, X] = ode45(@(t, x) [x(2); -x(1) + x(1)^3 - x(2)], [0 100], [0; 0.7], opc);
revisar('desde (0, 0.7) converge', norm(X(end, :)) < 1e-6, 1, 0);
cs = nivelCritico(@(x1, x2) 1.5*x1.^2 - x1.*x2 + x2.^2, ...
                  @(x1, x2) -(x1.^2 + x2.^2) - x1.^3.*x2 + 2*x1.^2.*x2.^2, [-3 3], [-3 3], 1201);
revisar('nivelCritico, van der Pol invertido: c* = 2.30 (cap. 7)', cs, 2.30, 0.01);

fprintf('8.6  Gradiente variable\n');
cs = nivelCritico(@(x1, x2) x1.^2 + x1.*x2 + x2.^2/2, @(x1, x2) -x1.^2 - (x1 + x2).*sin(x1 + x2), [-8 8], [-8 8], 1601);
revisar('G1 (a11 = 2): c* = pi^2/2 (malla)', cs, pi^2/2, 0.05);
area = @(a) pi*nivelCritico(@(x1, x2) a*x1.^2/2 + x1.*x2 + x2.^2/2, ...
    @(x1, x2) (a - 2)*x1.*x2 - x1.^2 - (x1 + x2).*sin(x1 + x2), [-12 12], [-12 12], 801)/sqrt(a/4 - 1/4);
revisar('G1: área con a11 = 1.48 = 37.4', area(1.48), 37.4, 0.3);
revisar('G1: área con a11 = 1.1 casi 0', area(1.1) < 0.1, 1, 0);
revisar('G1: intervalo 4 - 2 sqrt2 = 1.17', 4 - 2*sqrt(2), 1.17, 5e-3);
revisar('G2: c*(b/2) = 2.308 con b = 0.5', 2 + pi^2*0.25*0.25/2, 2.308, 1e-3);

fprintf('8.7  Krasovskii\n');
lmin = min(arrayfun(@(x2) min(eig([5 -2; -2 1 + 6*x2^2])), linspace(-5, 5, 201)));
revisar('K1: min valor propio de -(2J + I) > 0', lmin > 0, 1, 0);
A = [0 1; -1 -1];  P = ecuacionLyapunov(A, eye(2));
revisar('oscilador: max eig(A + A'') = 0 con P = I', max(eig(A + A')), 0, 1e-12);
revisar('oscilador: P = [1.5 0.5; 0.5 1]', norm(P - [1.5 0.5; 0.5 1]), 0, 1e-12);
revisar('P8.10: A''PA = [1 0.5; 0.5 1.5]', norm(A'*P*A - [1 0.5; 0.5 1.5]), 0, 1e-12);
revisar('K2: (r - r^3)^2 en r = 1/sqrt3 = 4/27', (1/sqrt(3) - 1/sqrt(3)^3)^2, 4/27, 1e-12);
[te, ~] = ode45(@(t, x) [-x(1) + x(1)^3; -x(2)], [0 10], [1.05; 0], escape(10));
revisar('K2: desde (1.05, 0) escapa en t = 1.18', te(end), 1.18, 0.01);

fprintf('8.8  Zubov\n');
fz = @(t, x) [-x(1) + 2*x(1)^2*x(2); -x(2)];
W = @(x1, x2) x2.^2/2 + x1.^2./(2*(1 - x1.*x2));
h = 1e-6;  x1 = 0.7;  x2 = 0.9;  F = fz(0, [x1; x2]);
Wd = (W(x1 + h, x2) - W(x1 - h, x2))/(2*h)*F(1) + (W(x1, x2 + h) - W(x1, x2 - h))/(2*h)*F(2);
revisar('Z2: dW/dt = -||x||^2 en (0.7, 0.9)', Wd + x1^2 + x2^2, 0, 1e-7);
[te, ~] = ode45(fz, [0 30], [2.1; 0.5], escape(1e3));
revisar('Z2: desde (2.1, 0.5) escapa (t < 30)', te(end) < 30, 1, 0);
fv = @(t, x) [-x(2); x(1) + (x(1)^2 - 1)*x(2)];  hz = @(x) x(1)^2 + x(2)^2;
revisar('Z3: W(0.1, 0) = 0.0150', zubovMalla(fv, 0.1, 0, hz), 0.0150, 2e-4);
revisar('Z3: W(1, 0) = 1.60', zubovMalla(fv, 1, 0, hz), 1.60, 5e-3);
revisar('Z3: W(1.9, 0) = 11.25', zubovMalla(fv, 1.9, 0, hz), 11.25, 0.05);
revisar('Z3: W(2.1, 0) = Inf', isinf(zubovMalla(fv, 2.1, 0, hz)), 1, 0);
Pv = ecuacionLyapunov([0 -1; 1 -1], eye(2));
revisar('Z3: área de la elipse x''Px <= 2.30 = 6.46', pi*2.30/sqrt(det(Pv)), 6.46, 0.01);

fprintf('\n%d/%d pruebas correctas\n', n - fallas, n);
end
