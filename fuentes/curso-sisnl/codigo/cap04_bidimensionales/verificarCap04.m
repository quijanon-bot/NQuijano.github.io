function verificarCap04()
% VERIFICARCAP04  Pruebas automáticas de los números del capítulo 4
% (sistemas bidimensionales).   >> verificarCap04
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap04_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));  addpath(raiz);  addpath(fullfile(raiz, '..', 'cap02_unidimensionales'));
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
es = @(a, b) double(strcmp(a, b));

fprintf('4.2  Plano de fase\n');
[~, X] = ode45(@(t, x) [2*x(1)*x(2); x(1)*x(2)], [0 0.3], [1; 2], opc);
revisar('x1 - 2 x2 se conserva desde (1,2)', X(end, 1) - 2*X(end, 2), -3, 1e-7);
[~, X] = ode45(@(t, x) [x(2); -4*x(1)], [0 10], [1; 0], opc);
E = 4*X(:, 1).^2 + X(:, 2).^2;
revisar('masa-resorte: w^2 x1^2 + x2^2 constante', max(E) - min(E), 0, 1e-7);
f = @(x) [-x(1) + x(1)*x(2); x(1) + x(2) - 2*x(1)*x(2)];
revisar('(0,1) no es equilibrio: f2(0,1)', [0 1]*f([0; 1]), 1, 0);

fprintf('4.3  Sistemas lineales\n');
A = [-1 -3; 0 2];  t = 0.7;
revisar('expm(At) contra la fórmula', norm(expm(A*t) - [exp(-t), exp(-t) - exp(2*t); 0, exp(2*t)]), 0, 1e-12);
P = [1 -1; 0 1];
revisar('P^{-1} A P = diag(-1,2)', norm(P\A*P - diag([-1 2])), 0, 1e-14);
revisar('desde (1,1): x1 = 0 en ln(2)/3', fzero(@(s) [1 0]*expm(A*s)*[1; 1], [0.01 1]), log(2)/3, 1e-9);

fprintf('4.4  Clasificación\n');
revisar('diag(-6,-2): nodo estable', es(clasificarEquilibrio([-6 0; 0 -2]), 'nodo estable'), 1, 0);
revisar('[1 2; 3 4]: silla', es(clasificarEquilibrio([1 2; 3 4]), 'silla'), 1, 0);
[tipo, info] = clasificarEquilibrio([-2 1; -1 -2]);
revisar('[-2 1; -1 -2]: foco estable', es(tipo, 'foco estable'), 1, 0);
revisar('... horario', es(info.giro, 'horario'), 1, 0);
revisar('[2 1; -1 0]: nodo impropio inestable', es(clasificarEquilibrio([2 1; -1 0]), 'nodo impropio inestable'), 1, 0);
[tipo, info] = clasificarEquilibrio([1 -2; 1 -1]);
revisar('[1 -2; 1 -1]: centro antihorario', es(tipo, 'centro')*es(info.giro, 'antihorario'), 1, 0);
[~, info] = clasificarEquilibrio([0 1; -4 0]);
revisar('[0 1; -4 0] (masa-resorte): giro horario', es(info.giro, 'horario'), 1, 0);
revisar('a = 0: recta de equilibrios', es(clasificarEquilibrio([0 0; 0 -1]), 'no aislado (det A = 0)'), 1, 0);
revisar('nodo impropio + 0.01: Im lambda = 0.1', max(imag(eig([-1 1; -0.01 -1]))), 0.1, 1e-12);
revisar('centro + 0.05 I: Re lambda', max(real(eig([0.05 -1; 1 0.05]))), 0.05, 1e-14);

fprintf('4.5  Linealización\n');
J = @(x) [1 + x(2), x(1); x(2) - 3*x(1)^2, -1 + 2*x(2) + x(1)];
revisar('(0,0): silla', es(clasificarEquilibrio(J([0; 0])), 'silla'), 1, 0);
revisar('(0,1): nodo inestable', es(clasificarEquilibrio(J([0; 1])), 'nodo inestable'), 1, 0);
revisar('(1,-1): det = 4', det(J([1; -1])), 4, 1e-12);
revisar('(1,-1): Im lambda = sqrt3', max(imag(eig(J([1; -1])))), sqrt(3), 1e-12);
revisar('cuaderno (1,1): traza -1, foco', es(clasificarEquilibrio(jacobianoNumerico(f, [1; 1]), 1e-6), 'foco estable'), 1, 0);
[~, X] = ode45(@(t, x) [x(2); -x(1) - x(1)^2*x(2)], [0 60], [0.5; 0], opc);
revisar('eps = 1: r(60) desde 0.5', norm(X(end, :)), 0.2297, 1e-3);

fprintf('4.6  Duffing y diodo túnel\n');
revisar('Duffing delta=0.5: lambda silla', max(eig([0 1; 1 -0.5])), (-0.5 + sqrt(4.25))/2, 1e-12);
revisar('Duffing delta=0.5: Im lambda foco', max(imag(eig([0 1; -2 -0.5]))), sqrt(7.75)/2, 1e-12);
revisar('Duffing delta=3: (1,0) nodo estable', es(clasificarEquilibrio([0 1; -2 -3]), 'nodo estable'), 1, 0);
g = @(t, x) [x(2); x(1) - x(1)^3 - 0.5*x(2)];
[~, X] = ode45(g, [0 80], [1.5; 0], opc);  revisar('desde (1.5,0) -> (1,0)', X(end, 1), 1, 1e-5);
[~, X] = ode45(g, [0 80], [2; 0], opc);    revisar('desde (2,0) -> (-1,0)', X(end, 1), -1, 1e-5);
[h, dh] = diodoTunel();  Ed = 1.2;  Rd = 1.5;  Cd = 2;  Ld = 5;
vq = [fzero(@(v) h(v) - (Ed - v)/Rd, 0.06), fzero(@(v) h(v) - (Ed - v)/Rd, 0.28), fzero(@(v) h(v) - (Ed - v)/Rd, 0.88)];
revisar('diodo Q1: v', vq(1), 0.06264, 1e-4);
revisar('diodo Q2: v', vq(2), 0.28537, 1e-4);
revisar('diodo Q3: v', vq(3), 0.88443, 1e-4);
Jd = @(v) [-dh(v)/Cd, 1/Cd; -1/Ld, -Rd/Ld];
revisar('diodo Q2: lambda+ = 1.772', max(eig(Jd(vq(2)))), 1.7719, 1e-3);
revisar('diodo Q1: lambda rápido = -3.592', min(eig(Jd(vq(1)))), -3.5919, 1e-3);
fd = @(t, x) [(-h(x(1)) + x(2))/Cd; (-x(1) - Rd*x(2) + Ed)/Ld];
[~, X] = ode45(fd, [0 300], [0.4; 0], opc);    revisar('desde (0.4, 0) -> Q1', X(end, 1), vq(1), 1e-4);
[~, X] = ode45(fd, [0 300], [0.4; 0.3], opc);  revisar('desde (0.4, 0.3) -> Q3', X(end, 1), vq(3), 1e-4);

fprintf('4.7  Variedades\n');
ramas = variedadSilla(@(x) [-x(1); x(2) + x(1)^2], [0; 0], 'estable', 8, 1e-6, [-2 2 -2.5 2]);
revisar('W^s numérica = -x1^2/3', max(abs(ramas{1}(:, 2) + ramas{1}(:, 1).^2/3)), 0, 1e-5);
[~, X] = ode45(@(t, x) [-x(1); x(2) + x(1)^2], [0 1], [1; 0], opc);
revisar('desde (1,0): x2(1) = (e - e^{-2})/3', X(end, 2), (exp(1) - exp(-2))/3, 1e-8);

fprintf('4.8  Variedad central\n');
[~, X] = ode45(@(t, x) [x(1)*x(2); -x(2) - x(1)^2], [0 40], [0.3; 0.2], opc);
revisar('a = -1: y(40)', X(end, 1), 0.1055, 2e-3);
[~, X] = ode45(@(t, x) [x(1)*x(2); -x(2)], [0 30], [0.3; 0.2], opc);
revisar('a = 0: y(inf) = y0 e^{z0}', X(end, 1), 0.3*exp(0.2), 1e-6);

fprintf('\n%d/%d verificaciones correctas\n', n - fallas, n);
if fallas > 0, error('verificarCap04: %d fallas', fallas); end
end
