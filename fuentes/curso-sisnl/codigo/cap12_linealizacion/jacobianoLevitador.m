function [A, B] = jacobianoLevitador(yb, P)
% JACOBIANOLEVITADOR  Linealización jacobiana del levitador en el equilibrio y = yb.
D = P.L1*(P.a + yb) + P.L0*P.a;
A = [ 0,                1,          0;
      2*P.g/(P.a + yb), -P.k/P.m,  -sqrt(2*P.g*P.a*P.L0/P.m)/(P.a + yb);
      0,  sqrt(2*P.g*P.m*P.a*P.L0)/D,  -P.R*(P.a + yb)/D ];
B = [0; 0; (P.a + yb)/D];
end
