function p = polosDeseados(OS, varargin)
% POLOSDESEADOS  Polos dominantes (y, si se pide, uno real adicional) a partir
% de las especificaciones de la respuesta al escalón.
%   p = polosDeseados(OS, 'tp', tp)              OS en fracción (0.1 = 10 %)
%   p = polosDeseados(OS, 'ts', ts)              ts al 2 %
%   p = polosDeseados(OS, 'ts', ts, 'extra', m)  agrega un polo real en m*Re(p)
%   p = polosDeseados(OS, 'tp', tp, 'extra', -1) ... o en una posición fija (m<0 => s=m)
% Ejemplo: polosDeseados(0.1, 'tp', 1, 'extra', 10) -> [-2.30±3.14j, -23.03]
op = struct('tp', [], 'ts', [], 'extra', []);
for k = 1:2:numel(varargin), op.(varargin{k}) = varargin{k+1}; end
zeta = -log(OS)/sqrt(pi^2 + log(OS)^2);
if ~isempty(op.tp), wn = pi/(op.tp*sqrt(1 - zeta^2)); else, wn = 4/(zeta*op.ts); end
p = roots([1 2*zeta*wn wn^2]);
if ~isempty(op.extra)
    if op.extra > 0, p(end+1) = op.extra*real(p(1)); else, p(end+1) = op.extra; end
end
p = p(:);
end
