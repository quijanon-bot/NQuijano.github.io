function verificarCap05()
% VERIFICARCAP05  Pruebas automáticas de los números del capítulo 5.
%   >> verificarCap05
% (Los mismos números se verificaron con sympy y python-control en
%  herramientas/cap05_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'));
fallas = 0;  n = 0;
    function revisar(nombre, valor, esperado, tol)
        n = n + 1;
        if abs(valor - esperado) <= tol
            fprintf('  ok   %-42s %12.4f\n', nombre, valor);
        else
            fprintf(2, '  FALLA %-41s %12.4f  (esperado %g +- %g)\n', nombre, valor, esperado, tol);
            fallas = fallas + 1;
        end
    end
nInestables = @(p) sum(real(roots(p)) > 1e-9);
esHurwitz = @(p) all(real(roots(p)) < 0);

fprintf('5.3  Routh\n');
[~, c] = tablaRouth([1 2 3 4 5]);   revisar('s^4+2s^3+3s^2+4s+5: cambios', c, 2, 0);
revisar('   raíces inestables', nInestables([1 2 3 4 5]), 2, 0);
revisar('   parte real', max(real(roots([1 2 3 4 5]))), 0.2878, 1e-4);
[~, c] = tablaRouth([1 1 2 8]);     revisar('s^3+s^2+2s+8: cambios', c, 2, 0);
[~, c] = tablaRouth([1 2 3 4]);     revisar('s^3+2s^2+3s+4: cambios', c, 0, 0);

fprintf('5.4  Casos especiales\n');
[~, c] = tablaRouth([1 2 4 8 10 6]);   revisar('caso 1: cambios', c, 2, 0);
revisar('   raíces inestables', nInestables([1 2 4 8 10 6]), 2, 0);
[T, c] = tablaRouth([1 7 6 42 8 56]);  revisar('caso 2: cambios', c, 0, 0);
revisar('   fila s^3 = [28 84]', T(3, 2), 84, 1e-9);
revisar('   fila s^1', T(5, 1), 28/3, 1e-9);
revisar('   |raíz| mayor en el eje', max(abs(imag(roots([1 7 6 42 8 56])))), 2, 1e-6);
[~, c] = tablaRouth([1 0 0 0 4]);      revisar('s^4+4: cambios', c, 2, 0);
[~, c] = tablaRouth([1 2 1 2]);        revisar('s^3+2s^2+s+2: cambios', c, 0, 0);

fprintf('5.5  Diseño\n');
Kcr = (420*43/900 - 1)/0.8;            revisar('Kcr (tres primer orden)', Kcr, 23.8333, 1e-4);
revisar('wcr', sqrt((1 + 0.8*Kcr)/420), 0.21858, 1e-5);
revisar('margin GM = Kcr', margin(tf(0.8, [900 420 43 1])), Kcr, 1e-3);
revisar('Kmax planta inestable', -8 + 2*sqrt(33), 3.4891, 1e-4);
revisar('K = 3.2 estable', esHurwitz([1 4 3 3.2-2 2*3.2-6]), 1, 0);
revisar('K = 3.6 inestable', esHurwitz([1 4 3 3.6-2 2*3.6-6]), 0, 0);
revisar('PI frontera Kc=5', (1 + 5)*(9 - 5)/8, 3, 1e-12);
revisar('PI (5,1) estable', esHurwitz([1 4 5 12 2]), 1, 0);
revisar('PI (5,4) inestable', esHurwitz([1 4 5 12 8]), 0, 0);
revisar('PI w frontera', sqrt(2*3/((9 - 5)/2)), 1.7321, 1e-4);
revisar('   Kc = 10/3: polo en -0.05', max(real(roots([900 420 43 1+0.8*10/3]))), -0.05, 1e-6);
revisar('   Kc = 17/64: polo en -0.05', max(real(roots([900 420 43 1+0.8*17/64]))), -0.05, 1e-6);

fprintf('5.6  Tiempo muerto (Padé)\n');
ck = @(n, k) factorial(2*n-k)*factorial(n)/(factorial(2*n)*factorial(k)*factorial(n-k));
revisar('Padé 2: c2 = 1/12', ck(2, 2), 1/12, 1e-12);
revisar('Padé 1, T=1: K < 1+2/T', 1 + 2/1, 3, 0);
T = 1;  d2 = [ck(2,2)*T^2 ck(2,1)*T 1];  n2 = [ck(2,2)*T^2 -ck(2,1)*T 1];
Ks = linspace(2, 2.5, 50001);
ok = arrayfun(@(K) all(real(roots(conv([1 1], d2) + K*[0 n2])) < 0), Ks);
revisar('Padé 2, T=1: Kmax', Ks(find(ok, 1, 'last')), 2.2915, 1e-3);
w = fzero(@(w) w*T + atan(w) - pi, [0.1 3]);
revisar('exacto T=1: w', w, 2.0288, 1e-4);
revisar('exacto T=1: Kmax', sqrt(1 + w^2), 2.2618, 1e-4);
w = fzero(@(w) w*1 + atan(w/2) - pi, [0.1 3]);
revisar('(s+2), T=1: Kmax exacto', sqrt(4 + w^2), 3.0396, 1e-4);
revisar('(s+2), K=2.5: Tmax exacto', (pi - atan(1.5/2))/1.5, 1.6654, 1e-4);

fprintf('5.7  Espacio de estado\n');
revisar('eig A (máx)', max(real(eig([0 1 0; 0 0 1; -6 -11 -6]))), -1, 1e-9);
Au = [0 1 0; 0 0 1; 2 1 -2];
revisar('modo escondido: max eig', max(real(eig(Au))), 1, 1e-9);
G = minreal(tf(ss(Au, [0; 0; 1], [-1 0 1], 0)));
revisar('   orden de la FT', numel(pole(G)), 1, 0);
revisar('   polo de la FT', pole(G), -2, 1e-6);
revisar('péndulo arriba', max(eig([0 1; 9.81 -0.5])), 2.8921, 1e-4);

fprintf('5.8  Kharitonov\n');
P = kharitonov([1 4 3 1], [2 5 4 2]);
revisar('pausa: 4 polinomios Hurwitz', sum(arrayfun(@(k) esHurwitz(P(k, :)), 1:4)), 4, 0);
revisar('K1 = a0- + a1- s + a2+ s^2 + a3+ s^3', P(1, 1)*1000 + P(1, 2)*100 + P(1, 3)*10 + P(1, 4), 2531, 0);
P = kharitonov([1 6 16 30 35 26], [1.1 6.4 18.6 44.4 61 50]);
revisar('ejemplo 1: polinomios Hurwitz', sum(arrayfun(@(k) esHurwitz(P(k, :)), 1:4)), 1, 0);
c = conv([1 2 2], [1 4 6 20]) + [0 0 0 0 5 10];
revisar('   vértice (1,4,6,20,5) inestable', esHurwitz(c), 0, 0);
P = kharitonov([1 7 106 100+251], [2 15 247 120+251]);   % = Kharitonov(caja)
revisar('diseño K=251: el cuarto, en el borde', max(real(roots(P(4, :)))), 0, 1e-6);
P = kharitonov([1 7 106 100+300], [2 15 247 120+300]);
revisar('diseño K=300: alguno falla', sum(arrayfun(@(k) esHurwitz(P(k, :)), 1:4)), 3, 0);
[r1, r2, r3] = ndgrid(linspace(6, 7, 6), linspace(100, 120, 6), linspace(1, 2, 11));
revisar('diseño: K real máximo', min(r1(:).*r2(:).*r3(:) + r1(:).^2 + r1(:)./r3(:)), 642, 1e-9);
revisar('   K=641 en el peor vértice', esHurwitz([1 7 106 100+641]), 1, 0);
revisar('   K=643 en el peor vértice', esHurwitz([1 7 106 100+643]), 0, 0);

fprintf('\n%d de %d pruebas correctas.\n', n - fallas, n);
end
