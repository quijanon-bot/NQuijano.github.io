%% C3_Ej6_Mason -- Notas: sección 3.8 (ley de Mason)
% QUÉ HACE   Verifica la ley de Mason sobre el grafo de cuatro lazos de las
%            notas: escribe una ecuación por nodo y la resuelve con el
%            Symbolic Math Toolbox, y compara con P1 D1 + P2 D2 sobre D.
% OBSERVE    Mason es solo una manera ordenada de resolver un sistema lineal
%            de ecuaciones: las dos respuestas deben ser idénticas.
% ESPERADO   diferencia = 0
% EXPLORE    Agregue una rama G10 del nodo 9 al nodo 5 y repita: ¿qué lazos
%            nuevos aparecen?
clear; clc;

% [ini:mason]
syms G1 G2 G3 G4 G5 G6 G7 G8 G9 H1 H2 H3 H4 R
x = sym('x', [1 9]);
ecs = [x(1) == R
       x(2) == G1*x(1) - H1*x(3) - H4*x(5)
       x(3) == G2*x(2)
       x(4) == G3*x(3) - H2*x(5)
       x(5) == G4*x(4)
       x(6) == G5*x(5)
       x(7) == G7*x(3) - H3*x(8)
       x(8) == G8*x(7)
       x(9) == G6*x(6) + G9*x(8)];
sol = solve(ecs, x);
Tdirecta = simplify(sol.x9/R);
% Ley de Mason
L1 = -G2*H1;  L2 = -G2*G3*G4*H4;  L3 = -G4*H2;  L4 = -G8*H3;
D  = 1 - (L1+L2+L3+L4) + (L1*L3 + L1*L4 + L2*L4 + L3*L4) - L1*L3*L4;
P1 = G1*G2*G3*G4*G5*G6;  D1 = 1 - L4;
P2 = G1*G2*G7*G8*G9;     D2 = 1 - L3;
Tmason = (P1*D1 + P2*D2)/D;
simplify(Tdirecta - Tmason)              % -> 0
% [fin:mason]
