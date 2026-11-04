function verificarCap10()
% VERIFICARCAP10  Pruebas automáticas de los números del capítulo 10.
% Corre los cálculos clave de las notas y verifica cada resultado con una
% tolerancia. Úselo cada vez que MODIFIQUE un código: si algo deja de
% coincidir con las notas, aquí se ve de inmediato.
%   >> verificarCap10
% (Los mismos números se verificaron de forma independiente con
%  python-control en herramientas/cap10_numeros.py.)
raiz = fileparts(mfilename('fullpath'));
addpath(fullfile(raiz, '..', 'comun'), fullfile(raiz, 'Clase4_Compensadores'));
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

fprintf('10.2  Respuesta senoidal\n');
G = 1/(s+10);  g = evalfr(G, 1j);
revisar('|1/(j+10)|', abs(g), 0.0995, 5e-4);
revisar('fase (grados)', rad2deg(angle(g)), -5.71, 0.01);

fprintf('10.5  Ejemplo s/(s+10)\n');
G = s/(s+10);
revisar('dB en w = 10', 20*log10(abs(evalfr(G, 10j))), -3.01, 0.01);
revisar('fase en w = 10', faseEn(G, 10), 45, 0.01);
revisar('dB en w = 1', 20*log10(abs(evalfr(G, 1j))), -20.04, 0.01);

fprintf('10.4  Ejemplo con resonancia\n');
[Gm, Pm] = margin(1000/((s+1)*(s^2+4*s+100)));
revisar('PM (inestable)', mod(Pm + 180, 360) - 180, -45.5, 0.1);   % mod: algunas versiones dan +314.5
revisar('GM dB (inestable)', 20*log10(Gm), -7.5, 0.1);

fprintf('10.7  Márgenes y rango de Kc\n');
[Gm, Pm, Wcg, Wcp] = margin(1e4/((s+1)*(s+10)*(s+100)));
revisar('GM (dB)', 20*log10(Gm), 21.74, 0.01);
revisar('w_GM', Wcg, 33.32, 0.01);
revisar('PM', Pm, 54.90, 0.01);
revisar('w_PM', Wcp, 7.80, 0.01);
[Gm, ~, Wcg] = margin(1000/((s+1)*(s+10)*(s+100)));
revisar('Kcr = 1000*GM', 1000*Gm, 122210, 2);
revisar('Pcr', 2*pi/Wcg, 0.1886, 1e-4);
[~, Pm] = margin(1e4/((s+1)*(s+10)*(s+100))*20/(s+20));
revisar('PM con sensor a = 20', Pm, 36.4, 0.1);

fprintf('10.8  PM -> zeta -> transitorio\n');
[~, Pm, ~, Wcp] = margin(100/(s*(s+10)));
z = zetaDePM(Pm);
revisar('zeta', z, 0.50, 1e-3);
revisar('wn', Wcp/sqrt(-2*z^2 + sqrt(1+4*z^4)), 10, 0.01);
revisar('w_BW', bandwidth(feedback(100/(s*(s+10)), 1)), 12.72, 0.01);
revisar('PM(zeta = 0.707)', pmDeZeta(0.707), 65.5, 0.06);

fprintf('10.10 Ajuste de ganancia\n');
G0 = 1/(s*(s+20)*(s+100));
wd = fzero(@(w) faseEn(G0, w) + 180 - pmDeZeta(zetaDeOS(0.2)), [1 30]);
revisar('w objetivo', wd, 13.56, 0.01);
revisar('Kc', 1/abs(evalfr(G0, 1j*wd)), 33056, 2);

fprintf('10.11 Compensadores\n');
Gp = zpk([], [0 -2], 40);
[~, il] = disenoAdelanto(Gp, 45, 10);
revisar('adelanto alpha', il.alpha, 4.03, 0.01);
revisar('adelanto wM', il.wM, 8.85, 0.01);
revisar('adelanto PM', il.PM, 49.8, 0.1);
[~, ig] = disenoAtraso(Gp, 45, 5);
revisar('atraso wdes', ig.wdes, 1.68, 0.01);
revisar('atraso alpha', ig.alpha, 9.13, 0.01);
revisar('atraso PM', ig.PM, 44.8, 0.1);

fprintf('\n%d de %d verificaciones correctas.\n', n - fallas, n);
if fallas > 0, error('verificarCap10:falla', '%d verificaciones fallaron.', fallas); end
end
