function verificarCap09()
% VERIFICARCAP09  Pruebas automáticas de los números del capítulo 9
% (sistemas variantes en el tiempo).   >> verificarCap09
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap09_numeros.py.)
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
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-13);
escape = @(L) odeset(opc, 'Events', @(t, x) eventoODE(norm(x) - L, 1, 0));
monodromia = @(A, T) [ultimo(A, T, [1; 0]), ultimo(A, T, [0; 1])];

fprintf('9.2  Uniformidad\n');
for t0 = [0 100]
    [t, x] = ode45(@(t, x) -x/(1 + t), linspace(t0, t0 + 12*(1 + t0), 200001), 1, opc);
    revisar(sprintf('x'' = -x/(1+t): T(0.1, t0 = %d) = %d', t0, 9*(1 + t0)), t(find(x < 0.1, 1)) - t0, 9*(1 + t0), 0.01*(1 + t0));
end
L = log(10);
revisar('x'' = -x/sqrt(1+t): T(0.1, 0) = 3.63', L + L^2/4, 3.63, 0.01);
revisar('x'' = -x/sqrt(1+t): T(0.1, 100) = 24.47', L*sqrt(101) + L^2/4, 24.47, 0.01);
[~, x] = ode45(@(t, x) -x/sqrt(1 + t), [100 100 + 24.466], 1, opc);
revisar('   simulado: x(124.47) = 0.1', x(end), 0.1, 1e-4);
for nn = [0 1 2]
    t0 = 2*nn*pi;  [~, x] = ode45(@(t, x) (6*t*sin(t) - 2*t)*x, [t0 t0 + pi], 1, opc);
    revisar(sprintf('6t sin t: ln x(t0 + pi)/x(t0), n = %d', nn), log(x(end)), (4*nn + 1)*(6 - pi)*pi, 1e-6);
end

fprintf('9.3  Funciones de comparación\n');
r = linspace(0, 3, 300001);  [~, i] = max(r.*exp(-2*r));
revisar('r e^{-2r}: máximo en r = 1/2', r(i), 0.5, 1e-4);
revisar('r e^{-sr} <= r/(1 + rs) (s = 2)', max(r.*exp(-2*r) - r./(1 + 2*r)) <= 0, 1, 0);

fprintf('9.4  Lyapunov con V(t,x)\n');
revisar('trampa dV/dt: (cos t - 0.2(2 + sin t)) en t = 0', cos(0) - 0.2*2, 0.6, 1e-12);
for t0 = [0 10]
    [~, x] = ode45(@(t, x) -x/(1 + t)^2, [t0 5000], 1, opc);
    revisar(sprintf('E1: límite con t0 = %d', t0), x(end), exp(1/5001 - 1/(1 + t0)), 1e-7);
end
revisar('E1: e^{-1} = 0.368', exp(-1), 0.368, 5e-4);  revisar('E1: e^{-1/11} = 0.913', exp(-1/11), 0.913, 5e-4);
revisar('V = x1^2 + x1 x2^2 (1 + e^{-t}) en (-eps^2, eps), t = 0, eps = 0.1', ...
    (-0.01)^2 + (-0.01)*0.01*2, -1e-4, 1e-15);

fprintf('9.5  Ejemplos\n');
tt = linspace(0, 2*pi, 400001);
revisar('Mathieu: c = min (4 + 2 sin t + cos t)/(2 + sin t)^2', min((4 + 2*sin(tt) + cos(tt))./(2 + sin(tt)).^2), 0.637, 1e-3);
revisar('Mathieu: cota a mano (4 - sqrt5)/9', (4 - sqrt(5))/9, 0.196, 1e-3);
Am = @(t) [0 1; -(2 + sin(t)) -1];  M = monodromia(Am, 2*pi);  mu = eig(M);
revisar('Mathieu: det M = e^{-2 pi}', det(M), exp(-2*pi), 1e-10);
revisar('Mathieu: |mu| = e^{-pi} = 0.0432', abs(mu(1)), exp(-pi), 1e-8);
revisar('Mathieu: Re mu = -0.0099', real(mu(1)), -0.0099, 1e-4);
revisar('Mathieu: |Im mu| = 0.0421', abs(imag(mu(1))), 0.0421, 1e-4);
[t, X] = ode45(@(t, x) Am(t)*x, linspace(10, 40, 30001), ultimo(Am, 10, [1; 0]), opc);
revisar('Mathieu: max ||x|| e^{t/2} en [10, 40] = 2.05', max(sqrt(sum(X.^2, 2)).*exp(t/2)), 2.05, 0.01);
g = @(t) 1 + 0.5*sin(t);  peor = 0;
for t0 = [0 3 7]
    for th = linspace(0, pi, 7)
        q = linspace(t0, t0 + 20, 2001);
        [~, X] = ode45(@(t, x) [-x(1) - g(t)*x(2); x(1) - x(2)], q, [cos(th); sin(th)], opc);
        peor = max(peor, max(sqrt(sum(X.^2, 2))./(sqrt(2.5)*exp(-(q' - t0)/5))));
    end
end
revisar('ganancia: peor ||x||/cota = 0.632', peor, 0.632, 1e-3);
revisar('ganancia: min(g - g'') = 1 - sqrt2/2', min(g(tt) - 0.5*cos(tt)), 1 - sqrt(2)/2, 1e-8);
revisar('ganancia rápida: 2 + 2g - g'' en t = 0 = -2', 2 + 2*0.5 - 5, -2, 0);
Ag = @(t) [-1 -(1 + sin(10*t))/2; 1 -1];  mu = eig(monodromia(Ag, pi/5));
revisar('ganancia rápida: |mu| = e^{-pi/5} = 0.533', abs(mu(1)), exp(-pi/5), 1e-8);
revisar('ganancia rápida: Re mu = 0.482', real(mu(1)), 0.482, 1e-3);
revisar('ganancia rápida: |Im mu| = 0.230', abs(imag(mu(1))), 0.230, 1e-3);
AMY = @(t) [-1 + 1.5*cos(t)^2, 1 - 1.5*sin(t)*cos(t); -1 - 1.5*sin(t)*cos(t), -1 + 1.5*sin(t)^2];
revisar('Markus--Yamabe: tr A(1.3) = -1/2', trace(AMY(1.3)), -0.5, 1e-12);
revisar('Markus--Yamabe: det A(1.3) = 1/2', det(AMY(1.3)), 0.5, 1e-12);
revisar('Markus--Yamabe: ||x(10)|| desde (1,0) = e^5', norm(ultimo(AMY, 10, [1; 0])), exp(5), 1e-4);
revisar('Markus--Yamabe: ||x(10)|| desde (0,1) = e^{-10}', norm(ultimo(AMY, 10, [0; 1])), exp(-10), 1e-9);
fl = @(t, x) [-x(1) + t*x(2)^2; x(1) - x(2)];
[t, X] = ode45(fl, [0 50], [0.1; 0.1], escape(1e3));
revisar('linealización: t0 = 0 converge', norm(X(end, :)) < 1e-6, 1, 0);
[t, ~] = ode45(fl, [10 60], [0.1; 0.1], escape(1e3));
revisar('linealización: t0 = 10 explota en t = 16.33', t(end), 16.33, 0.01);
[t, ~] = ode45(fl, [100 150], [0.1; 0.1], escape(1e3));
revisar('linealización: t0 = 100 explota', t(end) < 150, 1, 0);

fprintf('9.6  Vdot semidefinida\n');
t = linspace(0, 30, 30001)';  [t, X] = ode45(@(t, x) Am(t)*x, t, [1; 0], opc);
x2d = -X(:, 2) - (2 + sin(t)).*X(:, 1);  x2dd = -x2d - cos(t).*X(:, 1) - (2 + sin(t)).*X(:, 2);
revisar('Mathieu: max |x2''''| desde (1, 0) = 2.77', max(abs(x2dd)), 2.77, 0.01);
revisar('Mathieu: ||x(30)|| < 1e-5', norm(X(end, :)) < 1e-5, 1, 0);
x = [0.3; -0.7];  tm = 0.9;  F = Am(tm)*x;
revisar('Matrosov: U = x1 x2, Udot = x2^2 - x1x2 - (2 + sin t)x1^2', F(1)*x(2) + x(1)*F(2), ...
    x(2)^2 - x(1)*x(2) - (2 + sin(tm))*x(1)^2, 1e-14);

fprintf('9.7  Inestabilidad\n');
[TH, RR] = meshgrid(linspace(0, 2*pi, 721), linspace(1e-3, 0.5, 400));
X1 = RR.*cos(TH);  X2 = RR.*sin(TH);
q = (X1.^2 + X2.^2 + X2.^3 - X1.^3.*X2)./RR.^2;
revisar('Cetaev: min Vdot/||x||^2 en B_{1/2} = 0.50', min(q(:)), 0.50, 0.01);
revisar('Cetaev: cota min(1 - r^2/2, 1 - r) con r = 1/2', min(1 - 0.125, 0.5), 0.5, 0);
revisar('E8: V = x1 en (0.01, -0.1): Vdot = -9e-4', 0.01^2 + (-0.1)^3, -9e-4, 1e-15);
f2 = @(x) [x(1) + 3*x(2)*sin(x(2))^2 + 5*x(1)*x(2)^2*sin(x(1))^2; 3*x(1)*sin(x(2))^2 + x(2) - 5*x(1)^2*x(2)*cos(x(1))^2];
F = f2([0; 0.5]);
revisar('2o teorema: Vdot(0, 0.5) = -0.25', 0*F(1) - 0.5*F(2), -0.25, 1e-12);
F = f2([0.3; -0.2]);  V = (0.09 - 0.04)/2;
revisar('2o teorema: Vdot - 2V = 5 x1^2 x2^2 en (0.3, -0.2)', 0.3*F(1) + 0.2*F(2) - 2*V, 5*0.09*0.04, 1e-12);
fv = @(t, x) [x(2); -x(1) + (1 - x(1)^2)*x(2)];
[t, X] = ode45(fv, linspace(0, 100, 100001), [2; 0], opc);  nx = sqrt(sum(X(t > 60, :).^2, 2));
revisar('van der Pol: min ||x|| en el ciclo = 1.532', min(nx), 1.532, 1e-3);
revisar('van der Pol: max ||x|| en el ciclo = 2.830', max(nx), 2.830, 1e-3);
sal = odeset(opc, 'AbsTol', 1e-14, 'Events', @(t, x) eventoODE(norm(x) - 1, 1, 1));
for par = [1e-2 8.90; 1e-4 18.97; 1e-6 27.23]'
    [te, ~] = ode45(fv, [0 100], [par(1); 0], sal);
    revisar(sprintf('van der Pol: desde (%g, 0) sale de B_1', par(1)), te(end), par(2), 0.01);
end

fprintf('Problemas\n');
pfun = @(t) integral(@(tau) exp(-2*(2*(tau - t) - cos(tau) + cos(t))), t, t + 60);
ps = arrayfun(pfun, linspace(0, 2*pi, 200));
revisar('Lyapunov diferencial: min p = 0.167', min(ps), 0.167, 1e-3);
revisar('Lyapunov diferencial: max p = 0.467', max(ps), 0.467, 1e-3);

fprintf('\n%d/%d pruebas correctas\n', n - fallas, n);
end

function x = ultimo(A, T, x0)
[~, X] = ode45(@(t, x) A(t)*x, [0 T], x0, odeset('RelTol', 1e-12, 'AbsTol', 1e-14));
x = X(end, :)';
end
