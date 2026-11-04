%% C11_Ej13_Agua -- Notas: sección 11.10 (distribución de agua con el replicador)
% QUÉ HACE   Tres tanques (Torricelli) alimentados por un caudal total Q que se
%            reparte con la dinámica del replicador (modeloAgua.m). En t = 40 s la
%            demanda del tanque 3 sube de c3 = 1.4 a c3 = 2.0.
% OBSERVE    sum q_i = Q todo el tiempo (el replicador solo redistribuye).
%            V = V1 + V2 (energiaAgua.m), calculada respecto al equilibrio vigente,
%            decrece; salta en t = 40 s y vuelve a decrecer.
% ESPERADO   antes: v* = 4/9 = 0.4444, q* = (0.400, 0.667, 0.933);
%            después: v* = 0.3086, q* = (0.333, 0.556, 1.111).
% EXPLORE    Ponga r = 0.5: ¿converge más lento o más rápido? ¿Por qué?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:equilibrio]
Q = 2;  r = 2;  vm = 2;
c1 = [0.6; 1.0; 1.4];   c2 = [0.6; 1.0; 2.0];
for c = [c1 c2]
    vs = Q^2/sum(c)^2;   qs = c*Q/sum(c);
    fprintf('c = %s:  v* = %.4f   q* = %s   (v* < vm: %d)\n', mat2str(c.', 2), vs, ...
            mat2str(qs.', 3), vs < vm);
end
% [fin:equilibrio]

% [ini:simulacion]
x0  = [0.1; 0.8; 0.3; 0.9; 0.6; 0.5];           % [v; q], con sum q = Q
opc = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t1, X1] = ode45(@(t, x) modeloAgua(x, c1, Q, r, vm), linspace(0, 40, 4001), x0, opc);
[t2, X2] = ode45(@(t, x) modeloAgua(x, c2, Q, r, vm), linspace(40, 80, 4001), ...
        X1(end,:).', opc);
[V1a, V2a] = energiaAgua(X1, c1, Q, r, vm);
[V1b, V2b] = energiaAgua(X2, c2, Q, r, vm);
t = [t1; t2];   X = [X1; X2];   V = [V1a + V2a; V1b + V2b];
fprintf('max |sum q - Q| = %.1e\n', max(abs(sum(X(:,4:6), 2) - Q)));
fprintf('¿V no creciente en cada tramo? %d %d\n', all(diff(V1a + V2a) <= 1e-9), ...
        all(diff(V1b + V2b) <= 1e-9));
fprintf('v(80) = %s   q(80) = %s\n', mat2str(X(end,1:3), 4), mat2str(X(end,4:6), 4));
% [fin:simulacion]

fig = estiloFigura(1100, 420);
subplot(1,3,1); plot(t, X(:,1:3)); grid on; title('vol\''umenes'); xlabel('$t$');
subplot(1,3,2); plot(t, X(:,4:6)); grid on; title('caudales'); xlabel('$t$');
subplot(1,3,3); semilogy(t, V); grid on; title('$V_1+V_2$'); xlabel('$t$');
