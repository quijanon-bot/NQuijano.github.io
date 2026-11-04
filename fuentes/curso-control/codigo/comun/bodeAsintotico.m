function [magdB, fase] = bodeAsintotico(w, Kb, N, quiebres)
% BODEASINTOTICO  Diagrama de Bode asintótico (ganancia, origen, polos y ceros reales).
%   [magdB, fase] = bodeAsintotico(w, Kb, N, quiebres)
%
%   w        vector de frecuencias (rad/s)
%   Kb       ganancia en FORMA DE BODE:
%              G'(s) = Kb * prod(s/wz + 1) / ( s^N * prod(s/wp + 1) )
%   N        número de polos en el origen (negativo = ceros en el origen)
%   quiebres matriz [w_i  orden_i]; orden > 0 cero, orden < 0 polo
%            (2 = cero doble, -2 = polo doble, ...)
%
%   Reglas (notas, sección 10.4): +-20 dB/dec por orden desde w_i; la fase
%   cambia +-45°/dec por orden entre w_i/10 y 10 w_i.
%   No se usa para polos complejos: el curso no dibuja asintóticos de
%   segundo orden (para ellos se usa bode).
%
%   Ejemplo (notas, ejemplo s/(s+10)):
%       w = logspace(-1, 3, 500);
%       [m, f] = bodeAsintotico(w, 0.1, -1, [10 -1]);
%
%   Ver también: bode, faseEn
if nargin < 4 || isempty(quiebres), quiebres = zeros(0, 2); end
w = w(:).';
magdB = 20*log10(abs(Kb)) - 20*N*log10(w);
fase  = -90*N*ones(size(w)) + 180*(Kb < 0);
for i = 1:size(quiebres, 1)
    wb = quiebres(i, 1);  o = quiebres(i, 2);
    magdB = magdB + 20*o*max(0, log10(w/wb));
    fase  = fase  + 45*o*min(2, max(0, log10(w/wb) + 1));
end
end
