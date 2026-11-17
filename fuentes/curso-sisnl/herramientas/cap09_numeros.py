"""Verificación independiente (sympy/scipy) de los números del capítulo 9
(sistemas variantes en el tiempo: uniformidad, funciones de comparación, teoremas de
Lyapunov con V(t,x) e inestabilidad).
Ejecutar:  python3 herramientas/cap09_numeros.py
Los mismos números se comprueban en MATLAB/Octave con codigo/cap09_variantes/verificarCap09.m.
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    try:
        valor = float(valor)
    except TypeError:
        valor = float(bool(valor))
    bien = abs(valor - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:70s} {float(valor):14.6g}" + ('' if bien else f'  (esperado {esperado})'))

o = dict(rtol=1e-10, atol=1e-12)
t, s, r, x, x0, t0, k = sp.symbols('t s r x x0 t0 k', real=True)
x1, x2 = sp.symbols('x1 x2', real=True)

# ------------------------------------------------------------------ 9.2 uniformidad
print('9.2 el tiempo inicial importa: x\' = -x/(1+t)')
sol = x0*(1 + t0)/(1 + t)
revisar('x(t) = x0 (1+t0)/(1+t) cumple la ecuación', sp.simplify(sp.diff(sol, t) + sol/(1 + t)), 0)
T = sp.solve(sp.Eq((1 + t0)/(1 + t0 + s), sp.Rational(1, 10)), s)[0]
revisar('T(0.1, t0) = 9 (1 + t0)', sp.simplify(T - 9*(1 + t0)), 0)
revisar('T con t0 = 0: 9', T.subs(t0, 0), 9); revisar('T con t0 = 100: 909', T.subs(t0, 100), 909)
for tt0 in (0.0, 100.0):
    so = solve_ivp(lambda tt, z: [-z[0]/(1 + tt)], (tt0, tt0 + 2000), [1.0], dense_output=True, **o)
    q = np.linspace(tt0, tt0 + 2000, 200001); xx = so.sol(q)[0]
    revisar(f'ode: t0 = {tt0:.0f}, primer instante con |x| < 0.1 tras t0', q[np.argmax(xx < 0.1)] - tt0, 9*(1 + tt0), 0.05)
beta = r*(1 + t0)/(1 + t0 + s)
revisar('sup_{t0} beta_{t0}(r, s) = r (no decae)', sp.simplify(sp.limit(beta, t0, sp.oo) - r), 0)

# ------------------------------------------------------------------ 9.3 funciones de comparación
print('9.3 funciones de comparación')
rr = np.linspace(1e-3, 10, 2001); ss = np.linspace(0, 10, 2001)
R, S = np.meshgrid(rr, ss)
b1 = R/(S*R + 1)
revisar('r/(sr+1): creciente en r', np.all(np.diff(b1, axis=1) > 0), 1)
revisar('r/(sr+1): no creciente en s', np.all(np.diff(b1, axis=0) <= 0), 1)
b2 = R*np.exp(-S*R)
revisar('r e^{-sr}: NO es creciente en r para todo s > 0', np.all(np.diff(b2[1:], axis=1) > 0), 0)
revisar('r e^{-sr}: máximo en r = 1/s (s = 2: r = 0.5)', rr[np.argmax(1*np.exp(-2*rr)*rr)], 0.5, 6e-3)
bc = np.minimum(R, 1)*np.exp(-S)
revisar('min{r,1} e^{-s}: constante en r para r >= 1', np.ptp(bc[:, rr >= 1], axis=1).max(), 0)
revisar('(a) r^2/(1+s): d/dr = 2r/(1+s) > 0', np.all(np.diff(R**2/(1 + S), axis=1) > 0), 1)
revisar('(d) r/(1+s) + r e^{-s}: creciente en r', np.all(np.diff(R/(1 + S) + R*np.exp(-S), axis=1) > 0), 1)
revisar('e^{-x} <= 1/(1+x) para x >= 0', np.all(np.exp(-ss) <= 1/(1 + ss) + 1e-15), 1)
y = sp.Function('y')
for alfa, sigma in ((k*sp.Symbol('Y'), r*sp.exp(-k*s)), (k*sp.Symbol('Y')**2, r/(k*r*s + 1)), (sp.Symbol('Y')**3, r/sp.sqrt(1 + 2*r**2*s))):
    expr = sp.diff(sigma, s) + alfa.subs(sp.Symbol('Y'), sigma)
    revisar(f'y\' = -({alfa}) tiene solución {sigma}', sp.simplify(expr), 0)
    revisar(f'   y es flujo: sigma(r, 0) = r', sp.simplify(sigma.subs(s, 0) - r), 0)
revisar('(a) r^2/(1+s) no es flujo: sigma(r,0) = r^2', (r**2/(1 + s)).subs(s, 0) - r != 0, 1)

# ------------------------------------------------------------------ 9.4 Lyapunov con V(t,x)
print('9.4 V(t,x): positividad, decrecimiento, derivada')
V1 = x1**2*(1 + sp.sin(t)**2) + x2**2*(1 + sp.cos(t)**2)
revisar('K&B 2.7: V1 <= 2||x||^2 (1 + sin^2 <= 2)', sp.maximum(1 + sp.sin(t)**2, t, sp.Interval(0, 2*sp.pi)), 2)
V2 = x1**2 + x2**2*(1 + t)
revisar('K&B 2.7: V2(t, (0,1)) = 1 + t no acotada', sp.limit(V2.subs({x1: 0, x2: 1}), t, sp.oo) == sp.oo, 1)
Va = x1**2 + x1*x2**2*(1 + sp.exp(-t))
revisar('V = x1^2 + x1 x2^2 (1+e^{-t}) en (-0.01, 1), t = 0: < 0', Va.subs({x1: -0.01, x2: 1, t: 0}) < 0, 1)
Vp = (2 + sp.sin(t))*x**2
Vpd = sp.diff(Vp, t) + sp.diff(Vp, x)*(-x/10)
revisar('trampa: Vdot = (cos t - 0.2(2 + sin t)) x^2', sp.simplify(Vpd - (sp.cos(t) - sp.Rational(1, 5)*(2 + sp.sin(t)))*x**2), 0)
revisar('trampa: en t = 0 vale 0.6 x^2 > 0', (Vpd/x**2).subs(t, 0), 0.6, 1e-12)
revisar('E1: x\' = -x/(1+t)^2 -> x0 e^{-1/(1+t0)} (t0 = 0: 0.368)', solve_ivp(lambda tt, z: [-z[0]/(1 + tt)**2], (0, 2000), [1.0], **o).y[0, -1], np.exp(1/2001 - 1), 1e-7)
revisar('E1: t0 = 10: límite 0.913', solve_ivp(lambda tt, z: [-z[0]/(1 + tt)**2], (10, 2000), [1.0], **o).y[0, -1], np.exp(1/2001 - 1/11), 1e-7)
# teorema ES: cota
k1_, k2_, k3_, a_ = sp.symbols('k1 k2 k3 a', positive=True)
revisar('ES: exponente k3/(a k2) (de V <= V0 e^{-k3/k2 s} y k1|x|^a <= V)', sp.simplify(sp.log(sp.exp(-k3_/k2_*s))/a_ + k3_/(a_*k2_)*s), 0)

# ------------------------------------------------------------------ 9.5 ejemplos
print('9.5 Mathieu amortiguada')
f_m = [x2, -x2 - (2 + sp.sin(t))*x1]
Vm = x1**2 + x2**2/(2 + sp.sin(t))
Vmd = sp.diff(Vm, t) + sp.diff(Vm, x1)*f_m[0] + sp.diff(Vm, x2)*f_m[1]
revisar('Vdot = -x2^2 (4 + 2 sin t + cos t)/(2 + sin t)^2', sp.simplify(Vmd + x2**2*(4 + 2*sp.sin(t) + sp.cos(t))/(2 + sp.sin(t))**2), 0)
tq = np.linspace(0, 2*np.pi, 400001)
revisar('min(4 + 2 sin t + cos t) = 4 - sqrt5 = 1.764', (4 + 2*np.sin(tq) + np.cos(tq)).min(), 4 - np.sqrt(5), 1e-8)
cc = (4 + 2*np.sin(tq) + np.cos(tq))/(2 + np.sin(tq))**2
revisar('c = min coef = 0.637', cc.min(), 0.637, 1e-3)
revisar('cota a mano (4 - sqrt5)/9 = 0.196', (4 - np.sqrt(5))/9, 0.196, 1e-3)
A = lambda tt: np.array([[0, 1], [-(2 + np.sin(tt)), -1]])
M = np.column_stack([solve_ivp(lambda tt, z: A(tt) @ z, (0, 2*np.pi), e, **o).y[:, -1] for e in np.eye(2)])
mu = np.linalg.eigvals(M)
revisar('det M = e^{-2pi} (Liouville)', np.linalg.det(M), np.exp(-2*np.pi), 1e-10)
revisar('multiplicadores complejos: |mu| = e^{-pi} = 0.0432', abs(mu[0]), np.exp(-np.pi), 1e-8)
revisar('Re mu = -0.0099', mu[0].real, -0.0099, 1e-4); revisar('|Im mu| = 0.0421', abs(mu[0].imag), 0.0421, 1e-4)
so = solve_ivp(lambda tt, z: A(tt) @ z, (0, 40), [1, 0], dense_output=True, **o)
qq = np.linspace(10, 40, 30001); nx = np.linalg.norm(so.sol(qq), axis=0)
revisar('||x(t)|| e^{t/2} acotado en [10, 40] (exponente -1/2): max 2.05', (nx*np.exp(qq/2)).max(), 2.05, 0.01)
print('9.5 ganancia variable')
g = sp.Function('g')(t)
Vg = x1**2 + (1 + g)*x2**2
fg = [-x1 - g*x2, x1 - x2]
Vgd = sp.diff(Vg, t) + sp.diff(Vg, x1)*fg[0] + sp.diff(Vg, x2)*fg[1]
revisar('Vdot = -2x1^2 + 2x1x2 - (2 + 2g - gdot) x2^2', sp.simplify(Vgd - (-2*x1**2 + 2*x1*x2 - (2 + 2*g - sp.diff(g, t))*x2**2)), 0)
revisar('lambda_min([2 -1; -1 2]) = 1', min(np.linalg.eigvalsh([[2, -1], [-1, 2]])), 1, 1e-12)
gfn = lambda tt: 1 + 0.5*np.sin(tt)
revisar('g = 1 + 0.5 sin t cumple g - gdot >= 0 (min 1 - 0.5 sqrt2 = 0.29)', (gfn(tq) - 0.5*np.cos(tq)).min(), 1 - 0.5*np.sqrt(2), 1e-8)
peor = 0
for tt0 in (0.0, 3.0, 7.0):
    for th in np.linspace(0, np.pi, 7):
        q = np.linspace(tt0, tt0 + 20, 2001)
        so = solve_ivp(lambda tt, z: [-z[0] - gfn(tt)*z[1], z[0] - z[1]], (tt0, tt0 + 20), [np.cos(th), np.sin(th)], t_eval=q, **o)
        peor = max(peor, (np.linalg.norm(so.y, axis=0)/(np.sqrt(2.5)*np.exp(-(q - tt0)/5))).max())
revisar('||x(t)|| / cota sqrt(1+k) e^{-(t-t0)/(2(1+k))} <= 1 (k = 1.5): 0.63', peor, 0.632, 1e-3)
revisar('g = (1 + sin 10t)/2: coeficiente en t = 0 es -2', 2 + 2*0.5 - 5, -2, 0)
print('9.5 Markus--Yamabe')
MY = sp.Matrix([[-1 + sp.Rational(3, 2)*sp.cos(t)**2, 1 - sp.Rational(3, 2)*sp.sin(t)*sp.cos(t)],
                [-1 - sp.Rational(3, 2)*sp.sin(t)*sp.cos(t), -1 + sp.Rational(3, 2)*sp.sin(t)**2]])
revisar('tr A(t) = -1/2', sp.simplify(MY.trace()), -0.5); revisar('det A(t) = 1/2', sp.simplify(MY.det()), 0.5)
revisar('lambda = -1/4 +- j sqrt7/4: |Im| = 0.661', np.sqrt(7)/4, 0.661, 1e-3)
Phi = sp.Matrix([[sp.exp(t/2)*sp.cos(t), sp.exp(-t)*sp.sin(t)], [-sp.exp(t/2)*sp.sin(t), sp.exp(-t)*sp.cos(t)]])
revisar('Phi\' = A Phi', sp.simplify(Phi.diff(t) - MY*Phi).norm(), 0)
revisar('det Phi = e^{-t/2}', sp.simplify(Phi.det() - sp.exp(-t/2)), 0)
so = solve_ivp(lambda tt, z: np.array(MY.subs(t, tt), dtype=float) @ z, (0, 10), [1, 0], **o)
revisar('x(10) desde (1,0): ||x|| = e^5 = 148.4', np.linalg.norm(so.y[:, -1]), np.exp(5), 1e-4)
print('9.5 linealización variante')
for tt0, esc in ((0.0, 0), (10.0, 1), (100.0, 1)):
    ev = lambda tt, z: np.hypot(*z) - 1e3; ev.terminal = True
    so = solve_ivp(lambda tt, z: [-z[0] + tt*z[1]**2, z[0] - z[1]], (tt0, tt0 + 50), [0.1, 0.1], events=ev, **o)
    revisar(f'x1\' = -x1 + t x2^2: desde (0.1, 0.1) con t0 = {tt0:.0f} escapa: {esc}', so.status, esc, 0)
revisar('   con t0 = 10 escapa en t = 16.33', solve_ivp(lambda tt, z: [-z[0] + tt*z[1]**2, z[0] - z[1]], (10, 60), [0.1, 0.1], events=ev, **o).t[-1], 16.33, 0.01)

# ------------------------------------------------------------------ 9.6 Vdot <= 0
print('9.6 cuando Vdot <= 0')
th_ = sp.symbols('theta'); e_ = sp.symbols('e'); w_ = sp.Function('w')(t)
Va2 = e_**2 + th_**2
revisar('adaptativo: Vdot = -2e^2', sp.simplify(sp.diff(Va2, e_)*(-e_ + th_*w_) + sp.diff(Va2, th_)*(-e_*w_) + 2*e_**2), 0)
so = solve_ivp(lambda tt, z: [-z[0] + z[1]*np.exp(-0.2*tt), -z[0]*np.exp(-0.2*tt)], (0, 40), [1, 1], **o)
revisar('adaptativo, w = e^{-0.2t} desde (1,1): theta -> -0.10', so.y[1, -1], -0.102, 1e-3)
so = solve_ivp(lambda tt, z: [z[1], -z[1] - (2 + np.sin(tt))*z[0]], (0, 30), [1, 0], dense_output=True, **o)
q = np.linspace(0, 30, 30001); X = so.sol(q)
revisar('Mathieu: x2 -> 0 y x1 -> 0 (||x(30)|| < 1e-5)', np.linalg.norm(X[:, -1]) < 1e-5, 1)
x2d = -X[1] - (2 + np.sin(q))*X[0]
x2dd = -x2d - np.cos(q)*X[0] - (2 + np.sin(q))*X[1]   # derivada de xdot2 = -x2 - (2+sin t) x1
revisar('Mathieu: x2_ddot acotada desde (1, 0): max |x2_ddot| = 2.77', np.abs(x2dd).max(), 2.77, 0.01)

# ------------------------------------------------------------------ 9.7 inestabilidad
print('9.7 inestabilidad')
fA = [2*x2 + x1*(x1**2 + 2*x2**4), -2*x1 + x2*(x1**2 + x2**4)]
VA = (x1**2 + x2**2)/2
VAd = sp.expand(sp.diff(VA, x1)*fA[0] + sp.diff(VA, x2)*fA[1])
revisar('primer teorema: Vdot = x1^4 + x1^2x2^2 + 2x1^2x2^4 + x2^6', sp.simplify(VAd - (x1**4 + x1**2*x2**2 + 2*x1**2*x2**4 + x2**6)), 0)
JA = sp.Matrix(fA).jacobian([x1, x2]).subs({x1: 0, x2: 0})
revisar('primer teorema: linealización con lambda = +-2j (centro)', abs(complex(JA.eigenvals().popitem()[0]).imag), 2)
fB = [x1 + 3*x2*sp.sin(x2)**2 + 5*x1*x2**2*sp.sin(x1)**2, 3*x1*sp.sin(x2)**2 + x2 - 5*x1**2*x2*sp.cos(x1)**2]
VB = (x1**2 - x2**2)/2
VBd = sp.diff(VB, x1)*fB[0] + sp.diff(VB, x2)*fB[1]
revisar('segundo teorema: Vdot = 2V + 5x1^2x2^2', sp.simplify(VBd - (2*VB + 5*x1**2*x2**2)), 0)
revisar('segundo teorema: en (0, 0.5), V = -0.125', VB.subs({x1: 0, x2: 0.5}), -0.125, 1e-12)
revisar('segundo teorema: en (0, 0.5), Vdot = -0.25 < 0', VBd.subs({x1: 0, x2: 0.5}), -0.25, 1e-12)
fS = [x1, -x2]; VS = (x1**2 - x2**2)/2
revisar('silla: Vdot = x1^2 + x2^2', sp.simplify(sp.diff(VS, x1)*fS[0] + sp.diff(VS, x2)*fS[1] - x1**2 - x2**2), 0)
fC = [x1**2 + x2**3, -x2 + x1**3]; VC = x1 - x2**2/2
VCd = sp.expand(sp.diff(VC, x1)*fC[0] + sp.diff(VC, x2)*fC[1])
revisar('Cetaev: Vdot = x1^2 + x2^2 + x2^3 - x1^3 x2', sp.simplify(VCd - (x1**2 + x2**2 + x2**3 - x1**3*x2)), 0)
th = np.linspace(0, 2*np.pi, 721); rq = np.linspace(1e-3, 0.5, 400)
TH, RQ = np.meshgrid(th, rq); X1, X2 = RQ*np.cos(TH), RQ*np.sin(TH)
cociente = (X1**2 + X2**2 + X2**3 - X1**3*X2)/(X1**2 + X2**2)
revisar('Cetaev: en B_{1/2}, min Vdot/||x||^2 >= 1/2 (la diapositiva daba 3/8)', cociente.min() >= 0.5 - 1e-12, 1)
revisar('Cetaev: min Vdot/||x||^2 en B_{1/2} = 0.50', cociente.min(), 0.50, 0.01)
revisar('E8: con V = x1, en (delta^2, -delta), delta = 0.1: Vdot = delta^4 - delta^3 < 0', (0.01**2 + (-0.1)**3), 1e-4 - 1e-3, 1e-15)
fv = lambda tt, z: [z[1], -z[0] + (1 - z[0]**2)*z[1]]
so = solve_ivp(fv, (0, 100), [2, 0], dense_output=True, **o)
nn = np.linalg.norm(so.sol(np.linspace(60, 100, 200001)), axis=0)
revisar('van der Pol: el ciclo cumple 1.53 <= ||x|| <= 2.83', nn.min(), 1.532, 1e-3)
revisar('   máximo de ||x|| en el ciclo = 2.83', nn.max(), 2.830, 1e-3)
for d, tsal in ((1e-2, 8.90), (1e-4, 18.97), (1e-6, 27.23)):
    ev = lambda tt, z: np.hypot(*z) - 1; ev.terminal = True
    revisar(f'van der Pol: desde ({d:g}, 0) sale de B_1 en t = {tsal}', solve_ivp(fv, (0, 100), [d, 0], events=ev, **o).t[-1], tsal, 0.01)

# ------------------------------------------------------------------ agregados al redactar
print('agregados: raíz, 6t sin t, g rápida, Matrosov, Lyapunov diferencial')
L = np.log(10)
revisar('x\' = -x/sqrt(1+t): T(0.1, 0) = 3.63', L + L**2/4, 3.63, 0.01)
revisar('x\' = -x/sqrt(1+t): T(0.1, 100) = 24.47', L*np.sqrt(101) + L**2/4, 24.47, 0.01)
revisar('   simulado: x(100 + 24.466) = 0.1', solve_ivp(lambda tt, z: [-z[0]/np.sqrt(1 + tt)], (100, 100 + L*np.sqrt(101) + L**2/4), [1.0], **o).y[0, -1], 0.1, 1e-6)
nn = sp.symbols('n', integer=True, nonnegative=True); tau = sp.symbols('tau')
expo = sp.integrate(6*tau*sp.sin(tau) - 2*tau, (tau, 2*nn*sp.pi, (2*nn + 1)*sp.pi))
revisar('6t sin t: exponente en [2n pi, (2n+1) pi] = (4n+1)(6 - pi) pi', sp.simplify(expo - (4*nn + 1)*(6 - sp.pi)*sp.pi), 0)
Ag = lambda tt: np.array([[-1, -(1 + np.sin(10*tt))/2], [1, -1]])
Mg = np.column_stack([solve_ivp(lambda tt, z: Ag(tt) @ z, (0, np.pi/5), e, **o).y[:, -1] for e in np.eye(2)])
mg = np.linalg.eigvals(Mg)
revisar('g rápida: |mu| = e^{-pi/5} = 0.533', abs(mg[0]), np.exp(-np.pi/5), 1e-8)
revisar('g rápida: Re mu = 0.482', mg[0].real, 0.482, 1e-3); revisar('g rápida: |Im mu| = 0.230', abs(mg[0].imag), 0.230, 1e-3)
U = x1*x2; Ud = sp.diff(U, x1)*f_m[0] + sp.diff(U, x2)*f_m[1]
revisar('Matrosov: Udot = x2^2 - x1 x2 - (2 + sin t) x1^2', sp.simplify(Ud - (x2**2 - x1*x2 - (2 + sp.sin(t))*x1**2)), 0)
from scipy.integrate import quad
pv = [quad(lambda ta, t_=t_: np.exp(-2*(2*(ta - t_) - np.cos(ta) + np.cos(t_))), t_, t_ + 60, limit=400)[0] for t_ in np.linspace(0, 2*np.pi, 200)]
revisar('Lyapunov diferencial escalar: min p = 0.167', min(pv), 0.167, 1e-3); revisar('   max p = 0.467', max(pv), 0.467, 1e-3)
so = solve_ivp(lambda tt, z: np.array(MY.subs(t, tt), dtype=float) @ z, (0, 10), [0, 1], **o)
revisar('Markus--Yamabe desde (0,1): ||x(10)|| = e^{-10}', np.linalg.norm(so.y[:, -1]), np.exp(-10), 1e-9)
revisar('Markus--Yamabe: segunda columna resuelve', sp.simplify(Phi[:, 1].diff(t) - MY*Phi[:, 1]).norm(), 0)
revisar('6t sin t es US? exponente n=2: 80.82', float(expo.subs(nn, 2)), 80.82, 0.01)

# ------------------------------------------------------------------ problemas
print('Problemas')
xx0 = sp.symbols('xx0', positive=True); kk = sp.symbols('kk', positive=True)
cota4 = xx0/sp.sqrt(1 + 2*(1 + kk)*xx0**2*s)
revisar('P9.4: x0/sqrt(1+2(1+k)x0^2 s) resuelve y\' = -(1+k) y^3', sp.simplify(sp.diff(cota4, s) + (1 + kk)*cota4**3), 0)
g5 = sp.symbols('g5', real=True)
M5 = sp.Matrix([[-4, 2*g5], [2*g5, -4]])
revisar('P9.5: Vdot = x\'[-4 2g; 2g -4]x <= -2||x||^2 si |g| <= 1', max(np.linalg.eigvalsh(np.array(M5.subs(g5, 1), dtype=float))), -2, 1e-12)
f6 = sp.Matrix([x2 - g*x1*(x1**2 + x2**2), -x1 - g*x2*(x1**2 + x2**2)])
revisar('P9.6: Vdot = -2 g ||x||^4', sp.simplify(2*x1*f6[0] + 2*x2*f6[1] + 2*g*(x1**2 + x2**2)**2), 0)
revisar('P9.9: tr A = -1/2 (Liouville: det Phi = e^{-t/2})', sp.simplify(MY.trace()), -0.5)
print(f'\n{ok}/{total} verificaciones correctas')
