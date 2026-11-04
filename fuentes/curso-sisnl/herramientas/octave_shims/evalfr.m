function r = evalfr(G, s)
% Shim de pruebas (Octave): evalúa una FT SISO en s.
[n, d] = tfdata(tf(G), 'v');
r = polyval(n, s)./polyval(d, s);
end
