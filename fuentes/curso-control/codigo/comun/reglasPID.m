function [Kc, Ti, Td] = reglasPID(regla, tipo, a, b, c)
% REGLASPID  Parámetros de un PID ideal Kc(1 + 1/(Ti s) + Td s) por reglas clásicas.
%   Malla abierta (modelo Kp e^{-Ls}/(tau s + 1)):
%     [Kc, Ti, Td] = reglasPID('ZN',    tipo, Kp, L, tau)   tipo: 'P','PI','PID'
%     [Kc, Ti, Td] = reglasPID('CC',    tipo, Kp, L, tau)   tipo: 'P','PI','PD','PID'
%     [Kc, Ti, Td] = reglasPID('ajust', '',   Kp, L, tau)   coeficiente de ajustabilidad
%   Malla cerrada (ganancia y periodo críticos):
%     [Kc, Ti, Td] = reglasPID('ZNcr',  tipo, Kcr, Pcr)     tipo: 'P','PI','PID'
%     [Kc, Ti, Td] = reglasPID('TL',    tipo, Kcr, Pcr)     tipo: 'PI','PID'
%   Ti = Inf significa sin acción integral; Td = 0, sin acción derivativa.
Ti = Inf;  Td = 0;
switch regla
    case 'ZN'
        Kp = a; L = b; tau = c;  k = tau/(Kp*L);
        switch tipo
            case 'P',   Kc = k;
            case 'PI',  Kc = 0.9*k;  Ti = L/0.3;
            case 'PID', Kc = 1.2*k;  Ti = 2*L;  Td = 0.5*L;
        end
    case 'CC'
        Kp = a; L = b; tau = c;  k = tau/(Kp*L);  r = L/tau;
        switch tipo
            case 'P',   Kc = k*(1 + r/3);
            case 'PI',  Kc = k*(0.9 + r/12);  Ti = L*(30 + 3*r)/(9 + 20*r);
            case 'PD',  Kc = k*(1.25 + r/6);  Td = L*(6 - 2*r)/(22 + 3*r);
            case 'PID', Kc = k*(4/3 + r/4);   Ti = L*(32 + 6*r)/(13 + 8*r);  Td = 4*L/(11 + 2*r);
        end
    case 'ajust'
        Kp = a; L = b; tau = c;  r = L/tau;
        if r <= 0.1,      Kc = 5/Kp;           Ti = tau;
        elseif r < 0.2,   Kc = 0.5/(Kp*r);     Ti = tau;
        elseif r <= 0.5,  Kc = 0.5*(1 + 0.5*r)/(Kp*r);  Ti = tau*(1 + 0.5*r);  Td = tau*0.5*r/(0.5*r + 1);
        else,  error('reglasPID:rc', 'r_c = L/tau > 0.5: la tabla no da valores.');
        end
    case 'ZNcr'
        Kcr = a; Pcr = b;
        switch tipo
            case 'P',   Kc = 0.5*Kcr;
            case 'PI',  Kc = 0.45*Kcr;  Ti = Pcr/1.2;
            case 'PID', Kc = 0.6*Kcr;   Ti = Pcr/2;  Td = Pcr/8;
        end
    case 'TL'
        Kcr = a; Pcr = b;
        switch tipo
            case 'PI',  Kc = Kcr/3.2;  Ti = 2.2*Pcr;
            case 'PID', Kc = Kcr/2.2;  Ti = 2.2*Pcr;  Td = Pcr/6.3;
        end
    otherwise
        error('reglasPID:regla', 'Reglas: ZN, CC, ajust, ZNcr, TL.');
end
if ~exist('Kc', 'var'), error('reglasPID:tipo', 'La regla %s no define el tipo %s.', regla, tipo); end
end
