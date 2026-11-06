function [t, y, u, v, I] = simularPID(G, Kc, Ti, Td, varargin)
% SIMULARPID  Lazo PID ideal con planta G (tf), retardo, saturación y anti-windup.
%   [t, y, u, v, I] = simularPID(G, Kc, Ti, Td, 'opcion', valor, ...)
%   Ley:  u = Kc*(b r - y) + Kc/Ti * int(e) + Kc*Td*s/(Td s/N + 1) * (c r - y)
%   Opciones (por defecto):
%     'tf' (50) tiempo final   'dt' (0.01) paso   'L' (0) tiempo muerto a la entrada de G
%     'r' (1) escalón de referencia en t=0   'b' (1), 'c' (1) ponderación de la referencia
%     'N' (Inf) filtro derivativo   'umin','umax' (-Inf, Inf) saturación
%     'aw' ('ninguno' | 'back' | 'clamp')   'Tt' constante de back-calculation
%     'd' (0) escalón de perturbación a la entrada de G (desde t=0)
%   Salidas: y salida, u actuador, v controlador antes de saturar, I término integral.
%   Ti = Inf para quitar la acción integral; Td = 0 para quitar la derivativa.
%   Es una simulación sencilla (planta exacta con ZOH, controlador con Euler) pensada
%   para explorar; para el trabajo serio use Simulink (crearModelo_AntiWindup).
p = inputParser;
addParameter(p, 'tf', 50); addParameter(p, 'dt', 0.01); addParameter(p, 'L', 0);
addParameter(p, 'r', 1); addParameter(p, 'b', 1); addParameter(p, 'c', 1); addParameter(p, 'N', Inf);
addParameter(p, 'umin', -Inf); addParameter(p, 'umax', Inf); addParameter(p, 'aw', 'ninguno');
addParameter(p, 'Tt', 1); addParameter(p, 'd', 0);
parse(p, varargin{:}); o = p.Results;
sysd = c2d(ss(G), o.dt, 'zoh');  A = sysd.A; B = sysd.B; C = sysd.C;
n = round(o.tf/o.dt);  t = (0:n)'*o.dt;
x = zeros(size(A, 1), 1);  nL = round(o.L/o.dt);  buf = zeros(1, nL);
y = zeros(n+1, 1); u = y; v = y; I = y;
Ii = 0; Dprev = 0; epdPrev = 0;
if isinf(o.N), a = 0; else, a = Td/o.N; end
for k = 1:n+1
    y(k) = C*x;  e = o.r - y(k);
    P = Kc*(o.b*o.r - y(k));  epd = o.c*o.r - y(k);
    if Td > 0, D = (a*Dprev + Kc*Td*(epd - epdPrev))/(a + o.dt); else, D = 0; end
    vk = P + Ii + D;  uk = min(max(vk, o.umin), o.umax);
    v(k) = vk; u(k) = uk; I(k) = Ii;
    if isfinite(Ti)
        dI = Kc/Ti*e;
        switch o.aw
            case 'back',  dI = dI + (uk - vk)/o.Tt;
            case 'clamp', if uk ~= vk && (vk - uk)*e > 0, dI = 0; end
        end
        Ii = Ii + o.dt*dI;
    end
    Dprev = D; epdPrev = epd;
    uin = uk + o.d;
    if nL > 0, sal = buf(1); buf = [buf(2:end) uin]; uin = sal; end
    x = A*x + B*uin;
end
end
