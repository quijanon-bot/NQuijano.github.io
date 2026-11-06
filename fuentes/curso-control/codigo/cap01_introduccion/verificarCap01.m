function verificarCap01()
% VERIFICARCAP01  Pruebas automáticas de los números del capítulo 1.
%   >> verificarCap01
% (Los mismos números se verificaron con python-control en
%  herramientas/cap01_numeros.py.)
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-40s %12.4f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-39s %12.4f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end

fprintf('1.2  Tanque en lazo abierto y cerrado\n');
Area = 0.5;  R = 2;  Kn = 2;  Kc = 5;
t = linspace(0, 30, 6001)';  hr = ones(size(t));  d = 0.2*ones(size(t));
ola = @(Rr) ss(-1/(Area*Rr), [1/(Area*Kn) 1/Area], 1, 0);
lc  = @(Rr, kc) ss(-(1/Rr + kc)/Area, [(1/Kn + kc)/Area 1/Area], 1, 0);
y = lsim(ola(R), [hr d], t);          revisar('abierto con lluvia', y(end), 1.4, 1e-3);
y = lsim(lc(R, Kc), [hr d], t);       revisar('cerrado con lluvia (Kc = 5)', y(end), 11.4/11, 1e-4);
y = lsim(ola(2.4), [hr 0*d], t);      revisar('abierto con R = 2.4', y(end), 1.2, 1e-3);
y = lsim(lc(2.4, Kc), [hr 0*d], t);   revisar('cerrado con R = 2.4', y(end), 2.4*5.5/13, 1e-4);
y = lsim(lc(R, 1), [hr d], t);        revisar('cerrado, lluvia, Kc = 1', y(end), 3.4/3, 1e-4);
y = lsim(lc(R, 10), [hr d], t);       revisar('cerrado, lluvia, Kc = 10', y(end), 21.4/21, 1e-4);
revisar('tau lazo cerrado (s)', 60*-1/pole(lc(R, Kc)), 60/11, 1e-6);
revisar('Kc mínimo para < 1 cm', (0.4/0.01 - 1)/2, 19.5, 1e-9);
y = lsim(ss(-(1/R + Kc)/Area, [Kc/Area 1/Area], 1, 0), [hr 0*d], t);
revisar('sin calibración: RKc/(1+RKc)', y(end), 10/11, 1e-4);

fprintf('1.3  Ascensor\n');
T = 4*0.975*tf(0.64, [1 0.96 0.64]);
S = stepinfo(T);   % criterio por defecto: 2 %
revisar('sobrepaso (%)', S.Overshoot, 9.48, 0.02);
revisar('tiempo pico (s)', S.PeakTime, pi/(0.8*0.8), 0.02);
revisar('tiempo de establecimiento (s)', S.SettlingTime, 7.43, 0.05);
revisar('valor final', dcgain(T), 3.9, 1e-9);

fprintf('1.4  Prealimentación y ganancia de proceso\n');
A2 = 2;  eps = 0.1;  t = linspace(0, 18, 3601)';  F1 = 0.5*ones(size(t));
y = lsim(ss(0, eps/A2, 1, 0), F1, t);        revisar('deriva en 18 min', y(end), 0.45, 1e-3);
t = linspace(0, 60, 6001)';  F1 = 0.5*ones(size(t));
y = lsim(ss(-1/A2, 1/A2, 1, 0), F1, t);      revisar('solo retroalimentación', y(end), 0.5, 1e-4);
y = lsim(ss(-1/A2, eps/A2, 1, 0), F1, t);    revisar('combinadas', y(end), 0.05, 1e-4);
revisar('ganancia 10 C / 0.5 kW', 10/0.5, 20, 0);

fprintf('\n%d de %d pruebas pasaron.\n', n - fallas, n);
end
