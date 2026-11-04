function S = stepinfo(T)
% Shim de pruebas (Octave): sobrepico, tiempos de pico, de establecimiento (2 %)
% y de subida (10-90 %), como el stepinfo de MATLAB.
t = linspace(0, 60, 60001); y = step(T, t); y = y(:); yf = y(end);
[ym, i] = max(y); S.Overshoot = max(0, 100*(ym - yf)/abs(yf)); S.PeakTime = t(i);
k = find(abs(y - yf) > 0.02*abs(yf), 1, 'last'); S.SettlingTime = t(min(k+1, end));
S.RiseTime = t(find(y >= 0.9*yf, 1)) - t(find(y >= 0.1*yf, 1));
end
