function verificarCap12()
% VERIFICARCAP12  Pruebas automáticas de los números del capítulo 12
% (linealización por retroalimentación).   >> verificarCap12
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap12_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));  addpath(raiz);
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-52s %12.5g\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-51s %12.5g  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
P = parametrosLevitador();
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12, 'MaxStep', 1e-3);

fprintf('12.1-12.2  Levitador y linealización jacobiana\n');
[xs, us] = equilibrioLevitador(0.05, P);  [A, B] = jacobianoLevitador(0.05, P);
revisar('x3* = u* en y = 0.05', us, 6.26418, 1e-5);
revisar('f(x*, u*) = 0', norm(modeloLevitador(xs, us, P)), 0, 1e-12);
Jn = zeros(3);  for i = 1:3, e = zeros(3, 1); e(i) = 1e-7; Jn(:, i) = (modeloLevitador(xs + e, us, P) - modeloLevitador(xs - e, us, P))/2e-7; end
revisar('jacobiano cerrado = numérico', max(abs(A(:) - Jn(:))), 0, 1e-4);
revisar('valor propio inestable de A(0.05)', max(real(eig(A))), 13.6413, 1e-4);
K = ubicarPolos(A, B, [-20 -25 -30]);
revisar('K(1)', K(1), -237.166, 1e-3);  revisar('K(3)', K(3), 0.87475, 1e-5);
revisar('eig(A - BK) en -20, -25, -30', norm(sort(eig(A - B*K)) - [-30; -25; -20]), 0, 1e-8);
x0 = [0.15; 0; xs(3)];  t = linspace(0, 0.6, 1201);
[~, X] = ode45(@(t, x) modeloLevitador(x, us - K*(x - xs), P), t, x0, opc);
YL = arrayfun(@(tt) [1 0 0]*expm((A - B*K)*tt)*(x0 - xs) + 0.05, t(:));
revisar('y0 = 0.15: max|y - y_lin| [m]', max(abs(X(:,1) - YL)), 0.010668, 2e-5);
C = [1 0 0];  revisar('rango [A B; C 0]', rank([A B; C 0]), 4, 0);
Ka = ubicarPolos([A zeros(3, 1); C 0], [B; 0], [-15 -20 -25 -30]);
mR = @(t) 0.10 + 0.02*(t >= 0.5);  t = [0 3];
[~, X1] = ode45(@(t, x) modeloLevitador(x, us - K*(x - xs), P, mR(t)), t, xs, opc);
[~, Z2] = ode45(@(t, z) [modeloLevitador(z(1:3), us - Ka(1:3)*(z(1:3) - xs) - Ka(4)*z(4), P, mR(t)); z(1) - 0.05], t, [xs; 0], opc);
revisar('carga 0.12 kg: error con estados [cm]', 100*(X1(end,1) - 0.05), 1.0329, 1e-3);
revisar('carga 0.12 kg: error con integrador', Z2(end,1) - 0.05, 0, 1e-8);

fprintf('12.3  Péndulo\n');
a = 10;  b = 1;  c = 10;  k1 = 4;  k2 = 3;  o2 = odeset('RelTol', 1e-11, 'AbsTol', 1e-12);  t = linspace(0, 6, 1201);
pend = @(u) @(t, x) [x(2); -a*sin(x(1)) - b*x(2) + c*u(x)];
[~, XJ] = ode45(pend(@(x) (-(a + k1)*(x(1) - pi) - k2*x(2))/c), t, [0; 0], o2);
[~, XE] = ode45(pend(@(x) (a*sin(x(1)) - k1*(x(1) - pi) - k2*x(2))/c), t, [0; 0], o2);
[~, E]  = ode45(@(t, e) [e(2); -k1*e(1) - (b + k2)*e(2)], t, [-pi; 0], o2);
revisar('exacta: max|x1 - predicción|', max(abs(XE(:,1) - E(:,1) - pi)), 0, 1e-8);
revisar('jacobiana: max|x1 - predicción|', max(abs(XJ(:,1) - E(:,1) - pi)), 1.4179, 2e-3);
revisar('a_hat = 8 hacia pi/2: equilibrio', fzero(@(x) -2*sin(x) - 4*(x - pi/2), [0 3]), 1.120613, 1e-6);

fprintf('12.4-12.6  Lie, grado relativo, forma normal\n');
mu = 1;  f = @(x) [x(2); -x(1) + mu*(1 - x(1)^2)*x(2)];  g = @(x) [0; 1];  x = [0.7; -0.4];
revisar('van der Pol: L_f lambda = mu (1 - x1^2) x2^2', derivadaLie(f, @(x) (x(1)^2 + x(2)^2)/2, x), mu*(1 - 0.49)*0.16, 1e-8);
revisar('y = x1: L_g L_f h = 1', derivadaLie(g, @(x) derivadaLie(f, @(z) z(1), x), x), 1, 1e-5);
revisar('y = x1^2 + x2: L_g h = 1', derivadaLie(g, @(x) x(1)^2 + x(2), x), 1, 1e-8);
[~, ~, bb] = leyExactaLevitador(xs, [0 0 0 0], [0 0 0], P);
revisar('levitador: b = L_g L_f^2 h en el equilibrio', bb, -125.2837, 1e-4);
gL = @(x) [0; 0; 1/P.L(x(1))];  xi3 = @(x) P.g - P.k/P.m*x(2) - P.L0*P.a*x(3)^2/(2*P.m*(P.a + x(1))^2);
xx = [0.04; 0.1; 5];  [u0, ~, b0] = leyExactaLevitador(xx, [0 0 0 0], [0 0 0], P);
revisar('levitador: L_g L_f^2 h cerrada = numérica', b0 - derivadaLie(gL, xi3, xx), 0, 1e-4);
revisar('levitador: L_f^3 h en (0.04, 0.1, 5)', -u0*b0, 617.2630, 1e-3);
revisar('levitador: L_f^3 h cerrada = numérica', -u0*b0 - derivadaLie(@(x) modeloLevitador(x, 0, P), xi3, xx), 0, 1e-3);
Psi = @(x) exp(x(1))*[cos(x(2)); sin(x(2))];
revisar('Psi(0,0) = Psi(0, 2 pi): no es uno a uno', norm(Psi([0; 0]) - Psi([0; 2*pi])), 0, 1e-12);
A3 = [0 1 0; 0 0 1; -1 -3 -3];  B3 = [0; 0; 1];  C3 = [1 0 0];
revisar('1/(s+1)^3: C B = C A B = 0, C A^2 B = 1 (r = 3)', abs(C3*B3) + abs(C3*A3*B3) + abs(C3*A3^2*B3 - 1), 0, 0);
u = @(t) 0.5*sin(t);  t = linspace(0, 2, 201);
fx  = @(t, x) [-x(1); x(1)*x(2); x(2)] + [exp(x(2)); 1; 0]*u(t);
fz  = @(t, z) [z(2); (-1 + z(3) + exp(z(2)))*z(2) + u(t); -(-1 + z(3) + exp(z(2)))*(1 + z(2)*exp(z(2)))];
Phi = @(x) [x(3); x(2); 1 + x(1) - exp(x(2))];  x0 = [0.3; -0.2; 0.5];
[~, X] = ode45(fx, t, x0, o2);  [~, Z] = ode45(fz, t, Phi(x0), o2);
revisar('forma normal (ejemplo exp) = sistema original', norm(Z(end,:).' - Phi(X(end,:).')), 0, 1e-8);

fprintf('12.7-12.8  Linealización entrada/salida y levitador exacto\n');
revisar('(s+10)(s+20)(s+30)', norm(poly([-10 -20 -30]) - [1 60 1100 6000]), 0, 1e-9);
Am = 0.03;  w = 2*pi;  KFL = [6000 1100 60];  c3 = sqrt(2*P.g*P.m/(P.L0*P.a));
yd = @(t) [0.08 + Am*sin(w*t), Am*w*cos(w*t), -Am*w^2*sin(w*t), -Am*w^3*cos(w*t)];
xsRef = @(t) [0.08 + Am*sin(w*t); 0; c3*(P.a + 0.08 + Am*sin(w*t))];
x0 = equilibrioLevitador(0.08, P);  t = linspace(0, 3, 3001);  k = t > 1;  Yd = 0.08 + Am*sin(w*t(:));
[~, X1] = ode45(@(t, x) modeloLevitador(x, P.R*[0 0 1]*xsRef(t) - K*(x - xsRef(t)), P), t, x0, opc);
[~, X2] = ode45(@(t, x) modeloLevitador(x, leyExactaLevitador(x, yd(t), KFL, P), P), t, x0, opc);
revisar('seguimiento: error jacobiana [cm]', 100*max(abs(X1(k,1) - Yd(k))), 2.3599, 2e-3);
revisar('seguimiento: error exacta [m]', max(abs(X2(k,1) - Yd(k))), 0, 1e-5);
x0 = equilibrioLevitador(0.05, P);
ev = odeset(opc, 'MaxStep', 2e-4, 'Events', @(t, x) deal(x(3) - 0.02, 1, -1));
[ts, ~] = ode45(@(t, x) modeloLevitador(x, leyExactaLevitador(x, [0.2 0 0 0], KFL, P), P), [0 1.2], x0, ev);
revisar('escalón: i = 0.02 A en t [s]', ts(end), 0.02048, 5e-5);
[~, X3] = ode45(@(t, x) modeloLevitador(x, leyExactaLevitador(x, [0.05 0 0 0], KFL, P), P, mR(t)), [0 3], xs, opc);
revisar('masa 0.12: error final exacta sola [cm]', 100*(X3(end,1) - 0.05), 1.9617, 1e-3);

fprintf('12.9-12.10  Dinámica cero\n');
lazo = @(t, x) [x(1) + x(2); 3*x(1)^2*x(2) + x(1) + (-x(1) + 3*x(1)^3 - 2*(-x(1)^3 + x(2)))];
[te, ~] = ode45(lazo, [0 10], [0.05; 0.6], odeset(o2, 'MaxStep', 0.005, 'Events', @(t, x) deal(abs(x(1)) - 2.2, 1, 0)));
revisar('fase no mínima: |eta| = 2.2 en t', te(end), 1.39448, 2e-4);
revisar('dinámica cero: escape desde 0.05', log(1 + 1/0.05^2)/2, 2.99698, 1e-5);
for cs = [1 -2 -0.0095955; 2 -1 179.3018].'
    al = cs(1);  be = cs(2);  uu = @(x) -al*x(3) - 4*x(1) - 4*x(2);
    [~, X] = ode45(@(t, x) [x(2); al*x(3) + uu(x); be*x(3) - uu(x)], [0 6], [1; 0; 0], o2);
    revisar(sprintf('alpha + beta = %+d: x3(6)', al + be), X(end,3), cs(3), 1e-3*max(1, abs(cs(3))));
end
tEsc = @(k, xi0, eta0) log((xi0/(k + 1))/(xi0/(k + 1) - 1/eta0))/(k + 1);
revisar('escape xi0 = eta0 = 2, k = 1', tEsc(1, 2, 2), log(2)/2, 1e-12);
revisar('energía de control al cancelar: 117/2', 3^6/6 - 3^4 + 4*9/2, 58.5, 1e-12);
revisar('energía de control al conservar: 2 ln 10', 2*log(10), 4.60517, 1e-5);
[~, xC] = ode45(@(t, x) -x - x^3, [0 1], 3, o2);
revisar('conservar: x(1)', xC(end), 0.372418, 1e-5);

fprintf('\n%d de %d verificaciones correctas\n', n - fallas, n);
end
