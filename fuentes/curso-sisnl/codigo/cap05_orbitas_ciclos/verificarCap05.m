function verificarCap05()
% VERIFICARCAP05  Pruebas automáticas de los números del capítulo 5
% (órbitas, osciladores y ciclos límite).   >> verificarCap05
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap05_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));  addpath(raiz);
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

fprintf('5.1  Duffing\n');
revisar('Im lambda en (1,0) = sqrt(2)', max(imag(eig([0 1; -2 0]))), sqrt(2), 1e-12);
revisar('H(1,0) = -1/4', -1/2 + 1/4, -0.25, 0);
f = @(t, x) [x(2); x(1) - x(1)^3];
for h = [-0.2 -0.01]
    ev = odeset(opc, 'Events', @(t, x) deal(x(2), 0, 0));
    [~, ~, te] = ode45(f, [0 100], [sqrt(1 + sqrt(1 + 4*h)); 0], ev);  te = te(te > 1e-6);
    revisar(sprintf('período de la órbita H = %.2f', h), te(2), 4.6307*(h < -0.1) + 7.4087*(h > -0.1), 2e-4);
end
revisar('período límite 2 pi/sqrt 2', 2*pi/sqrt(2), 4.4429, 1e-4);

fprintf('5.3  Ciclos límite\n');
rex = @(t, r0) (1 + (1/r0^2 - 1)*exp(-2*t)).^(-1/2);
revisar('r(5) desde 0.1 (exacto)', rex(5, 0.1), 0.997760, 1e-6);
vdp = @(mu) @(t, x) [x(2); -x(1) - mu*(x(1)^2 - 1)*x(2)];
[t, X] = ode45(vdp(1), [0 200], [0.5; 0], opc);  k = find(t > 100);
s = k(X(k(1:end-1),2) < 0 & X(k(2:end),2) >= 0 & X(k(1:end-1),1) < 0);
revisar('van der Pol mu = 1: período', mean(diff(t(s))), 6.6633, 1e-3);
revisar('van der Pol mu = 1: amplitud', max(X(k,1)), 2.0086, 1e-3);
revisar('Liénard: cero de F = sqrt(3)', fzero(@(x) x^3/3 - x, [1 2]), sqrt(3), 1e-10);

fprintf('5.4  Flujos en el círculo\n');
revisar('T_lap con T1 = 4, T2 = 5', 1/(1/4 - 1/5), 20, 1e-12);
revisar('T no uniforme w = 2, a = 1', 2*pi/sqrt(3), 3.6276, 1e-4);
revisar('T no uniforme w = 2, a = 1.99', 2*pi/sqrt(4 - 1.99^2), 31.4553, 1e-4);

fprintf('5.5  Luciérnagas\n');
revisar('phi* con Omega = 1.3 (w = 1, A = 0.5)', asin(0.6), 0.6435, 1e-4);
revisar('T deriva Omega = 1.6', 2*pi/sqrt(0.36 - 0.25), 18.9445, 1e-4);
revisar('T deriva Omega = 2', 2*pi/sqrt(1 - 0.25), 7.2552, 1e-4);

fprintf('5.6  Kuramoto\n');
revisar('r teórico K = 2, gamma = 0.5', sqrt(1 - 1/2), 0.7071, 1e-4);
N = 400;  i = (1:N).';  w = 0.5*tan(pi*(i - 0.5)/N - pi/2);
th0 = 2*pi*mod(i*0.6180339887, 1);  o2 = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
[~, TH] = ode45(@(t, th) modeloKuramoto(t, th, w, 2), [0 100], th0, o2);
[~, TH] = ode45(@(t, th) modeloKuramoto(t, th, w, 2), linspace(100, 200, 201), TH(end,:).', o2);
revisar('r simulado K = 2 (N = 400)', mean(abs(mean(exp(1j*TH), 2))), 0.7071, 0.01);

fprintf('5.7  Índice\n');
revisar('índice silla', indiceCurva(@(x) [x(1); -x(2)], [0 0], 1), -1, 1e-9);
revisar('índice z^2', indiceCurva(@(x) [x(1)^2 - x(2)^2; 2*x(1)*x(2)], [0 0], 1), 2, 1e-9);
revisar('índice (x1^2 x2, x1^2 - x2^2)', indiceCurva(@(x) [x(1)^2*x(2); x(1)^2 - x(2)^2], [0 0], 1), 0, 1e-9);
fk = @(x) [-x(1) + x(1)*x(2); x(1) + x(2) - 2*x(1)*x(2)];
revisar('ejemplo: círculo alrededor de silla y foco', indiceCurva(fk, [0.5 0.5], 2), 0, 1e-9);
revisar('ejemplo: det J(1,1) = 1', det([0 1; -1 -1]), 1, 1e-12);

fprintf('5.9  Poincaré-Bendixson\n');
revisar('max V'' en V = 3/2: 3c - 2c^2', 3*1.5 - 2*1.5^2, 0, 1e-12);
fpb = @(t, x) [x(1) + x(2) - x(1)*(x(1)^2 + x(2)^2); -2*x(1) + x(2) - x(2)*(x(1)^2 + x(2)^2)];
[t, X] = ode45(fpb, [0 60], [0.01; 0], opc);  r = vecnorm(X(t > 40,:).');
revisar('ciclo: r mínimo', min(r), 0.8501, 2e-4);  revisar('ciclo: r máximo', max(r), 1.1302, 2e-4);

fprintf('5.10 Presa-depredador\n');
revisar('competencia: v3', (1*0.2 + 1*0.5)/(1*1 + 0.5*0.2), 0.6364, 1e-4);
revisar('competencia: p3', (1*1 - 0.5*0.5)/(1*1 + 0.5*0.2), 0.6818, 1e-4);
revisar('Rosenzweig-MacArthur: K_H', (2 + 1)/(2 - 1), 3, 0);
K = 5;  rm = @(t, x) [x(1)*(1 - x(1)/K) - x(1)*x(2)/(1 + x(1)); x(2)*(2*x(1)/(1 + x(1)) - 1)];
[t, X] = ode45(rm, [0 800], [1.1; 1.6], odeset(opc, 'MaxStep', 0.5));
revisar('R-M K = 5: v máximo en el ciclo', max(X(t > 600, 1)), 4.4666, 2e-3);

fprintf('5.11 Nowak\n');
B = 0.2*ones(3) + 0.68*eye(3);  Qc = @(c) [0.8 - c, 0.2, c; c, 0.8 - c, 0.2; 0.2, c, 0.8 - c];
P = [1 0; 0 1; -1 -1];  xs = ones(3,1)/3;
Js = @(c) jacobianoNumerico(@(y) [1 0 0; 0 1 0]*modeloNowak(0, xs + P*y, B, Qc(c)), [0; 0]);
revisar('Re lambda con c = 0.01', max(real(eig(Js(0.01)))), 0.020867, 1e-5);
revisar('Im lambda con c = 0.01', max(imag(eig(Js(0.01)))), 0.107503, 1e-5);
revisar('c* de Hopf', fzero(@(c) max(real(eig(Js(c)))), [0.01 0.04]), 0.031293, 1e-5);
revisar('Fbar* = 0.4267 (tasa de atracción al símplex)', xs.'*B*xs, 0.426667, 1e-6);
dx = modeloNowak(0, [1e-6; 0.5; 0.5 - 1e-6], B, Qc(0.01));
revisar('frontera repelente: x1'' en (1e-6, .5, .5)', dx(1), 0.0567, 1e-4);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
end
