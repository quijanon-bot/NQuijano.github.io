"""Verificación independiente (sympy/scipy) de los números del capítulo 5.
Ejecutar:  python3 herramientas/cap05_numeros.py
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp, quad
from scipy.optimize import brentq

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:58s} {float(valor):13.6f}" + ('' if bien else f'  (esperado {esperado})'))

o = dict(rtol=1e-11, atol=1e-12)
x1, x2, r, th, t = sp.symbols('x1 x2 r theta t', real=True)

print('5.1 Duffing y el centro falso')
f = sp.Matrix([x2, x1 - x1**3]); J = f.jacobian([x1, x2])
revisar('det J(1,0) = 2 (centro lineal)', J.subs({x1: 1, x2: 0}).det(), 2)
H = x2**2/2 - x1**2/2 + x1**4/4
revisar('dH/dt = 0 a lo largo de Duffing', sp.simplify(sp.diff(H, x1)*f[0] + sp.diff(H, x2)*f[1]), 0)
for h, T in [(-0.2, 4.6307), (-0.01, 7.4087)]:
    lo, hi = np.sqrt(1 - np.sqrt(1 + 4*h)), np.sqrt(1 + np.sqrt(1 + 4*h))
    revisar(f'período de la órbita H = {h}', 2*quad(lambda x: 1/np.sqrt(2*(h + x**2/2 - x**4/4)), lo, hi, limit=400)[0], T, 2e-4)
g = sp.Matrix([-x2 + x1*(x1**2 + x2**2), x1 + x2*(x1**2 + x2**2)])
revisar('centro falso: r r\' = r^4', sp.simplify(x1*g[0] + x2*g[1] - (x1**2 + x2**2)**2), 0)
revisar('centro falso: escape en t = 1/(2 r0^2), r0 = 0.5', 1/(2*0.25), 2)

print('5.2-5.3 Ciclos')
F = sp.Matrix([-x2 + x1*(1 - x1**2 - x2**2), x1 + x2*(1 - x1**2 - x2**2)])
revisar('r r\' = r^2 (1 - r^2)', sp.simplify(x1*F[0] + x2*F[1] - (x1**2 + x2**2)*(1 - x1**2 - x2**2)), 0)
revisar('r^2 theta\' = r^2', sp.simplify(x1*F[1] - x2*F[0] - (x1**2 + x2**2)), 0)
r0 = sp.symbols('r0', positive=True); rr = (1 + (1/r0**2 - 1)*sp.exp(-2*t))**sp.Rational(-1, 2)
revisar('r(t) exacta cumple r\' = r(1 - r^2)', sp.simplify(sp.diff(rr, t) - rr*(1 - rr**2)), 0)
revisar('r(5) desde 0.1', rr.subs({r0: sp.Rational(1, 10), t: 5}), 0.997760, 1e-6)
mu = 1
s = solve_ivp(lambda tt, x: [x[1], -x[0] - mu*(x[0]**2 - 1)*x[1]], (0, 300), [0.5, 0], dense_output=True, max_step=0.01, **o)
tt = np.linspace(150, 300, 300001); xx = s.sol(tt)[0]
up = tt[1:][(xx[:-1] < 0) & (xx[1:] >= 0)]
revisar('van der Pol mu = 1: período', np.diff(up).mean(), 6.6633, 2e-4)
revisar('van der Pol mu = 1: amplitud', xx.max(), 2.0086, 2e-4)
mu = 5
s = solve_ivp(lambda tt, x: [x[1], -x[0] - mu*(x[0]**2 - 1)*x[1]], (0, 300), [0.5, 0], dense_output=True, max_step=0.01, **o)
tt = np.linspace(150, 300, 300001); xx = s.sol(tt)[0]; up = tt[1:][(xx[:-1] < 0) & (xx[1:] >= 0)]
revisar('van der Pol mu = 5: período', np.diff(up).mean(), 11.612, 2e-3)
revisar('aprox. de relajación (3 - 2 ln 2) mu con mu = 5', (3 - 2*np.log(2))*5, 8.0685, 1e-4)
xx_ = sp.symbols('x', real=True)
revisar('Liénard: F(x) = x^3/3 - x se anula en sqrt 3', (sp.sqrt(3)**3/3 - sp.sqrt(3)), 0)

print('5.4 Círculo')
revisar('T_lap = (1/4 - 1/5)^-1', 1/(sp.Rational(1, 4) - sp.Rational(1, 5)), 20)
w, a = sp.symbols('omega a', positive=True)
Tint = sp.integrate(1/(2 - sp.sin(th)), (th, 0, 2*sp.pi))
revisar('int_0^{2pi} dth/(2 - sin th) = 2 pi/sqrt 3', Tint, 2*np.pi/np.sqrt(3))
revisar('T(a = 1.99, w = 2)', 2*np.pi/np.sqrt(4 - 1.99**2), 31.4553, 1e-4)
revisar('T(a = 1.9, w = 2)', 2*np.pi/np.sqrt(4 - 1.9**2), 10.0611, 1e-4)

print('5.5 Luciérnagas')
phi = sp.symbols('phi'); Om, ww, A = 1.6, 1, 0.5
Td = quad(lambda p: 1/(Om - ww - A*np.sin(p)), 0, 2*np.pi)[0]
revisar('T deriva por cuadratura = 2 pi/sqrt((Om-w)^2 - A^2)', Td, 2*np.pi/np.sqrt(0.36 - 0.25), 1e-9)
revisar('phi* = arcsin(0.6)', np.arcsin(0.6), 0.6435, 1e-4)
revisar('estabilidad de phi*: -A cos(phi*) < 0', -0.5*np.cos(np.arcsin(0.6)) < 0, 1)
t1, t2, w1, w2, a12, a21 = sp.symbols('theta1 theta2 omega1 omega2 a12 a21', real=True)
dphi = (w1 - a12*sp.sin(t1 - t2)) - (w2 - a21*sp.sin(t2 - t1))
revisar('dos osciladores: phi\' = dw - (a12 + a21) sin phi', sp.simplify(dphi - ((w1 - w2) - (a12 + a21)*sp.sin(t1 - t2))), 0)

print('5.6 Kuramoto')
gam = sp.symbols('gamma', positive=True); om = sp.symbols('omega', real=True)
gL = gam/(sp.pi*(gam**2 + om**2))
revisar('Lorentz integra 1', sp.integrate(gL, (om, -sp.oo, sp.oo)), 1)
revisar('Kc = 2/(pi g(0)) = 2 gamma', sp.simplify(2/(sp.pi*gL.subs(om, 0)) - 2*gam), 0)
revisar('r(K = 2, gamma = 0.5)', np.sqrt(1 - 1/2), 0.7071, 1e-4)
N = 400; i = np.arange(1, N + 1); wq = 0.5*np.tan(np.pi*(i - 0.5)/N - np.pi/2)
th0 = 2*np.pi*np.mod(i*0.6180339887, 1)
def fk(tt, thv, K):
    z = np.mean(np.exp(1j*thv)); return wq + K*abs(z)*np.sin(np.angle(z) - thv)
s1 = solve_ivp(fk, (0, 100), th0, args=(3.0,), rtol=1e-6, atol=1e-8)
s2 = solve_ivp(fk, (100, 200), s1.y[:, -1], args=(3.0,), rtol=1e-6, atol=1e-8, t_eval=np.linspace(100, 200, 101))
revisar('r simulado K = 3', np.mean(abs(np.mean(np.exp(1j*s2.y), axis=0))), np.sqrt(2/3), 0.01)

print('5.7 Índice')
def indice(fun, c, R, n=20000):
    s_ = np.linspace(0, 2*np.pi, n); P = np.c_[c[0] + R*np.cos(s_), c[1] + R*np.sin(s_)]
    V = np.array([fun(p) for p in P]); ang = np.unwrap(np.arctan2(V[:, 1], V[:, 0]))
    return (ang[-1] - ang[0])/(2*np.pi)
revisar('índice silla', indice(lambda p: [p[0], -p[1]], (0, 0), 1), -1, 1e-9)
revisar('índice z^2', indice(lambda p: [p[0]**2 - p[1]**2, 2*p[0]*p[1]], (0, 0), 1), 2, 1e-9)
revisar('índice (x1^2 x2, x1^2 - x2^2)', indice(lambda p: [p[0]**2*p[1], p[0]**2 - p[1]**2], (0, 0), 1), 0, 1e-9)
fe = sp.Matrix([-x1 + x1*x2, x1 + x2 - 2*x1*x2]); Je = fe.jacobian([x1, x2])
revisar('J(1,1) = [[0,1],[-1,-1]]', (Je.subs({x1: 1, x2: 1}) - sp.Matrix([[0, 1], [-1, -1]])).norm(), 0)
revisar('equilibrios del ejemplo: solo (0,0) y (1,1)', len(sp.solve(list(fe), [x1, x2], dict=True)), 2)
revisar('índice de la curva que rodea ambos', indice(lambda p: [-p[0] + p[0]*p[1], p[0] + p[1] - 2*p[0]*p[1]], (0.5, 0.5), 2), 0, 1e-9)
revisar('único equilibrio de (x1^2 x2, x1^2 - x2^2) es el origen', len(sp.solve([x1**2*x2, x1**2 - x2**2], [x1, x2], dict=True)), 1)

print('5.8 Descartar órbitas')
V = -x1*sp.sin(x2)
revisar('gradiente: f = -grad V', (sp.Matrix([sp.sin(x2), x1*sp.cos(x2)]) + sp.Matrix([sp.diff(V, x1), sp.diff(V, x2)])).norm(), 0)
Vd = sp.expand(2*x1*(-x1 + 4*x2) + 8*x2*(-x1 - x2**3))
revisar('V\' = -2 x1^2 - 8 x2^4', sp.simplify(Vd + 2*x1**2 + 8*x2**4), 0)
dl = sp.symbols('delta')
revisar('div Duffing = -delta', sp.simplify(sp.diff(x2, x1) + sp.diff(x1 - x1**3 - dl*x2, x2) + dl), 0)
v, p, aa, bb, cc, dd, ee, ff = sp.symbols('v p a b c d e f', positive=True)
gv = v*(aa - ee*v - bb*p)/(v*p); gp = p*(-cc + dd*v - ff*p)/(v*p)
revisar('Dulac LV: div(f/(vp)) = -e/p - f/v', sp.simplify(sp.diff(gv, v) + sp.diff(gp, p) + ee/p + ff/v), 0)
gv0 = v*(aa - bb*p)/(v*p); gp0 = p*(-cc + dd*v)/(v*p)
revisar('Dulac LV clásico: div(f/(vp)) = 0', sp.simplify(sp.diff(gv0, v) + sp.diff(gp0, p)), 0)

print('5.9 Poincaré-Bendixson')
fpb = sp.Matrix([x1 + x2 - x1*(x1**2 + x2**2), -2*x1 + x2 - x2*(x1**2 + x2**2)])
Vd = sp.expand(2*x1*fpb[0] + 2*x2*fpb[1])
revisar('V\' = 2r^2 - 2 x1 x2 - 2 r^4', sp.simplify(Vd - (2*(x1**2 + x2**2) - 2*x1*x2 - 2*(x1**2 + x2**2)**2)), 0)
c = sp.symbols('c', positive=True)
revisar('3c - 2c^2 = 0 en c = 3/2', (3*c - 2*c**2).subs(c, sp.Rational(3, 2)), 0)
revisar('valores propios 1 +- j sqrt 2: det = 3, tr = 2', sp.Matrix([[1, 1], [-2, 1]]).det(), 3)
s = solve_ivp(lambda tt, x: [x[0] + x[1] - x[0]*(x[0]**2 + x[1]**2), -2*x[0] + x[1] - x[1]*(x[0]**2 + x[1]**2)], (0, 60), [0.01, 0], dense_output=True, **o)
rr_ = np.linalg.norm(s.sol(np.linspace(40, 60, 20001)), axis=0)
revisar('ciclo: r mínimo', rr_.min(), 0.8501, 2e-4); revisar('ciclo: r máximo', rr_.max(), 1.1302, 2e-4)

print('5.10 Presa-depredador')
v3 = (aa*ff + bb*cc)/(bb*dd + ee*ff); p3 = (aa*dd - cc*ee)/(bb*dd + ee*ff)
fv = v*(aa - ee*v - bb*p); fp = p*(-cc + dd*v - ff*p)
W = dd*(v - v3*sp.log(v)) + bb*(p - p3*sp.log(p))
revisar('Volterra: W\' = -de(v-v3)^2 - bf(p-p3)^2', sp.simplify(sp.diff(W, v)*fv + sp.diff(W, p)*fp + dd*ee*(v - v3)**2 + bb*ff*(p - p3)**2), 0)
J3 = sp.Matrix([fv, fp]).jacobian([v, p]).subs({v: v3, p: p3})
revisar('traza J3 = -(e v3 + f p3)', sp.simplify(J3.trace() + ee*v3 + ff*p3), 0)
K0 = dd*v - cc*sp.log(v) + bb*p - aa*sp.log(p)
revisar('clásico: K se conserva', sp.simplify(sp.diff(K0, v)*v*(aa - bb*p) + sp.diff(K0, p)*p*(-cc + dd*v)), 0)
revisar('competencia (1,1,.5,1,.5,.2): v3', 0.7/1.1, 0.63636, 1e-5)
be, ga, KK = sp.symbols('beta gamma K', positive=True)
F1 = v*(1 - v/KK) - v*p/(1 + v); F2 = p*(be*v/(1 + v) - ga)
vs = ga/(be - ga); ps = (1 - vs/KK)*(1 + vs)
JR = sp.Matrix([F1, F2]).jacobian([v, p]).subs({v: vs, p: ps})
revisar('R-M: K_H = (beta+gamma)/(beta-gamma) con beta=2, gamma=1', sp.solve(sp.Eq(sp.simplify(JR.trace()), 0), KK)[0].subs({be: 2, ga: 1}), 3)
s = solve_ivp(lambda tt, x: [x[0]*(1 - x[0]/5) - x[0]*x[1]/(1 + x[0]), x[1]*(2*x[0]/(1 + x[0]) - 1)], (0, 800), [1.1, 1.6], dense_output=True, max_step=0.5, **o)
vv = s.sol(np.linspace(600, 800, 200001))[0]
revisar('R-M K = 5: v máximo', vv.max(), 4.4666, 1e-3); revisar('R-M K = 5: v mínimo', vv.min(), 0.0465, 1e-3)

print('5.11 Nowak')
cc_ = sp.symbols('c', real=True); y1, y2 = sp.symbols('y1 y2', real=True)
Bm = sp.Matrix(3, 3, lambda i, j: sp.Rational(22, 25) if i == j else sp.Rational(1, 5))
Qm = sp.Matrix([[sp.Rational(4, 5) - cc_, sp.Rational(1, 5), cc_], [cc_, sp.Rational(4, 5) - cc_, sp.Rational(1, 5)], [sp.Rational(1, 5), cc_, sp.Rational(4, 5) - cc_]])
X = sp.Matrix([y1, y2, 1 - y1 - y2]); Fv = Bm*X; Fb = (X.T*Fv)[0]
dX = Qm.T*sp.Matrix([Fv[i]*X[i] for i in range(3)]) - Fb*X
Js = sp.Matrix(dX[:2]).jacobian([y1, y2]).subs({y1: sp.Rational(1, 3), y2: sp.Rational(1, 3)})
tr = sp.simplify(Js.trace())
revisar('Re lambda = tr/2 = (0.092 - 2.94 c)/3', sp.simplify(tr/2 - (sp.Rational(92, 1000) - sp.Rational(294, 100)*cc_)/3), 0)
cstar = sp.solve(sp.Eq(tr, 0), cc_)[0]
revisar('c* = 23/735', sp.simplify(cstar - sp.Rational(23, 735)), 0)
revisar('c* numérico', cstar, 0.031293, 1e-6)
detJ = sp.simplify(Js.det().subs(cc_, cstar))
revisar('período en c* = 2 pi/sqrt(det)', 2*np.pi/np.sqrt(float(detJ)), 65.82, 0.01)
revisar('Fbar* = 1.28/3', (X.T*Bm*X)[0].subs({y1: sp.Rational(1, 3), y2: sp.Rational(1, 3)}), 1.28/3)
xs = sp.symbols('x1:4'); xv = sp.Matrix(xs); Fx = Bm*xv; Fbx = (xv.T*Fx)[0]
revisar('Fisher: Fbar\' = 2 sum x_i (F_i - Fbar)^2 (Q = I, en el símplex)',
        sp.simplify((2*(xv.T*Bm*sp.Matrix([xs[i]*(Fx[i] - Fbx) for i in range(3)]))[0] - 2*sum(xs[i]*(Fx[i] - Fbx)**2 for i in range(3))).subs(xs[2], 1 - xs[0] - xs[1])), 0)
dxs = Qm.T*sp.Matrix([Fx[i]*xs[i] for i in range(3)]) - Fbx*xv
revisar('suma: s\' = Fbar (1 - s)', sp.simplify(sum(dxs) - Fbx*(1 - sum(xs))), 0)
val = dxs[0].subs({xs[0]: sp.Rational(1, 10**6), xs[1]: sp.Rational(1, 2), xs[2]: sp.Rational(1, 2) - sp.Rational(1, 10**6), cc_: sp.Rational(1, 100)})
revisar('frontera repelente: x1\' en (1e-6, 1/2, 1/2)', val, 0.0567, 1e-4)

print(f'\n{ok} de {total} verificaciones correctas.')
