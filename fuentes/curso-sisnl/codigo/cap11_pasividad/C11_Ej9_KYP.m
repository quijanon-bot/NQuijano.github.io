%% C11_Ej9_KYP -- Notas: sección 11.7 (lema de Kalman-Yakubovich-Popov)
% QUÉ HACE   Verifica las ecuaciones KYP de Khalil (Lema 6.3)
%              P A + A' P = -L' L - eps P,   P B = C' - L' W,   W' W = D + D'
%            en tres ejemplos: el RLC serie s/(s^2+s+1) (PR), (s+3)/((s+1)(s+2))
%            (PR) y (s+1.5)/((s+1)(s+2)) (SPR). Y comprueba la identidad
%              u y - V' = (L x + W u)'(L x + W u)/2 + (eps/2) x' P x.
% OBSERVE    Con D = 0, W = 0 y P B = C' fija una columna de P. En los dos
%            casos PR el término (2,2) de PA + A'P es cero: no hay eps > 0.
% ESPERADO   RLC: P = I, L = [0 sqrt(2)];  (s+3)/..: P = [11 3; 3 1], L = [2 sqrt(3) 0];
%            SPR: P = [6.5 1.5; 1.5 1], eps máximo = 0.8172.
% EXPLORE    Con el último ejemplo, tome eps = 0.9 y explique por qué falla chol.
clear; close all; clc;

% [ini:kyp]
ejemplos = { 'RLC s/(s^2+s+1)',      [0 1; -1 -1], [0; 1], [0 1],   eye(2),         0;
             '(s+3)/((s+1)(s+2))',   [0 1; -2 -3], [0; 1], [3 1],   [11 3; 3 1],    0;
             '(s+1.5)/((s+1)(s+2))', [0 1; -2 -3], [0; 1], [1.5 1], [6.5 1.5; 1.5 1], 0.5 };
for k = 1:size(ejemplos, 1)
    [nombre, A, B, C, P, ep] = ejemplos{k, :};
    M = P*A + A.'*P + ep*P;                     % debe ser -L'L <= 0
    L = sqrt(max(0, -diag(M))).' + 0;           % aquí M resulta diagonal
    if norm(M - diag(diag(M))) > 1e-12, L = chol(-M); end
    fprintf('%-22s eig(P) = %s  |PB - C''| = %.1e  |M + L''L| = %.1e  L = %s\n', nombre, ...
            mat2str(eig(P).', 4), norm(P*B - C.'), norm(M + L.'*L), mat2str(L, 4));
end
% el mayor eps del ejemplo SPR: PA + A'P + eps P <= 0
A = [0 1; -2 -3];  P = [6.5 1.5; 1.5 1];  M0 = P*A + A.'*P;
epsmax = fzero(@(e) max(eig(M0 + e*P)), [0.01 3]);
fprintf('ejemplo SPR: eps máximo = %.4f\n', epsmax);
% [fin:kyp]

% [ini:identidad]
% u y - V' = |L x + W u|^2/2 + (eps/2) x'Px  para x y u al azar (ejemplo SPR, D = 0, W = 0)
C = [1.5 1];  ep = 0.5;  L = chol(-(M0 + ep*P));  B = [0; 1];
x = randn(2, 1);  u = randn;
Vp = x.'*P*(A*x + B*u);                      % V = x'Px/2  ->  V' = x'P(Ax + Bu)
fprintf('u y - V'' = %.6f;   |Lx|^2/2 + (eps/2) x''Px = %.6f\n', u*(C*x) - Vp, ...
        norm(L*x)^2/2 + ep/2*x.'*P*x);
% [fin:identidad]
