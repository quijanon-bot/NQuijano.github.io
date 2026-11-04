function PM = pmDeZeta(zeta)
% PMDEZETA  Margen de fase (grados) del lazo w_n^2/(s(s+2 zeta w_n)) con
% retroalimentación unitaria. Notas, ecuación PM(zeta), sección 10.8.
%   PM = atan( 2 zeta / sqrt(-2 zeta^2 + sqrt(1 + 4 zeta^4)) )
%   Valores: zeta = 0.25 -> 28.0°, 0.5 -> 51.8°, 0.707 -> 65.5°.
%   Aproximación útil: PM ~ 100*zeta para zeta < 0.6.
PM = atand(2*zeta ./ sqrt(-2*zeta.^2 + sqrt(1 + 4*zeta.^4)));
end
