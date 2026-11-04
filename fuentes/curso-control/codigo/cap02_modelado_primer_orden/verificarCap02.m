function verificarCap02()
% VERIFICARCAP02  Pruebas automáticas de los números del capítulo 2.
% Corre los cálculos clave de las notas (sin Symbolic Math Toolbox) y
% verifica cada resultado con una tolerancia.   >> verificarCap02
% (Los mismos números se verificaron con sympy/python-control en
%  herramientas/cap02_numeros.py.)
s = tf('s');  fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-36s %12.4f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-35s %12.4f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end

fprintf('2.1  Sistema estático\n');
revisar('90 F en C', 5/9*(90 - 32), 32.22, 0.01);

fprintf('2.4  Fracciones parciales\n');
[r, p] = residue([1 5], [1 5 6]);
revisar('residuo en -2', r(abs(p + 2) < 1e-9), 3, 1e-9);
revisar('residuo en -3', r(abs(p + 3) < 1e-9), -2, 1e-9);
[r, p] = residue(1, conv([1 0 0], [1 2 1]));
revisar('1/(s^2(s+1)^2): suma residuos simples', sum(r([1 3])), 0, 1e-6);
p = roots([3 2 1]);
revisar('polos complejos: Re', real(p(1)), -1/3, 1e-9);
revisar('polos complejos: |Im|', abs(imag(p(1))), sqrt(2)/3, 1e-9);
t = linspace(0, 20, 2001)';
xf = exp(-t/3).*(-cos(sqrt(2)*t/3) + 2.5*sqrt(2)*sin(sqrt(2)*t/3));
dx = gradient(xf, t);
revisar('x(0)', xf(1), -1, 1e-9);
revisar('xdot(0) (numérica)', dx(1), 2, 0.02);

fprintf('2.6  Teorema del valor final\n');
revisar('polo inestable de 6(s^2-2)/(...)', max(real(roots([1 1 -4 -4]))), 2, 1e-9);

fprintf('2.7  Proceso térmico\n');
t = linspace(0, 40, 4001);
y = 2*step(1/(5*s + 1), t);
revisar('T(5) = 25 + 2(1-e^-1)', 25 + interp1(t, y, 5), 26.264, 1e-3);

fprintf('2.8  Primer orden\n');
revisar('63.2 %', 100*(1 - exp(-1)), 63.21, 0.01);
revisar('98.2 %', 100*(1 - exp(-4)), 98.17, 0.01);
y = step(tf(10, [5 1]), t);
revisar('pendiente inicial K1/tau', (y(2) - y(1))/(t(2) - t(1)), 2, 0.01);
yr = lsim(tf(1, [10 1]), t, t);
revisar('error rampa en t = 40 (K1 tau = 10)', t(end) - yr(end), 10*(1 - exp(-4)), 1e-2);

fprintf('2.10 Problemas\n');
K1 = 12/5;  tau = -30/log(1 - 7.6/12);
revisar('identificación K1', K1, 2.4, 1e-9);
revisar('identificación tau', tau, 29.90, 0.01);
revisar('e_ss rampa', K1*0.01*tau, 0.7176, 1e-3);
y = step(tf(24, [2 10 12]), t);   % las condiciones iniciales no cambian el valor final
revisar('2y''''+10y''+12y=24u: valor final', y(end), 2, 1e-3);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
if fallas > 0, error('verificarCap02:falla', '%d verificaciones fallaron.', fallas); end
end
