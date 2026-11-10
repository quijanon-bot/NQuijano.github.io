function verificarCap07()
% VERIFICARCAP07  Pruebas automáticas de los números del capítulo 7
% (estabilidad de Lyapunov).   >> verificarCap07
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap07_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));  addpath(raiz);
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-56s %12.5g\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-55s %12.5g  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
a = 1;  b = 0.5;  pend = @(t, x) [x(2); -a*sin(x(1)) - b*x(2)];

fprintf('7.2  Definiciones\n');
[~, X] = ode45(@(t, x) [x(2); -a*sin(x(1))], linspace(0, 40, 4001), [0.3; 0], opc);
E = a*(1 - cos(X(:,1))) + X(:,2).^2/2;
revisar('sin fricción: max|E - E0|', max(abs(E - E(1))), 0, 1e-7);
[~, X] = ode45(pend, [0 40], [0.3; 0], opc);
revisar('con fricción: |x(40)|', norm(X(end, :)), 0, 1e-3);
[~, X] = ode45(pend, [0 60], [1.5; 3], opc);
revisar('desde (1.5, 3) termina en x1 = 2 pi (x1/pi)', X(end, 1)/pi, 2, 1e-4);
[~, Z] = ode45(@(t, z) [z(1)*(1 - z(1)); sin(z(2)/2)^2], [0 400], [1; 0.1], opc);
d = sqrt((Z(:,1).*cos(Z(:,2)) - 1).^2 + (Z(:,1).*sin(Z(:,2))).^2);
revisar('polar: distancia máxima a (1, 0)', max(d), 2, 1e-3);
revisar('polar: theta(400)/(2 pi)', Z(end, 2)/(2*pi), 0.99823, 1e-4);

fprintf('7.3  Método indirecto\n');
J = @(x1) [0 1; -a*cos(x1) -b];
revisar('(0,0): max Re lambda', max(real(eig(J(0)))), -0.25, 1e-12);
revisar('(0,0): |Im lambda|', max(abs(imag(eig(J(0))))), sqrt(1 - 1/16), 1e-12);
revisar('(pi,0): valor propio positivo', max(eig(J(pi))), 0.780776, 1e-6);
[~, xc] = ode45(@(t, x) -x^3, [0 10], 1, opc);
revisar('x'' = -x^3: x(10) = 1/sqrt(21)', xc(end), 1/sqrt(21), 1e-7);

fprintf('7.4-7.5  Método directo, global y exponencial\n');
t = linspace(0, 20, 4001);  [~, X] = ode45(pend, t, [2.5; 0], opc);
Vt = a*(1 - cos(X(:,1))) + X(:,2).^2/2;
revisar('V(0) - V(20) = int b x2^2 dt', Vt(1) - Vt(end) - trapz(t, b*X(:,2).^2), 0, 1e-4);
revisar('V no crece (max diff)', max(diff(Vt)) <= 1e-10, 1, 0);
fK = @(t, x) [-6*x(1)/(1 + x(1)^2)^2 + 2*x(2); -2*(x(1) + x(2))/(1 + x(1)^2)^2];
[~, X] = ode45(fK, [0 200], [2; 2], opc);
revisar('Khalil: x1(200) > 700 desde (2, 2)', X(end, 1) > 700, 1, 0);
revisar('Khalil: x2(200)', X(end, 2), 1.912, 1e-2);
[~, xe] = ode45(@(t, x) -x - x^3, [0 1], 3, opc);
revisar('x'' = -x - x^3 desde 3: x(1)', xe(end), 0.372418, 1e-5);

fprintf('7.6  Formas cuadráticas\n');
Pa = @(a) [a 0 1; 0 a 2; 1 2 a];
revisar('det P(3) = a(a^2 - 5)', det(Pa(3)), 12, 1e-10);
revisar('min eig P(3) = 3 - sqrt5', min(eig(Pa(3))), 3 - sqrt(5), 1e-12);
revisar('min eig P(sqrt5) = 0', min(eig(Pa(sqrt(5)))), 0, 1e-12);
q = b/2;  cEst = 2*a + pi^2/2*q*(b - q);
x2s = linspace(-4, 4, 80001);
Vb = 0.5*(b*q*pi^2 + 2*q*pi*x2s + x2s.^2) + 2*a;
revisar('c*(b/2) = 2a + pi^2 b^2/8', cEst, 2.308425, 1e-6);
revisar('c*(b/2) = min de V en x1 = pi', min(Vb), cEst, 1e-6);

fprintf('7.7  Sistemas lineales\n');
A = [0 1; -1 0];  B = [0; 1];  C = [1 0];
revisar('rank(A_P - jI)', rank([A zeros(2); zeros(2) A] - 1i*eye(4)), 2, 0);
AS = [A zeros(2); B*C A];
revisar('rank(A_S - jI)', rank(AS - 1i*eye(4)), 3, 0);
y = [0 0 1 0]*expm(AS*7)*[1; 0; 0; 0];
revisar('serie: y(7) = (7/2) sin 7', y, 3.5*sin(7), 1e-9);
P = ecuacionLyapunov([0 -1; 1 -1], eye(2));
revisar('P11', P(1,1), 1.5, 1e-12);  revisar('P12', P(1,2), -0.5, 1e-12);  revisar('P22', P(2,2), 1, 1e-12);
revisar('x0''P x0, x0 = (1.2, 1)', [1.2 1]*P*[1.2; 1], 1.96, 1e-12);
Pn = ecuacionLyapunov([-1 10; 0 -2], eye(2));  ln = eig(Pn);
revisar('no normal: |x(ln 2)| desde (0, 1)', norm(expm([-1 10; 0 -2]*log(2))*[0; 1]), sqrt(6.3125), 1e-12);
revisar('no normal: sqrt(lmax/lmin)', sqrt(max(ln)/min(ln)), 7.2444, 1e-3);
warning('off', 'ecuacionLyapunov:singular');
revisar('A(0.5): número de valores propios negativos de P', sum(eig(ecuacionLyapunov([-1 2; 0 0.5], eye(2))) < 0), 1, 0);
Pq = ecuacionLyapunov([-1 2; 0 1], eye(2));
revisar('A(1): sin solución única (NaN)', any(isnan(Pq(:))), 1, 0);
warning('on', 'ecuacionLyapunov:singular');
k1 = 1;  k2 = 1;  bm = 0.3;  Cm = [0 sqrt(bm) 0 0];
for ka = [0 0.4]
    Am = [0 1 0 0; -(k1 + ka) -bm ka 0; 0 0 0 1; ka 0 -(k2 + ka) 0];
    revisar(sprintf('dos masas, kappa = %.1f: rango de observabilidad', ka), ...
            rank([Cm; Cm*Am; Cm*Am^2; Cm*Am^3]), 2 + 2*(ka > 0), 0);
end

fprintf('7.8  Región de atracción\n');
P = ecuacionLyapunov([0 -1; 1 -1], eye(2));
th = linspace(0, 2*pi, 72001);  c = cos(th);  s = sin(th);  k = -c.^3.*s + 2*c.^2.*s.^2;
r = 1./sqrt(k(k > 0));  D = [c(k > 0); s(k > 0)].*[r; r];
revisar('c* (van der Pol invertido)', min(sum(D.*(P*D))), 2.30448, 1e-4);
revisar('cota con bola', min(eig(P))*2/sqrt(5), 0.618034, 1e-6);

fprintf('\n%d/%d verificaciones correctas\n', n - fallas, n);
end
