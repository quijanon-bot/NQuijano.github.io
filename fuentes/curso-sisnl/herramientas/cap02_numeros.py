"""Verificación independiente (sympy/scipy) de los números del capítulo 2.
Ejecutar:  python3 herramientas/cap02_numeros.py
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp
from scipy.optimize import brentq

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:58s} {float(valor):14.6f}" + ('' if bien else f'  (esperado {esperado})'))

o = dict(rtol=1e-11, atol=1e-13)
t, x, x0 = sp.symbols('t x x_0', real=True)

print('2.2 El flujo de sin x')
xt = 2*sp.atan(sp.tan(x0/2)*sp.exp(t))
revisar('2 atan(tan(x0/2) e^t) resuelve x\' = sin x', sp.simplify(sp.diff(xt, t) - sp.sin(xt)).subs({x0: 0.7, t: 1.3}), 0, 1e-12)
revisar('x(1) desde pi/4', xt.subs({x0: sp.pi/4, t: 1}).evalf(), 1.689145, 1e-6)
revisar('tan(pi/8) = sqrt 2 - 1', sp.tan(sp.pi/8) - (sp.sqrt(2) - 1), 0, 1e-15)
revisar('f\'(k pi) = (-1)^k: f\'(pi) = -1', sp.cos(sp.pi), -1)

print('2.3 No hiperbólicos')
xs = 1/sp.sqrt(1 + 2*t)   # candidata para x0 = 1
revisar('1/sqrt(1 + 2t) resuelve x\' = -x^3', sp.simplify(sp.diff(xs, t) + xs**3), 0)
val = [xs.subs(t, 10)]
revisar('x\' = -x^3: x(10) = 1/sqrt(21)', val[0], 1/np.sqrt(21), 1e-12)
revisar('x\' = x^3: escape en 1/(2 x0^2) con x0 = 1', sp.integrate(1/x**3, (x, 1, sp.oo)), 0.5)
revisar('x\' = x^2: escape en 1/x0 con x0 = 1', sp.integrate(1/x**2, (x, 1, sp.oo)), 1)

print('2.4 Potencial')
V = -sp.integrate(sp.sin(x), (x, 0, x))
revisar('V(x) = cos x - 1 en x = 1', (V - (sp.cos(x) - 1)).subs(x, 1), 0, 1e-15)
revisar('dV/dt = -f^2', sp.simplify(sp.diff(V, x)*sp.sin(x) + sp.sin(x)**2), 0)

print('2.5 Logística con cosecha')
h = sp.symbols('h', positive=True)
raices = sp.solve(x*(1 - x) - h, x)
revisar('h = 0.2: equilibrio bajo', min(r.subs(h, sp.Rational(1, 5)) for r in raices).evalf(), 0.276393, 1e-6)
revisar('h = 0.2: equilibrio alto', max(r.subs(h, sp.Rational(1, 5)) for r in raices).evalf(), 0.723607, 1e-6)
revisar('h_c: discriminante 1 - 4h = 0', sp.solve(1 - 4*h, h)[0], 0.25)
ev = lambda tt, z: z[0]; ev.terminal = True; ev.direction = -1
s1 = solve_ivp(lambda tt, z: [z[0]*(1 - z[0]) - 0.3], (0, 20), [0.5], events=ev, **o)
revisar('h = 0.3 desde 0.5: extinción', s1.t_events[0][0], 5.144128, 1e-5)
a = np.sqrt(0.05)
revisar('fórmula atan(0.5/a)/a', np.arctan(0.5/a)/a, 5.144128, 1e-6)

print('2.6 Diodo túnel')
hd = lambda v: 17.76*v - 103.79*v**2 + 229.62*v**3 - 226.31*v**4 + 83.72*v**5
dhd = lambda v: 17.76 - 2*103.79*v + 3*229.62*v**2 - 4*226.31*v**3 + 5*83.72*v**4
E, R, C = 1.2, 1.5, 2.0
f = lambda v: ((E - v)/R - hd(v))/C
vs = [brentq(f, 0, 0.15), brentq(f, 0.15, 0.5), brentq(f, 0.5, 1.2)]
for k, (ve, le, ie) in enumerate([(0.0626, -3.956, 0.7582), (0.2854, 1.487, 0.6098), (0.8844, -1.770, 0.2104)]):
    revisar(f'v*_{k+1}', vs[k], ve, 1e-4)
    revisar(f'f\'(v*_{k+1})', -(1/R + dhd(vs[k]))/C, le, 1e-3)
    revisar(f'i*_{k+1}', hd(vs[k]), ie, 1e-4)
    revisar(f'tau_{k+1} = 1/|f\'|', 1/abs(-(1/R + dhd(vs[k]))/C), [0.2528, 0.6726, 0.5649][k], 1e-4)
gE = lambda v: v + R*hd(v); dg = lambda v: 1 + R*dhd(v)
revisar('E máximo con tres equilibrios', gE(brentq(dg, 0.05, 0.3)), 1.64326, 1e-5)
revisar('E mínimo con tres equilibrios', gE(brentq(dg, 0.3, 0.7)), 0.65900, 1e-5)
revisar('inestable sii h\'(v*) < -1/R (equilibrio del medio)', dhd(vs[1]) < -1/R and dhd(vs[0]) > -1/R and dhd(vs[2]) > -1/R, 1)

print('2.7 Halcón y paloma')
p, v, c = sp.symbols('p v c', positive=True)
Pio = sp.Matrix([[(v - c)/2, v], [0, v/2]]); q = sp.Matrix([p, 1 - p])
rep = (q[0]*((Pio*q)[0] - (q.T*Pio*q)[0]))
revisar('replicador = (1/2) p(1-p)(v - c p)', sp.simplify(rep - sp.Rational(1, 2)*p*(1 - p)*(v - c*p)).subs({p: 0.3, v: 1, c: 3}), 0, 1e-15)
fp = sp.diff(sp.Rational(1, 2)*p*(1 - p)*(v - c*p), p)
revisar('f\'(v/c) = -(v/2)(1 - v/c)', sp.simplify(fp.subs(p, v/c) + v/2*(1 - v/c)), 0)
revisar('f\'(0) = v/2 (v = 1)', fp.subs({p: 0, v: 1, c: 3}), 0.5)
revisar('f\'(1) = (c - v)/2 (v = 1, c = 3)', fp.subs({p: 1, v: 1, c: 3}), 1)
s2 = solve_ivp(lambda tt, z: [0.5*z[0]*(1 - z[0])*(1 - 3*z[0])], (0, 40), [0.01], **o)
revisar('v = 1, c = 3: p1(40) desde 0.01', s2.y[0, -1], 1/3, 1e-4)

print('2.8 Unicidad')
revisar('x_c resuelve x\' = x^(1/3) (t > c)', sp.simplify(sp.diff((sp.Rational(2, 3)*t)**sp.Rational(3, 2), t) - ((sp.Rational(2, 3)*t)**sp.Rational(3, 2))**sp.Rational(1, 3)).subs(t, 2), 0, 1e-12)
revisar('x_0(3) = 2^(3/2)', (sp.Rational(2, 3)*3)**sp.Rational(3, 2), 2*np.sqrt(2), 1e-12)
revisar('x\' = -x^(1/3): T = (3/2) x0^(2/3), x0 = 1', sp.integrate(x**sp.Rational(-1, 3), (x, 0, 1)), 1.5)
revisar('(-8)^(1/3) principal = 1 + sqrt(3) i', abs(complex(-8)**(1/3) - (1 + 1j*np.sqrt(3))), 0, 1e-12)

print('2.9 Escape')
revisar('x\' = x^2 - 1: escape desde 1.5 = (1/2) ln 5', sp.integrate(1/(x**2 - 1), (x, sp.Rational(3, 2), sp.oo)).evalf(), 0.804719, 1e-6)
revisar('x\' = x^2 - 1: escape desde 3 = (1/2) ln 2', sp.integrate(1/(x**2 - 1), (x, 3, sp.oo)).evalf(), 0.346574, 1e-6)
ev2 = lambda tt, z: abs(z[0]) - 1e3; ev2.terminal = True
s3 = solve_ivp(lambda tt, z: [z[0]**2], (0, 6), [0.5], events=ev2, **o)
revisar('x\' = x^2, x0 = 0.5: |x| = 1000 en 2 - 0.001', s3.t_events[0][0], 1.999, 1e-6)
print(f'\n{ok} de {total} verificaciones correctas.')
