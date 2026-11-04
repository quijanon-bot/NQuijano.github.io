function V = energiaAguaSL(u, Q, r, vm)
% ENERGIAAGUASL  V = V1 + V2 para Simulink: u = [v (3); q (3); c (3)].
%   La usa el bloque "Interpreted MATLAB Function" de crearModelo_Agua.m.
[V1, V2] = energiaAgua(u(1:6).', u(7:9), Q, r, vm);
V = V1 + V2;
end
