function v = abrirVideo(nombre, fps)
% ABRIRVIDEO  VideoWriter compatible con el sistema operativo.
%   En Windows y macOS genera .mp4 (MPEG-4). En Linux MATLAB no soporta
%   MPEG-4, así que usa 'Motion JPEG AVI' (.avi).
%   Los videos se guardan en la carpeta "videos" junto al script que llama.
if nargin < 2, fps = 30; end
if ispc || ismac
    v = VideoWriter(nombre, 'MPEG-4');
else
    v = VideoWriter(nombre, 'Motion JPEG AVI');
end
v.Quality = 95;
v.FrameRate = fps;
open(v);
fprintf('Grabando %s ... (no cierre ni mueva la figura)\n', v.Filename);
end
