%% C5_Ej11_Nowak -- Notas: sección 5.11 (ciclos límite y lenguaje)
% QUÉ HACE   Dinámica replicador-mutador con tres gramáticas (Mitchener y Nowak,
%            2004): B con 0.88 en la diagonal y 0.2 fuera; Q = circ(0.8 - c, 0.2, c).
%            (1) El símplex atrae: s = sum(x) cumple s' = Fbar (1 - s).
%            (2) Valores propios en x* = (1/3,1/3,1/3) restringidos al símplex.
%            (3) Bifurcación de Hopf en c*.  (4) La frontera repele.
%            (5) Con Q = I y B simétrica, Fbar crece (Fisher): no hay ciclos.
% OBSERVE    Con c = 0.01 el equilibrio es un foco inestable y aparece un ciclo
%            límite; con c = 0.04, un foco estable. El ciclo nace en c* ~ 0.0313.
% ESPERADO   c = 0.01: lambda = 0.0209 +- 0.1075j (y -0.4267 transversal al símplex).
%            c* = 0.031293, período en c*: 65.82.  Ciclo con c = 0.01: x1 entre
%            0.1856 y 0.4781, período ~63.  Frontera: x1' = +0.0567 en (1e-6, 0.5, 0.5).
%            Fisher: |dFbar/dt - 2 sum x_i (F_i - Fbar)^2| < 1e-12.
% EXPLORE    Pase a cinco gramáticas (como el artículo). ¿Por qué con tres nunca
%            podría aparecer caos?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end
B  = 0.2*ones(3) + 0.68*eye(3);
Qc = @(c) [0.8 - c, 0.2, c; c, 0.8 - c, 0.2; 0.2, c, 0.8 - c];
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);

% [ini:simplex]
x = [0.5; 0.4; 0.3];                              % fuera del símplex: suma 1.2
F = B*x;  Fbar = x.'*F;  dx = modeloNowak(0, x, B, Qc(0.01));
fprintf('(1) s'' = %.6f;  Fbar (1 - s) = %.6f\n', sum(dx), Fbar*(1 - sum(x)));
% [fin:simplex]

% [ini:hopf]
xs = ones(3,1)/3;  P = [1 0; 0 1; -1 -1];         % coordenadas (x1, x2) en el símplex
Js = @(c) jacobianoNumerico(@(y) [1 0 0; 0 1 0]*modeloNowak(0, xs + P*y, B, Qc(c)), [0; 0]);
for c = [0.01 0.04]
    fprintf('(2) c = %.2f: valores propios en el símplex %s\n', c, mat2str(eig(Js(c)).', 4));
end
cs = fzero(@(c) max(real(eig(Js(c)))), [0.01 0.04]);
fprintf('(3) Hopf en c* = %.6f, período %.2f\n', cs, 2*pi/max(abs(imag(eig(Js(cs))))));
% [fin:hopf]

% [ini:ciclo]
[t, X] = ode45(@(t, x) modeloNowak(t, x, B, Qc(0.01)), [0 3000], [0.6; 0.3; 0.1], ...
               odeset(opc, 'MaxStep', 1));
k = t > 2000;  x1 = X(k,1);  tk = t(k);
sube = tk([false; x1(1:end-1) < 1/3 & x1(2:end) >= 1/3]);
fprintf('    ciclo (c = 0.01): x1 entre %.4f y %.4f, período %.2f\n', min(x1), max(x1), mean(diff(sube)));
dx = modeloNowak(0, [1e-6; 0.5; 0.5 - 1e-6], B, Qc(0.01));
fprintf('(4) en (1e-6, 0.5, 0.5): x1'' = %+.4f\n', dx(1));
% [fin:ciclo]

% [ini:fisher]
peor = 0;
for k = 1:200
    x = rand(3,1);  x = x/sum(x);  F = B*x;  Fbar = x.'*F;
    xd = x.*(F - Fbar);                            % replicador puro (Q = I)
    peor = max(peor, abs(2*x.'*B*xd - 2*sum(x.*(F - Fbar).^2)));
end
fprintf('(5) Fisher: max |dFbar/dt - 2 sum x_i (F_i - Fbar)^2| = %.1e\n', peor);
% [fin:fisher]

