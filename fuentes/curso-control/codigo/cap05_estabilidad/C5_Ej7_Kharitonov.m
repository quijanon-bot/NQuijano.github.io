%% C5_Ej7_Kharitonov -- Notas: sección 5.7 (robustez: teorema de Kharitonov)
% QUÉ HACE   (1) Construye los cuatro polinomios de Kharitonov (función
%            kharitonov de comun/) y los revisa. (2) Contrasta con un muestreo
%            aleatorio de 2000 polinomios. (3) Rango robusto de K en el lazo
%            K/(s^2 + r1 s + r2) con sensor 1/(r3 s + 1).
% OBSERVE    Cuatro verificaciones reemplazan infinitas. Pero si los
%            coeficientes dependen de los mismos parámetros, la "caja" es
%            más grande que la familia real y el resultado es conservador.
% ESPERADO   Familia [1,2]s^3 + [4,5]s^2 + [3,4]s + [1,2]: robustamente estable.
%            Diseño: Kharitonov da -100 < K < 251 (en 251 el cuarto polinomio queda en el borde); la familia real tolera K < 642.
% EXPLORE    Cambie el intervalo de s^1 a [0.5, 4] y repita.
clear; close all; clc;
if ~exist('tablaRouth', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:kharitonov]
bajo = [1 4 3 1];  alto = [2 5 4 2];       % a3 s^3 + a2 s^2 + a1 s + a0
P = kharitonov(bajo, alto)                 % cuatro filas = cuatro polinomios
esHurwitz = @(p) all(real(roots(p)) < 0);
robusto = all(arrayfun(@(k) esHurwitz(P(k, :)), 1:4))
% Muestreo aleatorio: 2000 polinomios de la familia
N = 2000;  peor = -inf;
for k = 1:N
    p = bajo + rand(1, 4).*(alto - bajo);
    peor = max(peor, max(real(roots(p))));
end
peor                                       % < 0, pero no es una PRUEBA
% [fin:kharitonov]

% [ini:diseno]
% (s^2 + r1 s + r2)(r3 s + 1) + K = r3 s^3 + (r1 r3 + 1)s^2 + (r2 r3 + r1)s + (r2 + K)
for K = [200 250 300]
    bajo = [1  7 106 100 + K];  alto = [2 15 247 120 + K];
    P = kharitonov(bajo, alto);
    fprintf('K = %3d: Kharitonov ->', K);  fprintf(' %d', arrayfun(@(k) esHurwitz(P(k, :)), 1:4));  fprintf('\n');
end
% La familia real (r1, r2, r3 entran en varios coeficientes a la vez):
[r1, r2, r3] = ndgrid(linspace(6, 7, 6), linspace(100, 120, 6), linspace(1, 2, 11));
Kreal = min(r1(:).*r2(:).*r3(:) + r1(:).^2 + r1(:)./r3(:))   % 642
% [fin:diseno]
