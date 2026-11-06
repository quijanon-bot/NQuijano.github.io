function verificarCap04()
% VERIFICARCAP04  Pruebas automáticas de los números del capítulo 4.
%   >> verificarCap04
% (Los mismos números se verificaron en herramientas/cap04_numeros.py.)
raiz = fileparts(mfilename('fullpath'));  addpath(fullfile(raiz, '..', 'comun'));
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-46s %12.5g\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-45s %12.5g  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end

fprintf('4.2  Ciclo del carbono\n');
k = [0.0842 0.0684 0.0159 0.0332 0.0846 0.0433 0.0011 0.0001];
A = [-(k(5)+k(1)) k(2) k(4) k(6) 0; k(1) -(k(2)+k(3)) 0 0 0; 0 k(3) -k(4) 0 0;
     k(5) 0 0 -(k(6)+k(7)) k(8); 0 0 0 k(7) -k(8)];
revisar('suma de columnas de A', max(abs(sum(A))), 0, 1e-15);
ev = sort(eig(A));
revisar('valor propio más rápido', ev(1), -0.2274, 1e-4);
revisar('valor propio nulo', ev(5), 0, 1e-12);
revisar('constante de tiempo más lenta (años)', -1/ev(4), 1729.1, 0.5);
x0 = [590; 550; 1500; 900; 37000];  t = 0:0.5:500;
[~, ~, x] = lsim(ss(A, [1;0;0;0;0], eye(5), 0), 8*ones(size(t)), t, x0);
revisar('carbono total en t = 500', sum(x(end,:)), 44540, 0.5);
revisar('atmósfera en t = 500', x(end,1), 1833.0, 1);

fprintf('4.3  Masa-resorte (M = 2, k = 16)\n');
revisar('b = 2: parte real', max(real(eig([0 1; -8 -1]))), -0.5, 1e-12);
revisar('b = 8: polos -2 +- 2j (imag)', max(imag(eig([0 1; -8 -4]))), 2, 1e-12);
revisar('b = 16: polo lento', max(eig([0 1; -8 -8])), -1.1716, 1e-4);
[~, ~, xm] = lsim(ss([0 1; -8 -1], [0; 0.5], [1 0], 0), 5*ones(1, 3001), 0:0.01:30);
revisar('posición final con u = 5', xm(end,1), 5/16, 1e-3);

fprintf('4.4  Función de transferencia -> estado\n');
[Af, Bf, Cf] = variablesFase([1 7 2], [1 9 26 24]);
revisar('variables de fase: A(3,:)', norm(Af(3,:) - [-24 -26 -9]), 0, 1e-12);
revisar('variables de fase: C = [2 7 1]', norm(Cf - [2 7 1]), 0, 1e-12);
[A1, B1, C1] = tf2ss([1 7 2], [1 9 26 24]);  P = fliplr(eye(3));
revisar('tf2ss con estados al revés = fase', norm(P*A1*P - Af) + norm(P*B1 - Bf) + norm(C1*P - Cf), 0, 1e-12);

fprintf('4.5  Matriz de transición (A = [0 1; -2 -3])\n');
A = [0 1; -2 -3];  P05 = expm(A*0.5);
revisar('Phi(0.5)(1,1)', P05(1,1), 2*exp(-0.5) - exp(-1), 1e-12);
revisar('Phi(0.5)(2,1)', P05(2,1), -0.4773, 1e-4);
revisar('Phi(t1+t2) = Phi(t1) Phi(t2)', norm(expm(A*1.7) - expm(A*0.5)*expm(A*1.2)), 0, 1e-12);
revisar('Phi(-t) = Phi(t)^-1', norm(expm(-A*0.5) - inv(P05)), 0, 1e-12);
tt = 0:0.01:6;  [~, ~, x] = lsim(ss(A, [0;1], eye(2), 0), ones(size(tt)), tt);
revisar('escalón: x1 = 1/2 - e^-t + e^-2t/2', max(abs(x(:,1)' - (0.5 - exp(-tt) + exp(-2*tt)/2))), 0, 1e-4);
xl = expm(A*2)*[1; -1];  revisar('libre con x(0) = [1;-1]: un solo modo', xl(1), exp(-2), 1e-12);
al = 3;  Pm = expm([0 1; 0 -al]*0.7);
revisar('motor DC: Phi12 = (1-e^-at)/a', Pm(1,2), (1 - exp(-al*0.7))/al, 1e-12);

fprintf('4.6  Estado -> función de transferencia\n');
revisar('determinante del ejemplo', det([2 4 1; 3 0 2; 2 0 3]), -20, 1e-12);
[num, den] = ss2tf([0 1; -6 -5], [0; 1], [1 0], 0);
revisar('(i): ganancia DC', num(end)/den(end), 1/6, 1e-12);
[num, den] = ss2tf([-2 1 0; 0 -3 1; 0 0 -4], [0; 0; 1], [1 0 0], 0);
revisar('(ii): ganancia DC', num(end)/den(end), 1/24, 1e-12);
A3 = [0 1 0; 0 0 1; -6 -11 -6];
[num, den] = ss2tf(A3, [0;0;1], [2 3 1], 0);  r = roots(den);  z = roots(num(find(abs(num) > 1e-12, 1):end));
revisar('Cb: ceros que cancelan polos', min(abs(z(1) - r)) + min(abs(z(2) - r)), 0, 1e-8);
[T, L] = eig(A3);
revisar('Phi = T e^{Lambda t} T^-1', norm(T*expm(L*1)/T - expm(A3*1)), 0, 1e-10);

fprintf('4.7  Linealización\n');
revisar('Duffing origen, delta = 0.3: valor propio +', max(eig([0 1; 1 -0.3])), 0.8612, 1e-4);
revisar('Duffing (1,0): parte real', max(real(eig([0 1; -2 -0.3]))), -0.15, 1e-12);
revisar('Duffing: delta crítico sqrt(8)', sqrt(8), 2.8284, 1e-4);
M = 0.05; R = 10; Lb = 0.5; Cf = 1e-3; g = 9.81; yd = 0.01;
ie = sqrt(M*g*yd/Cf);  revisar('levitador: i*', ie, 2.2147, 1e-4);  revisar('levitador: u*', R*ie, 22.147, 1e-3);
Al = [0 1 0; Cf*ie^2/(M*yd^2) 0 -2*Cf*ie/(M*yd); 0 0 -R/Lb];
revisar('levitador: a21 = g/y*', Al(2,1), 981, 1e-9);
revisar('levitador: valor propio inestable', max(real(eig(Al))), 31.321, 1e-3);
mumax = 0.53; km = 0.12; k1 = 0.4545; Y = 0.4; u1 = 0.3; u2 = 4;
x2e = sort(roots([u1*k1, u1 - mumax, u1*km]));
revisar('bioreactor: x2* estable', x2e(1), 0.17459, 1e-5);
revisar('bioreactor: x2* de operación', x2e(2), 1.51224, 1e-5);
revisar('bioreactor: x1* de operación', Y*(u2 - x2e(2)), 0.99510, 1e-5);
dmu = @(x) mumax*(km - k1*x^2)/(km + x + k1*x^2)^2;
a = Y*(u2 - x2e(2));  c = x2e(2);
Ab = [0, a*dmu(c); -u1/Y, -u1 - a*dmu(c)/Y];
revisar('bioreactor: a12', Ab(1,2), -0.06794, 1e-5);
revisar('bioreactor: valor propio inestable', max(eig(Ab)), 0.16976, 1e-4);
revisar('bioreactor: dmu/dx2 = 0 en sqrt(km/k1)', sqrt(km/k1), 0.51383, 1e-5);

fprintf('\n%d de %d pruebas correctas.\n', n - fallas, n);
end
