%% C4_Ej5_Carbono -- Notas: sección 4.2 (ciclo global del carbono)
% QUÉ HACE   Arma el modelo de cinco reservorios, comprueba que conserva la masa
%            (las columnas de A suman cero) y simula 500 años con 8 GtC/año.
% OBSERVE    A tiene un valor propio en cero: el carbono emitido no desaparece, se
%            redistribuye. Las demás constantes de tiempo van de 4 años a 1700 años.
% ESPERADO   Valores propios -0.2274, -0.0673, -0.0355, -0.000578 y 0; el carbono
%            total crece exactamente 8 GtC/año; la atmósfera pasa de 590 a 1833 GtC.
% EXPLORE    Corte las emisiones en el año 100 y mire cuánto tarda en bajar m_A.
clear; close all; clc;
if ~exist('variablesFase', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:matrices]
kL1 = 0.0842; kL2 = 0.0684; kL3 = 0.0159; kL4 = 0.0332;     % 1/año
kO1 = 0.0846; kO2 = 0.0433; kO3 = 0.0011; kO4 = 0.0001;
A = [-(kO1+kL1)  kL2         kL4   kO2          0
      kL1       -(kL2+kL3)   0     0            0
      0          kL3        -kL4   0            0
      kO1        0           0    -(kO2+kO3)    kO4
      0          0           0     kO3         -kO4];
B = [1; 0; 0; 0; 0];
sum(A)                                      % ceros: conservación de la masa
lambda = eig(A)
tau = -1./lambda(abs(lambda) > 1e-9)        % constantes de tiempo (años)
% [fin:matrices]

% [ini:simulacion]
x0 = [590; 550; 1500; 900; 37000];          % GtC
t = 0:1:500;  uE = 8*ones(size(t));          % GtC/año
[~, ~, x] = lsim(ss(A, B, eye(5), 0), uE, t, x0);
plot(t, x(:,1:4)); grid on; xlabel('años'); ylabel('GtC');
legend('atmósfera', 'vegetación', 'suelo', 'océano superficial');
total = sum(x, 2);  (total(end) - total(1))/500  % 8 GtC/año
x(end, :)
% [fin:simulacion]
