function verificarCap06()
% VERIFICARCAP06  Pruebas automáticas de los números del capítulo 6.
%   >> verificarCap06
% (Los mismos números se verificaron en herramientas/cap06_numeros.py.)
raiz = fileparts(mfilename('fullpath'));  addpath(fullfile(raiz, '..', 'comun'));
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol || (isinf(valor) && isinf(esperado))
            fprintf('  ok   %-46s %12.5g\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-45s %12.5g  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
s = tf('s');

fprintf('6.3  Tipo y constantes\n');
revisar('motor: K para ess = 1', (0.01 + 0.05*10)/10, 0.051, 1e-12);
G = {20*(s+2)/((s+1)*(s+5)), 50/(s*(s+3)*(s+10)), 100*(s+4)*(s+6)/(s^2*(s+5)*(s+8)), 5*(s+1)/(s^3*(s+2))};
[t1, kp] = constantesError(G{1});  revisar('(i) tipo', t1, 0, 0);  revisar('(i) kp', kp, 8, 1e-9);
revisar('(i) ess con r = 5', 5/(1 + kp), 5/9, 1e-9);
[t2, ~, kv] = constantesError(G{2});  revisar('(ii) tipo', t2, 1, 0);  revisar('(ii) kv', kv, 5/3, 1e-9);
revisar('(ii) ess con r = 2t', 2/kv, 1.2, 1e-9);
[t3, ~, ~, ka] = constantesError(G{3});  revisar('(iii) tipo', t3, 2, 0);  revisar('(iii) ka', ka, 60, 1e-9);
revisar('(iii) ess con r = 1.5t^2', 3/ka, 0.05, 1e-9);
revisar('(iv) inestable: max Re', max(real(pole(feedback(G{4}, 1)))) > 0, 1, 0);
revisar('(ii) estable: max Re', max(real(pole(feedback(G{2}, 1)))), -1.1909, 1e-3);
t = 0:0.01:30;  y = lsim(feedback(G{2}, 1), 2*t, t);
revisar('(ii) error de rampa simulado', 2*t(end) - y(end), 1.2, 1e-3);

fprintf('6.4  Retroalimentación no unitaria\n');
Gn = 100/(s+1);  H = 1/(s+5);
revisar('error de actuación 1/21', 1/(1 + dcgain(Gn*H)), 1/21, 1e-12);
revisar('y final 100/21', dcgain(feedback(Gn, H)), 100/21, 1e-9);
Gol = minreal(Gn/(1 + Gn*H - Gn));
revisar('kp de G_OL', dcgain(Gol), -100/79, 1e-9);
revisar('error de seguimiento', 1/(1 + dcgain(Gol)), 1 - 100/21, 1e-9);
revisar('polo inestable de G_OL', max(real(pole(Gol))), 98.029, 1e-3);
revisar('sensor recalibrado k', (500 - 5)/100, 4.95, 1e-12);
revisar('con k = 4.95: y final', dcgain(feedback(Gn, 4.95/(s+5))), 1, 1e-9);

fprintf('6.5  Perturbaciones\n');
Gp = 1/((s+1)*(s+2));  esp = [-0.5/3 -0.5/12 -0.5/102];  Ks = [1 10 100];
for i = 1:3
    revisar(sprintf('P K=%d, entrada', Ks(i)), 0.5*dcgain(-feedback(Gp, Ks(i))), esp(i), 1e-9);
    revisar(sprintf('P K=%d, salida', Ks(i)), 0.5*dcgain(-feedback(1, Ks(i)*Gp)), 2*esp(i), 1e-9);
end
revisar('PI: estable con Ki = 35', max(real(roots([1 3 12 35]))) < 0, 1, 0);
revisar('PI: inestable con Ki = 37', max(real(roots([1 3 12 37]))) > 0, 1, 0);
revisar('PI: error nulo', abs(dcgain(-feedback(Gp, 10 + 18/s))), 0, 1e-9);

fprintf('6.6  Espacio de estado\n');
A = [0 1; -2 -3];  B = [0; 1];  C = [2 0];
xss = -(A - B*C)\B;  revisar('x1 estacionario', xss(1), 0.25, 1e-12);
revisar('ess = 1 - C xss', 1 - C*xss, 0.5, 1e-12);
Aa = [A - B*C, B*3; -C, 0];  Ba = [B; 1];
revisar('aumentado: poly = [1 3 4 6]', norm(poly(Aa) - [1 3 4 6]), 0, 1e-9);
revisar('aumentado: y final', [C 0]*(-Aa\Ba), 1, 1e-12);
revisar('aumentado: inestable con Ki = 6.5', max(real(roots([1 3 4 13]))) > 0, 1, 0);

fprintf('6.7  Especificaciones en conflicto\n');
revisar('K para ess = 0.05', 32/0.05, 640, 1e-9);
revisar('K máximo (Routh)', 12*32, 384, 0);
K = 67.83;  Gp3 = 1/(s*(s+4)*(s+8));
T0 = feedback(K*Gp3, 1);  tt = 0:0.001:30;  y0 = step(T0, tt);
revisar('solo K: %OS', 100*(max(y0) - 1), 16.19, 0.05);
T1 = feedback(K*(s + 0.0519)/(s + 0.005)*Gp3, 1);  y1 = step(T1, 0:0.001:60);
revisar('con atraso: %OS', 100*(max(y1) - 1), 18.95, 0.3);
revisar('con atraso: kv', K*0.0519/0.005/32, 22.0, 0.05);
revisar('con atraso: estable', max(real(pole(T1))) < 0, 1, 0);

fprintf('6.1  Sensitividad\n');
Gs = 1/((s+1)*(s+10));
for K = [10 200]
    L = K*Gs;  S = 1/(1 + L);  T = L/(1 + L);
    revisar(sprintf('K=%d: |S+T| en w = 3', K), abs(evalfr(S + T, 3j)), 1, 1e-12);
end
L = 200/((s+1)*(s+10));
revisar('K=200: aporte perturbación', 0.5*abs(evalfr(Gs/(1 + 200*Gs), 0.2j)), 0.0023813, 1e-6);
revisar('K=200: aporte ruido', 0.01*abs(evalfr(L/(1 + L), 50j)), 0.00084921, 1e-7);
revisar('K=10: aporte perturbación', 0.5*abs(evalfr(Gs/(1 + 10*Gs), 0.2j)), 0.024899, 1e-6);

fprintf('\n%d de %d pruebas correctas.\n', n - fallas, n);
end
