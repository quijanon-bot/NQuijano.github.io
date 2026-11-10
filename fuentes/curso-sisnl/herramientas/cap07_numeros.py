"""Verificación independiente (sympy/scipy) de los números del capítulo 7
(estabilidad de Lyapunov).   Ejecutar:  python3 herramientas/cap07_numeros.py
Los mismos números se comprueban en MATLAB/Octave con codigo/cap07_lyapunov/verificarCap07.m.
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp, quad
from scipy.linalg import expm, solve_continuous_lyapunov
from scipy.optimize import brentq

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:62s} {float(valor):14.6g}" + ('' if bien else f'  (esperado {esperado})'))

x1, x2, x3, t, x = sp.symbols('x1 x2 x3 t x', real=True)
X = sp.Matrix([x1, x2])
def Vdot(V, f, xs=X):
    return sp.simplify((sp.Matrix([V]).jacobian(xs)*f)[0])
o = dict(rtol=1e-11, atol=1e-12)
def lyapP(A, Q):
    """Solución de A'P + PA = -Q (convención del curso)."""
    return solve_continuous_lyapunov(np.array(A, float).T, -np.array(Q, float))

# ------------------------------------------------------------------ 7.2 definiciones
print('7.2 Definiciones')
a, b = 1.0, 0.5                                    # péndulo normalizado: x2' = -a sin x1 - b x2
pend = lambda tt, z, bb=b: [z[1], -a*np.sin(z[0]) - bb*z[1]]
s = solve_ivp(lambda tt, z: pend(tt, z, 0), (0, 2*np.pi*1.2), [0.3, 0], **o)
E = lambda z: a*(1 - np.cos(z[0])) + 0.5*z[1]**2
revisar('sin fricción: la energía se conserva (máx |E - E0|)', np.max(np.abs(E(s.y) - E(s.y[:, 0]))), 0, 1e-8)
revisar('sin fricción: amplitud de x1 = 0.3 (no converge)', np.max(s.y[0, s.t > 5]), 0.3, 1e-6)
s = solve_ivp(pend, (0, 40), [0.3, 0], **o)
revisar('con fricción: |x(40)| (converge)', np.linalg.norm(s.y[:, -1]), 0, 1e-3)
s = solve_ivp(pend, (0, 60), [1.5, 3.0], dense_output=True, **o)
revisar('con fricción desde (1.5, 3): termina en (2 pi, 0)  -> x1/pi', s.y[0, -1]/np.pi, 2, 1e-5)
revisar('... sale de D = {|x1| < pi} en t', brentq(lambda tt: s.sol(tt)[0] - np.pi, 0, 5), 0.72386, 1e-4)
# sistema en coordenadas polares: r' = r(1 - r), th' = sin^2(th/2)
fp = lambda tt, z: [z[0]*(1 - z[0]), np.sin(z[1]/2)**2]
s = solve_ivp(fp, (0, 400), [1, 0.1], **o)
d = np.hypot(np.cos(s.y[1]) - 1, np.sin(s.y[1]))
revisar('polar: desde theta0 = 0.1 converge (theta(400)/2pi)', s.y[1, -1]/(2*np.pi), 0.99823, 1e-4)
revisar('polar: ... pero se aleja hasta distancia 2 de (1, 0)', d.max(), 2, 1e-3)
s = solve_ivp(fp, (0, 400), [0.5, 0.01], **o)
revisar('polar: desde (0.5, 0.01) también da la vuelta (dist. máx.)', np.hypot(np.cos(s.y[1]) - 1, np.sin(s.y[1])).max() * (s.y[0, -1] > 0.99), 2, 1e-2)

# ------------------------------------------------------------------ 7.3 método indirecto
print('7.3 Método indirecto')
J0 = np.array([[0, 1], [-a, -b]]); Jpi = np.array([[0, 1], [a, -b]])
ev = np.linalg.eigvals(J0)
revisar('péndulo en (0,0): Re lambda = -b/2', ev.real.max(), -0.25, 1e-12)
revisar('péndulo en (0,0): Im lambda = sqrt(a - b^2/4)', abs(ev.imag).max(), np.sqrt(1 - 0.0625), 1e-12)
ev = np.sort(np.linalg.eigvals(Jpi).real)
revisar('péndulo en (pi,0): lambda+ = (-b + sqrt(b^2 + 4a))/2', ev[1], 0.780776, 1e-6)
revisar('péndulo en (pi,0): lambda- ', ev[0], -1.280776, 1e-6)
aa = sp.symbols('a', positive=True)
revisar('x\' = ax - x^3: jacobiano en sqrt(a) es -2a (a = 1)', sp.diff(aa*x - x**3, x).subs(x, sp.sqrt(aa)).subs(aa, 1), -2)
x0 = sp.symbols('x0', positive=True)
sol = x0/sp.sqrt(1 + 2*x0**2*t)
revisar('x\' = -x^3: x(t) = x0/sqrt(1 + 2 x0^2 t) resuelve la EDO', sp.simplify(sp.diff(sol, t) + sol**3), 0)
revisar('x\' = -x^3 desde 1: x(10) = 1/sqrt(21)', float(sol.subs({x0: 1, t: 10})), 0.218218, 1e-6)
revisar('x\' = -x desde 1: x(10) = e^-10', np.exp(-10), 4.54e-5, 1e-7)

# ------------------------------------------------------------------ 7.4 método directo
print('7.4 Método directo')
aS, bS = sp.symbols('a b', positive=True)
fpend = sp.Matrix([x2, -aS*sp.sin(x1) - bS*x2])
Ep = aS*(1 - sp.cos(x1)) + x2**2/2
revisar('péndulo: V = energía, Vdot + b x2^2 = 0', sp.simplify(Vdot(Ep, fpend) + bS*x2**2), 0)
revisar('x\' = -x^3, V = x^2/2: Vdot + x^4 = 0', sp.simplify(sp.diff(x**2/2, x)*(-x**3) + x**4), 0)
g = sp.Function('g')
Vg = sp.integrate(sp.sin(x) + x**3, (x, 0, x))
revisar('x\' = -g(x), V = int g: Vdot = -g^2 (g = sin x + x^3)', sp.simplify(sp.diff(Vg, x)*(-(sp.sin(x) + x**3)) + (sp.sin(x) + x**3)**2), 0)

# ------------------------------------------------------------------ 7.5 global y exponencial
print('7.5 Estabilidad global y exponencial')
u_ = 1 + x1**2
fK = sp.Matrix([-6*x1/u_**2 + 2*x2, -2*(x1 + x2)/u_**2])
VK = x1**2/(1 + x1**2) + x2**2
VdK = Vdot(VK, fK)
revisar('Khalil: Vdot = -12x1^2/(1+x1^2)^4 - 4x2^2/(1+x1^2)^2', sp.simplify(VdK + 12*x1**2/u_**4 + 4*x2**2/u_**2), 0)
FK = sp.lambdify((x1, x2), list(fK))
s = solve_ivp(lambda tt, z: FK(*z), (0, 200), [2, 2], **o)
revisar('Khalil: desde (2, 2), x1(200) > 700 (no converge)', s.y[0, -1] > 700, 1)
revisar('Khalil: ... y x2(200) -> 2 (aprox.)', s.y[1, -1], 1.912, 1e-2)
revisar('Khalil: V(x) < 1 para todo x1 si x2 = 0 (nivel no acotado c >= 1)', sp.limit(VK.subs(x2, 0), x1, sp.oo), 1)
# x' = -x - x^3, V = x^2/2: |x(t)| <= |x0| e^-t
solx = x0*sp.exp(-t)/sp.sqrt(1 + x0**2*(1 - sp.exp(-2*t)))
revisar('x\' = -x - x^3: solución exacta resuelve la EDO', sp.simplify(sp.diff(solx, t) + solx + solx**3), 0)
revisar('x\' = -x - x^3 desde 3: x(1) (cota 3/e = 1.1036)', float(solx.subs({x0: 3, t: 1})), 0.37242, 1e-5)

# ------------------------------------------------------------------ 7.6 formas cuadráticas
print('7.6 Formas cuadráticas')
Pa = sp.Matrix([[aS, 0, 1], [0, aS, 2], [1, 2, aS]])
a_ = sp.symbols('a', real=True); Pa = Pa.subs(aS, a_)
revisar('P(a): Delta3 - a(a^2 - 5) = 0', sp.expand(Pa.det() - a_*(a_**2 - 5)), 0)
evs = sorted(np.linalg.eigvalsh(np.array(Pa.subs(a_, 3), float)))
revisar('P(3): valores propios a - sqrt5, a, a + sqrt5 (el menor)', evs[0], 3 - np.sqrt(5), 1e-12)
revisar('P(3): el mayor', evs[2], 3 + np.sqrt(5), 1e-12)
revisar('P(sqrt5): menor valor propio = 0 (semidefinida)', min(np.linalg.eigvalsh(np.array(Pa.subs(a_, sp.sqrt(5)), float))), 0, 1e-12)
Pt = np.diag([0., -1.])
revisar('trampa: P = diag(0, -1) tiene Delta1 = Delta2 = 0', abs(Pt[0, 0]) + abs(np.linalg.det(Pt)), 0)
revisar('... pero el menor principal P22 = -1 < 0', Pt[1, 1], -1)
p12 = sp.symbols('p12', positive=True)
Vc = sp.Rational(1, 2)*(bS*p12*x1**2 + 2*p12*x1*x2 + x2**2) + aS*(1 - sp.cos(x1))
revisar('término cruzado: Vdot + a p12 x1 sin x1 + (b - p12) x2^2 = 0', sp.simplify(Vdot(Vc, fpend) + aS*p12*x1*sp.sin(x1) + (bS - p12)*x2**2), 0)
cst = lambda q: 2*a + np.pi**2/2*q*(b - q)
revisar('c*(p12) = 2a + pi^2/2 p12(b - p12): con p12 = b/2', cst(b/2), 2.308425, 1e-6)
mins = min(0.5*(b*0.25*np.pi**2 + 2*0.25*np.pi*y + y**2) + 2*a for y in np.linspace(-3, 3, 600001))
revisar('... = min de V sobre la frontera x1 = pi (numérico)', mins, cst(0.25), 1e-6)
revisar('V(1.5, 3) con p12 = b/2 (fuera de Omega_c)', 0.5*(b*0.25*1.5**2 + 2*0.25*1.5*3 + 9) + a*(1 - np.cos(1.5)), 6.69489, 1e-5)
# ejemplo x1' = -x1 + x1 x2, x2' = -x2
fe = sp.Matrix([-x1 + x1*x2, -x2])
revisar('x1\'=-x1+x1x2: Vdot = -x1^2 + x1^2 x2 - x2^2 con V = |x|^2/2', sp.simplify(Vdot((x1**2 + x2**2)/2, fe) + x1**2 - x1**2*x2 + x2**2), 0)
x10, x20 = 0.5, 3.0
s = solve_ivp(lambda tt, z: [-z[0] + z[0]*z[1], -z[1]], (0, 2), [x10, x20], **o)
revisar('... x1(t) = x1(0) exp(-t + x2(0)(1 - e^-t)) (t = 2)', s.y[0, -1], x10*np.exp(-2 + x20*(1 - np.exp(-2))), 1e-8)
s = solve_ivp(lambda tt, z: [-z[0] + z[0]*z[1], -z[1]], (0, 5), [x10, x20], dense_output=True, **o)
tt = np.linspace(0, 5, 50001)
revisar('... máximo de x1 desde (0.5, 3): 0.5 e^{2 - ln 3}', s.sol(tt)[0].max(), 0.5*np.exp(2 - np.log(3)), 1e-6)
revisar('... alcanzado en t = ln 3', tt[np.argmax(s.sol(tt)[0])], np.log(3), 1e-3)
fg = sp.Matrix([-x1**3 + x2, -x1 - x2])
revisar('ejemplo global: Vdot + x1^4 + x2^2 = 0 con V = |x|^2/2', sp.simplify(Vdot((x1**2 + x2**2)/2, fg) + x1**4 + x2**2), 0)

# ------------------------------------------------------------------ 7.7 sistemas lineales
print('7.7 Sistemas lineales')
A = np.array([[0, 1], [-1, 0]]); B = np.array([[0], [1]]); Cc = np.array([[1, 0]])
AP = np.block([[A, np.zeros((2, 2))], [np.zeros((2, 2)), A]])
AS = np.block([[A, np.zeros((2, 2))], [B@Cc, A]])
revisar('paralelo: rank(A_P - jI) = 2', np.linalg.matrix_rank(AP - 1j*np.eye(4)), 2)
revisar('serie: rank(A_S - jI) = 3', np.linalg.matrix_rank(AS - 1j*np.eye(4)), 3)
tt = np.linspace(0, 30, 301)
yS = np.array([(np.array([0, 0, 1, 0])@expm(AS*ti)@np.array([1, 0, 0, 0])) for ti in tt])
revisar('serie: y(t) = (t/2) sin t desde x0 = (1,0,0,0)', np.max(np.abs(yS - tt/2*np.sin(tt))), 0, 1e-9)
revisar('paralelo: A_P + A_P\' = 0 (|x|^2 se conserva)', np.abs(AP + AP.T).max(), 0)
A1 = np.array([[0, -1], [1, -1]])
P1 = lyapP(A1, np.eye(2))
revisar('A = [0 -1; 1 -1], Q = I: P11 = 1.5', P1[0, 0], 1.5, 1e-12)
revisar('... P12 = -0.5', P1[0, 1], -0.5, 1e-12)
revisar('... P22 = 1', P1[1, 1], 1, 1e-12)
lP = np.linalg.eigvalsh(P1)
revisar('... lambda_min(P) = (5 - sqrt5)/4', lP[0], (5 - np.sqrt(5))/4, 1e-12)
revisar('... lambda_max(P) = (5 + sqrt5)/4', lP[1], (5 + np.sqrt(5))/4, 1e-12)
Pint = np.array([[quad(lambda s_: (expm(A1.T*s_)@expm(A1*s_))[i, j], 0, 60, limit=200)[0] for j in range(2)] for i in range(2)])
revisar('P = int_0^inf e^{A\'t} e^{At} dt', np.abs(Pint - P1).max(), 0, 1e-8)
xa = np.array([1.2, 1.0])
J = quad(lambda s_: np.sum((expm(A1*s_)@xa)**2), 0, 60, limit=200)[0]
revisar('costo: int |x|^2 dt = x0\'P x0 (x0 = (1.2, 1))', J, xa@P1@xa, 1e-8)
revisar('... = 1.96', xa@P1@xa, 1.96, 1e-12)
revisar('trampa MATLAB: lyap(A,Q) (= P de A\') no es la P del curso', np.abs(lyapP(A1.T, np.eye(2)) - P1).max() > 0.1, 1)
An = np.array([[-1, 10], [0, -2]])
revisar('no normal: eig(A + A\') máximo > 0', np.linalg.eigvalsh(An + An.T).max(), -3 + np.sqrt(101), 1e-12)
x_t = lambda ti: expm(An*ti)@np.array([0, 1])
revisar('no normal: |x(ln 2)| desde (0,1) (crece de 1)', np.linalg.norm(x_t(np.log(2))), np.sqrt(2.5**2 + 0.25**2), 1e-12)
Pn = lyapP(An, np.eye(2)); ln = np.linalg.eigvalsh(Pn)
revisar('no normal: lambda_min(P) > 0', ln[0] > 0, 1)
revisar('no normal: M = sqrt(lmax/lmin)', np.sqrt(ln[1]/ln[0]), 7.2444, 1e-3)
revisar('no normal: tasa 1/(2 lmax)', 1/(2*ln[1]), 0.05609, 1e-4)
ts = np.linspace(0, 8, 801); Vs = [x_t(ti)@Pn@x_t(ti) for ti in ts]
revisar('no normal: x\'Px decrece siempre (máx dV < 0)', np.max(np.diff(Vs)) < 0, 1)
# inercia
Am = lambda mu: np.array([[-1, 2], [0, mu]])
Pm = lyapP(Am(0.5), np.eye(2))
revisar('A(0.5): P tiene un valor propio negativo', np.sum(np.linalg.eigvalsh(Pm) < 0), 1)
revisar('A(-0.5): P > 0', np.sum(np.linalg.eigvalsh(lyapP(Am(-0.5), np.eye(2))) > 0), 2)
revisar('A(0.5): A\'P + PA = -I (residuo)', np.abs(Am(0.5).T@Pm + Pm@Am(0.5) + np.eye(2)).max(), 0, 1e-12)
mu = sp.symbols('mu', real=True)
p1, p2, p3 = sp.symbols('p1 p2 p3'); Ps = sp.Matrix([[p1, p2], [p2, p3]]); Ams = sp.Matrix([[-1, 2], [0, mu]])
solP = sp.solve(list(Ams.T*Ps + Ps*Ams + sp.eye(2)), [p1, p2, p3], dict=True)[0]
revisar('A(mu): solución simbólica = numérica (mu = -0.5)', float(solP[p3].subs(mu, -0.5)), lyapP(Am(-0.5), np.eye(2))[1, 1], 1e-12)
revisar('A(mu): p22 explota cuando mu -> 0^- (mu = -0.01)', float(solP[p3].subs(mu, -0.01)) > 100, 1)
# dos masas
k1 = k2 = 1; bm = 0.3
Af = lambda ka: np.array([[0, 1, 0, 0], [-(k1 + ka), -bm, ka, 0], [0, 0, 0, 1], [ka, 0, -(k2 + ka), 0]])
Pf = lambda ka: 0.5*np.array([[k1 + ka, 0, -ka, 0], [0, 1, 0, 0], [-ka, 0, k2 + ka, 0], [0, 0, 0, 1]])
Cm = np.array([[0, np.sqrt(bm), 0, 0]])
for ka, rk, re in [(0, 2, 0), (0.4, 4, None)]:
    Aq = Af(ka); Ob = np.vstack([Cm@np.linalg.matrix_power(Aq, i) for i in range(4)])
    revisar(f'dos masas kappa = {ka}: A\'P + PA = -C\'C', np.abs(Aq.T@Pf(ka) + Pf(ka)@Aq + Cm.T@Cm).max(), 0, 1e-12)
    revisar(f'dos masas kappa = {ka}: rango de observabilidad', np.linalg.matrix_rank(Ob), rk)
    if re is not None:
        revisar(f'dos masas kappa = {ka}: max Re lambda = 0', np.linalg.eigvals(Aq).real.max(), 0, 1e-12)
    else:
        revisar(f'dos masas kappa = {ka}: max Re lambda < 0', np.linalg.eigvals(Aq).real.max() < 0, 1)

# ------------------------------------------------------------------ 7.8 región de atracción
print('7.8 Región de atracción (van der Pol en tiempo invertido)')
fV = sp.Matrix([-x2, x1 + (x1**2 - 1)*x2])
VV = sp.Rational(3, 2)*x1**2 - x1*x2 + x2**2
revisar('Vdot = -|x|^2 - x1^3 x2 + 2 x1^2 x2^2', sp.simplify(sp.expand(Vdot(VV, fV)) + x1**2 + x2**2 + x1**3*x2 - 2*x1**2*x2**2), 0)
best = 1e9
for th in np.linspace(0, 2*np.pi, 72001):
    c_, s_ = np.cos(th), np.sin(th); kk = -c_**3*s_ + 2*c_**2*s_**2
    if kk > 0:
        r = 1/np.sqrt(kk); xx = r*np.array([c_, s_]); best = min(best, xx@P1@xx)
revisar('c* = min{V : Vdot = 0, x != 0}', best, 2.30448, 1e-4)
revisar('cota con bola: lambda_min(P) 2/sqrt5', lP[0]*2/np.sqrt(5), 0.618034, 1e-6)
revisar('razón de áreas Omega_c*/Omega_bola = c*/c_bola', best/(lP[0]*2/np.sqrt(5)), 3.7287, 1e-3)
# un punto en Omega_c* converge; uno fuera, cerca del ciclo, diverge
fv = lambda tt, z: [-z[1], z[0] + (z[0]**2 - 1)*z[1]]
dirx = np.array([-0.85586, 0.75057]); dirx = dirx/np.sqrt(dirx@P1@dirx)
s = solve_ivp(fv, (0, 30), 0.99*np.sqrt(best)*dirx, **o)
revisar('punto de Omega_c (0.99 sqrt c*) converge: |x(30)|', np.linalg.norm(s.y[:, -1]), 0, 1e-4)
s = solve_ivp(fv, (0, 10), [3, 0], events=lambda tt, z: np.linalg.norm(z) - 20, **o)
revisar('desde (3, 0) (fuera del ciclo) diverge', np.linalg.norm(s.y[:, -1]) >= 19.9, 1)

th = np.linspace(0, 2*np.pi, 36001); cth, sth = np.cos(th), np.sin(th)
def area_q(q):
    Pq = lyapP(A1, np.diag([1, q])); Qd = cth**2 + q*sth**2; N = 2*(Pq[0, 1]*cth + Pq[1, 1]*sth)*cth**2*sth
    m = N > 0; d = np.vstack([cth[m], sth[m]]); Vq = (Qd[m]/N[m])*np.einsum('ij,ik,kj->j', d, Pq, d)
    return np.pi*Vq.min()/np.sqrt(np.linalg.det(Pq))
qs = np.linspace(0.2, 5, 481); ar = np.array([area_q(q) for q in qs])
revisar('Q = diag(1,q): mejora del área en el mejor q (~2 %)', ar.max()/area_q(1), 1.0203, 1e-3)
revisar('... en q ~ 0.8', qs[ar.argmax()], 0.8, 0.02)

print(f'\n{ok}/{total} verificaciones correctas')
