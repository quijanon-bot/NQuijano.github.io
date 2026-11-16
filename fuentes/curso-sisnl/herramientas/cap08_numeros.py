"""Verificación independiente (sympy/scipy) de los números del capítulo 8
(principio de invarianza y construcción de funciones de Lyapunov).
Ejecutar:  python3 herramientas/cap08_numeros.py
Los mismos números se comprueban en MATLAB/Octave con codigo/cap08_invarianza/verificarCap08.m.
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp
from scipy.linalg import solve_continuous_lyapunov
from scipy.optimize import brentq, minimize_scalar

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:68s} {float(valor):14.6g}" + ('' if bien else f'  (esperado {esperado})'))

o = dict(rtol=1e-10, atol=1e-12)
x1, x2, y, k, a, b, r, w = sp.symbols('x1 x2 y k a b r w', real=True)
X = sp.Matrix([x1, x2])
def vdot(V, f):
    return sp.simplify(sum(sp.diff(V, X[i])*f[i] for i in range(2)))
def lyapP(A):   # A'P + PA = -I
    return solve_continuous_lyapunov(np.array(A, float).T, -np.eye(len(A)))

# ------------------------------------------------------------------ 8.1-8.3 péndulo
print('8.1-8.3 péndulo con fricción (a = 1, b = 0.3)')
fp = [x2, -a*sp.sin(x1) - b*x2]
Vp = a*(1 - sp.cos(x1)) + x2**2/2
revisar('Vdot = -b x2^2', sp.simplify(vdot(Vp, fp) + b*x2**2), 0)
revisar('borde de E: arccos(1 - c/a) con c = 1.8', np.arccos(1 - 1.8), 2.498, 1e-3)
ap, bp = 1.0, 0.3
fpn = lambda t, z: [z[1], -ap*np.sin(z[0]) - bp*z[1]]
Vpn = lambda z: ap*(1 - np.cos(z[0])) + z[1]**2/2
x0p = [2.0, 0.8]
revisar('V(2, 0.8) = 1.736 < 1.8', Vpn(x0p), 1.736, 1e-3)
ev = lambda t, z: z[1]; ev.direction = 0
s = solve_ivp(lambda t, z: fpn(t, z) + [z[1]**2], (0, 40), x0p + [0], events=ev, dense_output=True, **o)
revisar('cruces de x2 = 0 en [0, 40]: 12', len(s.t_events[0]), 12, 0)
Vfin = Vpn(s.y[:2, -1])
revisar('b int x2^2 = V(x0) - V(x(40))', bp*s.y[2, -1], Vpn(x0p) - Vfin, 1e-7)
revisar('x(40) cerca del origen (||x|| < 0.01)', np.linalg.norm(s.y[:2, -1]) < 0.01, 1)
tt = np.linspace(0, 40, 40001); Vt = np.array([Vpn(s.sol(q)[:2]) for q in tt])
revisar('V(x(t)) no crece (máx. incremento < 1e-9)', max(0, np.diff(Vt).max()) < 1e-9, 1)
# conjuntos límite: van der Pol mu = 1
fv = lambda t, z: [z[1], -z[0] + (1 - z[0]**2)*z[1]]
s = solve_ivp(fv, (0, 80), [0.1, 0], dense_output=True, **o)
q = s.sol(np.linspace(60, 80, 40001))
revisar('van der Pol: amplitud del ciclo = 2.009', q[0].max(), 2.009, 1e-3)
revisar('van der Pol: el límite de x(t) no existe (x1 oscila entre +-2)', q[0].max() - q[0].min() > 3.9, 1)
ivp = [solve_ivp(fv, (0, 200), [r0, 0], **o) for r0 in (0.1, 4.0)]
revisar('van der Pol: desde dentro y desde fuera llegan al mismo ciclo', abs(np.hypot(*ivp[0].y[:, -1]) - np.hypot(*ivp[1].y[:, -1])) < 1.5, 1)

# ------------------------------------------------------------------ 8.4 ejemplos
print('8.4 Duffing con amortiguamiento cuadrático')
Vd_ = x1**2/2 + k*x1**4/4 + x2**2/2
fd = [x2, -(x1 + k*x1**3) - b*x2*sp.Abs(x2)]
revisar('Vdot = -beta |x2|^3', sp.simplify(vdot(Vd_, fd) + b*x2**2*sp.Abs(x2)), 0)
Vb = lambda z: z[0]**2/2 - z[0]**4/4 + z[1]**2/2
revisar('blando: c* = V(1, 0) = 1/4', Vb([1, 0]), 0.25)
revisar('blando: V(1.2, 0) = 0.2016 < 1/4', Vb([1.2, 0]), 0.2016, 1e-12)
fdb = lambda t, z: [z[1], -(z[0] - z[0]**3) - 0.4*z[1]*abs(z[1])]
esc = lambda t, z: abs(z[0]) - 50; esc.terminal = True
s = solve_ivp(fdb, (0, 100), [1.2, 0], events=esc, **o)
revisar('blando: desde (1.2, 0) escapa (|x1| = 50 en t = 2.40)', s.t[-1], 2.40, 0.01)
s = solve_ivp(fdb, (0, 300), [0.9, 0], **o)
revisar('blando: desde (0.9, 0), V = 0.241, converge', np.linalg.norm(s.y[:, -1]) < 0.05, 1)
fdd = lambda t, z: [z[1], -(z[0] + z[0]**3) - 0.4*z[1]*abs(z[1])]
s = solve_ivp(fdd, (0, 400), [2, 0], dense_output=True, **o)
prod = [np.abs(s.sol(np.linspace(T - 10, T, 4001))[0]).max()*T for T in (100, 200, 400)]
revisar('duro: amplitud x t casi constante (~6) entre t = 100 y 400', max(prod) - min(prod) < 0.4, 1)
revisar('duro: amplitud(400) x 400 = 5.9', prod[-1], 5.95, 0.1)

print('8.4 ciclo límite con V no definida positiva')
fc = [x1*(1 - x1**2 - x2**2) - x2, x2*(1 - x1**2 - x2**2) + x1]
Vc = (x1**2 + x2**2 - 1)**2/4
revisar('Vdot = -r^2 (1 - r^2)^2', sp.simplify(vdot(Vc, fc) + (x1**2 + x2**2)*(1 - x1**2 - x2**2)**2), 0)
c = 0.2
revisar('anillo c = 0.2: r_min = sqrt(1 - 2 sqrt c) = 0.325', np.sqrt(1 - 2*np.sqrt(c)), 0.325, 1e-3)
revisar('anillo c = 0.2: r_max = sqrt(1 + 2 sqrt c) = 1.376', np.sqrt(1 + 2*np.sqrt(c)), 1.376, 1e-3)
revisar('V(0) = 1/4: el origen queda fuera del anillo si c < 1/4', float(Vc.subs({x1: 0, x2: 0})), 0.25)

print('8.4 control adaptativo')
yy, kk, gg, aa, bb = sp.symbols('y k gamma a b', real=True)
Va = yy**2/2 + (kk - bb)**2/(2*gg)
Vad = sp.diff(Va, yy)*(-(kk - aa)*yy) + sp.diff(Va, kk)*(gg*yy**2)
revisar('Vdot = -(b - a) y^2', sp.simplify(Vad + (bb - aa)*yy**2), 0)
Wa = yy**2/2 + (kk - aa)**2/(2*gg)
revisar('con b = a: W se conserva', sp.simplify(sp.diff(Wa, yy)*(-(kk - aa)*yy) + sp.diff(Wa, kk)*(gg*yy**2)), 0)
fa = lambda t, z: [-(z[1] - 1)*z[0], z[0]**2]
s = solve_ivp(fa, (0, 60), [2, -1], **o)
revisar('k_inf = 1 + 2 sqrt2 = 3.828 desde (2, -1)', s.y[1, -1], 1 + 2*np.sqrt(2), 1e-6)
revisar('y(60) -> 0', abs(s.y[0, -1]) < 1e-8, 1)
s = solve_ivp(fa, (0, 60), [0.5, 3], **o)
revisar('desde (0.5, 3): k_inf = 1 + sqrt(4 + 0.25) = 3.062', s.y[1, -1], 1 + np.sqrt(4.25), 1e-6)

print('8.4 observabilidad: las dos masas del capítulo 7')
def masas(kap, bm=0.3):
    A = np.array([[0, 1, 0, 0], [-(1 + kap), -bm, kap, 0], [0, 0, 0, 1], [kap, 0, -(1 + kap), 0]])
    C = np.array([[0, np.sqrt(bm), 0, 0]])
    O = np.vstack([C @ np.linalg.matrix_power(A, i) for i in range(4)])
    return A, C, O
for kap, rg in ((0.4, 4), (0.0, 2)):
    A, C, O = masas(kap)
    revisar(f'kappa = {kap}: rango de observabilidad = {rg}', np.linalg.matrix_rank(O), rg, 0)
A, C, O = masas(0.0)
N = np.linalg.svd(O)[2][2:]   # base del espacio nulo
revisar('kappa = 0: el subespacio no observable es {q1 = v1 = 0}', np.abs(N[:, :2]).max(), 0, 1e-12)
revisar('kappa = 0: es invariante (A N^T en span N^T)', np.linalg.norm((A @ N.T)[:2, :]), 0, 1e-12)
A, C, O = masas(0.4)
revisar('kappa = 0.4: A es Hurwitz', np.linalg.eigvals(A).real.max() < 0, 1)
# energía con acople: V = (q1^2 + q2^2 + kappa (q1 - q2)^2 + v1^2 + v2^2)/2 -> Vdot = -b v1^2
q1, v1, q2, v2, kap_ = sp.symbols('q1 v1 q2 v2 kappa', real=True)
Vm = (q1**2 + q2**2 + kap_*(q1 - q2)**2 + v1**2 + v2**2)/2
fm = [v1, -q1 - kap_*(q1 - q2) - sp.Rational(3, 10)*v1, v2, -q2 + kap_*(q1 - q2)]
Vmd = sum(sp.diff(Vm, z)*fz for z, fz in zip((q1, v1, q2, v2), fm))
revisar('masas: Vdot = -0.3 v1^2', sp.simplify(Vmd + sp.Rational(3, 10)*v1**2), 0)

print('8.4 Lotka--Volterra con autolimitación')
v, p = sp.symbols('v p', positive=True)
A_, B_, C_, D_, E_ = 1, 1, sp.Rational(1, 2), 1, sp.Rational(1, 5)
vs, ps = C_/D_, (A_ - E_*C_/D_)/B_
revisar('v* = c/d = 0.5', vs, 0.5); revisar('p* = (a - e v*)/b = 0.9', ps, 0.9)
Vl = D_*(v - vs - vs*sp.log(v/vs)) + B_*(p - ps - ps*sp.log(p/ps))
fl = [v*(A_ - E_*v - B_*p), p*(-C_ + D_*v)]
Vld = sp.diff(Vl, v)*fl[0] + sp.diff(Vl, p)*fl[1]
revisar('Vdot = -d e (v - v*)^2', sp.simplify(Vld + D_*E_*(v - vs)**2), 0)
s = solve_ivp(lambda t, z: [z[0]*(1 - 0.2*z[0] - z[1]), z[1]*(-0.5 + z[0])], (0, 300), [2, 0.2], **o)
revisar('desde (2, 0.2) converge a (0.5, 0.9)', np.linalg.norm(s.y[:, -1] - [0.5, 0.9]) < 1e-4, 1)
s = solve_ivp(lambda t, z: [z[0]*(1 - z[1]), z[1]*(-0.5 + z[0])], (0, 60), [2, 0.2], dense_output=True, **o)
Vl0 = sp.lambdify((v, p), D_*(v - vs - vs*sp.log(v/vs)) + B_*(p - 1 - sp.log(p)))   # e = 0: p* = a/b = 1
VV = [Vl0(*s.sol(q)) for q in np.linspace(0, 60, 601)]
revisar('e = 0: la función de Volterra se conserva', max(VV) - min(VV), 0, 1e-7)

print('8.4 atractivo pero inestable')
def fpolar(t, z):
    xx, yy_ = z; rr = np.hypot(xx, yy_); th = np.arctan2(yy_, xx)
    rd = rr*(1 - rr); thd = 1 - np.cos(th)
    return [rd*np.cos(th) - rr*thd*np.sin(th), rd*np.sin(th) + rr*thd*np.cos(th)]
x0 = [np.cos(0.15), np.sin(0.15)]
revisar('distancia inicial a (1, 0) = 0.15', np.hypot(x0[0] - 1, x0[1]), 0.15, 1e-3)
s = solve_ivp(fpolar, (0, 400), x0, dense_output=True, **o)
d = np.hypot(*(s.sol(np.linspace(0, 400, 40001)) - np.array([[1], [0]])))
revisar('excursión máxima = 2', d.max(), 2, 1e-4)
revisar('distancia en t = 400 < 0.01 (converge, lento)', d[-1] < 0.01, 1)
Vr = (1 - r)**2
revisar('Vdot = -2 r (1 - r)^2', sp.simplify(sp.diff(Vr, r)*r*(1 - r) + 2*r*(1 - r)**2), 0)

print('8.5 estimar la región de atracción con LaSalle')
fe = [x2, -x1 + x1**3 - x2]; Ve = x1**2/2 - x1**4/4 + x2**2/2
revisar('Vdot = -x2^2 (problema del cap. 7)', sp.simplify(vdot(Ve, fe) + x2**2), 0)
revisar('V en las sillas (+-1, 0) = 1/4', Ve.subs({x1: 1, x2: 0}), 0.25)
s = solve_ivp(lambda t, z: [z[1], -z[0] + z[0]**3 - z[1]], (0, 100), [0, 0.7], **o)
revisar('desde (0, 0.7), V = 0.245, converge', np.linalg.norm(s.y[:, -1]) < 1e-6, 1)

# ------------------------------------------------------------------ 8.6 gradiente variable
print('8.6 gradiente variable')
g = sp.Matrix([x1, x1 + x2])
revisar('trampa: g = (x1, x1 + x2) no es simétrico', sp.diff(g[0], x2) - sp.diff(g[1], x1), -1)
Vt_ = sp.integrate(g[0].subs(x2, 0), (x1, 0, x1)) + sp.integrate(g[1].subs(x2, y), (y, 0, x2))
revisar('trampa: integrar por los ejes da (x1 + x2)^2/2', sp.simplify(Vt_ - (x1 + x2)**2/2), 0)
a11 = sp.symbols('a11', real=True)
gG = sp.Matrix([a11*x1 + x2, x1 + x2])
fG = [x2, -(x1 + x2) - sp.sin(x1 + x2)]
VdG = sp.expand(gG[0]*fG[0] + gG[1]*fG[1])
revisar('G1: Vdot = (a11 - 2) x1 x2 - x1^2 - y sin y', sp.simplify(VdG - ((a11 - 2)*x1*x2 - x1**2 - (x1 + x2)*sp.sin(x1 + x2))), 0)
VG = sp.integrate((2*x1 + x2).subs(x2, 0), (x1, 0, x1)) + sp.integrate((x1 + y), (y, 0, x2))
revisar('G1 (a11 = 2): V = (x1^2 + (x1 + x2)^2)/2', sp.simplify(VG - (x1**2 + (x1 + x2)**2)/2), 0)
revisar('G1: intervalo de a11: 4 - 2 sqrt2 = 1.17', 4 - 2*np.sqrt(2), 1.17, 5e-3)
revisar('G1: intervalo de a11: 4 + 2 sqrt2 = 6.83', 4 + 2*np.sqrt(2), 6.83, 5e-3)
def cstarG(a_, nth=1800, rmax=15):
    best = np.inf; rr = np.linspace(1e-3, rmax, 6000)
    for th in np.linspace(0, np.pi, nth, endpoint=False):
        cc, ss = np.cos(th), np.sin(th)
        F = lambda R: (a_ - 2)*R*cc*R*ss - (R*cc)**2 - (R*(cc + ss))*np.sin(R*(cc + ss))
        val = F(rr); i = np.argmax(val >= 0)
        if val[i] >= 0:
            R0 = brentq(F, rr[i-1], rr[i]) if i > 0 else rr[0]
            best = min(best, a_*(R0*cc)**2/2 + R0*cc*R0*ss + (R0*ss)**2/2)
    return best
area = lambda a_: np.pi*cstarG(a_)/np.sqrt(a_/4 - 1/4)
revisar('G1 (a11 = 2): c* = pi^2/2', cstarG(2.0), np.pi**2/2, 1e-6)
revisar('G1 (a11 = 2): área = pi^3 = 31.0', area(2.0), 31.0, 0.01)
rb = minimize_scalar(lambda a_: -area(a_), bounds=(1.25, 1.9), method='bounded', options=dict(xatol=1e-3))
revisar('G1: el mejor a11 = 1.48', rb.x, 1.48, 0.01)
revisar('G1: el área máxima = 37.4', -rb.fun, 37.4, 0.05)
revisar('G1 (a11 = 1.1): c* casi 0 (Vdot no es definida negativa)', cstarG(1.1) < 0.01, 1)
nb = 0
for u0 in np.linspace(-12, 12, 7):
    for v0 in np.linspace(-12, 12, 7):
        s = solve_ivp(lambda t, z: [z[1], -(z[0] + z[1]) - np.sin(z[0] + z[1])], (0, 150), [u0, v0], **o)
        nb += np.linalg.norm(s.y[:, -1]) > 1e-4
revisar('G1: las 49 trayectorias de prueba convergen, también fuera del estimado', nb, 0, 0)
# G2: la V del capítulo 7 sale del gradiente variable
phi = sp.sin(x1) + k*b*x1
g2 = sp.Matrix([phi + k*x2, k*x1 + x2])
f2 = [x2, -sp.sin(x1) - b*x2]
revisar('G2: simetría dg1/dx2 = dg2/dx1 = k', sp.diff(g2[0], x2) - sp.diff(g2[1], x1), 0)
revisar('G2: Vdot = -k x1 sin x1 - (b - k) x2^2', sp.simplify(g2[0]*f2[0] + g2[1]*f2[1] + k*x1*sp.sin(x1) + (b - k)*x2**2), 0)
V2 = sp.integrate(g2[0].subs(x2, 0), (x1, 0, x1)) + sp.integrate(g2[1].subs(x2, y), (y, 0, x2))
revisar('G2: V = 1 - cos x1 + (k b x1^2 + 2 k x1 x2 + x2^2)/2', sp.simplify(V2 - (1 - sp.cos(x1) + (k*b*x1**2 + 2*k*x1*x2 + x2**2)/2)), 0)
cs = sp.simplify(V2.subs(x1, sp.pi).subs(x2, -k*sp.pi))
revisar('G2: c*(k) = 2 + k pi^2 (b - k)/2', sp.simplify(cs - (2 + k*sp.pi**2*(b - k)/2)), 0)
revisar('G2 (b = 0.5, k = b/2): c* = 2.308 (como en el cap. 7)', float(cs.subs({k: 0.25, b: 0.5})), 2.308, 1e-3)

# ------------------------------------------------------------------ 8.7 Krasovskii
print('8.7 Krasovskii')
fK = sp.Matrix([-3*x1 + x2, x1 - x2 - x2**3]); J = fK.jacobian(X)
Mk = -(J.T + J + sp.eye(2))
revisar('K1: menor 1 de -(2J + I) = 5', Mk[0, 0], 5)
revisar('K1: menor 2 = 1 + 30 x2^2', sp.expand(Mk.det() - (1 + 30*x2**2)), 0)
fKn = sp.lambdify((x1, x2), list(fK))
s = solve_ivp(lambda t, z: fKn(*z), (0, 20), [2.2, 0], dense_output=True, **o)
nz = [np.linalg.norm(fKn(*s.sol(q))) for q in np.linspace(0, 20, 2001)]
revisar('K1: ||f(x(t))|| decrece', max(0, np.diff(nz).max()) < 1e-9, 1)
A0 = np.array([[0, 1], [-1, -1]])
revisar('oscilador: con P = I, J + J^T tiene valor propio 0', np.linalg.eigvalsh(A0 + A0.T).max(), 0, 1e-12)
P0 = lyapP(A0)
revisar('oscilador: P = [1.5 0.5; 0.5 1]', np.abs(P0 - [[1.5, 0.5], [0.5, 1]]).max(), 0, 1e-12)
fk2 = [-x1 + x1**3, -x2]; J2 = sp.Matrix(fk2).jacobian(X)
revisar('K2: J + J^T = diag(-2 + 6 x1^2, -2)', sp.simplify((J2 + J2.T)[0, 0] - (-2 + 6*x1**2)), 0)
revisar('K2: (r - r^3)^2 en r = 1/sqrt3 = 4/27', (1/np.sqrt(3) - 1/np.sqrt(3)**3)**2, 4/27, 1e-12)
revisar('K2: 4/27 = 0.148', 4/27, 0.148, 1e-3)
revisar('K2: V(1.05, 0) = 0.0116 < 0.12', (1.05 - 1.05**3)**2, 0.0116, 1e-4)
esc2 = lambda t, z: z[0] - 10; esc2.terminal = True
s = solve_ivp(lambda t, z: [-z[0] + z[0]**3, -z[1]], (0, 10), [1.05, 0], events=esc2, **o)
revisar('K2: desde (1.05, 0) escapa (x1 = 10 en t = 1.18)', s.t[-1], 1.18, 0.01)
fK3 = sp.Matrix([-6*x1 + 2*x2, 2*x1 - 6*x2 - 2*x2**3]); J3 = fK3.jacobian(X)
M3 = -(J3.T + J3 + sp.eye(2))
revisar('P8.9: -(2J + I) = [11 -4; -4 11 + 12 x2^2] (d.p.)', sp.expand(M3.det() - (105 + 132*x2**2)), 0)

# ------------------------------------------------------------------ 8.8 Zubov
print('8.8 Zubov')
xx = sp.symbols('x', real=True)
Vz = xx**2
revisar('Z1: V = x^2 resuelve V\'(x)(-x + x^3) = -2x^2 (1 - V)', sp.simplify(sp.diff(Vz, xx)*(-xx + xx**3) + 2*xx**2*(1 - Vz)), 0)
wv = x1*x2
fz = [-x1 + 2*x1**2*x2, -x2]
revisar('Z2: w = x1 x2 cumple wdot = -2 w (1 - w)', sp.simplify(vdot(wv, fz) + 2*wv*(1 - wv)), 0)
Wz = x2**2/2 + x1**2/(2*(1 - x1*x2))
revisar('Z2: Wdot = -(x1^2 + x2^2)', sp.simplify(vdot(Wz, fz) + x1**2 + x2**2), 0)
Vzz = 1 - sp.exp(-Wz)
revisar('Z2: V = 1 - e^{-W} cumple la ecuación de Zubov', sp.simplify(vdot(Vzz, fz) + (x1**2 + x2**2)*(1 - Vzz)), 0)
s = solve_ivp(lambda t, z: [-z[0] + 2*z[0]**2*z[1], -z[1]], (0, 30), [1.9, 0.5], **o)
revisar('Z2: desde (1.9, 0.5), w = 0.95 < 1, converge', np.linalg.norm(s.y[:, -1]) < 1e-6, 1)
esc3 = lambda t, z: z[0] - 1e3; esc3.terminal = True
s = solve_ivp(lambda t, z: [-z[0] + 2*z[0]**2*z[1], -z[1]], (0, 30), [2.1, 0.5], events=esc3, **o)
revisar('Z2: desde (2.1, 0.5), w = 1.05 > 1, escapa', s.status, 1, 0)
# Zubov numérico, van der Pol en tiempo invertido
fW = lambda t, z: [-z[1], z[0] + (z[0]**2 - 1)*z[1], z[0]**2 + z[1]**2]
def Wnum(x0, T=40):
    e = lambda t, z: z[0]**2 + z[1]**2 - 100; e.terminal = True
    s_ = solve_ivp(fW, (0, T), [x0[0], x0[1], 0], events=e, rtol=1e-9, atol=1e-11)
    return np.inf if s_.status == 1 or np.hypot(*s_.y[:2, -1]) > 1e-3 else s_.y[2, -1]
Pv = lyapP([[0, -1], [1, -1]])
revisar('Z3: P = [1.5 -0.5; -0.5 1] (la del cap. 7)', np.abs(Pv - [[1.5, -0.5], [-0.5, 1]]).max(), 0, 1e-12)
revisar('Z3: W(0.1, 0) = x\'Px = 0.015 cerca del origen', Wnum([0.1, 0]), 0.015, 1e-4)
revisar('Z3: W(1, 0) = 1.60 (x\'Px = 1.5)', Wnum([1, 0]), 1.60, 5e-3)
revisar('Z3: W(1.9, 0) = 11.2 (cerca del ciclo)', Wnum([1.9, 0]), 11.25, 0.05)
revisar('Z3: W(2.1, 0) = infinito (fuera del ciclo)', np.isinf(Wnum([2.1, 0])), 1)
s = solve_ivp(lambda t, z: [z[1], -z[0] + (1 - z[0]**2)*z[1]], (0, 100), [2, 0], dense_output=True, **o)
tq = np.linspace(60, 100, 400001); Q = s.sol(tq)
idx = np.where((Q[1][:-1] < 0) & (Q[1][1:] >= 0))[0]; Pc = Q[:, idx[0]:idx[1] + 1]
Aciclo = 0.5*abs(np.sum(Pc[0][:-1]*Pc[1][1:] - Pc[0][1:]*Pc[1][:-1]))
revisar('Z3: área de la región de atracción (interior del ciclo) = 13.7', Aciclo, 13.72, 0.01)
revisar('Z3: área del mejor estimado cuadrático (c* = 2.30) = 6.46', np.pi*2.30/np.sqrt(np.linalg.det(Pv)), 6.46, 0.01)
revisar('Z3: el estimado cuadrático cubre el 47 %', np.pi*2.30/np.sqrt(np.linalg.det(Pv))/Aciclo, 0.47, 0.005)

# ------------------------------------------------------------------ problemas
print('Problemas')
fS = [-2*x1, -2*x2 + 2*x1*x2**2]
revisar('P8.7: Vdot = -2 x1^2 - 2 x2^2 (1 - x1 x2)', sp.simplify(vdot((x1**2 + x2**2)/2, fS) + 2*x1**2 + 2*x2**2*(1 - x1*x2)), 0)
revisar('P8.7: wdot = -2 w (2 - w)', sp.simplify(vdot(x1*x2, fS) + 2*x1*x2*(2 - x1*x2)), 0)
WS = x1**2/2 + x2**2/(2*(1 - x1*x2/2))
WSd = sp.simplify(vdot(WS, fS))
revisar('P8.7: W = x1^2/2 + x2^2/(2(1 - w/2)) da Wdot = -2(x1^2 + x2^2)', sp.simplify(WSd + 2*(x1**2 + x2**2)), 0)
Wq = -2*xx - 2*sp.log(1 - xx)
revisar('P8.11: W = -2x - 2 ln(1 - x) resuelve Wdot = -2x^2 para x\' = -x + x^2', sp.simplify(sp.diff(Wq, xx)*(-xx + xx**2) + 2*xx**2), 0)
revisar('P8.11: W(-5) finito: V(-5) = 1 - 36 e^{-10} = 0.998', 1 - 36*np.exp(-10), 0.998, 1e-3)
f4 = [x2, -x1**3 - x2**3]
revisar('pausa 8.3: Vdot = -x2^4 con V = x1^4/4 + x2^2/2', sp.simplify(vdot(x1**4/4 + x2**2/2, f4) + x2**4), 0)
Ug = (x1**2 - 1)**2/4 + x2**2/2
fg = [-sp.diff(Ug, x1), -sp.diff(Ug, x2)]
revisar('P8.2: Udot = -||grad U||^2', sp.simplify(vdot(Ug, fg) + fg[0]**2 + fg[1]**2), 0)
Lc, Cc, dl = sp.symbols('L C delta', positive=True)
revisar('P8.4: amplitud de corriente sqrt(2V/L) = delta <=> V = L delta^2/2', sp.simplify(sp.sqrt(2*(Lc*dl**2/2)/Lc) - dl), 0)
A0 = np.array([[0, 1], [-1, -1]])
revisar('P8.10: A\'PA = [1 0.5; 0.5 1.5]', np.abs(A0.T @ lyapP(A0) @ A0 - [[1, 0.5], [0.5, 1.5]]).max(), 0, 1e-12)
esc4 = lambda t, z: abs(z[1]) - 1e3; esc4.terminal = True
s_ = solve_ivp(lambda t, z: [-2*z[0], -2*z[1] + 2*z[0]*z[1]**2], (0, 10), [3, 1], events=esc4, **o)
revisar('P8.7: desde (3, 1), w = 3 > 2, escapa', s_.status, 1, 0)
s_ = solve_ivp(lambda t, z: [-2*z[0], -2*z[1] + 2*z[0]*z[1]**2], (0, 30), [1.9, 1], **o)
revisar('P8.7: desde (1.9, 1), w = 1.9 < 2, converge', np.linalg.norm(s_.y[:, -1]) < 1e-6, 1)
ss = sp.symbols('s', real=True)
revisar('P8.1: int_0^s t/(1+t^2)^2 dt = (1 - 1/(1+s^2))/2', sp.simplify(sp.integrate(y/(1 + y**2)**2, (y, 0, ss)) - (1 - 1/(1 + ss**2))/2), 0)
revisar('P8.8: c*(b/2) = 2 + pi^2 b^2/8', sp.simplify(cs.subs(k, b/2) - (2 + sp.pi**2*b**2/8)), 0)
print(f'\n{ok}/{total} verificaciones correctas')
