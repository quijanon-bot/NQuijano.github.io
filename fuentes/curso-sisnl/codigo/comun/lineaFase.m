function eq = lineaFase(ax, f, xr, varargin)
% LINEAFASE  Línea de fase del sistema escalar  x' = f(x)  (capítulos 2 y 6).
%   eq = lineaFase(ax, f, [a b])  grafica f(x) en [a,b], marca los equilibrios y
%   dibuja sobre el eje el sentido del flujo. Devuelve eq.x (equilibrios) y
%   eq.tipo (celda con 'estable', 'inestable' o 'semiestable').
%   Opciones (pares nombre-valor):
%     'Equilibrios'  vector con los equilibrios, si se conocen. Si se omite, se
%                    buscan como cambios de signo de f (no encuentra ceros donde f
%                    no cambia de signo, como el de x^2: páselos aquí).
%     'N'            puntos de la malla (2001).    'Color'  color de f(x).
%   Convención (la misma de las notas y de la página web):
%     círculo lleno = estable, vacío = inestable, gris = semiestable;
%     triángulos = sentido del flujo.
%   El tipo se decide por el SIGNO de f a cada lado del equilibrio, no por
%   f'(x*): así también clasifica los equilibrios no hiperbólicos (f'(x*) = 0).
%   Compatible con MATLAB y GNU Octave.
p = struct('Equilibrios', [], 'N', 2001, 'Color', [30 90 168]/255);
for k = 1:2:numel(varargin), p.(varargin{k}) = varargin{k+1}; end
x = linspace(xr(1), xr(2), p.N);
y = arrayfun(f, x);
plot(ax, x, y, 'Color', p.Color, 'LineWidth', 2); hold(ax, 'on');
plot(ax, xr, [0 0], 'k-', 'LineWidth', 0.6);
if isempty(p.Equilibrios)
    xe = [];
    for k = 1:numel(x) - 1
        if y(k) == 0
            xe(end+1) = x(k);                                   %#ok<AGROW>
        elseif sign(y(k))*sign(y(k+1)) < 0
            xe(end+1) = fzero(f, [x(k) x(k+1)]);                %#ok<AGROW>
        end
    end
    tol = 1e-12*max(1, max(abs(y)));
    if abs(y(1)) < tol, xe(end+1) = x(1); end
    if abs(y(end)) < tol, xe(end+1) = x(end); end
else
    xe = p.Equilibrios(:).';
end
xe = unique(round(xe*1e10)/1e10);
h = 1e-4*(xr(2) - xr(1));
tipo = cell(size(xe));
for k = 1:numel(xe)
    fl = f(xe(k) - h);  fr = f(xe(k) + h);
    if fl > 0 && fr < 0,     tipo{k} = 'estable';
    elseif fl < 0 && fr > 0, tipo{k} = 'inestable';
    else,                    tipo{k} = 'semiestable';
    end
end
bordes = unique([xr(1), xe, xr(2)]);
azul = [30 90 168]/255;  dy = 0.04*(max(y) - min(y) + eps);
for k = 1:numel(bordes) - 1
    xm = 0.5*(bordes(k) + bordes(k+1));
    if f(xm) > 0, m = '>'; elseif f(xm) < 0, m = '<'; else, continue; end
    plot(ax, xm, 0, m, 'MarkerSize', 7, 'MarkerFaceColor', azul, 'MarkerEdgeColor', azul);
end
for k = 1:numel(xe)
    switch tipo{k}
        case 'estable',   cara = [20 33 61]/255;
        case 'inestable', cara = [1 1 1];
        otherwise,        cara = [0.6 0.6 0.6];
    end
    plot(ax, xe(k), 0, 'o', 'MarkerSize', 8, 'MarkerEdgeColor', [20 33 61]/255, ...
         'MarkerFaceColor', cara, 'LineWidth', 1.2);
end
xlim(ax, xr); ylim(ax, [min(y) - dy, max(y) + dy]); grid(ax, 'on'); hold(ax, 'off');
eq.x = xe;  eq.tipo = tipo;
end
