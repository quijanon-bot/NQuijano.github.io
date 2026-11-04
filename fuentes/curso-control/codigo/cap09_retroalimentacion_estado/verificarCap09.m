function verificarCap09()
% VERIFICARCAP09  Pruebas automáticas de los números del capítulo 9.
%   >> verificarCap09
% (Los mismos números se verificaron con python-control y sympy en
%  herramientas/cap09_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-38s %12.4f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-37s %12.4f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end

fprintf('9.1  Friedland\n');
A = [2 3 2 1; -2 -3 0 0; -2 -2 -4 0; -2 -2 -2 -5];  B = [1; -2; 2; -1];  C = [7 6 4 2];
revisar('rank ctrb', rank(ctrb(A, B)), 2, 0);
revisar('rank obsv', rank(obsv(A, C)), 2, 0);
revisar('H(0) = 1 (como 1/(s+1))', dcgain(ss(A, B, C, 0)), 1, 1e-9);

fprintf('9.2  Ejemplo motivador\n');
A = [-1 2; 3 -2];  B = [0; 1];
revisar('polo inestable', max(eig(A)), 1, 1e-9);
K = acker(A, B, [-2 -3]);
revisar('K1', K(1), 4, 1e-9);  revisar('K2', K(2), 2, 1e-9);

fprintf('9.3  Controlabilidad\n');
K = acker(diag([-1 -3]), [1; 1], [-2 -2]);
revisar('K1 (diag)', K(1), 0.5, 1e-9);  revisar('K2 (diag)', K(2), -0.5, 1e-9);
revisar('rank con a = 0', rank(ctrb([-1 0; 3 -2], [0; 1])), 1, 0);

fprintf('9.4  Ackermann\n');
K = acker([0 1; 0 0], [0; 1], [-1+1j, -1-1j]);
revisar('1/s^2: K1', K(1), 2, 1e-9);  revisar('1/s^2: K2', K(2), 2, 1e-9);

fprintf('9.5  Especificaciones\n');
p = polosDeseados(0.10, 'tp', 1, 'extra', 10);
[Af, Bf] = variablesFase(10, conv([1 10], [1 0.5 1]));
K = acker(Af, Bf, p);
revisar('K (fase) 1', K(1), 339.3368, 1e-3);  revisar('K (fase) 3', K(3), 17.131, 1e-3);
[A, B, C] = variablesFase(1, conv([1 0], conv([1 1], [1 2])));
K = acker(A, B, [-2+3.4641j, -2-3.4641j, -10]);
revisar('servo K1', K(1), 160, 0.01);  revisar('servo K2', K(2), 54, 0.01);  revisar('servo K3', K(3), 11, 1e-6);
revisar('servo valor final', dcgain(ss(A - B*K, B*K(1), C, 0)), 1, 1e-6);

fprintf('9.6  Observador\n');
L = acker([2 3; -1 4].', [1 0].', roots([1 16 100])).';
revisar('L1', L(1), 22, 1e-6);  revisar('L2', L(2), 59, 1e-6);
L = acker([0 1; -10 -2].', [1 0].', roots([1 16 100])).';
revisar('L1', L(1), 14, 1e-6);  revisar('L2', L(2), 62, 1e-6);

fprintf('9.7  Separación\n');
A = [0 1; -2 -3];  B = [0; 1];  C = [1 0];
K = acker(A, B, [-2+2j, -2-2j]);  L = acker(A.', C.', [-10 -10]).';
revisar('K1', K(1), 6, 1e-9);  revisar('L2', L(2), 47, 1e-9);
ev = eig([A - B*K, B*K; zeros(2), A - L*C]);
revisar('suma de valores propios', real(sum(ev)), -24, 1e-6);
revisar('ganancia DC del compensador', dcgain(ss(A - B*K - L*C, L, -K, 0)), -554/123, 1e-6);

fprintf('9.8  Acción integral\n');
A = [0 1; -3 -5];  B = [0; 1];  C = [1 0];
p = polosDeseados(0.10, 'ts', 0.5);
K = acker(A, B, p);
revisar('K1 sin integrador', K(1), 180.1, 0.05);
revisar('e_ss sin integrador', 1 - dcgain(ss(A - B*K, B, C, 0)), 0.9945, 1e-4);
Aa = [A zeros(2,1); -C 0];  Ba = [B; 0];
Ka = acker(Aa, Ba, [p; -100]);
revisar('K1 con integrador', Ka(1), 1780.1, 0.1);
revisar('Ke', -Ka(3), 18313.7, 0.1);
revisar('valor final con integrador', dcgain(ss(Aa - Ba*Ka, [0;0;1], [C 0], 0)), 1, 1e-9);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
if fallas > 0, error('verificarCap09:falla', '%d verificaciones fallaron.', fallas); end
end
