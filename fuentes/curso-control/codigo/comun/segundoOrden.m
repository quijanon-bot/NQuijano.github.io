function F = segundoOrden(zeta, wn)
% SEGUNDOORDEN  Características del escalón de wn^2/(s^2 + 2 zeta wn s + wn^2)
% según las fórmulas de las notas (sección 3.5). Para 0 < zeta < 1:
%   F.wd      frecuencia amortiguada  wn sqrt(1 - zeta^2)
%   F.beta    ángulo del polo (rad)   acos(zeta)
%   F.OS      sobrepico (%)           100 exp(-zeta pi / sqrt(1 - zeta^2))
%   F.tp      tiempo de pico          pi/wd
%   F.ts      establecimiento 2 %     4/(zeta wn)     (F.ts5: 3/(zeta wn))
%   F.tr0100  subida 0-100 %          (pi - beta)/wd
%   F.tr1090  subida 10-90 % (aprox.) (2.3 zeta^2 - 0.078 zeta + 1.12)/wn
%   F.polos   -zeta wn ± j wd
F.zeta = zeta;  F.wn = wn;
F.wd   = wn*sqrt(1 - zeta^2);
F.beta = acos(zeta);
F.OS   = 100*exp(-zeta*pi/sqrt(1 - zeta^2));
F.tp   = pi/F.wd;
F.ts   = 4/(zeta*wn);
F.ts5  = 3/(zeta*wn);
F.tr0100 = (pi - F.beta)/F.wd;
F.tr1090 = (2.3*zeta^2 - 0.078*zeta + 1.12)/wn;
F.polos = -zeta*wn + [1; -1]*1j*F.wd;
end
