"""Verificación independiente de los números del capítulo 11 (pasividad).
Cada número que aparece en las notas, en las láminas o en los comentarios
de los códigos se recalcula aquí (sympy para lo exacto, scipy para lo
numérico). Los mismos números se prueban en MATLAB con verificarCap11.m.
Ejecutar:  python3 herramientas/cap11_numeros.py
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp, quad
from scipy.optimize import brentq

ok = True
n = 0


def revisar(nombre, valor, esperado, tol=1e-6):
    global ok, n
    n += 1
    v = float(np.real(complex(valor)))
    bien = abs(v - esperado) <= tol
    ok &= bien
    print(f"  {'ok  ' if bien else 'FALLA'} {nombre:<54s} {v:14.6f}  (esperado {esperado})")


def ode(f, T, x0, n=4001, **kw):
    t = np.linspace(0, T, n)
    s = solve_ivp(f, (0, T), x0, t_eval=t, rtol=1e-10, atol=1e-12, **kw)
    return s.t, s.y


def cumtrapz(y, t):
    return np.concatenate([[0], np.cumsum(0.5*(y[1:] + y[:-1])*np.diff(t))])


s, w, eps, p, p1, a, b, z, x1, x2, u = sp.symbols('s omega epsilon p p1 a b z x1 x2 u', real=True)

# ------------------------------------------------------------------ 11.2
print('11.2  Balance de energía: masa con resorte duro, F(x1) = x1 + x1^3, delta = 0.3')
F = x1 + x1**3
V = sp.integrate(F.subs(x1, sp.Symbol('q')), (sp.Symbol('q'), 0, x1)) + x2**2/2
dV = sp.diff(V, x1)*x2 + sp.diff(V, x2)*(-F - sp.Rational(3, 10)*x2 + u)
revisar('Vdot - (u y - delta y^2) = 0 (simbólico)', sp.simplify(dV - (u*x2 - sp.Rational(3, 10)*x2**2)), 0)
uf = lambda t: 0.8*np.sin(1.2*t)*(t < 12)
fm = lambda t, x: [x[1], -(x[0] + x[0]**3) - 0.3*x[1] + uf(t)]
t, X = ode(fm, 30, [0, 0], n=60001)
Vt = 0.5*X[0]**2 + 0.25*X[0]**4 + 0.5*X[1]**2
sumi = cumtrapz(uf(t)*X[1], t); dis = cumtrapz(0.3*X[1]**2, t)
revisar('max |V(t) - V(0) - sumin + disip|', np.max(abs(Vt - sumi + dis)), 0, 1e-4)
revisar('V(30) < V(12) (sin entrada solo disipa)', float(Vt[-1] < Vt[np.searchsorted(t, 12)]), 1, 0)
print(f'     V(12) = {Vt[np.searchsorted(t, 12)]:.4f}, V(30) = {Vt[-1]:.4f}, suministrada(12) = {sumi[np.searchsorted(t, 12)]:.4f}')

print('11.2  Señales: L2 frente a Linf')
revisar('energía de un pulso triangular h=k, base 1/k^4: 1/(3k^2), k=2', quad(lambda t: (2*(1 - abs(2*t*2**4 - 1)))**2, 0, 1/16)[0], 1/12, 1e-9)
revisar('suma de 1/(3k^2) = pi^2/18', float(sp.summation(1/(3*sp.Symbol('k')**2), (sp.Symbol('k'), 1, sp.oo))), np.pi**2/18, 1e-12)
revisar('int_0^T dt/(1+t) con T = 1e6 (diverge como ln T)', np.log1p(1e6), 13.815511, 1e-5)

print('11.3  Almacenamiento disponible del integrador')
x0 = sp.Symbol('x0'); xT = sp.Symbol('xT')
revisar('-int u y = x0^2/2 - xT^2/2 (x0=2, xT=0.5)', (x0**2/2 - xT**2/2).subs({x0: 2, xT: 0.5}), 1.875)

# ------------------------------------------------------------------ 11.4
print('11.4  Sin memoria: diodo túnel (Khalil, ej. 1.2.2) es pasivo con pendiente negativa')
h = lambda v: 17.76*v - 103.79*v**2 + 229.62*v**3 - 226.31*v**4 + 83.72*v**5
dh = lambda v: 17.76 - 2*103.79*v + 3*229.62*v**2 - 4*226.31*v**3 + 5*83.72*v**4
vv = np.linspace(-1.5, 1.5, 300001)
revisar('min_v v h(v) >= 0 en [-1.5, 1.5]', float(np.min(vv*h(vv)) >= -1e-12), 1, 0)
v1 = brentq(dh, 0.1, 0.4); v2 = brentq(dh, 0.4, 0.9)
revisar('pendiente negativa entre v1 (máximo local)', v1, 0.1381, 5e-4)
revisar('... y v2 (mínimo local)', v2, 0.6601, 5e-4)
revisar('h(v2) > 0 (la curva no baja al 4.o cuadrante)', h(v2), 0.0683, 5e-4)
vs = np.linspace(-5, 5, 10001); sat = np.clip(vs, -1, 1)
revisar('u sat(u) - sat(u)^2 >= 0 (saturación OSP)', float(np.min(vs*sat - sat**2) >= 0), 1, 0)

# ------------------------------------------------------------------ 11.5
print('11.5  Modelos de estado')
# RLC de Khalil: balance de potencia simbólico
L_, C_ = sp.symbols('L C', positive=True)
h1, h2, h3 = sp.Function('h1'), sp.Function('h2'), sp.Function('h3')
Vr = L_*x1**2/2 + C_*x2**2/2
dVr = L_*x1*(u - h2(x1) - x2)/L_ + C_*x2*(x1 - h3(x2))/C_
yr = x1 + h1(u)
revisar('u y = Vdot + u h1 + x1 h2 + x2 h3 (simbólico)', sp.simplify(u*yr - (dVr + u*h1(u) + x1*h2(x1) + x2*h3(x2))), 0)
# pasividad local
k = 1.0; xb = 1.5
revisar('x^3-kx+u: potencia suministrada por segundo (k=1, x=1.5)', -xb**2*(xb**2 - k), -2.8125)
revisar('umbral |x| <= sqrt(k), k = 1', np.sqrt(k), 1.0)
# trampa OSP: RLC lineal
Am = sp.Matrix([[0, 1], [-1, -1]]); Bm = sp.Matrix([0, 1]); Cm = sp.Matrix([[0, 1]])
G = sp.simplify((Cm*(s*sp.eye(2) - Am).inv()*Bm)[0])
revisar('G(s) = s/(s^2+s+1)', sp.simplify(G - s/(s**2 + s + 1)), 0)

# ------------------------------------------------------------------ 11.6
print('11.6  De la pasividad a la estabilidad')
Ve = (x1**2 + x2**2)/2 + eps*x1*x2
dVe = sp.expand(sp.diff(Ve, x1)*x2 + sp.diff(Ve, x2)*(-x1 - x2))
revisar('Vdot_eps = -eps x1^2 - eps x1 x2 - (1-eps) x2^2', sp.simplify(dVe - (-eps*x1**2 - eps*x1*x2 - (1 - eps)*x2**2)), 0)
eps_c = sp.solve(sp.Eq(eps*(1 - eps), eps**2/4), eps)
revisar('cota eps < 4/5', max(eps_c), 0.8)
# LaSalle: con u=0 la trayectoria toca x2=0 y no se queda allí; V decrece a 0
t, X = ode(lambda t, x: [x[1], -x[0] - x[1]], 20, [1.5, 0])
revisar('V(20) del RLC (x0 = [1.5, 0])', 0.5*(X[0, -1]**2 + X[1, -1]**2), 0, 1e-7)
# contraejemplo sin ZSO
revisar('x1 constante en el contraejemplo (x1(0) = 1)', 1.0, 1.0)

# ------------------------------------------------------------------ 11.7
print('11.7  Funciones reales positivas')
Gz = (s + z)/(s**2 + a*s + b)
ReG = sp.simplify(sp.re(Gz.subs(s, sp.I*w)))
revisar('Re Gz(jw) = (zb + (a-z) w^2)/|D|^2', sp.simplify(ReG - (z*b + (a - z)*w**2)/((b - w**2)**2 + a**2*w**2)), 0)
revisar('lim w^2 Re Gz = a - z  (a=3, z=1.5)', sp.limit((w**2*ReG).subs({a: 3, b: 2, z: sp.Rational(3, 2)}), w, sp.oo), 1.5)
wc = np.sqrt(5*2/(5 - 3))
revisar('z = 5: Re < 0 para w > sqrt(zb/(z-a)) = sqrt(5)', wc, np.sqrt(5))
G3 = (s + 3)/((s + 1)*(s + 2))
revisar('Re G(jw) de (s+3)/((s+1)(s+2)) en w = 1: 6/(1+9) = 0.6', sp.re(G3.subs(s, sp.I)), 0.6)
revisar('... y w^2 Re G -> 0', sp.limit(w**2*sp.re(G3.subs(s, sp.I*w)), w, sp.oo), 0)
# corrimiento: G(s - eps) con eps = 0.1 cruza al semiplano izquierdo
Gs = sp.lambdify(w, sp.re(G3.subs(s, sp.I*w - sp.Rational(1, 10))))
revisar('G(jw - 0.1): Re < 0 en w = 10', float(Gs(10.0) < 0), 1, 0)

print('11.7  Lema KYP: tres ejemplos')
# (a) RLC: P = I, L = [0 sqrt2], eps = 0
P = sp.diag(p, 1)
M = P*Am + Am.T*P
revisar('RLC: PA + A^T P con P = diag(p,1): entrada (1,2) = p - 1 (p=3)', M[0, 1].subs(p, 3), 2)
revisar('RLC: det(PA + A^T P) = -(1-p)^2 (p=3)', M.det().subs(p, 3), -4)
Lr = sp.Matrix([[0, sp.sqrt(2)]])
revisar('RLC: PA+A^TP + L^T L = 0 con P = I', (Am + Am.T + Lr.T*Lr).norm(), 0)
# (b) (s+3)/((s+1)(s+2))
A3 = sp.Matrix([[0, 1], [-2, -3]]); B3 = sp.Matrix([0, 1]); C3 = sp.Matrix([[3, 1]])
revisar('realización da (s+3)/(s^2+3s+2)', sp.simplify((C3*(s*sp.eye(2) - A3).inv()*B3)[0] - G3), 0)
P3 = sp.Matrix([[p1, 3], [3, 1]])
M3 = P3*A3 + A3.T*P3
revisar('(s+3)/..: entrada (1,1) = -12', M3[0, 0], -12)
revisar('(s+3)/..: entrada (2,2) = 0 (siempre)', M3[1, 1], 0)
revisar('(s+3)/..: entrada (1,2) = p1 - 11 (p1 = 11 -> 0)', M3[0, 1].subs(p1, 11), 0)
revisar('(s+3)/..: L = [2 sqrt3, 0] -> L^T L = 12', (2*sp.sqrt(3))**2, 12)
revisar('(s+3)/..: P > 0 con p1 = 11 (det = 2)', P3.subs(p1, 11).det(), 2)
# (c) SPR: (s+1.5)/((s+1)(s+2)), P = [6.5 1.5; 1.5 1]
Ac = np.array([[0, 1], [-2, -3.]]); Bc = np.array([[0], [1.]]); Cc = np.array([[1.5, 1.]])
Pc = np.array([[6.5, 1.5], [1.5, 1.]])
revisar('SPR: PB = C^T', np.linalg.norm(Pc @ Bc - Cc.T), 0)
Mc = Pc @ Ac + Ac.T @ Pc
revisar('SPR: PA + A^T P = diag(-6, -3)', np.linalg.norm(Mc - np.diag([-6, -3])), 0)
# mayor eps con -(Mc + eps P) >= 0
fe = lambda e: np.max(np.linalg.eigvals(Mc + e*Pc).real)
emax = brentq(fe, 0.01, 3)
revisar('SPR: eps máximo (Mc + eps P <= 0)', emax, 0.817179, 1e-5)
Lc = np.linalg.cholesky(-(Mc + 0.5*Pc)).T          # con eps = 0.5
revisar('SPR: con eps = 0.5, PA+A^TP = -L^TL - eps P', np.linalg.norm(Mc + Lc.T @ Lc + 0.5*Pc), 0, 1e-12)
revisar('SPR: L(1,1) con eps = 0.5', Lc[0, 0], np.sqrt(2.75), 1e-12)

# ------------------------------------------------------------------ 11.8
print('11.8  Interconexión: dos osciladores (a=1, k=0.5, b=2)')
def osc(t, x, a=1, k=0.5, b=2):
    e1 = -x[3]; e2 = x[1]
    return [x[1], -a*x[0]**3 - k*x[1] + e1, x[3], -b*x[2] - x[3]**3 + e2]
t, X = ode(osc, 40, [1.5, 0, 0, 0], n=40001)
V1 = 0.25*X[0]**4 + 0.5*X[1]**2; V2 = X[2]**2 + 0.5*X[3]**2
Vs = V1 + V2
revisar('V(0) = a x1^4/4 = 1.265625', Vs[0], 1.265625)
revisar('V es no creciente (max dV)', float(np.max(np.diff(Vs)) <= 1e-10), 1, 0)
revisar('V2 sube desde 0 hasta su máximo', V2.max(), 0.4922, 5e-4)
revisar('V1 sube en algún instante', float(np.max(np.diff(V1)) > 1e-4), 1, 0)
print(f'     V(10) = {Vs[np.searchsorted(t, 10)]:.4f}, V(40) = {Vs[-1]:.5f}, max V2 = {V2.max():.4f}')
dVnum = np.gradient(Vs, t); dVteo = -0.5*X[1]**2 - X[3]**4
revisar('Vdot = -k y1^2 - y2^4 (error numérico máx.)', np.max(abs(dVnum - dVteo)[5:-5]), 0, 1e-4)
# trampa del signo: realimentación positiva
e1, e2, y1, y2 = sp.symbols('e1 e2 y1 y2'); u1, u2 = sp.symbols('u1 u2')
revisar('cancelación con signos correctos', sp.expand((u1 - y2)*y1 + (u2 + y1)*y2 - u1*y1 - u2*y2), 0)
revisar('con realimentación positiva sobra 2 y1 y2 (y1=y2=1)', sp.expand((u1 + y2)*y1 + (u2 + y1)*y2 - u1*y1 - u2*y2).subs({y1: 1, y2: 1}), 2)

# ------------------------------------------------------------------ 11.9
print('11.9  Control basado en pasividad')
def osc3(t, x, kk, tipo):
    y = x[1]
    uu = -kk*y if tipo == 'lin' else -(2*kk/np.pi)*np.arctan(y)
    return [x[1], -x[0]**3 + uu]
for tipo in ('lin', 'atan'):
    t, X = ode(lambda t, x: osc3(t, x, 1.0, tipo), 60, [2, 0], n=6001)
    r = np.hypot(X[0], X[1])
    print(f'     u {tipo}: |x(60)| = {r[-1]:.4f}, max |u| = {np.max(abs(-X[1] if tipo == "lin" else -(2/np.pi)*np.arctan(X[1]))):.4f}')
revisar('cota |u| <= 2k/pi con atan (k=1)', 2/np.pi, 0.636620, 1e-6)
# péndulo: PD con y sin compensación de gravedad
m, l, g, bb, Kp, Kd = 1, 1, 9.81, 0.5, 20, 5
qr = np.pi/3
fpd = lambda q: Kp*(qr - q) - m*g*l*np.sin(q)
qss = brentq(fpd, 0, qr)
revisar('PD sin compensación: q_ss (rad)', qss, 0.722755, 1e-5)
revisar('... error q_r - q_ss (grados)', np.degrees(qr - qss), 18.589, 1e-3)
def pend(t, x, comp):
    q, dq = x
    uu = (m*g*l*np.sin(q) if comp else 0) - Kp*(q - qr) - Kd*dq
    return [dq, (uu - bb*dq - m*g*l*np.sin(q))/(m*l**2)]
t, X = ode(lambda t, x: pend(t, x, True), 10, [0, 0])
revisar('PD + compensación: q(10) = q_r', X[0, -1], qr, 1e-6)
t, X = ode(lambda t, x: pend(t, x, False), 10, [0, 0])
revisar('PD sin compensación: q(10) = q_ss', X[0, -1], qss, 1e-5)
# cascada: z' = u, x' = -x + x^2 z
print('11.9  Cascada: pasivación frente a u = -kz')
kk = 1.0
revisar('u = -kz: escape si x0 z0 > 1 + k (umbral, k=1)', 1 + kk, 2.0)
x0c, z0c = 1.0, 3.0      # x0 z0 = 3 > 2
te = np.log((z0c/(1 + kk))/(z0c/(1 + kk) - 1/x0c))/(1 + kk)
revisar('tiempo de escape exacto (x0=1, z0=3, k=1)', te, np.log(3)/2, 1e-12)
ev = lambda t, x: abs(x[0]) - 1e6; ev.terminal = True
sol = solve_ivp(lambda t, x: [-x[0] + x[0]**2*x[1], -kk*x[1]], (0, 5), [x0c, z0c], events=ev, rtol=1e-11, atol=1e-12)
revisar('simulación: escape en t = ln(3)/2 = 0.5493', sol.t_events[0][0], np.log(3)/2, 1e-5)
t, X = ode(lambda t, x: [-x[0] + x[0]**2*x[1], -x[0]**3 - kk*x[1]], 30, [x0c, z0c])
revisar('pasivación u = -x^3 - kz: |(x,z)|(30)', np.hypot(X[0, -1], X[1, -1]), 0, 1e-6)
Wc = 0.5*X[0]**2 + 0.5*X[1]**2
revisar('U = x^2/2 + z^2/2 no creciente', float(np.max(np.diff(Wc)) <= 1e-10), 1, 0)

# ------------------------------------------------------------------ 11.10
print('11.10 Distribución de agua (Q=2, r=2, vm=2, c=(0.6, 1.0, 1.4))')
Q, r_, vm = 2.0, 2.0, 2.0
c = np.array([0.6, 1.0, 1.4])
vst = Q**2/c.sum()**2; qst = c*Q/c.sum()
revisar('v* = 4/9', vst, 4/9, 1e-12)
revisar('q*_1 = 0.4', qst[0], 0.4, 1e-12)
revisar('q*_2 = 2/3', qst[1], 2/3, 1e-12)
revisar('q*_3 = 14/15', qst[2], 14/15, 1e-12)
c2 = np.array([0.6, 1.0, 2.0])
revisar('tras el cambio: v* = 4/12.96', Q**2/c2.sum()**2, 4/12.96, 1e-12)
revisar('tras el cambio: q*_3 = 10/9', c2[2]*Q/c2.sum(), 10/9, 1e-12)
revisar('q = 2 q*: V2 = -ln 2', np.sum(qst*np.log(qst/(2*qst)))/Q, -np.log(2), 1e-12)


def agua(t, x, cc):
    v, q = x[:3], x[3:]
    v = np.maximum(v, 0)
    Fi = r_*(1 - v/vm); Fb = q @ Fi/Q
    return np.concatenate([q - cc*np.sqrt(v), q*(Fi - Fb)])


def Vtot(X, cc):
    vs_ = Q**2/cc.sum()**2; qs_ = cc*Q/cc.sum()
    v, q = X[:3], X[3:]
    return r_/(2*Q*vm)*np.sum((v - vs_[None] if np.ndim(vs_) else v - vs_)**2, axis=0) + \
        np.sum(qs_[:, None]*np.log(qs_[:, None]/q), axis=0)/Q


x0w = np.array([0.1, 0.8, 0.3, 0.9, 0.6, 0.5])
t, X = ode(lambda t, x: agua(t, x, c), 40, x0w, n=8001)
Vw = Vtot(X, c)
revisar('sum q constante (= Q)', np.max(abs(X[3:].sum(axis=0) - Q)), 0, 1e-8)
revisar('V = V1 + V2 no creciente', float(np.max(np.diff(Vw)) <= 1e-9), 1, 0)
revisar('v(40) -> v* (error máx.)', np.max(abs(X[:3, -1] - vst)), 0, 2e-3)
revisar('q(40) -> q* (error máx.)', np.max(abs(X[3:, -1] - qst)), 0, 5e-3)
t2, X2 = ode(lambda t, x: agua(t, x, c2), 60, X[:, -1], n=12001)
revisar('tras el cambio, v -> 0.3086', X2[0, -1], 4/12.96, 2e-3)
revisar('tras el cambio, q3 -> 10/9', X2[5, -1], 10/9, 5e-3)

print('11.10 Trampa de las caras: q3(0) = 0 y q3(0) pequeño')
x0f = np.array([0.4, 0.4, 0.4, 1.0, 1.0, 0.0])
ev0 = lambda t, x: x[2] - 1e-9; ev0.terminal = True
sol = solve_ivp(lambda t, x: agua(t, x, c), (0, 50), x0f, events=ev0, rtol=1e-10, atol=1e-13)
tv = sol.t_events[0][0]
revisar('tanque 3 se vacía en tiempo finito 2 sqrt(v0)/c3', tv, 2*np.sqrt(0.4)/1.4, 1e-4)
def tiempo_llegada(q30, umbral=0.5):
    x0 = np.array([0.4, 0.4, 0.4, 1.0 - q30/2, 1.0 - q30/2, q30])
    ev = lambda t, x: x[5] - umbral; ev.terminal = True
    so = solve_ivp(lambda t, x: agua(t, x, c), (0, 400), x0, events=ev, rtol=1e-10, atol=1e-14)
    return so.t_events[0][0]
tl = [tiempo_llegada(10.0**-k) for k in (2, 4, 6, 8)]
dif = np.diff(tl)
print('     tiempo en que q3 llega a 0.5:', ', '.join(f'{x:.2f}' for x in tl))
revisar('retardo crece ~ ln(1/q3(0)): incrementos casi iguales', np.std(dif)/np.mean(dif), 0, 0.05)

print(f'\n{n} verificaciones; resultado global:', 'TODO BIEN' if ok else 'HAY FALLAS')
