function verificarCap08()
% VERIFICARCAP08  Pruebas automáticas de los números del capítulo 8.
%   >> verificarCap08
% (Los mismos números se verificaron en herramientas/cap08_numeros.py.)
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
s = tf('s');

fprintf('8.2  Identificación\n');
revisar('ganancia normalizada del ejemplo', (30/60)/(20/100), 2.5, 1e-12);
t = [0 2 4 6 8 10 15 20 24 30 40 50 60 100];
y = [80 80 80.1 81.7 83.3 84.6 87.7 89.9 91.4 93.1 95.0 96.2 96.9 97.9];
[Kp, L, t63, tZN] = identificarFOPDT(t, (y - 80)/100, 0.15);
revisar('datos: Kp', Kp, 1.1933, 1e-4);  revisar('datos: L (tangente)', L, 3.875, 1e-9);
revisar('datos: tau ZN (100 %)', tZN, 22.375, 1e-9);  revisar('datos: tau 63 %', t63, 19.89, 0.01);
ym = 80 + 18*(1 - exp(-max(t - 4, 0)/20));
revisar('ECM del modelo L=4, tau=20', mean((ym - y).^2), 0.0019, 1e-4);
[Kp, L, t63, tZN] = identificarFOPDT(0:0.01:80, fopdtOrden2(0:0.01:80), 1);
revisar('e^{-2s}/((8s+1)(2s+1)): L', L, 3.0, 0.05);  revisar('  tau ZN', tZN, 12.7, 0.05);
revisar('  tau 63', t63, 9.26, 0.05);

fprintf('8.3  Reglas de malla abierta (Kp=1.2, L=4, tau=20)\n');
[Kc, Ti, Td] = reglasPID('ZN', 'PID', 1.2, 4, 20);
revisar('ZN PID Kc', Kc, 5, 1e-12); revisar('ZN PID Ti', Ti, 8, 1e-12); revisar('ZN PID Td', Td, 2, 1e-12);
[Kc, Ti] = reglasPID('ZN', 'PI', 1.2, 4, 20);  revisar('ZN PI Kc', Kc, 3.75, 1e-12); revisar('ZN PI Ti', Ti, 13.333, 1e-3);
[Kc, Ti, Td] = reglasPID('CC', 'PID', 1.2, 4, 20);
revisar('CC PID Kc', Kc, 5.7639, 1e-4); revisar('CC PID Ti', Ti, 9.0959, 1e-4); revisar('CC PID Td', Td, 1.4035, 1e-4);
[Kc, ~, Td] = reglasPID('CC', 'PD', 1.2, 4, 20);  revisar('CC PD Kc', Kc, 5.3472, 1e-4); revisar('CC PD Td', Td, 0.99115, 1e-5);
[Kc, Ti] = reglasPID('CC', 'PI', 1.2, 4, 20);  revisar('CC PI Kc', Kc, 3.8194, 1e-4); revisar('CC PI Ti', Ti, 9.4154, 1e-4);
[Kc, Ti, Td] = reglasPID('ajust', '', 1.2, 4, 20);
revisar('ajust. Kc', Kc, 2.2917, 1e-4); revisar('ajust. Ti', Ti, 22, 1e-12); revisar('ajust. Td', Td, 1.8182, 1e-4);
G = 1.2/(20*s + 1);  op = {'tf', 150, 'dt', 0.005, 'L', 4, 'N', 10};
[tt, yy] = simularPID(G, 5, 8, 2, op{:});  revisar('ZN: OS (%)', 100*(max(yy) - 1), 87.2, 0.3);
[tt, yy] = simularPID(G, 2.2917, 22, 1.8182, op{:});  revisar('ajust.: OS (%)', 100*(max(yy) - 1), 0, 0.05);
[MG, MF] = margenesRetardo([5 8 2], 1.2, 20, 4);  revisar('ZN: MG', MG, 1.33, 0.01); revisar('ZN: MF (°)', MF, 39.3, 0.2);
[MG, MF] = margenesRetardo([5.7639 9.0959 1.4035], 1.2, 20, 4);  revisar('CC: MF (°)', MF, 26.7, 0.2);
[MG, MF] = margenesRetardo([2.2917 22 1.8182], 1.2, 20, 4);  revisar('ajust.: MG', MG, 2.91, 0.01); revisar('ajust.: MF (°)', MF, 74.8, 0.2);

fprintf('8.3  Ejemplo del texto (Kp=2, L=2, tau=10, PI-D)\n');
G = 2/(10*s + 1);  op = {'tf', 60, 'dt', 0.005, 'L', 2, 'N', 10, 'c', 0};
[~, yy] = simularPID(G, 3, 4, 1, op{:});  revisar('ZN 3/4/1: OS (%)', 100*(max(yy) - 1), 64, 0.5);
[Kc, Ti, Td] = reglasPID('CC', 'PID', 2, 2, 10);  [~, yy] = simularPID(G, Kc, Ti, Td, op{:});
revisar('CC: OS (%)', 100*(max(yy) - 1), 84, 0.5);
[Kc, Ti, Td] = reglasPID('ajust', '', 2, 2, 10);  revisar('ajust. Kc', Kc, 1.375, 1e-12);
[~, yy] = simularPID(G, Kc, Ti, Td, op{:});  revisar('ajust.: OS (%)', 100*(max(yy) - 1), 2.3, 0.3);
[~, yd] = simularPID(G, Kc, Ti, Td, op{:}, 'r', 0, 'd', 1);  revisar('ajust.: pico perturbación', max(yd), 0.48, 0.005);
[~, yd] = simularPID(G, 3, 4, 1, op{:}, 'r', 0, 'd', 1);  revisar('ZN: pico perturbación', max(yd), 0.383, 0.005);

fprintf('8.4  Malla cerrada\n');
d = [0.1 0.8 1.7 1];  revisar('Kcr (0.1,0.8,1.7,1)', d(2)*d(3)/d(1) - d(4), 12.6, 1e-12);
revisar('Pcr', 2*pi/sqrt(17), 1.5239, 1e-4);
d = [6 11 6 1];  Kcr = d(2)*d(3)/d(1) - d(4);  revisar('Kcr (3s+1)(2s+1)(s+1)', Kcr, 10, 1e-12);
r = roots([d(1:3) d(4) + Kcr]);  revisar('raíces en +-j', max(abs(imag(r))), 1, 1e-9);
[Kc, Ti, Td] = reglasPID('ZNcr', 'PID', 10, 2*pi);
[~, yy] = simularPID(tf(1, d), Kc, Ti, Td, 'tf', 120, 'dt', 0.002, 'N', 10);
revisar('ZN: OS (%)', 100*(max(yy) - 1), 46.5, 0.3);
e = yy - 1;  pk = find(e(2:end-1) > e(1:end-2) & e(2:end-1) >= e(3:end) & e(2:end-1) > 1e-4);
revisar('ZN: relación de decaimiento', e(pk(2)+1)/e(pk(1)+1), 0.168, 0.005);
[Kc, Ti, Td] = reglasPID('TL', 'PID', 10, 2*pi);  revisar('TL Ti', Ti, 13.823, 1e-3);
[~, yy] = simularPID(tf(1, d), Kc, Ti, Td, 'tf', 120, 'dt', 0.002, 'N', 10);
revisar('TL: OS (%)', 100*(max(yy) - 1), 9.0, 0.3);
[Kc, Ti] = reglasPID('ZNcr', 'PI', 10, 2*pi);  revisar('ZN PI: Ti = Pcr/1.2', Ti, 5.236, 1e-3);
d = [8 14 7 1];  revisar('ejercicio: Kcr', d(2)*d(3)/d(1) - d(4), 11.25, 1e-12);
revisar('ejercicio: Pcr', 2*pi/sqrt(7/8), 6.717, 1e-3);

fprintf('8.5  Síntesis directa\n');
for lam = [1 3 5]
    [tt, yy] = simularPID(3/((2*s + 1)*(10*s + 1)), 4/lam, 12, 20/12, 'tf', 40, 'dt', 1e-3, 'N', 10);
    k = find(abs(yy - 1) > 0.02, 1, 'last');  revisar(sprintf('lambda=%d: ts (~4 lambda)', lam), tt(k+1), [3.90 12.05 19.76]*([1 3 5]' == lam), 0.05);
end
revisar('fase no mínima lambda=5: Kc', 18/19, 0.9474, 1e-4);
revisar('fase no mínima lambda=5: tau_f', 25/19, 1.3158, 1e-4);
revisar('Ti Td = 45 (coef. s^2)', 18*2.5, 45, 1e-12);

fprintf('8.6  IMC\n');
lmin = max(roots([20 33 -45]));  revisar('Bequette: lambda mínimo', lmin, 0.8869, 1e-4);
for lam = [0.85 1.5]
    p = roots([8*lam, 10*lam - 7.5, 2*lam + 6, 1.5]);
    revisar(sprintf('lambda=%.2f: max Re(polo)', lam), sign(max(real(p))), (lam < lmin)*2 - 1, 0);
end
q1 = (15*s + 1)*(3*s + 1)/((1 - 9*s)*(5*s + 1));  tt = 0:0.01:60;  u1 = step(q1, tt);
revisar('Q1: |u|>50 en t', tt(find(abs(u1) > 50, 1)), 27.95, 0.02);
for k = 1:3
    lam = [3.2 6.7 10];  lam = lam(k);
    Kc = 22/(1.2*(lam + 2));  [~, yy] = simularPID(1.2/(20*s + 1), Kc, 22, 80/44, 'tf', 150, 'dt', 0.005, 'L', 4, 'N', 10);
    revisar(sprintf('IMC-PID lambda=%.1f: OS (%%)', lam), 100*max(max(yy) - 1, 0), [16.1 0 0]*([1 2 3]' == k), 0.2);
end
lam = 1;  tu = 1;  revisar('inestable: Kc', -(lam + 2*tu)/lam, -3, 1e-12);
revisar('inestable: Ti', lam*(lam + 2*tu)/tu, 3, 1e-12);
T = feedback(-3*(1 + 1/(3*s))/(1 - s), 1);  revisar('inestable: polos en -1/lambda', max(real(pole(T))), -1, 1e-5);

fprintf('8.7  Robustez\n');
v = linspace(-1, 1, 5);  P = [5 8 2; 5.7639 9.0959 1.4035; 2.2917 22 1.8182];  esp = [98 90 125];
for k = 1:3
    m = 0;
    for a = v, for b = v, for c = v
        m = m + estableRetardo(P(k,:), 1.2*(1 + 0.3*a), 20*(1 + 0.3*b), 4*(1 + 0.5*c));
    end, end, end
    revisar(sprintf('malla: estables con sintonía %d', k), m, esp(k), 0);
end

fprintf('\n%d de %d pruebas correctas.\n', n - fallas, n);
end

function y = fopdtOrden2(t)
% Respuesta escalón exacta de e^{-2s}/((8s+1)(2s+1)).
tt = max(t - 2, 0);  y = 1 - (8*exp(-tt/8) - 2*exp(-tt/2))/6;
end

function Lw = lazoRetardo(p, Kp, tau, L, w)
jw = 1j*w;
Lw = p(1)*(1 + 1./(p(2)*jw) + p(3)*jw./(p(3)/10*jw + 1)).*Kp./(tau*jw + 1).*exp(-jw*L);
end

function [MG, MF] = margenesRetardo(p, Kp, tau, L)
w = logspace(-3, 1, 40000);  Lw = lazoRetardo(p, Kp, tau, L, w);
ph = unwrap(angle(Lw));  ic = find(diff(sign(abs(Lw) - 1)), 1);  MF = 180 + ph(ic)*180/pi;
ip = find(diff(sign(ph + pi)), 1);  MG = 1/abs(Lw(ip));
end

function ok = estableRetardo(p, Kp, tau, L)
w = logspace(-3, 1.5, 60000);  Lw = lazoRetardo(p, Kp, tau, L, w);  ph = unwrap(angle(Lw));  ok = true;
for k = 0:19
    i = find(diff(sign(ph + pi + 2*pi*k)));
    if any(abs(Lw(i)) >= 1), ok = false; return; end
end
end
