function verificarCap11()
% VERIFICARCAP11  Pruebas automáticas de los números del capítulo 11 (pasividad).
%   >> verificarCap11
% (Los mismos números se verificaron de forma independiente con sympy y
%  scipy en herramientas/cap11_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-46s %12.5f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-45s %12.5f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

fprintf('11.2  Balance de energía\n');
u = @(t) 0.8*sin(1.2*t).*(t < 12);
f = @(t, x) [x(2); -(x(1) + x(1)^3) - 0.3*x(2) + u(t)];
o2 = odeset(opc, 'MaxStep', 0.01);
[t1, X1] = ode45(f, [0 12], [0; 0], o2);  [t2, X2] = ode45(f, [12 30], X1(end,:).', o2);
t = [t1; t2(2:end)];  X = [X1; X2(2:end,:)];
V = X(:,1).^2/2 + X(:,1).^4/4 + X(:,2).^2/2;
[S, ~, res] = balanceEnergia(t, V, [u(t1); zeros(numel(t2) - 1, 1)].*X(:,2), 0.3*X(:,2).^2);
revisar('residuo del balance', max(abs(res)), 0, 1e-5);
revisar('V(12)', V(numel(t1)), 1.3743, 2e-4);
revisar('V(30)', V(end), 0.0058, 2e-4);
revisar('suministrada hasta 12 s', S(numel(t1)), 4.9766, 5e-4);
revisar('energía total de los pulsos pi^2/18', pi^2/18, 0.548311, 1e-6);

fprintf('11.4  Sin memoria\n');
h  = @(v) 17.76*v - 103.79*v.^2 + 229.62*v.^3 - 226.31*v.^4 + 83.72*v.^5;
dh = @(v) 17.76 - 207.58*v + 688.86*v.^2 - 905.24*v.^3 + 418.6*v.^4;
v = linspace(-1.5, 1.5, 300001);
revisar('min u h(u) del diodo >= 0', double(min(v.*h(v)) >= 0), 1, 0);
v1 = fzero(dh, [0.1 0.4]);  v2 = fzero(dh, [0.4 0.9]);
revisar('v1 (máximo local)', v1, 0.1381, 5e-4);
revisar('v2 (mínimo local)', v2, 0.6601, 5e-4);
revisar('h(v2) > 0', h(v2), 0.0683, 5e-4);

fprintf('11.5  Pasividad local\n');
revisar('potencia con x = 1.5, k = 1', -1.5^2*(1.5^2 - 1), -2.8125, 1e-12);

fprintf('11.6  LaSalle\n');
[~, X] = ode45(@(t, x) [x(2); -x(1) - x(2)], [0 20], [1.5; 0], opc);
revisar('RLC: V(20)', (X(end,1)^2 + X(end,2)^2)/2, 0, 1e-7);
revisar('cota eps < 4/5', 4/5, 0.8, 0);

fprintf('11.7  PR, SPR y KYP\n');
revisar('z = 1.5 es SPR', double(strcmp(esPR([1 1.5], [1 3 2]), 'SPR')), 1, 0);
revisar('z = 3 es PR', double(strcmp(esPR([1 3], [1 3 2]), 'PR')), 1, 0);
revisar('z = 5 no es PR', double(strcmp(esPR([1 5], [1 3 2]), 'no PR')), 1, 0);
revisar('s/(s^2+s+1) es PR', double(strcmp(esPR([1 0], [1 1 1]), 'PR')), 1, 0);
revisar('1/s es PR', double(strcmp(esPR(1, [1 0]), 'PR')), 1, 0);
revisar('1/(s^2+3s+2) no es PR (grado relativo 2)', double(strcmp(esPR(1, [1 3 2]), 'no PR')), 1, 0);
revisar('Re G(j1) de (s+3)/((s+1)(s+2))', real(respFrec([1 3], [1 3 2], 1)), 0.6, 1e-12);
A = [0 1; -1 -1];  M = A + A.';
revisar('RLC: PA + A''P + L''L = 0 (P = I)', norm(M + [0 0; 0 2]), 0, 1e-12);
A = [0 1; -2 -3];  P = [11 3; 3 1];  M = P*A + A.'*P;
revisar('(s+3)/..: (PA + A''P)(1,1)', M(1,1), -12, 1e-12);
revisar('(s+3)/..: (PA + A''P)(2,2)', M(2,2), 0, 1e-12);
revisar('(s+3)/..: PB = C''', norm(P*[0; 1] - [3; 1]), 0, 1e-12);
P = [6.5 1.5; 1.5 1];  M0 = P*A + A.'*P;
revisar('SPR: PA + A''P = diag(-6, -3)', norm(M0 - diag([-6 -3])), 0, 1e-12);
revisar('SPR: eps máximo', fzero(@(e) max(eig(M0 + e*P)), [0.01 3]), 0.8172, 1e-4);

fprintf('11.8  Interconexión\n');
[t, X] = ode45(@(t, x) modeloOsciladores(t, x, 1, 0.5, 2), linspace(0, 40, 8001), [1.5; 0; 0; 0], opc);
V1 = X(:,1).^4/4 + X(:,2).^2/2;  V2 = X(:,3).^2 + X(:,4).^2/2;
revisar('V(0)', V1(1) + V2(1), 1.265625, 1e-12);
revisar('V no creciente', double(all(diff(V1 + V2) <= 1e-10)), 1, 0);
revisar('max V2', max(V2), 0.4922, 5e-4);

fprintf('11.9  Control basado en pasividad\n');
qr = pi/3;  qss = fzero(@(q) 20*(qr - q) - 9.81*sin(q), [0 qr]);
revisar('PD solo: q_ss', qss, 0.7228, 1e-4);
revisar('PD solo: error (grados)', rad2deg(qr - qss), 18.589, 1e-3);
revisar('escape exacto con x0 = 1, z0 = 3, k = 1', log((3/2)/(3/2 - 1))/2, log(3)/2, 1e-12);
ev = @(t, x) deal(abs(x(1)) - 1e6, 1, 0);
[~, ~, te] = ode45(@(t, x) [-x(1) + x(1)^2*x(2); -x(2)], [0 5], [1; 3], odeset(opc, 'Events', ev));
revisar('escape simulado', te(1), 0.5493, 1e-3);

fprintf('11.10 Distribución de agua\n');
Q = 2;  r = 2;  vm = 2;  c = [0.6; 1.0; 1.4];
revisar('v*', Q^2/sum(c)^2, 4/9, 1e-12);
revisar('q*_3', c(3)*Q/sum(c), 14/15, 1e-12);
revisar('v* tras el cambio', Q^2/3.6^2, 0.3086, 1e-4);
qs = c*Q/sum(c);
revisar('V2 con q = 2 q*', sum(qs.*log(qs./(2*qs)))/Q, -log(2), 1e-12);
[~, X] = ode45(@(t, x) modeloAgua(x, c, Q, r, vm), linspace(0, 40, 4001), [0.1; 0.8; 0.3; 0.9; 0.6; 0.5], opc);
[a1, b1] = energiaAgua(X, c, Q, r, vm);
revisar('sum q = Q', max(abs(sum(X(:,4:6), 2) - Q)), 0, 1e-8);
revisar('V = V1 + V2 no creciente', double(all(diff(a1 + b1) <= 1e-9)), 1, 0);
revisar('v(40) -> v*', max(abs(X(end,1:3) - 4/9)), 0, 2e-3);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
if fallas > 0, error('verificarCap11:falla', '%d verificaciones fallaron.', fallas); end
end
