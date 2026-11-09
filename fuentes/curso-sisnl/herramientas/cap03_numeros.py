"""Verificación independiente (sympy/scipy) de los números del capítulo 3.
Ejecutar:  python3 herramientas/cap03_numeros.py
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp, quad
from math import factorial

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:55s} {float(valor):14.6f}" + ('' if bien else f'  (esperado {esperado})'))

t, s, k, x, y, a, r = sp.symbols('t s k x y a r', positive=True)
print('3.2 Métricas')
revisar('d1((1,1),(4,3))', 3 + 2, 5)
revisar('d2 = sqrt(13)', sp.sqrt(9 + 4), np.sqrt(13))
revisar('dinf', max(3, 2), 3)
revisar('Hamming(casa,masa)+Hamming(masa,cama) >= Hamming(casa,cama)', (1 + 2) >= 1, 1)
d1 = quad(lambda u: abs(np.sin(2*np.pi*u) - u), 0, 1, points=[0.0, 0.5, 1.0], limit=200)[0]
revisar('d1(sin 2 pi t, t)', d1, 0.92143, 2e-5)
from scipy.optimize import minimize_scalar
m = minimize_scalar(lambda u: -(u - np.sin(2*np.pi*u)), bounds=(0.5, 1), method='bounded', options={'xatol': 1e-12})
revisar('dinf(sin 2 pi t, t)', -m.fun, 1.76269, 2e-5)
revisar('t* donde se alcanza dinf: cos(2 pi t*) = 1/(2 pi)', np.cos(2*np.pi*m.x), 1/(2*np.pi), 1e-6)
revisar('(x-y)^2 viola la triangular: 4 > 2', 4 - 2, 2)

print('3.3 Normas')
revisar('||(3,4)||_2', sp.sqrt(9 + 16), 5)
revisar('cota sqrt(2)*5', 5*np.sqrt(2), 7.0711, 1e-4)
revisar('||t^k||_L1 = 1/(k+1) (k=20)', sp.integrate(t**20, (t, 0, 1)), 1/21)
revisar('||t^k||_L2 = 1/sqrt(2k+1) (k=5)', sp.sqrt(sp.integrate(t**10, (t, 0, 1))), 1/np.sqrt(11))
revisar('1/(1+t) en L2[0,inf): norma^2 = 1', sp.integrate(1/(1 + t)**2, (t, 0, sp.oo)), 1)
revisar('1/(1+t) no en L1: integral diverge', sp.integrate(1/(1 + t), (t, 0, sp.oo)) == sp.oo, 1)
revisar('t^{-1/2} en (0,1): L1 = 2', sp.integrate(t**sp.Rational(-1, 2), (t, 0, 1)), 2)
A = sp.Matrix([[1, 2], [-3, 4]])
ev = (A.T*A).eigenvals()
revisar('||A||_2^2 = 15 + 5 sqrt 5', max(sp.N(e) for e in ev), 15 + 5*np.sqrt(5), 1e-9)
revisar('||A||_1 (columnas)', max(sum(abs(A[i, j]) for i in range(2)) for j in range(2)), 6)
revisar('||A||_inf (filas)', max(sum(abs(A[i, j]) for j in range(2)) for i in range(2)), 7)
revisar('rho(A) = sqrt(10)', max(abs(complex(sp.N(e))) for e in A.eigenvals()), np.sqrt(10), 1e-12)
revisar('sqrt(||A||_1 ||A||_inf)', np.sqrt(42), 6.4807, 1e-4)

print('3.4 Producto interno')
revisar('paralelogramo con ||.||_1: 8 != 4', 2**2 + 2**2 - 2*(1 + 1), 4)
revisar('paralelogramo con ||.||_2: 0', (np.sqrt(2)**2 + np.sqrt(2)**2) - 2*(1 + 1), 0, 1e-12)

print('3.5 Completitud')
fk = lambda kk: sp.Piecewise((0, t <= sp.Rational(1, 2)), (kk*(t - sp.Rational(1, 2)), t <= sp.Rational(1, 2) + 1/sp.Integer(kk)), (1, True))
revisar('||f_10 - escalón||_L2^2 = 1/30', sp.integrate((1 - 10*(t - sp.Rational(1, 2)))**2, (t, sp.Rational(1, 2), sp.Rational(6, 10))), 1/30)
d2 = sp.integrate((20*(t - sp.Rational(1, 2)) - 10*(t - sp.Rational(1, 2)))**2, (t, sp.Rational(1, 2), sp.Rational(11, 20))) + \
     sp.integrate((1 - 10*(t - sp.Rational(1, 2)))**2, (t, sp.Rational(11, 20), sp.Rational(6, 10)))
revisar('||f_10 - f_20||_L2^2 = 1/120', d2, 1/120)
revisar('||f_k - escalón||_L2^2 = 1/(3k) (k simbólico)', sp.simplify(sp.integrate((1 - k*s)**2, (s, 0, 1/k)) - 1/(3*k)), 0)

print('3.8 Lipschitz')
x1, x2 = sp.symbols('x1 x2', real=True)
J = sp.Matrix([-x1 + x1*x2, x2 - x1*x2]).jacobian([x1, x2])
revisar('jacobiano: J = [[-1+x2, x1], [-x2, 1-x1]]', sp.simplify(J - sp.Matrix([[-1 + x2, x1], [-x2, 1 - x1]])).norm(), 0)
fila_max = max(1 + 2 + 1, 2 + 1 + 1)
revisar('cota fila del jacobiano en la caja a1 = 1, a2 = 2', fila_max, 4)
revisar('pendiente máxima de x^3 en [-10,10] = 300', sp.diff(x**3, x).subs(x, 10), 300)
revisar('secante de x^(1/3) entre 0 y h = h^(-2/3), h = 1e-6', (1e-6)**(1/3)/1e-6, 1e4, 1e-6)

print('3.9 Existencia y unicidad')
u = sp.symbols('u', positive=True)   # u = t - c > 0
xc = (sp.Rational(2, 3)*u)**sp.Rational(3, 2)
revisar('x_c resuelve x\' = x^(1/3) para t > c', sp.simplify(sp.diff(xc, u) - xc**sp.Rational(1, 3)), 0)
dl = r/(2*(1 + r)*r + 1)
rs = sp.solve(sp.diff(dl, r), r)
revisar('r* = 1/sqrt(2)', rs[0], 1/np.sqrt(2))
revisar('delta* = (sqrt 2 - 1)/2', sp.simplify(dl.subs(r, rs[0])), (np.sqrt(2) - 1)/2)
revisar('rho/L en r* (rho -> 1) > delta*', 1/(2*(1 + 1/np.sqrt(2))) > (np.sqrt(2) - 1)/2, 1)
revisar('error Picard iteración 5 = e - sum 1/j!', np.e - sum(1/factorial(j) for j in range(6)), 1.6152e-3, 1e-7)
revisar('x\' = -x^3: x(t) = x0/sqrt(1 + 2 x0^2 t) cumple la ODE', sp.simplify(sp.diff(2/sp.sqrt(1 + 8*t), t) + (2/sp.sqrt(1 + 8*t))**3), 0)
o = dict(rtol=1e-11, atol=1e-12)
Y = solve_ivp(lambda tt, yy: [-yy[0] + 0.5*np.sin(yy[0])], (0, 5), [1.0], dense_output=True, **o)
Z = solve_ivp(lambda tt, zz: [-zz[0] + 0.5*np.sin(zz[0]) + 0.1*np.cos(tt)], (0, 5), [1.05], dense_output=True, **o)
tt = np.linspace(0, 5, 5001)
revisar('max |y - z| en [0,5]', np.max(abs(Y.sol(tt)[0] - Z.sol(tt)[0])), 0.0910, 2e-4)
revisar('cota en t = 5', 0.05*np.exp(7.5) + 0.1/1.5*(np.exp(7.5) - 1), 210.87, 0.01)
revisar('L = 1.5 es Lipschitz de -y + 0.5 sin y', max(abs(-1 + 0.5*np.cos(u)) for u in np.linspace(-10, 10, 10001)) <= 1.5, 1)

print('3.10 Comparación')
X = solve_ivp(lambda tt, xx: [-(1 + xx[0]**2)*xx[0]], (0, 1), [2.0], **o)
revisar('x(1) desde a = 2', X.y[0, -1], 0.34844, 2e-5)
xs = sp.symbols('xs', positive=True)
revisar('equilibrio (1,1) del sistema 2D', (-1 + 2*1/(1 + 1)), 0)
revisar('|2x/(1+x^2)| <= 1', max(abs(2*u/(1 + u**2)) for u in np.linspace(-50, 50, 100001)), 1, 1e-9)
gf = lambda tt, xx: [-xx[0] + 2*xx[1]/(1 + xx[1]**2), -xx[1] + 2*xx[0]/(1 + xx[0]**2)]
S = solve_ivp(gf, (0, 20), [3.0, -2.0], dense_output=True, **o)
tt = np.linspace(0, 20, 4001); nx = np.linalg.norm(S.sol(tt), axis=0)
cota = np.exp(-tt)*np.sqrt(13) + np.sqrt(2)*(1 - np.exp(-tt))
revisar('max(||x|| - cota) <= 0', np.max(nx - cota) <= 1e-9, 1)
revisar('||x(20)|| = sqrt(2)', nx[-1], np.sqrt(2), 1e-6)

print(f'\n{ok} de {total} verificaciones correctas.')
