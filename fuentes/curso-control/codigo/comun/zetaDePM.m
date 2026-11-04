function zeta = zetaDePM(PM)
% ZETADEPM  Inversa de pmDeZeta: factor de amortiguamiento para un PM (grados).
zeta = fzero(@(z) pmDeZeta(z) - PM, [1e-4 10]);   % vale también para zeta > 1
end
