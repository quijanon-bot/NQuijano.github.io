function f = faseEn(G, w)
% FASEEN  Fase continua (en grados, sin saltos de 360°) de G(jw).
%   f = faseEn(G, w) usa bode, que "desenrolla" la fase. Útil para buscar
%   la frecuencia donde la fase vale un valor dado con fzero:
%       wd = fzero(@(w) faseEn(G, w) + 131.85, [1 30]);
[~, f] = bode(G, w);
f = squeeze(f).';
end
