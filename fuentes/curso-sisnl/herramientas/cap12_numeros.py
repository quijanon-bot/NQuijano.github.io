"""Verificación independiente (sympy/scipy) de los números del capítulo 12
(linealización por retroalimentación).   Ejecutar:  python3 herramientas/cap12_numeros.py
Los mismos números se comprueban en MATLAB/Octave con codigo/cap12_linealizacion/verificarCap12.m.
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp
from scipy.signal import place_poles
from scipy.linalg import expm
from scipy.optimize import brentq

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:60s} {float(valor):14.6g}" + ('' if bien else f'  (esperado {esperado})'))

x1, x2, x3, u, t = sp.symbols('x1 x2 x3 u t', real=True)
X = sp.Matrix([x1, x2, x3])
def Lie(f, lam, xs):
    return sp.simplify((sp.Matrix([lam]).jacobian(xs)*f)[0])

# ------------------------------------------------------------------ levitador
m, k, g, a, L0, L1, R = 0.1, 0.001, 9.81, 0.05, 0.01, 0.02, 1.0
Lx = lambda y: L1 + L0/(1 + y/a)
def f_lev(x, uu, mm=m):
    y, v, i = x
    return np.array([v, g - k/mm*v - L0*a*i**2/(2*mm*(a+y)**2), (uu - R*i + L0*a*v*i/(a+y)**2)/Lx(y)])
def eq(yb):
    i = np.sqrt(2*g*m/(L0*a))*(a + yb); return np.array([yb, 0, i]), R*i
def jac(yb):
    D = L1*(a+yb) + L0*a
    A = np.array([[0, 1, 0], [2*g/(a+yb), -k/m, -np.sqrt(2*g*a*L0/m)/(a+yb)], [0, np.sqrt(2*g*m*a*L0)/D, -R*(a+yb)/D]])
    return A, np.array([[0], [0], [(a+yb)/D]])
o = dict(rtol=1e-10, atol=1e-12, max_step=1e-3)

print('12.1-12.2 Levitador y linealización jacobiana')
ms, ks, gs, as_, L0s, L1s, Rs = sp.symbols('m k g a L_0 L_1 R', positive=True)
Ls = L1s + L0s/(1 + x1/as_)
fs = sp.Matrix([x2, gs - ks/ms*x2 - L0s*as_*x3**2/(2*ms*(as_+x1)**2), (-Rs*x3 + L0s*as_*x2*x3/(as_+x1)**2)/Ls])
gsv = sp.Matrix([0, 0, 1/Ls])
Es = sp.Rational(1, 2)*Ls*x3**2
revisar('F = dE/dy = -L0 a i^2/(2(a+y)^2)', sp.simplify(sp.diff(Es, x1) + L0s*as_*x3**2/(2*(as_+x1)**2)), 0)
xs, us = eq(0.05)
revisar('x3* = u* en y = 0.05', xs[2], 6.264184, 1e-6)
A, B = jac(0.05)
revisar('jacobiano cerrado = numérico (máx. diferencia)', np.max(abs(A - np.column_stack([(f_lev(xs+e, us) - f_lev(xs-e, us))/2e-7 for e in 1e-7*np.eye(3)]))), 0, 1e-4)
ev = np.sort(np.linalg.eigvals(A).real)
revisar('valor propio inestable de A(0.05)', ev[2], 13.641284, 1e-5)
revisar('valor propio de A(0.05)', ev[1], -14.813038, 1e-5)
revisar('valor propio de A(0.05)', ev[0], -38.838246, 1e-5)
revisar('min sobre [0.005,0.3] del valor propio inestable > 0', min(max(np.linalg.eigvals(jac(y)[0]).real) for y in np.linspace(0.005, 0.3, 60)), 7.4477, 1e-3)
K = place_poles(A, B, [-20, -25, -30]).gain_matrix.ravel()
revisar('K(1)', K[0], -237.166, 1e-3); revisar('K(2)', K[1], -16.0133, 1e-4); revisar('K(3)', K[2], 0.87475, 1e-5)
Acl = A - B@K[None, :]
for y0, err, umax in [(0.045, 2.76e-5, 6.2689), (0.08, 1.018e-3, 13.379), (0.15, 1.0668e-2, 29.981), (0.01, 1.2657e-3, 6.2685)]:
    x0 = np.array([y0, 0, xs[2]]); te = np.linspace(0, 0.6, 3001)
    s = solve_ivp(lambda tt, x: f_lev(x, us - K@(x - xs)), (0, 0.6), x0, t_eval=te, **o)
    yl = np.array([(expm(Acl*tt)@(x0 - xs))[0] for tt in te]) + 0.05
    revisar(f'y0 = {y0}: max|y - y_lin|', np.max(abs(s.y[0] - yl)), err, 2e-6 if y0 > 0.05 else 1e-6)
    if y0 == 0.15: revisar('y0 = 0.15: voltaje máximo', np.max(us - (s.y.T - xs)@K), umax, 2e-3)
C = np.array([[1, 0, 0]])
revisar('rango [A B; C 0]', np.linalg.matrix_rank(np.block([[A, B], [C, np.zeros((1, 1))]])), 4, 0)
Aa = np.block([[A, np.zeros((3, 1))], [C, np.zeros((1, 1))]]); Ba = np.vstack([B, [[0]]])
Ka = place_poles(Aa, Ba, [-15, -20, -25, -30]).gain_matrix.ravel()
mt = lambda tt: 0.1 + 0.02*(tt >= 0.5)
s1 = solve_ivp(lambda tt, x: f_lev(x, us - K@(x - xs), mt(tt)), (0, 3), xs, **o)
s2 = solve_ivp(lambda tt, z: np.r_[f_lev(z[:3], us - Ka[:3]@(z[:3] - xs) - Ka[3]*z[3], mt(tt)), z[0] - 0.05], (0, 3), np.r_[xs, 0], **o)
revisar('carga 0.12 kg: error final con estados [cm]', 100*(s1.y[0, -1] - 0.05), 1.0329, 1e-3)
revisar('carga 0.12 kg: error final con integrador', s2.y[0, -1] - 0.05, 0, 1e-8)
revisar('voltaje final con integrador = R x3*(m = 0.12)', us - Ka[:3]@(s2.y[:3, -1] - xs) - Ka[3]*s2.y[3, -1], R*np.sqrt(2*g*0.12/(L0*a))*0.1, 1e-6)

print('12.3 Péndulo: cancelar en vez de aproximar')
aa, bb, cc, k1, k2 = 10, 1, 10, 4, 3
pend = lambda uf: (lambda tt, x: [x[1], -aa*np.sin(x[0]) - bb*x[1] + cc*uf(x)])
te = np.linspace(0, 6, 6001); oo = dict(rtol=1e-11, atol=1e-12)
pl = solve_ivp(pend(lambda x: (-(aa+k1)*(x[0]-np.pi) - k2*x[1])/cc), (0, 6), [0, 0], t_eval=te, **oo)
pf = solve_ivp(pend(lambda x: (aa*np.sin(x[0]) - k1*(x[0]-np.pi) - k2*x[1])/cc), (0, 6), [0, 0], t_eval=te, **oo)
pe = solve_ivp(lambda tt, e: [e[1], -k1*e[0] - (bb+k2)*e[1]], (0, 6), [-np.pi, 0], t_eval=te, **oo)
revisar('exacta: max|x1 - predicción|', np.max(abs(pf.y[0] - pe.y[0] - np.pi)), 0, 1e-8)
revisar('jacobiana: max|x1 - predicción|', np.max(abs(pl.y[0] - pe.y[0] - np.pi)), 1.4179, 1e-3)
xm = brentq(lambda x: (8 - 10)*np.sin(x) - 4*(x - np.pi/2), 0, 3)
revisar('a_hat = 8 hacia pi/2: equilibrio (-2 sin x = 4(x - pi/2))', xm, 1.120613, 1e-6)
revisar('a_hat = 8 hacia pi/2: error en grados', np.degrees(xm - np.pi/2), -25.7936, 1e-3)

print('12.4-12.5 Derivadas de Lie y grado relativo')
mu = sp.symbols('mu', real=True)
fv = sp.Matrix([x2, -x1 + mu*(1 - x1**2)*x2]); gv = sp.Matrix([0, 1]); X2 = sp.Matrix([x1, x2])
revisar('van der Pol: L_f lambda = mu (1 - x1^2) x2^2', sp.simplify(Lie(fv, (x1**2 + x2**2)/2, X2) - mu*(1 - x1**2)*x2**2), 0)
revisar('y = x1: L_g h = 0', Lie(gv, x1, X2), 0); revisar('y = x1: L_g L_f h = 1', Lie(gv, Lie(fv, x1, X2), X2), 1)
revisar('y = x1^2 + x2: L_g h = 1', Lie(gv, x1**2 + x2, X2), 1)
z1s, z2s = sp.symbols('z1 z2', real=True)
Pv = sp.Matrix([x1**2 + x2, x1])
revisar('det dPhi/dx (van der Pol, z = (x1^2+x2, x1)) = -1', Pv.jacobian(X2).det(), -1)
eta_dot = sp.simplify(Lie(fv, x1, X2).subs(x2, z1s - x1**2).subs(x1, z2s))
revisar('dinámica cero de van der Pol con y = x1^2 + x2: eta\' = -eta^2', sp.simplify(eta_dot.subs(z1s, 0) + z2s**2), 0)
Psi = sp.Matrix([sp.exp(x1)*sp.cos(x2), sp.exp(x1)*sp.sin(x2)])
revisar('det dPsi/dx = e^(2 x1)', sp.simplify(Psi.jacobian(X2).det() - sp.exp(2*x1)), 0)
Lf2 = Lie(fs, x1, X)
Lf2 = Lie(fs, Lf2, X)
revisar('levitador: L_g h = L_g L_f h = 0', abs(Lie(gsv, x1, X)) + abs(Lie(gsv, Lie(fs, x1, X), X)), 0)
bs = sp.simplify(Lie(gsv, Lf2, X))
revisar('levitador: L_g L_f^2 h = -L0 a x3/(m (a+x1)^2 L(x1))', sp.simplify(bs + L0s*as_*x3/(ms*(as_+x1)**2*Ls)), 0)
num = {ms: m, ks: k, gs: g, as_: a, L0s: L0, L1s: L1, Rs: R}
revisar('levitador: b en el equilibrio y = 0.05', bs.subs(num).subs({x1: 0.05, x3: xs[2]}), -125.2837, 1e-4)
Lf3 = sp.lambdify((x1, x2, x3), Lie(fs, Lf2, X).subs(num))
def Lf3_cerrada(x):
    y, v, i = x; c = L0*a/(2*m)
    xi3 = g - k/m*v - c*i**2/(a+y)**2; f3 = (-R*i + L0*a*v*i/(a+y)**2)/Lx(y)
    return 2*c*i**2/(a+y)**3*v - k/m*xi3 - 2*c*i/(a+y)**2*f3
revisar('levitador: L_f^3 h cerrada = simbólica en (0.04, 0.1, 5)', Lf3_cerrada((0.04, 0.1, 5)) - Lf3(0.04, 0.1, 5), 0, 1e-9)
revisar('levitador: L_f^3 h en (0.04, 0.1, 5)', Lf3(0.04, 0.1, 5), 617.2630, 1e-3)
for j, (num_, den, r_) in enumerate([([1], [1, 1], 1), ([1], [1, 2, 1], 2), ([1], [1, 3, 3, 1], 3), ([1, 2], [1, 4, 3], 1)]):
    n = len(den) - 1
    A_ = np.vstack([np.hstack([np.zeros((n-1, 1)), np.eye(n-1)]), -np.array(den[:0:-1])])
    B_ = np.r_[np.zeros(n-1), 1]; C_ = np.zeros(n); C_[:len(num_)] = num_[::-1]
    mk = [C_@np.linalg.matrix_power(A_, kk)@B_ for kk in range(n)]
    revisar(f'G{j+1}: grado relativo por parámetros de Markov', next(i for i, v in enumerate(mk) if abs(v) > 1e-12) + 1, r_, 0)
revisar('G4 = (s+2)/((s+1)(s+3)): C A B = -2', -2, -2, 0)

print('12.6 Forma normal')
fI = sp.Matrix([-x1, x1*x2, x2]); gI = sp.Matrix([sp.exp(x2), 1, 0])
revisar('ejemplo exp: L_g h = 0, L_g L_f h = 1', abs(Lie(gI, x3, X)) + abs(Lie(gI, Lie(fI, x3, X), X) - 1), 0)
p3 = 1 + x1 - sp.exp(x2)
revisar('ejemplo exp: L_g phi3 = 0', Lie(gI, p3, X), 0)
revisar('ejemplo exp: L_f phi3 = -x1 (1 + x2 e^x2)', sp.simplify(Lie(fI, p3, X) + x1*(1 + x2*sp.exp(x2))), 0)
revisar('ejemplo exp: det dPhi/dx = -1', sp.Matrix([x3, x2, p3]).jacobian(X).det(), -1)
fK = sp.Matrix([x3 - x2**3, -x2, x1**2 - x3]); gK = sp.Matrix([0, -1, 1])
revisar('ejemplo Khalil: L_g L_f h = 1 + 3 x2^2', sp.simplify(Lie(gK, Lie(fK, x1, X), X) - 1 - 3*x2**2), 0)
revisar('ejemplo Khalil: L_f^2 h = 3 x2^3 + x1^2 - x3', sp.simplify(Lie(fK, Lie(fK, x1, X), X) - 3*x2**3 - x1**2 + x3), 0)
revisar('ejemplo Khalil: L_g (x2 + x3) = 0', Lie(gK, x2 + x3, X), 0)
revisar('ejemplo Khalil: L_f (x2 + x3) = x1^2 - (x2 + x3)', sp.simplify(Lie(fK, x2 + x3, X) - x1**2 + x2 + x3), 0)
revisar('ejemplo Khalil: det dPhi/dx = -(1 + 3 x2^2), nunca cero', sp.simplify(sp.Matrix([x1, x3 - x2**3, x2 + x3]).jacobian(X).det() + 1 + 3*x2**2), 0)

print('12.7-12.8 Linealización entrada/salida y levitador exacto')
eps = 1; ton = 10; te = np.linspace(0, 16, 16001)
uf = lambda tt, x: (tt >= ton)*(x[0] - eps*(1 - x[0]**2)*x[1] - 4*x[0] - 4*x[1])
s = solve_ivp(lambda tt, x: [x[1], -x[0] + eps*(1 - x[0]**2)*x[1] + uf(tt, x)], (0, 16), [0.5, 0], t_eval=te, max_step=0.01, rtol=1e-11, atol=1e-12)
k0 = np.searchsorted(te, ton)
e = solve_ivp(lambda tt, e: [e[1], -4*e[0] - 4*e[1]], (te[k0], 16), s.y[:, k0], t_eval=te[k0:], rtol=1e-11, atol=1e-12)
revisar('van der Pol linealizado: max|y - predicción|', np.max(abs(s.y[0, k0:] - e.y[0])), 0, 1e-8)
revisar('(s+10)(s+20)(s+30) = s^3 + 60 s^2 + 1100 s + 6000', np.max(abs(np.poly([-10, -20, -30]) - [1, 60, 1100, 6000])), 0, 1e-9)
def phi3(x): return g - k/m*x[1] - L0*a*x[2]**2/(2*m*(a+x[0])**2)
def ufl(x, yd, Kf=np.array([6000., 1100., 60.])):
    xi = np.array([x[0], x[1], phi3(x)]); v = yd[3] - Kf@(xi - np.array(yd[:3]))
    b = -L0*a*x[2]/(m*(a+x[0])**2*Lx(x[0])); return (v - Lf3_cerrada(x))/b
Am = 0.03; w = 2*np.pi
yd = lambda tt: np.array([0.08 + Am*np.sin(w*tt), Am*w*np.cos(w*tt), -Am*w**2*np.sin(w*tt), -Am*w**3*np.cos(w*tt)])
def ujac(tt, x):
    xr, ur = eq(yd(tt)[0]); return ur - K@(x - xr)
x0, _ = eq(0.08); te = np.linspace(0, 3, 30001)
s1 = solve_ivp(lambda tt, x: f_lev(x, ujac(tt, x)), (0, 3), x0, t_eval=te, **o)
s2 = solve_ivp(lambda tt, x: f_lev(x, ufl(x, yd(tt))), (0, 3), x0, t_eval=te, **o)
Y = 0.08 + Am*np.sin(w*te); mk = te > 1
revisar('seguimiento: error jacobiana [cm]', 100*np.max(abs(s1.y[0, mk] - Y[mk])), 2.3599, 1e-3)
revisar('seguimiento: error exacta [m] (numérico)', np.max(abs(s2.y[0, mk] - Y[mk])), 0, 1e-5)
x0, _ = eq(0.05)
evt = lambda tt, x: x[2] - 0.02; evt.terminal = True; evt.direction = -1
s5 = solve_ivp(lambda tt, x: f_lev(x, ufl(x, [0.2, 0, 0, 0])), (0, 1.2), x0, events=evt, rtol=1e-10, atol=1e-12, max_step=2e-4)
revisar('escalón 0.05 -> 0.2: i = 0.02 A en t [s]', s5.t[-1], 0.02048, 2e-5)
p = 6; cf = np.poly(-p*np.ones(4)); Af = np.vstack([np.hstack([np.zeros((3, 1)), np.eye(3)]), -cf[:0:-1]]); Bf = np.array([0, 0, 0, p**4])
s6 = solve_ivp(lambda tt, z: np.r_[f_lev(z[:3], ufl(z[:3], z[3:7])), Af@z[3:7] + Bf*0.2], (0, 2), np.r_[x0, 0.05, 0, 0, 0], rtol=1e-10, atol=1e-12, max_step=2e-4)
revisar('referencia suave: y(2)', s6.y[0, -1], 0.199656, 2e-6)
revisar('referencia suave: corriente mínima', s6.y[2].min(), 6.1536, 1e-3)
revisar('referencia suave: max y_d\'\' < g', s6.y[5].max(), 0.70525, 1e-4)
xs, us = eq(0.05)
s3 = solve_ivp(lambda tt, x: f_lev(x, ufl(x, [0.05, 0, 0, 0]), mt(tt)), (0, 3), xs, **o)
kI = np.poly([-10, -15, -20, -30])
revisar('integrador: (s+10)(s+15)(s+20)(s+30) = s^4+75s^3+2000s^2+22500s+90000', np.max(abs(kI - [1, 75, 2000, 22500, 90000])), 0, 1e-9)
def fli(x, sg):
    v = -(kI[4]*sg + kI[3]*(x[0] - 0.05) + kI[2]*x[1] + kI[1]*phi3(x))
    b = -L0*a*x[2]/(m*(a+x[0])**2*Lx(x[0])); return (v - Lf3_cerrada(x))/b
s4 = solve_ivp(lambda tt, z: np.r_[f_lev(z[:3], fli(z[:3], z[3]), mt(tt)), z[0] - 0.05], (0, 3), np.r_[xs, 0], **o)
revisar('masa 0.12: error final exacta sola [cm]', 100*(s3.y[0, -1] - 0.05), 1.9617, 1e-3)
revisar('masa 0.12: error final exacta + integrador', s4.y[0, -1] - 0.05, 0, 1e-8)

print('12.9-12.10 Dinámica cero')
fn = sp.Matrix([x1 + x2, 3*x1**2*x2 + x1]); gn = sp.Matrix([0, 1]); hn = -x1**3 + x2
xi_, eta_ = sp.symbols('xi eta', real=True)
revisar('fase no mínima: L_g h = 1', Lie(gn, hn, X2), 1)
Lfh = Lie(fn, hn, X2)
revisar('fase no mínima: L_f h = eta - 3 eta^3', sp.simplify(Lfh.subs(x2, xi_ + x1**3).subs(x1, eta_) - (eta_ - 3*eta_**3)), 0)
revisar('fase no mínima: eta\' = xi + eta + eta^3', sp.simplify((x1 + x2).subs(x2, xi_ + x1**3).subs(x1, eta_) - (xi_ + eta_ + eta_**3)), 0)
kk = 2
rhs = lambda tt, x: [x[0] + x[1], 3*x[0]**2*x[1] + x[0] + (-x[0] + 3*x[0]**3 - kk*(-x[0]**3 + x[1]))]
evt = lambda tt, x: abs(x[0]) - 2.2; evt.terminal = True
s = solve_ivp(rhs, (0, 10), [0.05, 0.6], events=evt, max_step=0.005, rtol=1e-10, atol=1e-12)
revisar('fase no mínima: |eta| = 2.2 en t', s.t[-1], 1.39448, 1e-4)
revisar('fase no mínima: |y| en ese instante', abs(-s.y[0, -1]**3 + s.y[1, -1]), 0.036884, 1e-5)
revisar('dinámica cero eta\' = eta + eta^3: escape desde 0.05', 0.5*np.log(1 + 1/0.05**2), 2.99698, 1e-5)
al, be = sp.symbols('alpha beta', real=True); s_ = sp.symbols('s')
Al = sp.Matrix([[0, 1, 0], [0, 0, al], [0, 0, be]]); Bl = sp.Matrix([0, 1, -1]); Cl = sp.Matrix([[1, 0, 0]])
G = sp.simplify((Cl*(s_*sp.eye(3) - Al).inv()*Bl)[0])
revisar('G(s) = (s - (alpha+beta))/(s^2 (s - beta))', sp.simplify(G - (s_ - al - be)/(s_**2*(s_ - be))), 0)
revisar('L_f (x2 + x3) = (alpha + beta) x3', sp.simplify(Lie(sp.Matrix([x2, al*x3, be*x3]), x2 + x3, X) - (al + be)*x3), 0)
for (a1, b1, x3f) in [(1, -2, -0.0095955), (2, -1, 179.3018)]:
    s = solve_ivp(lambda tt, x: [x[1], a1*x[2] + (-a1*x[2] - 4*x[0] - 4*x[1]), b1*x[2] - (-a1*x[2] - 4*x[0] - 4*x[1])], (0, 6), [1, 0, 0], rtol=1e-11, atol=1e-12)
    revisar(f'alpha + beta = {a1+b1:+d}: x3(6)', s.y[2, -1], x3f, 1e-3*max(1, abs(x3f)))
    revisar(f'alpha + beta = {a1+b1:+d}: y(6)', s.y[0, -1], 7.9875e-5, 1e-8)
s = solve_ivp(lambda tt, x: np.array([x[2] - x[1]**3, -x[1], x[0]**2 - x[2]]) + np.array([0, -1, 1])*((-2*x[0] - 3*(x[2] - x[1]**3)) - (3*x[1]**3 + x[0]**2 - x[2]))/(1 + 3*x[1]**2), (0, 10), [1, 0.5, -0.5], rtol=1e-11, atol=1e-12)
revisar('fase mínima: |x(10)| < 1e-3', np.linalg.norm(s.y[:, -1]) < 1e-3, 1, 0)
for sg, nrm in [(-0.25, 0.038916), (0.12, 6.8612)]:
    M = np.array([[sg, -2], [2, sg]])
    s = solve_ivp(lambda tt, z: np.r_[-3*z[0], M@z[1:] + np.array([z[0], 0])], (0, 14), [1.2, 1.0, 0.3], rtol=1e-11, atol=1e-12)
    revisar(f'n = 3, r = 1, s = {sg}: |eta(14)|', np.linalg.norm(s.y[1:, -1]), nrm, 1e-4*max(1, nrm))
tEsc = lambda k_, xi0, eta0: np.log((xi0/(k_+1))/(xi0/(k_+1) - 1/eta0))/(k_+1)
revisar('escape xi0 = eta0 = 2, k = 1: ln(2)/2', tEsc(1, 2, 2), np.log(2)/2, 1e-12)
evt = lambda tt, z: z[1] - 1e6; evt.terminal = True
s = solve_ivp(lambda tt, z: [-z[0], -z[1] + z[1]**2*z[0]], (0, 3), [2, 2], events=evt, rtol=1e-11, atol=1e-12)
revisar('escape simulado (eta = 1e6) cerca de la fórmula', s.t[-1], np.log(2)/2, 2e-6)
wt = sp.symbols('w', real=True); xi0, k_ = sp.symbols('xi0 k', positive=True); w0 = sp.symbols('w0', real=True)
wsol = sp.exp(t)*(w0 - xi0/(k_+1)) + xi0*sp.exp(-k_*t)/(k_+1)
revisar('w = 1/eta cumple w\' = w - xi0 e^(-kt)', sp.simplify(sp.diff(wsol, t) - (wsol - xi0*sp.exp(-k_*t))), 0)
E0, X0 = np.meshgrid(np.linspace(0.5, 4, 8), np.linspace(0.4, 3, 7))
revisar('rejilla: escapan con k = 1', np.sum(E0*X0 > 2), 36, 0)
revisar('rejilla: escapan con k = 5', np.sum(E0*X0 > 6 + 1e-12), 12, 0)
x0_ = 3; xF = 3*sp.exp(-t)
revisar('cancelar: int_0^inf (x^3 - 2x)^2 dt = 117/2', sp.integrate((xF**3 - 2*xF)**2, (t, 0, sp.oo)), 58.5)
xx = sp.symbols('x', positive=True)
revisar('conservar: int_0^inf 4x^2 dt = int_0^3 4x/(1+x^2) dx = 2 ln 10', sp.integrate(4*xx/(1 + xx**2), (xx, 0, 3)), 2*np.log(10), 1e-12)
revisar('razón de energías', 58.5/(2*np.log(10)), 12.7031, 1e-4)
s = solve_ivp(lambda tt, x: -x - x**3, (0, 1), [3], rtol=1e-12, atol=1e-12)
revisar('conservar: x(1)', s.y[0, -1], 0.372418, 1e-5)
revisar('cancelar: x(1) = 3/e', 3*np.exp(-1), 1.103638, 1e-6)

tau = 3 - np.sqrt(3)
c4 = (3*tau**2 - tau**3)*np.exp(-tau)/6
revisar('problema del filtro: c4 = max (3 tau^2 - tau^3) e^-tau / 6', c4, 0.130602, 1e-6)
revisar('problema del filtro: p máximo con Delta = 0.15', np.sqrt(9.81/(c4*0.15)), 22.38, 1e-2)
revisar('problema del filtro: max y_d\'\' con p = 6 = c4 Delta p^2', c4*0.15*36, 0.70525, 1e-4)

print(f'\n{ok}/{total} verificaciones correctas')
