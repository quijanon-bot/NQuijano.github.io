"""Verificación independiente (sympy/scipy) de los números del capítulo 10
(estabilidad avanzada: UUB, conversos, CLF, Barbalat e ISS).
Ejecutar:  python3 herramientas/cap10_numeros.py
Los mismos números se comprueban en MATLAB/Octave con codigo/cap10_avanzada/verificarCap10.m.
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp, quad
from scipy.linalg import solve_continuous_lyapunov
from scipy.optimize import brentq

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:66s} {float(valor):14.6g}" + ('' if bien else f'  (esperado {esperado})'))

o = dict(rtol=1e-11, atol=1e-12)
x, t, s, x1, x2, w = sp.symbols('x t s x1 x2 w', real=True)
def lyapP(A):   # A'P + PA = -I
    return solve_continuous_lyapunov(np.array(A, float).T, -np.eye(len(A)))

# ------------------------------------------------------------------ 10.2 UUB
print('10.2 UUB')
d = 1.0
revisar('escalar: T(a=14, b=1.05) = ln 260', np.log((14 - d)/(1.05 - d)), np.log(260))
revisar('... = 5.56', np.log(260), 5.56, 5e-3)
revisar('escalar: T(a=4, b=1.5) = ln 6 = 1.79', np.log(3/0.5), 1.79, 5e-3)
s1 = solve_ivp(lambda tt, z: [-z[0] + d*np.sin(tt)], (0, 60), [14.0], dense_output=True, **o)
tt = np.linspace(40, 60, 4001)
revisar('escalar: amplitud en régimen = delta/sqrt2', np.max(np.abs(s1.sol(tt)[0])), d/np.sqrt(2), 1e-6)
xc = lambda tt_, a: np.exp(-tt_)*a + d/2*((np.sin(tt_) - np.cos(tt_)) - np.exp(-tt_)*(0 - 1))
revisar('escalar: solución cerrada contra ode (t = 3)', s1.sol(3.0)[0], xc(3.0, 14.0), 1e-8)
c, eps_ = 14**2/2, 1.05**2/2; kk = 1.05**2 - d*1.05
revisar('Lyapunov: k = b^2 - delta b = 0.0525', kk, 0.0525, 1e-12)
revisar('Lyapunov: T <= (c - eps)/k = 1856', (c - eps_)/kk, 1856, 1)
# oscilador poco amortiguado
A = np.array([[0, 1], [-4, -0.2]]); P = lyapP(A); B = np.array([0, 1.0])
revisar('oscilador: P11 = 12.525', P[0, 0], 12.525, 1e-9)
revisar('oscilador: P12 = 0.125', P[0, 1], 0.125, 1e-9)
revisar('oscilador: P22 = 3.125', P[1, 1], 3.125, 1e-9)
lm = np.linalg.eigvalsh(P)
revisar('oscilador: lambda_min = 3.123', lm[0], 3.123, 1e-3)
revisar('oscilador: lambda_max = 12.527', lm[1], 12.527, 1e-3)
nPB = np.linalg.norm(P @ B)
revisar('oscilador: ||PB|| = 3.127', nPB, 3.127, 1e-3)
mu = 2*nPB*0.2/0.5; bb = mu*np.sqrt(lm[1]/lm[0])
revisar('oscilador theta = 1/2: mu = 2.50', mu, 2.50, 5e-3)
revisar('oscilador theta = 1/2: b = 5.01', bb, 5.01, 5e-3)
revisar('oscilador theta = 0.9: mu = 1.39', 2*nPB*0.2/0.9, 1.39, 5e-3)
s2 = solve_ivp(lambda tt, z: A @ z + B*0.2*np.sin(1.3*tt), (0, 40), [2.45, 0], max_step=0.01, **o)
r2 = np.linalg.norm(s2.y, axis=0); Vt = np.einsum('ij,ik,kj->j', s2.y, P, s2.y)
revisar('oscilador: la trayectoria sale de B_mu (max ||x|| > mu)', r2.max() > mu, 1)
revisar('oscilador: max ||x|| = 4.50 (w = 0.2 sin 1.3t)', r2.max(), 4.50, 1e-2)
revisar('oscilador: nunca sale de Omega_eta (V <= lambda_max mu^2)', Vt.max() <= lm[1]*mu**2, 1)
s3 = solve_ivp(lambda tt, z: A @ z, (0, 10), [2.45, 0], max_step=0.01, **o)
revisar('oscilador con w = 0: también sale de B_mu (excursión ~4.9)', np.linalg.norm(s3.y, axis=0).max() > mu, 1)
# resorte endurecido (Khalil Ej. 4.23)
V = sp.Rational(3, 2)*x1**2 + x1*x2 + x2**2 + x1**4/2
Vd = sp.expand(sp.diff(V, x1)*x2 + sp.diff(V, x2)*(-(1 + x1**2)*x1 - x2 + w))
revisar('resorte: Vdot = -x1^2 - x2^2 - x1^4 + (x1 + 2x2) w', sp.simplify(Vd - (-x1**2 - x2**2 - x1**4 + (x1 + 2*x2)*w)), 0)
lp = np.linalg.eigvalsh([[1.5, 0.5], [0.5, 1]])
revisar('resorte: lambda_min(P) = (5 - sqrt5)/4 = 0.691', lp[0], (5 - np.sqrt(5))/4)
revisar('resorte: lambda_max(P) = 1.809', lp[1], (5 + np.sqrt(5))/4)
M, th = 0.3, 0.9
mu_r = np.sqrt(5)*M/th; b_r = np.sqrt((lp[1]*mu_r**2 + mu_r**4/2)/lp[0])
revisar('resorte: mu = 0.745', mu_r, 0.745, 1e-3)
revisar('resorte: b = 1.30', b_r, 1.30, 5e-3)
def limsup_resorte(wf):
    s_ = solve_ivp(lambda tt, z: [z[1], -(1 + z[0]**2)*z[0] - z[1] + wf(tt)], (0, 200), [2, 0], dense_output=True, max_step=0.05, **o)
    tt_ = np.linspace(120, 200, 8001); return np.linalg.norm(s_.sol(tt_), axis=0).max()
revisar('resorte: limsup con w = 0.3 cos t = 0.30', limsup_resorte(lambda tt: M*np.cos(tt)), 0.30, 1e-2)
revisar('resorte: limsup con w = 0.3 cos 2t = 0.17', limsup_resorte(lambda tt: M*np.cos(2*tt)), 0.17, 1e-2)
revisar('resorte: limsup con w = 0.3 (constante) = 0.28', limsup_resorte(lambda tt: M), 0.28, 1e-2)
revisar('resorte (E2): c = V(2,0) = 14', float(V.subs({x1: 2, x2: 0})), 14)

# ------------------------------------------------------------------ 10.3 conversos
print('10.3 Conversos')
A1 = np.array([[0, 1], [-1, -1]]); P1 = lyapP(A1)
revisar('lineal: P = [1.5 0.5; 0.5 1] (P11)', P1[0, 0], 1.5)
revisar('lineal: P12 = 0.5', P1[0, 1], 0.5)
revisar('lineal: P22 = 1', P1[1, 1], 1.0)
x0 = np.array([1, 0.5])
revisar('lineal: V(1, 0.5) = 2.25', x0 @ P1 @ x0, 2.25)
from scipy.linalg import expm
revisar('lineal: integral de ||phi||^2 = 2.25', quad(lambda tau: np.linalg.norm(expm(A1*tau) @ x0)**2, 0, 60, limit=400)[0], 2.25, 1e-8)
# Kellett-Braun (2.51)
F51 = lambda tt, z: [z[1], np.sin(np.pi/(z[0]**2 + z[1]**2))**2*z[1] - z[0]]
for r0, rf in [(0.60, 1/np.sqrt(2)), (0.53, 1/np.sqrt(3))]:
    s_ = solve_ivp(F51, (0, 400), [r0, 0], **o)
    revisar(f'Kellett-Braun (2.51): desde r = {r0} tiende a la órbita r = {rf:.4f}', np.hypot(*s_.y[:, -1]), rf, 2e-3)
# robustez
lm1 = np.linalg.eigvalsh(P1)
revisar('robustez: c4 = 2 lambda_max(P) = 3.62', 2*lm1[1], 3.62, 5e-3)
revisar('robustez: nu* = c3/c4 = 0.276', 1/(2*lm1[1]), 0.276, 1e-3)
revisar('robustez: margen real de nu [0; x1]: Hurwitz si nu < 1', max(np.linalg.eigvals([[0, 1], [-1 + 0.999, -1]]).real) < 0 and max(np.linalg.eigvals([[0, 1], [-1 + 1.001, -1]]).real) > 0, 1)
A5 = np.array([[0, 1], [-2, -3]]); P5 = lyapP(A5)
revisar('E5: P = [1.25 0.25; 0.25 0.25] (P11)', P5[0, 0], 1.25)
revisar('E5: P12 = P22 = 0.25', P5[0, 1] + P5[1, 1], 0.5)
revisar('E5: nu* = 1/(2 lambda_max) = 0.382', 1/(2*np.linalg.eigvalsh(P5)[1]), 0.382, 1e-3)
revisar("E6: x' = -x^3: integral de phi^2 diverge (log)", sp.limit(sp.log(1 + 2*t)/2, t, sp.oo) == sp.oo, 1)

# ------------------------------------------------------------------ 10.4 CLF y Sontag
print('10.4 CLF y Sontag')
p, q, r = sp.symbols('p q r', positive=True)
Lg = 2*(q*x1 + r*x2); Lf = 2*x2*(p*x1 + q*x2)
revisar('doble integrador: L_fV en L_gV = 0 es -2q(pr - q^2) x1^2/r^2',
        sp.simplify(Lf.subs(x2, -q*x1/r) + 2*q*(p*r - q**2)*x1**2/r**2), 0)
def sontag(lf, lg):
    return 0.0 if lg == 0 else -(lf + np.sqrt(lf**2 + lg**4))/lg
f0 = g0 = 1.0
revisar('lineal f = g = 1: ganancia -(1 + sqrt2) = -2.414', sontag(f0*1, g0*1), -(1 + np.sqrt(2)))
revisar('lineal: u(0) desde x = 2 = -4.83', sontag(f0*4, g0*2), -4.83, 5e-3)
revisar("lineal: u = 1 con f = 1: x(10) = 3e^10 - 1 = 6.6e4", 3*np.exp(10) - 1, 6.6e4, 1e3)
# cos x - x^3 + u
uS = lambda xx: -np.cos(xx) + xx**3 - xx*np.sqrt(xx**4 + 1)
uF = lambda xx: -np.cos(xx) + xx**3 - xx
revisar('coseno: u_Sontag(0) desde x = 2 = 0.17', uS(2.0), 0.17, 5e-3)
revisar('coseno: u_FL(0) = 6.42', uF(2.0), 6.42, 5e-3)
sc = solve_ivp(lambda tt, z: [np.cos(z[0]) - z[0]**3 + uS(z[0])], (0, 10), [2.0], **o)
revisar('coseno: lazo de Sontag x -> 0', abs(sc.y[0, -1]) < 1e-4, 1)
revisar('coseno: u(t) -> -1 (no 0)', uS(sc.y[0, -1]), -1, 1e-4)
revisar('coseno: para x grande, x^3 - x sqrt(x^4+1) ~ -1/(2x) (x = 10)', 10**3 - 10*np.sqrt(10**4 + 1), -1/20, 1e-4)
# control pequeño: x' = x + x^2 u
k8 = lambda xx: -(1 + np.sqrt(1 + xx**8))/xx
s8 = solve_ivp(lambda tt, z: [z[0] + z[0]**2*k8(z[0])], (0, 8), [1.0], **o)
revisar('control pequeño: x(8) ~ e^{-8} (GAS)', s8.y[0, -1], np.exp(-8), 1e-4)
revisar('control pequeño: |u(8)| = 2/x(8) > 6000 (diverge)', abs(k8(s8.y[0, -1]))*s8.y[0, -1]/2, 1, 1e-6)
revisar('... |u(8)| = 6249', abs(k8(s8.y[0, -1])), 6249, 2)
# x' = x^3 + x^2 u
k9 = lambda xx: -xx*(1 + np.sqrt(1 + xx**4))
revisar('ejemplo 4: Sontag linealizado en 0 = -2x (diseño a mano con c1 = 1)', (k9(1e-4) - k9(-1e-4))/2e-4, -2, 1e-6)
revisar('ejemplo 4: Vdot de Sontag = -x^4 sqrt(1 + x^4) en x = 1', 1**4 + 1**3*k9(1.0), -np.sqrt(2))
# E10
k10 = lambda xx: -xx*((1 - xx**2) + np.sqrt((1 - xx**2)**2 + 1))
revisar('E10: k(10) ~ -x/(2(x^2 - 1)) (conserva -x^3)', k10(10.0), -10/(2*99), 2e-5)
# fórmula: decrecimiento y la variante con lg^2
revisar('Sontag: Vdot = -sqrt(lf^2 + lg^4) (lf = 0.3, lg = 0.7)', 0.3 + 0.7*sontag(0.3, 0.7), -np.sqrt(0.09 + 0.7**4))
revisar('variante lg^2 con lf = 0: k = -sign(lg) (salta)', -(0 + np.sqrt(0 + 1e-6**2))/1e-6, -1)
revisar('variante lg^4 con lf = 0: k = -lg -> 0', sontag(0.0, 1e-3), -1e-3, 1e-12)

# ------------------------------------------------------------------ 10.5 Barbalat
print('10.5 Barbalat')
revisar('pulsos: área total = pi^2/12', sum(1/(2*k**2) for k in range(1, 200001)), np.pi**2/12, 1e-5)
revisar('sin(t^2): t_n y s_n se acercan (n = 1000): s - t < 0.02', np.sqrt(2*np.pi*1000 + np.pi/2) - np.sqrt(2*np.pi*1000), 0.0099, 2e-4)
def adapt(wf, T=40):
    return solve_ivp(lambda tt, z: [-z[0] + z[1]*wf(tt), -z[0]*wf(tt)], (0, T), [1, 1], **o).y[:, -1]
ea, tha = adapt(np.sin)
revisar('adaptativo w = sin t: e(40) -> 0', abs(ea) < 1e-3, 1)
revisar('adaptativo w = sin t: theta(40) -> 0', abs(tha) < 0.05, 1)
eb, thb = adapt(lambda tt: np.exp(-0.3*tt))
revisar('adaptativo w = e^{-0.3t}: theta -> -0.11', thb, -0.11, 5e-3)
e_, th_, om, omd = sp.symbols('e theta omega omegadot', real=True)
revisar('adaptativo: Vdot = -2e^2', sp.expand(2*e_*(-e_ + th_*om) + 2*th_*(-e_*om) + 2*e_**2), 0)

# ------------------------------------------------------------------ 10.6 ISS
print('10.6 ISS')
xr = (3 - sp.exp(t))/(3 - 2*sp.exp(t))
revisar("x' = -3x + (1 + 2x^2): x(t) = (3 - e^t)/(3 - 2e^t) resuelve con w = 1", sp.simplify(sp.diff(xr, t) - (-3*xr + 1 + 2*xr**2)), 0)
revisar('... x(0) = 2', xr.subs(t, 0), 2)
revisar('... escape en t = ln(3/2) = 0.405', np.log(1.5), 0.405, 1e-3)
ev = lambda tt, z: z[0] - 1e6; ev.terminal = True
se = solve_ivp(lambda tt, z: [-3*z[0] + 1 + 2*z[0]**2], (0, 1), [2.0], events=ev, **o)
revisar('... escape simulado', se.t_events[0][0], np.log(1.5), 1e-5)
def limsup_iss(x0_):
    s_ = solve_ivp(lambda tt, z: [-z[0]**3 + 0.5*np.sin(2*tt)], (0, 40), [x0_], dense_output=True, **o)
    return np.abs(s_.sol(np.linspace(20, 40, 4001))[0]).max()
revisar('ISS -x^3 + w: gamma(0.5) con theta = 0.5 = 1', (0.5/0.5)**(1/3), 1)
revisar('ISS -x^3 + 0.5 sin 2t: limsup real < gamma', limsup_iss(3.0) < 1, 1)
revisar('ISS ejemplo (b): Vdot <= -x^4 si |x| >= w^2 (x = 1.2, w = 1)', (-1.2**2 - 2*1.2**4 + 1.2*(1 + 1.2**2)*1) <= -1.2**4, 1)
# rediseño
ev = lambda tt, z: z[0] - 1e8; ev.terminal = True
sr = solve_ivp(lambda tt, z: [z[0] + (z[0]**2 + 1)*(-2*z[0]/(z[0]**2 + 1) + 1)], (0, 5), [0.0], events=ev, **o)
revisar('rediseño: con k y w = 1 escapa desde 0 en 4 pi/(3 sqrt3) = 2.42', sr.t_events[0][0], 4*np.pi/(3*np.sqrt(3)), 1e-4)
k1 = lambda xx: -2*xx/(xx**2 + 1) - xx*(xx**2 + 1)
s1r = solve_ivp(lambda tt, z: [z[0] + (z[0]**2 + 1)*(k1(z[0]) + 1)], (0, 6), [0.0], **o)
revisar('rediseño: con k1 = k - LgV y w = 1, x(6) acotado (0.4887, un equilibrio)', s1r.y[0, -1], 0.4887, 2e-4)
epsv = 0.1; xm = (1 - np.sqrt(1 - 4*epsv**2))/(2*epsv); xp = (1 + np.sqrt(1 - 4*epsv**2))/(2*epsv)
revisar('rediseño, w = 0.1: x_- = 0.101', xm, 0.101, 1e-3)
revisar('rediseño, w = 0.1: x_+ = 9.90', xp, 9.90, 1e-2)
s_ = solve_ivp(lambda tt, z: [-z[0] + (z[0]**2 + 1)*epsv], (0, 3), [10.5], events=ev, **o)
revisar('rediseño, w = 0.1: desde x(0) = 10.5 > x_+ escapa', len(s_.t_events[0]) > 0, 1)
revisar('Young: x(x^2+1)w <= x^2(x^2+1)^2/2 + w^2/2 (x = 0.7, w = 2)', 0.7*(1.49)*2 <= 0.49*1.49**2/2 + 2, 1)

# ------------------------------------------------------------------ 10.7 interconexiones
print('10.7 Interconexiones')
ev = lambda tt, z: abs(z[0]) - 1e8; ev.terminal = True
sc1 = solve_ivp(lambda tt, z: [-z[0] + z[0]**2*z[1], -z[1]], (0, 2), [2, 2], events=ev, **o)
revisar('cascada x1^2 x2: escape desde (2,2) en (1/2) ln 2 = 0.347', sc1.t_events[0][0], 0.5*np.log(2), 1e-5)
X10, X20 = 1.0, 3.0
x1c = lambda tt: X10*np.exp(-tt + X20**2/2*(1 - np.exp(-2*tt)))
sc2 = solve_ivp(lambda tt, z: [-z[0] + z[0]*z[1]**2, -z[1]], (0, 10), [X10, X20], **o)
revisar('cascada x1 x2^2: fórmula exacta (t = 10)', sc2.y[0, -1], x1c(10.0), 1e-9)
tm = brentq(lambda tt: -1 + X20**2*np.exp(-2*tt), 0.01, 5)
revisar('cascada x1 x2^2 desde (1, 3): pico de x1 = 18.2 = e^{4 - ln 3}', x1c(tm), 18.2, 0.01)
revisar('cascada: Young |x2|^3|w| <= x2^4/2 + 27/32 w^4 (lambda^4 = 8/27)', 1/(4*(8/27)), 27/32)
vv = sp.Rational(1, 2)*x1**2 + sp.Rational(1, 4)*sp.Symbol('a')*x2**4
a_ = sp.Symbol('a')
Vd2 = sp.expand(x1*(-x1 + x2**2) + a_*x2**3*(-x2))
revisar('V compuesta: Vdot = -(x1 - x2^2/2)^2 - (a - 1/4) x2^4', sp.simplify(Vd2 + (x1 - x2**2/2)**2 + (a_ - sp.Rational(1, 4))*x2**4), 0)
revisar('errata Handout7 (a = 1): -1/2(x1 - x2^2)^2 - 1/2(x1^2 + x2^4)',
        sp.expand(-sp.Rational(1, 2)*(x1 - x2**2)**2 - sp.Rational(1, 2)*(x1**2 + x2**4) - (-x1**2 + x1*x2**2 - x2**4)), 0)
xs = brentq(lambda z: z - 1.2*np.sin(z), 0.5, 2)
revisar('pequeña ganancia a = 1, b = 1.2: equilibrio x* = 1.027', xs, 1.027, 1e-3)
revisar('... ab cos x* = 0.62 < 1 (nodos estables)', 1.2*np.cos(xs), 0.62, 5e-3)
revisar('... en el origen, -1 + sqrt(1.2) > 0 (silla)', -1 + np.sqrt(1.2) > 0, 1)
revisar('ab = -3: x = -3 sin x solo en 0', len([z for z in np.linspace(-10, 10, 200001)[:-1] if (z + 3*np.sin(z))*((z + 1e-4) + 3*np.sin(z + 1e-4)) < 0]), 1)
revisar('ab = -3: valores propios -1 +- j sqrt3 (foco)', np.linalg.eigvals([[-1, 1], [-3, -1]]).imag.max(), np.sqrt(3))
revisar('E24: -1 + sqrt2 > 0', np.linalg.eigvals([[-1, 2], [1, -1]]).real.max(), -1 + np.sqrt(2))
s_ = solve_ivp(lambda tt, z: [-z[0] + z[1], -z[1] - 3*np.sin(z[0])], (0, 60), [3, -2], **o)
revisar('ab = -3: GAS desde (3, -2)', np.linalg.norm(s_.y[:, -1]) < 1e-6, 1)

# ------------------------------------------------------------------ problemas
print('Problemas')
Pr = np.array([[1.5, .5], [.5, 1]]); Vr = lambda x: x @ Pr @ x + 0.5*x[0]**4
Mr, thr = 0.3, 0.9; mur = np.sqrt(5)*Mr/thr; etar = (5 + np.sqrt(5))/4*mur**2 + mur**4/2; kr = (1 - thr)*mur**2
revisar('P10.2: c = V(2,0) = 14', Vr(np.array([2., 0.])), 14)
revisar('P10.2: eta = 1.16', etar, 1.16, 5e-3)
revisar('P10.2: T <= (c - eta)/k = 231', (14 - etar)/kr, 231, 0.5)
sr_ = solve_ivp(lambda tt, z: [z[1], -(1 + z[0]**2)*z[0] - z[1] + Mr*np.cos(tt)], (0, 20), [2, 0], dense_output=True, **o)
ttr = np.linspace(0, 20, 20001); vr_ = np.array([Vr(sr_.sol(q)) for q in ttr])
revisar('P10.2: la simulación entra a Omega_eta en t ~ 2.1', ttr[np.where(vr_ > etar)[0][-1]], 2.15, 0.05)
s_ = solve_ivp(lambda tt, z: [-z[0]**3 + 0.5*np.sin(tt)], (0, 80), [2], dense_output=True, **o)
revisar('P10.1: limsup con delta = 0.5 es 0.49 < 0.5^(1/3) = 0.794', np.abs(s_.sol(np.linspace(40, 80, 8001))[0]).max(), 0.49, 5e-3)
revisar('P10.4: con g_p = nu [0; x1] deja de ser Hurwitz en nu = 2', np.linalg.eigvals([[0, 1], [-2 + 2, -3]]).real.max(), 0, 1e-12)
kc = lambda xx: -xx*((1 - xx**2) + np.sqrt((1 - xx**2)**2 + 1))
for nom, uu, esf, tt01 in [('Sontag', kc, 1.46, 4.0), ('cancelación', lambda xx: -2*xx + xx**3, 58.5, 5.7)]:
    s_ = solve_ivp(lambda tt, z: [z[0] - z[0]**3 + uu(z[0]), uu(z[0])**2], (0, 10), [3, 0], dense_output=True, **o)
    tq = np.linspace(0, 10, 100001); xq = s_.sol(tq)[0]
    revisar(f'P10.6: esfuerzo {nom} = {esf}', s_.y[1, -1], esf, 0.01)
    revisar(f'P10.6: {nom} llega a |x| < 0.01 en t = {tt01}', tq[np.argmax(np.abs(xq) < 0.01)], tt01, 0.06)
revisar('P10.6: Sontag u(0) = -0.19', kc(3.0), -0.19, 5e-3)
def kk(xx):
    lf, lg = xx**2, xx*(xx**2 + 1)
    return 0.0 if abs(lg) < 1e-14 else -(1 + (lf + np.sqrt(lf**2 + lg**4))/lg**2)*lg
s_ = solve_ivp(lambda tt, z: [z[0] + (z[0]**2 + 1)*(kk(z[0]) + 1)], (0, 10), [0], **o)
revisar('P10.10: Sontag con kappa = 1 y w = 1 se asienta en 0.386', s_.y[0, -1], 0.386, 1e-3)

print(f'\n{ok}/{total} verificaciones correctas')
