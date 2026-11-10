function verificarCap02()
% VERIFICARCAP02  Pruebas automáticas de los números del capítulo 2
% (sistemas unidimensionales).   >> verificarCap02
% (Los mismos números se verificaron de forma independiente en Python con
%  herramientas/cap02_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(raiz); addpath(fullfile(raiz, '..', 'comun'));
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
opc = odeset('RelTol', 1e-11, 'AbsTol', 1e-13);

fprintf('2.2  El flujo de sin x\n');
xex = @(t) 2*atan(tan(pi/8)*exp(t));
[t, x] = ode45(@(t, x) sin(x), linspace(0, 6, 61), pi/4, opc);
revisar('x(1) desde pi/4', xex(1), 1.68915, 1e-5);
revisar('error de ode45 frente a la exacta', max(abs(x - xex(t))), 0, 1e-8);
revisar('tan(pi/8) = sqrt(2) - 1', tan(pi/8), sqrt(2) - 1, 1e-14);
revisar('x(30) -> pi', xex(30), pi, 1e-10);

fprintf('2.3  Equilibrios no hiperbólicos\n');
[~, x] = ode45(@(t, x) -x^3, [0 10], 1, opc);
revisar('x'' = -x^3: x(10) = 1/sqrt(21)', x(end), 1/sqrt(21), 1e-8);
[~, x] = ode45(@(t, x) x^2, [0 10], -1, opc);
revisar('x'' = x^2, x0 = -1: x(10) = -1/11', x(end), -1/11, 1e-8);
revisar('x'' = x^3: escape en 1/(2 x0^2), x0 = 1', 1/2, 0.5, 0);

fprintf('2.4  Potencial\n');
revisar('V(pi) = cos(pi) - 1', cos(pi) - 1, -2, 1e-15);

fprintf('2.5  Logística con cosecha\n');
revisar('h = 0.2: equilibrio inestable', (1 - sqrt(0.2))/2, 0.27639, 1e-5);
revisar('h = 0.2: equilibrio estable', (1 + sqrt(0.2))/2, 0.72361, 1e-5);
revisar('cosecha crítica h_c = r K/4', 1/4, 0.25, 0);
ev = @(t, x) deal(x, 1, -1);
[~, ~, te] = ode45(@(t, x) x*(1 - x) - 0.3, [0 20], 0.5, odeset(opc, 'Events', ev));
a = sqrt(0.05);
revisar('h = 0.3: tiempo de extinción', te, atan(0.5/a)/a, 1e-6);
revisar('fórmula del tiempo de extinción', atan(0.5/a)/a, 5.14413, 1e-5);

fprintf('2.6  Diodo túnel\n');
[h, dh] = diodoTunel();  E = 1.2;  R = 1.5;  C = 2;
f = @(v) ((E - v)/R - h(v))/C;
vs = [fzero(f, [0 0.15]), fzero(f, [0.15 0.5]), fzero(f, [0.5 1.2])];
esp = [0.0626 -3.956; 0.2854 1.487; 0.8844 -1.770];
for k = 1:3
    revisar(sprintf('v*_%d', k), vs(k), esp(k,1), 1e-4);
    revisar(sprintf('f''(v*_%d) = -(1/R + h''(v*))/C', k), -(1/R + dh(vs(k)))/C, esp(k,2), 1e-3);
end
revisar('i*_1 = h(v*_1) [mA]', h(vs(1)), 0.7582, 1e-4);
g = @(v) v + R*h(v);  dg = @(v) 1 + R*dh(v);
revisar('E máximo con tres equilibrios', g(fzero(dg, [0.05 0.3])), 1.64326, 1e-4);
revisar('E mínimo con tres equilibrios', g(fzero(dg, [0.3 0.7])), 0.65900, 1e-4);
Tm = 4000;  Ef = @(t) 1.8*min(t, 2*Tm - t)/Tm;  tt = linspace(0, 2*Tm, 80001)';
[~, v] = ode45(@(t, v) ((Ef(t) - v)/R - h(v))/C, tt, 0, odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'MaxStep', 0.5));
Et = Ef(tt);
revisar('histéresis: salto hacia arriba en E', Et(find(v(1:end-1) < 0.5 & v(2:end) >= 0.5, 1)), 1.652, 0.01);
revisar('histéresis: salto hacia abajo en E', Et(find(v(1:end-1) > 0.5 & v(2:end) <= 0.5, 1)), 0.650, 0.01);

fprintf('2.7  Halcón y paloma\n');
fh = @(p) 0.5*p.*(1 - p).*(1 - 3*p);
[~, p] = ode45(@(t, p) fh(p), [0 40], 0.01, opc);
revisar('v = 1, c = 3: p1(40) desde 0.01', p(end), 1/3, 1e-4);
[~, p] = ode45(@(t, p) fh(p), [0 40], 0.99, opc);
revisar('v = 1, c = 3: p1(40) desde 0.99', p(end), 1/3, 1e-4);
revisar('f''(v/c) = -(v/2)(1 - v/c)', -0.5*(1 - 1/3), -1/3, 1e-15);
Pio = [-1 1; 0 0.5];  Pim = [-1 0; 0 -0.5];  q = [0.3; 0.7];
d = q.*(Pio*q - q.'*Pio*q) - q.*(Pim*q - q.'*Pim*q);
revisar('invarianza por columnas', norm(d), 0, 1e-15);

fprintf('2.8  Unicidad\n');
revisar('nthroot(-8, 3)', nthroot(-8, 3), -2, 0);
revisar('|(-8)^(1/3)| = 2, pero no es real', double(abs(imag((-8)^(1/3))) > 1), 1, 0);
[~, x] = ode45(@(t, x) nthroot(x, 3), [0 3], 1e-12, odeset('RelTol', 1e-10, 'AbsTol', 1e-14));
revisar('x'' = x^(1/3) desde 1e-12: x(3)', x(end), 2*sqrt(2), 1e-3);
ev = @(t, x) deal(x - 1e-9, 1, -1);
[~, ~, te] = ode45(@(t, x) -nthroot(x, 3), [0 3], 1, odeset('RelTol', 1e-10, 'AbsTol', 1e-14, 'Events', ev));
revisar('x'' = -x^(1/3): llega a 0 en 3/2', te, 1.5, 1e-4);

fprintf('2.9  Escape\n');
ev = @(t, x) deal(abs(x) - 1e3, 1, 0);
for x0 = [0.5 2]
    [~, ~, te] = ode45(@(t, x) x^2, [0 6], x0, odeset(opc, 'Events', ev));
    revisar(sprintf('x'' = x^2, x0 = %g: evento en 1/x0 - 1/1000', x0), te, 1/x0 - 1e-3, 1e-6);
end
[~, ~, te] = ode45(@(t, x) x^2 - 1, [0 4], 1.5, odeset(opc, 'Events', ev));
revisar('x'' = x^2 - 1, x0 = 1.5: escape (1/2) ln 5', te, 0.5*log(5), 2e-3);
revisar('(1/2) ln 5', 0.5*log(5), 0.80472, 1e-5);
[~, x] = ode45(@(t, x) x^2 - 1, [0 20], 0.95, opc);
revisar('x'' = x^2 - 1, x0 = 0.95: converge a -1', x(end), -1, 1e-8);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
end
