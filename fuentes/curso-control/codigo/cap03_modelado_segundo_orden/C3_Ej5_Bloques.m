%% C3_Ej5_Bloques -- Notas: sección 3.6 (álgebra de bloques)
% QUÉ HACE   Reduce diagramas con series, parallel y feedback; verifica la
%            equivalencia con el lazo abierto G_OL y resuelve el sistema
%            multilazo de los problemas.
% OBSERVE    feedback(G,H) supone retroalimentación NEGATIVA; para positiva,
%            feedback(G,H,+1). minreal cancela polos y ceros repetidos.
% ESPERADO   multilazo: T(s) = 10/(s^3 + 6s^2 + 11s + 11)
% EXPLORE    Construya G_OL para G = 1/(s(s+1)), H = 1/(0.1s+1) y verifique
%            que feedback(G_OL,1) y feedback(G,H) coinciden.
clear; clc;

% [ini:algebra]
s  = tf('s');
G1 = 1/(s + 1);  G2 = 2/s;  G3 = 5/(s + 3);  H1 = 1;  H2 = 0.5;
interno = feedback(G2, H1);               % lazo interno: 2/(s+2)
directo = series(series(G1, interno), G3);
T = minreal(feedback(directo, H2))        % -> 10/(s^3+6s^2+11s+11)
pole(T)                                   % raíces de la ecuación característica
parallel(G1, G3)                          % G1 + G3 (bloques en paralelo)
% [fin:algebra]

% [ini:equivalente]
G = 1/(s*(s + 1));  H = 1/(0.1*s + 1);
Gol = minreal(G/(1 + G*H - G));           % lazo abierto equivalente
dif = minreal(feedback(Gol, 1) - feedback(G, H));
fprintf('diferencia entre los dos lazos cerrados: %g\n', norm(dif, inf));
% [fin:equivalente]
