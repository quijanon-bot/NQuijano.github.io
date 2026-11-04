%% INICIARCURSO  Prepara MATLAB para los códigos del curso Sistemas No Lineales.
% Ejecútelo UNA vez por sesión (o agréguelo a su startup.m):
%     >> run('ruta/al/repositorio/codigo/iniciarCurso.m')
% Agrega al path la carpeta comun/ y todas las carpetas de los capítulos,
% de modo que cualquier script se puede correr desde cualquier carpeta.
% Los scripts C*_Ej* no requieren toolboxes; los crearModelo_*.m requieren
% Simulink.
raizCurso = fileparts(mfilename('fullpath'));
addpath(genpath(raizCurso));
fprintf('Sistemas No Lineales: códigos listos (%s)\n', raizCurso);
clear raizCurso
