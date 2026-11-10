%% C7_Ej5_Cuadraticas -- Notas: sección 7.6 (formas cuadráticas)
% QUÉ HACE   (1) Clasifica P(a) = [a 0 1; 0 a 2; 1 2 a] (la forma
%            V = a x1^2 + 2 x1 x3 + a x2^2 + 4 x2 x3 + a x3^2) con los menores
%            principales líderes y con los valores propios.
%            (2) La trampa: P = diag(0, -1) tiene menores líderes Delta1 = Delta2 = 0 >= 0
%            y no es semidefinida positiva.
% OBSERVE    Sylvester (menores líderes) vale para "> 0"; para ">= 0" hay que mirar TODOS
%            los menores principales, o los valores propios.
% ESPERADO   (1) Delta = (a, a^2, a(a^2 - 5)); eig = a, a +- sqrt(5): P > 0 sii a > sqrt(5).
%            (2) menores líderes 0, 0; menores principales 0, -1, 0.
% EXPLORE    Encuentre una P de 3 x 3 con menores líderes > 0, > 0, = 0 que sea indefinida.
clear; close all; clc;

% [ini:sylvester]
Pa = @(a) [a 0 1; 0 a 2; 1 2 a];
for a = [1 sqrt(5) 3]
    P = Pa(a);  D = [P(1,1) det(P(1:2,1:2)) det(P)];
    fprintf('a = %.4f: menores líderes = (%7.3f, %7.3f, %7.3f), eig = (%s)\n', ...
            a, D, num2str(sort(eig(P)).', '%7.3f '));
end
% [fin:sylvester]

% [ini:trampa]
P = diag([0 -1]);
lideres = [P(1,1) det(P)];
principales = [P(1,1) P(2,2) det(P)];
fprintf('P = diag(0,-1): líderes = (%g, %g), todos los principales = (%g, %g, %g), eig = (%g, %g)\n', ...
        lideres, principales, eig(P));
% [fin:trampa]
