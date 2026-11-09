%% C5_Ej6_Kuramoto -- Notas: sección 5.6 (el modelo de Kuramoto)
% QUÉ HACE   N = 400 osciladores con frecuencias naturales de una distribución
%            de Lorentz (centro 0, ancho gamma = 0.5), tomadas por cuantiles para
%            que el experimento sea reproducible. Para varios K simula el modelo
%            y mide el parámetro de orden r = |mean(e^{j theta})| en régimen.
% OBSERVE    Para K < Kc = 2 gamma = 1 las fases siguen desordenadas (r ~ 0, solo
%            ruido de tamaño finito). Por encima, r crece como sqrt(1 - Kc/K)
%            (Kuramoto, 1975). Aun con K grande, r < 1: los osciladores más
%            rápidos y más lentos nunca se enganchan.
% ESPERADO   K = 1.5 -> r = 0.58 (teoría 0.5774);  K = 2 -> r = 0.71 (0.7071);
%            K = 3 -> r = 0.82 (0.8165).  K = 0.5 -> r < 0.08.
% EXPLORE    Pruebe K = 1.1: r tarda mucho en llegar a su valor (cerca de Kc todo
%            se vuelve lento). Cambie la distribución por una normal con la misma
%            g(0). ¿Cambia Kc?
%            ¿Cambia la forma de la curva r(K) cerca de Kc?
clear; close all; clc;
if ~exist('estiloFigura', 'file'), addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'comun')); end

% [ini:kuramoto]
N = 400;  gam = 0.5;  i = (1:N).';
w = gam*tan(pi*(i - 0.5)/N - pi/2);            % cuantiles de Lorentz
th0 = 2*pi*mod((1:N).'*0.6180339887, 1);       % fases iniciales repartidas (reproducible)
Ks = [0.5 1.5 2 3];  rK = zeros(size(Ks));
opc = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
for k = 1:numel(Ks)
    [~, TH] = ode45(@(t, th) modeloKuramoto(t, th, w, Ks(k)), [0 100], th0, opc);   % transitorio
    [~, TH] = ode45(@(t, th) modeloKuramoto(t, th, w, Ks(k)), linspace(100, 200, 201), TH(end,:).', opc);
    rK(k) = mean(abs(mean(exp(1j*TH), 2)));
    fprintf('K = %.1f: r = %.3f  (teoría %.4f)\n', Ks(k), rK(k), sqrt(max(0, 1 - 2*gam/Ks(k))));
end
% [fin:kuramoto]

fig = estiloFigura(700, 420);
Kt = linspace(0, 3.2, 400); plot(Kt, sqrt(max(0, 1 - 2*gam./Kt)), 'k'); hold on;
plot(Ks, rK, 'o', 'MarkerSize', 9, 'LineWidth', 2); grid on; xlabel('$K$'); ylabel('$r$');
legend('$\sqrt{1-K_c/K}$', 'simulaci\''on $N=400$', 'Location', 'southeast');
