function zeta = zetaDeOS(OS)
% ZETADEOS  Factor de amortiguamiento para un sobrepico %OS dado EN FRACCIÓN
% (0.2 = 20 %).   zeta = -ln(OS)/sqrt(pi^2 + ln(OS)^2)
zeta = -log(OS)./sqrt(pi^2 + log(OS).^2);
end
