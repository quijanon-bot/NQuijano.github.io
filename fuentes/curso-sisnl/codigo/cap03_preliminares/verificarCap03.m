function verificarCap03()
% VERIFICARCAP03  Pruebas automáticas de los números del capítulo 3
% (fundamentos matemáticos).   >> verificarCap03
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap03_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-48s %12.5f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-47s %12.5f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

fprintf('3.2  Métricas\n');
x = [1; 1];  y = [4; 3];
revisar('d1(x,y)', sum(abs(x - y)), 5, 0);
revisar('d2(x,y) = sqrt(13)', norm(x - y), sqrt(13), 1e-12);
revisar('dinf(x,y)', max(abs(x - y)), 3, 0);
revisar('Hamming(cama, masa)', sum('cama' ~= 'masa'), 2, 0);
t = linspace(0, 1, 200001);  d = abs(sin(2*pi*t) - t);
revisar('d1(sin 2 pi t, t)', trapz(t, d), 0.9214, 1e-4);
revisar('dinf(sin 2 pi t, t)', max(d), 1.7627, 1e-4);

fprintf('3.3  Normas\n');
v = [3; 4];
revisar('||(3,4)||_1', norm(v, 1), 7, 0);  revisar('||(3,4)||_2', norm(v), 5, 1e-12);
revisar('||(3,4)||_inf', norm(v, inf), 4, 0);
revisar('p = 1/2 viola la desigualdad: 4 - 2', (1 + 1)^2 - 2, 2, 0);
revisar('||t^20||_L1 = 1/21', 1/21, 0.047619, 1e-6);
A = [1 2; -3 4];
revisar('||A||_1', norm(A, 1), 6, 1e-12);  revisar('||A||_inf', norm(A, inf), 7, 1e-12);
revisar('||A||_2', norm(A), 5.1167, 1e-4);
revisar('||A||_2^2 = 15 + 5 sqrt(5)', norm(A)^2, 15 + 5*sqrt(5), 1e-10);
revisar('rho(A) = sqrt(10)', max(abs(eig(A))), sqrt(10), 1e-12);
revisar('||[0 1; 0 0]||_2', norm([0 1; 0 0]), 1, 1e-12);

fprintf('3.4  Producto interno\n');
revisar('ley del paralelogramo con ||.||_1: 8 vs 4', norm([1;1],1)^2 + norm([1;-1],1)^2, 8, 0);

fprintf('3.5  Completitud\n');
t = linspace(0, 1, 400001);  rampa = @(k) min(1, max(0, k*(t - 0.5)));
revisar('||f_10 - escalón||_L2 = 1/sqrt(30)', sqrt(trapz(t, (rampa(10) - (t > 0.5)).^2)), 1/sqrt(30), 2e-4);
revisar('||f_10 - f_20||_L2 = 1/sqrt(120)', sqrt(trapz(t, (rampa(10) - rampa(20)).^2)), 1/sqrt(120), 2e-4);
revisar('||f_10 - f_20||_inf', max(abs(rampa(10) - rampa(20))), 0.5, 1e-4);

fprintf('3.8  Lipschitz\n');
revisar('caja a1 = 1, a2 = 2: L = 1 + a1 + a2', 1 + 1 + 2, 4, 0);
revisar('pendiente x^(1/3) entre 0 y 1e-3', (1e-3)^(1/3)/1e-3, 100, 1e-9);

fprintf('3.9  Existencia y unicidad\n');
revisar('x_0(3) de x'' = x^(1/3)', (2/3*3)^(3/2), 2*sqrt(2), 1e-12);
r = 1/sqrt(2);
revisar('delta* de x'' = x^2 (r = 1/sqrt 2)', r/(2*(1 + r)*r + 1), (sqrt(2) - 1)/2, 1e-12);
revisar('error de Picard, iteración 5', exp(1) - sum(1./factorial(0:5)), 1.6152e-3, 1e-7);
[~, X] = ode45(@(t, x) -x^3, [0 10], 2, opc);
revisar('x'' = -x^3: x(10) = 2/9', X(end), 2/9, 1e-7);
tt = linspace(0, 5, 501);
[~, Y] = ode45(@(t, y) -y + 0.5*sin(y), tt, 1, opc);
[~, Z] = ode45(@(t, z) -z + 0.5*sin(z) + 0.1*cos(t), tt, 1.05, opc);
revisar('dependencia continua: max |y - z|', max(abs(Y - Z)), 0.0910, 2e-4);
revisar('cota de Gronwall en t = 5', 0.05*exp(7.5) + 0.1/1.5*(exp(7.5) - 1), 210.9, 0.05);

fprintf('3.10 Comparación\n');
[~, X] = ode45(@(t, x) -(1 + x^2)*x, [0 1], 2, opc);
revisar('x(1) desde a = 2', X(end), 0.3484, 1e-4);
revisar('cota 2 e^{-1}', 2*exp(-1), 0.7358, 1e-4);
g = @(t, x) [-x(1) + 2*x(2)/(1 + x(2)^2); -x(2) + 2*x(1)/(1 + x(1)^2)];
[t2, X2] = ode45(g, linspace(0, 20, 2001), [3; -2], opc);
nx = vecnorm(X2.');  cota = exp(-t2.')*sqrt(13) + sqrt(2)*(1 - exp(-t2.'));
revisar('sistema 2D: max(||x|| - cota) <= 0', double(max(nx - cota) <= 1e-9), 1, 0);
revisar('||x(20)|| -> sqrt(2) (equilibrio (1,1))', nx(end), sqrt(2), 1e-6);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
end
