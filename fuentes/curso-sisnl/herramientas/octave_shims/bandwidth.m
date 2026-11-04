function wb = bandwidth(T)
g0 = abs(evalfr(T, 0)); wb = fzero(@(w) abs(evalfr(T, 1j*w)) - g0/sqrt(2), [1e-3 1e3]);
end
