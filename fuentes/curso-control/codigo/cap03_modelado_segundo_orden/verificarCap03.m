function verificarCap03()
% VERIFICARCAP03  Pruebas automáticas de los números del capítulo 3.
%   >> verificarCap03
% (Los mismos números se verificaron con python-control en
%  herramientas/cap03_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'), raiz);
s = tf('s');  fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-38s %12.4f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-37s %12.4f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end

fprintf('3.2  Linealización\n');
f  = @(x) x.*sqrt(x.^2 + 5*x);
revisar('f(5)', f(5), 35.355, 1e-3);
revisar('f''(5) (diferencia central)', (f(5 + 1e-6) - f(5 - 1e-6))/2e-6, 12.374, 1e-3);

fprintf('3.3  Dos tanques\n');
A1 = 2;  A2 = 3;  Cv1 = 0.1;  Cv2 = 0.05;  h2e = 4;
fe = Cv2*sqrt(h2e);  h1e = h2e + (fe/Cv1)^2;
C1 = Cv1/(2*sqrt(h1e - h2e));  C2 = -C1;  C3 = Cv2/(2*sqrt(h2e));
K1 = 1/C1;  tau1 = A1/C1;  K2 = C1/(C3 - C2);  tau2 = A2/(C3 - C2);
G = K1*K2/((tau1*s + 1)*(tau2*s + 1) + K1*K2*C2);
revisar('h1*', h1e, 5, 1e-9);
revisar('tau1', tau1, 40, 1e-9);  revisar('tau2', tau2, 48, 1e-9);
revisar('ganancia DC', dcgain(G), 80, 1e-6);
wn = sqrt(C1*C3/(A1*A2));  z = ((C1 + C3)/A2 + C1/A1)/(2*wn);
revisar('zeta', z, 2.245, 1e-3);
revisar('polo lento', max(real(pole(G))), -0.002398, 1e-6);

fprintf('3.5  Fórmulas del subamortiguado\n');
F = segundoOrden(0.4, 1);
S = stepinfo(1/(s^2 + 0.8*s + 1));
revisar('%OS fórmula vs stepinfo', F.OS - S.Overshoot, 0, 0.05);
revisar('tp fórmula vs stepinfo', F.tp - S.PeakTime, 0, 0.02);
revisar('tr 0-100', F.tr0100, 2.16, 0.01);
revisar('%OS(0.4)', F.OS, 25.38, 0.01);

fprintf('3.7  Diseño K, Kh\n');
z = zetaDeOS(0.2);  wn = pi/sqrt(1 - z^2);  K = wn^2;  Kh = (2*z*wn - 1)/K;
revisar('zeta', z, 0.4559, 1e-4);  revisar('wn', wn, 3.5299, 1e-4);
revisar('K', K, 12.46, 0.01);      revisar('Kh', Kh, 0.1781, 1e-4);
T = feedback(K/s*1/(s + 1), 1 + Kh*s);
S = stepinfo(T);
revisar('%OS simulado', S.Overshoot, 20, 0.05);

fprintf('3.6  Bloques\n');
T = minreal(feedback(1/(s + 1)*feedback(2/s, 1)*5/(s + 3), 0.5));
[nu, de] = tfdata(T, 'v');  de = de/de(1);
revisar('multilazo: coef. s^0', de(end), 11, 1e-6);
revisar('multilazo: polo real', min(real(pole(T))), -3.9042, 1e-4);

fprintf('3.9  Orden superior\n');
S3 = stepinfo(20/((s + 10)*(s^2 + 2*s + 2)));  S2 = stepinfo(2/(s^2 + 2*s + 2));
revisar('%OS tercer orden', S3.Overshoot, 4.27, 0.05);
revisar('%OS aproximación', S2.Overshoot, 4.32, 0.05);
Sc = stepinfo(62.5*(s + 2.5)/((s^2 + 6*s + 25)*(s + 6.25)));
Sa = stepinfo(10*(s + 2.5)/(s^2 + 6*s + 25));
revisar('%OS completo', Sc.Overshoot, 38.0, 0.2);
revisar('%OS sin polo', Sa.Overshoot, 54.5, 0.2);

fprintf('3.10 Reducción\n');
[GL, d] = reduccionMomentos(6/(s^3 + 6*s^2 + 11*s + 6));
revisar('d1', d(1), 1.615, 1e-3);  revisar('d2', d(2), 0.6236, 1e-4);
revisar('polo lento G_L', max(real(pole(GL))), -1.024, 1e-3);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
if fallas > 0, error('verificarCap03:falla', '%d verificaciones fallaron.', fallas); end
end
