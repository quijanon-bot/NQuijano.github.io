%% INICIARCURSO  Prepara MATLAB para los códigos del curso.
% Ejecútelo UNA vez por sesión (o agréguelo a su startup.m):
%     >> run('ruta/al/repositorio/codigo/iniciarCurso.m')
% Agrega al path la carpeta comun/ y todas las carpetas de los capítulos,
% de modo que cualquier script se puede correr desde cualquier carpeta.
raizCurso = fileparts(mfilename('fullpath'));
addpath(genpath(raizCurso));
fprintf('Curso de Control: códigos listos (%s)\n', raizCurso);
v = ver('control');
if isempty(v)
    warning('No se encontró Control System Toolbox: es necesario para casi todos los scripts.');
end
clear raizCurso v
