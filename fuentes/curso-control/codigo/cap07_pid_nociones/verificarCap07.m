function verificarCap07()
% VERIFICARCAP07  Pruebas automáticas de los números del capítulo 7.
%   >> verificarCap07
% (Los mismos números se verificaron en herramientas/cap07_numeros.py.)
raiz = fileparts(mfilename('fullpath'));  addpath(fullfile(raiz, '..', 'comun'));
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-44s %12.4f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-43s %12.4f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
s = tf('s');  P = 1/(s^2 + 10*s + 20);
fprintf('7.5  Masa-resorte-amortiguador\n');
revisar('lazo abierto: valor final', dcgain(P), 0.05, 1e-12);
revisar('P Kc=300: ess', 1 - dcgain(feedback(300*P, 1)), 0.0625, 1e-9);
revisar('P Kc=300: zeta', 10/(2*sqrt(320)), 0.2795, 1e-4);
S = stepinfo(feedback(300*P, 1));  revisar('P Kc=300: OS (%)', S.Overshoot, 40.07, 0.1);
S = stepinfo(feedback((300 + 20*s)*P, 1));  revisar('PD Kd=20: OS (%)', S.Overshoot, 5.79, 0.1);
S = stepinfo(feedback((300 + 200/s)*P, 1));  revisar('PI Ki=200: OS (%)', S.Overshoot, 36.3, 0.2);
revisar('PI: Ki máximo (Routh)', 10*320, 3200, 0);
T = feedback((350 + 300/s + 50*s)*P, 1);  S = stepinfo(T);
revisar('PID 350/300/50: OS (%)', S.Overshoot, 0, 1e-6);
revisar('PID 350/300/50: polo lento', max(real(pole(T))), -0.9569, 1e-4);

fprintf('7.4  Conversiones\n');
[K, Ti, Td] = convertirPID(2, 8, 2, 'serie', 'ideal');
revisar('serie->ideal Kc', K, 2.5, 1e-12); revisar('serie->ideal Ti', Ti, 10, 1e-12); revisar('serie->ideal Td', Td, 1.6, 1e-12);
[K, Ti, Td] = convertirPID(K, Ti, Td, 'ideal', 'serie');
revisar('ida y vuelta Kc', K, 2, 1e-12); revisar('ida y vuelta Ti', Ti, 8, 1e-12); revisar('ida y vuelta Td', Td, 2, 1e-12);
revisar('ideal (5,4,2): ceros complejos', max(abs(imag(roots([40 20 5])))), 0.25, 1e-12);
[K, Ti, Td] = convertirPID(350, 300, 50, 'paralelo', 'ideal');
revisar('paralelo->ideal Ti', Ti, 350/300, 1e-12); revisar('paralelo->ideal Td', Td, 1/7, 1e-12);
[K, Ti, Td] = convertirPID(K, Ti, Td, 'ideal', 'serie');
revisar('-> serie Kc', K, 300, 1e-9); revisar('-> serie Ti', Ti, 1, 1e-9); revisar('-> serie Td', Td, 1/6, 1e-9);

fprintf('7.3  Banda proporcional (problema)\n');
Kc = (1/0.25)*(100/200);  revisar('Kc con rangos (%%/°C)', Kc, 2, 0);
revisar('error con u0=50 (°C)', 120 - 2.5*(50 + Kc*120)/(1 + 2.5*Kc), -0.8333, 1e-4);
revisar('u0 que anula el error', 120/2.5, 48, 0);
revisar('error con Kp=2.2', 120 - 2.2*(48 + Kc*120)/(1 + 2.2*Kc), 2.6667, 1e-4);

fprintf('7.6  Filtro derivativo y kicks\n');
revisar('ruido w=100, D pura', 0.01*3*2*100, 6, 1e-12);
revisar('ruido w=100, N=10', 0.01*3*abs(1j*100*2/(1j*100*2/10 + 1)), 0.2996, 1e-4);
[~, ~, u] = simularPID(P, 350, 350/300, 50/350, 'tf', 0.5, 'dt', 1e-4, 'N', (50/350)/0.01);
revisar('kick estándar |u|max', max(abs(u)), 5300, 60);
[~, ~, u] = simularPID(P, 350, 350/300, 50/350, 'tf', 6, 'dt', 1e-3, 'N', (50/350)/0.01, 'b', 0, 'c', 0);
revisar('I-PD |u|max (sin pico)', max(abs(u)), 20, 0.05);

fprintf('7.6  Wind-up\n');
G = 1/(10*s + 1);  op = {'tf', 100, 'dt', 0.005, 'L', 4, 'N', 10, 'umin', 0, 'umax', 1.5};
[t, y, u] = simularPID(G, 3, 8, 2, op{:});
revisar('sin anti-windup: OS (%)', (max(y) - 1)*100, 37.7, 0.3);
revisar('sin anti-windup: tiempo saturado (s)', sum(u >= 1.5 | u <= 0)*0.005, 24.6, 0.3);
[t, y] = simularPID(G, 3, 8, 2, op{:}, 'aw', 'back', 'Tt', 4);
revisar('back-calculation Tt=4: OS (%)', (max(y) - 1)*100, 3.3, 0.3);
[t, y] = simularPID(G, 3, 8, 2, op{:}, 'aw', 'clamp');
revisar('integración condicional: OS (%)', (max(y) - 1)*100, 3.7, 0.3);

fprintf('7.6  Ponderación de la referencia\n');
Gp = 1/((s + 1)*(s + 5));
[t, y] = simularPID(Gp, 20, 0.3, 0, 'tf', 6, 'dt', 1e-3, 'b', 1);  revisar('beta=1: OS (%)', (max(y) - 1)*100, 51.3, 0.3);
[t, y] = simularPID(Gp, 20, 0.3, 0, 'tf', 6, 'dt', 1e-3, 'b', 0);  revisar('beta=0: OS (%)', (max(y) - 1)*100, 26.9, 0.3);
[t, y] = simularPID(Gp, 20, 0.3, 0, 'tf', 6, 'dt', 1e-3, 'r', 0, 'd', 1);  revisar('perturbación: pico', max(y), 0.0324, 5e-4);

fprintf('7.7  Digital\n');
q = 3*[1 + 0.1/8 + 2/0.1, -1 - 2*2/0.1, 2/0.1];
revisar('q0', q(1), 63.0375, 1e-9); revisar('q1', q(2), -123, 1e-9); revisar('q2', q(3), 60, 1e-9);

fprintf('\n%d de %d pruebas correctas.\n', n - fallas, n);
end
