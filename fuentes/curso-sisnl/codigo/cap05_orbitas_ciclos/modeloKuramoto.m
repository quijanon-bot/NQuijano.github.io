function dth = modeloKuramoto(~, th, w, K)
% MODELOKURAMOTO  Osciladores de Kuramoto con acoplamiento global.
%   dth_i = w_i + (K/N) sum_j sin(th_j - th_i) = w_i + K r sin(Psi - th_i),
%   con r e^{j Psi} = (1/N) sum_j e^{j th_j} (parámetro de orden).
%   La segunda forma cuesta O(N) en lugar de O(N^2).
z   = mean(exp(1j*th));
dth = w(:) + K*abs(z)*sin(angle(z) - th(:));
end
