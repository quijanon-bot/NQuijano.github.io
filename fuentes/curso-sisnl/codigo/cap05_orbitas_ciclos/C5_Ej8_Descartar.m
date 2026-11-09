%% C5_Ej8_Descartar -- Notas: sección 5.8 (cómo descartar órbitas cerradas)
% QUÉ HACE   Tres certificados de "no hay órbitas cerradas": (1) el sistema
%            gradiente x' = -grad V con V = -x1 sin(x2); (2) la función
%            V = x1^2 + 4 x2^2 para x1' = -x1 + 4 x2, x2' = -x1 - x2^3; (3) la
%            divergencia de Duffing con fricción (Bendixson) y la de
%            Lotka-Volterra con competencia multiplicada por 1/(v p) (Dulac).
% OBSERVE    Cada certificado se verifica con una cuenta, sin simular. La
%            simulación solo ilustra.
% ESPERADO   (1) error entre f y -grad V: 0.  (2) max de V' en una malla sin el
%            origen: < 0, con V' = -2 x1^2 - 8 x2^4.  (3) div Duffing = -delta;
%            div Dulac de LV con competencia = -e/p - f/v < 0.
% EXPLORE    Para x1' = x2, x2' = -x1 + x2 - x2^3, ¿qué dice Bendixson en el disco
%            de radio 1/2? ¿Y en el plano? ¿Hay ciclo límite?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:gradiente]
[x1, x2] = meshgrid(linspace(-3, 3, 201));
f1 = sin(x2);  f2 = x1.*cos(x2);               % el campo
gV1 = -sin(x2);  gV2 = -x1.*cos(x2);           % gradiente de V = -x1 sin(x2)
fprintf('(1) max |f + grad V| = %g\n', max(abs([f1(:) + gV1(:); f2(:) + gV2(:)])));
% [fin:gradiente]

% [ini:lyapunov]
Vd = 2*x1.*(-x1 + 4*x2) + 8*x2.*(-x1 - x2.^3);
Vd(x1 == 0 & x2 == 0) = -1;
fprintf('(2) max de V'' fuera del origen = %.3e;  max |V'' - (-2 x1^2 - 8 x2^4)| = %g\n', ...
        max(Vd(:)), max(max(abs(Vd - (-2*x1.^2 - 8*x2.^4)).*(Vd ~= -1))));
% [fin:lyapunov]

% [ini:bendixson]
delta = 0.2;  h = 1e-6;
% f = (x2, x1 - x1^3 - delta x2):  div f = d f1/d x1 + d f2/d x2 = 0 + (-delta)
f2 = @(x) x(1) - x(1)^3 - delta*x(2);
divDuffing = @(x) 0 + (f2(x + [0 h]) - f2(x - [0 h]))/(2*h);
fprintf('(3) div Duffing en (0.7, -1.2) = %.6f  (= -delta)\n', divDuffing([0.7 -1.2]));
a = 1; b = 1; c = 0.5; d = 1; e = 0.5; ff = 0.2;  v = 0.8; p = 1.3;
g1 = @(v, p) (a - e*v - b*p)/p;  g2 = @(v, p) (-c + d*v - ff*p)/v;   % f/(v p)
divD = (g1(v + h, p) - g1(v - h, p))/(2*h) + (g2(v, p + h) - g2(v, p - h))/(2*h);
fprintf('    div(f/(v p)) en (0.8, 1.3) = %.6f;  -e/p - f/v = %.6f\n', divD, -e/p - ff/v);
% [fin:bendixson]
