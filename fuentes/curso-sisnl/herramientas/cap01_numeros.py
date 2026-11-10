"""Verificación independiente (sympy/scipy) de los números del capítulo 1.
Ejecutar:  python3 herramientas/cap01_numeros.py
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp
from scipy.special import ellipk

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:58s} {float(valor):14.6f}" + ('' if bien else f'  (esperado {esperado})'))

o = dict(rtol=1e-11, atol=1e-12)
P, R, K, t, k, m, c = sp.symbols('P R K t k m c', positive=True)

print('1.1 Superposición')
F = lambda p: sp.Rational(8, 5)*p*(1 - sp.Rational(1, 32)*p)
revisar('F(20) = 12', F(20), 12)
revisar('F(10) + F(10) = 22', 2*F(10), 22)
a = sp.symbols('a')
tot = sp.expand(F(a) + F(20 - a))
revisar('el reparto óptimo es a = 10', sp.solve(sp.diff(tot, a), a)[0], 10)

print('1.2 Reescalamiento')
alpha = lambda m, k, c: c/np.sqrt(k*m)
for trio in [(1, 1, 0.5), (1, 4, 1), (2, 18, 3)]:
    revisar(f'alpha{trio} = 0.5', alpha(*trio), 0.5, 1e-12)
revisar('omega de (2,18,3) = 3', np.sqrt(18/2), 3, 1e-12)

print('1.3 Fenómenos')
for th, esp in [(10, 1.00191), (45, 1.03997), (90, 1.18034), (170, 2.43936)]:
    revisar(f'péndulo: T/T0 a {th}°', 2/np.pi*ellipk(np.sin(np.radians(th)/2)**2), esp, 2e-5)
x = sp.Function('x')
sol = sp.dsolve(sp.Eq(x(t).diff(t), -x(t)**2), x(t), ics={x(0): -1})
revisar('x\' = -x^2, x(0) = -1: x(t) = 1/(t-1); x(0.9)', sol.rhs.subs(t, sp.Rational(9, 10)), -10)
vdp = lambda tt, z: [z[1], (1 - z[0]**2)*z[1] - z[0]]
s = solve_ivp(vdp, (0, 80), [0.1, 0], t_eval=np.linspace(60, 80, 20001), **o)
revisar('van der Pol eps = 1: amplitud del ciclo', s.y[0].max(), 2.00862, 2e-4)
lor = lambda tt, z: [10*(z[1] - z[0]), z[0]*(28 - z[2]) - z[1], z[0]*z[1] - 8/3*z[2]]
tt = np.linspace(0, 40, 40001)
A = solve_ivp(lor, (0, 40), [1, 1, 1], t_eval=tt, rtol=1e-12, atol=1e-12).y
B = solve_ivp(lor, (0, 40), [1 + 1e-9, 1, 1], t_eval=tt, rtol=1e-12, atol=1e-12).y
td = tt[np.argmax(np.linalg.norm(A - B, axis=0) > 1)]
revisar('Lorenz: separación de orden 1 entre t = 25 y t = 40', 25 < td < 40, 1)
revisar('silla-nodo r + x^2: equilibrios +-sqrt(-r) en r = -4', sp.sqrt(4), 2)

print('1.4 Mapa logístico')
p = 1.0; seq = [p]
for i in range(60):
    p = 1.6*p*(1 - p/32); seq.append(p)
revisar('P[1] = 1.55', seq[1], 1.55, 1e-12)
revisar('P[21] -> 12', seq[21], 12, 1e-4)
revisar('punto fijo K(1 - 1/R)', 32*(1 - 1/1.6), 12, 1e-12)
# ciclo de período 2 de R = 3.2: raíces de F(F(p)) = p distintas del punto fijo
Fs = lambda q: sp.Rational(16, 5)*q*(1 - q/32)
q = sp.symbols('q')
raices = sorted([float(r) for r in sp.solve(sp.expand(Fs(Fs(q)) - q), q) if r.is_real])
revisar('R = 3.2: ciclo de período 2, valor bajo', raices[1], 16.41742, 1e-5)
revisar('R = 3.2: ciclo de período 2, valor alto', raices[3], 25.58258, 1e-5)
revisar('período 2 nace en R = 3 (F\'(p*) = 2 - R = -1)', 2 - 3, -1)
Pt = K*1*sp.exp(R*t)/(K + 1*(sp.exp(R*t) - 1))
revisar('la solución de la logística continua cumple la ecuación', sp.simplify(sp.diff(Pt, t) - R*Pt*(1 - Pt/K)), 0)

print('1.5 Energía y Brockett')
x1, x2 = sp.symbols('x1 x2')
Edot = sp.expand(k*x1*x2 + m*x2*((-k*x1 - c*x2)/m))
revisar('dE/dt = -c x2^2', sp.simplify(Edot + c*x2**2), 0)
s = solve_ivp(lambda tt, z: [z[1], -4*z[0] - 0.5*z[1]], (0, 20), [1, 0], dense_output=True, **o)
for T, esp in [(5, 0.182686), (10, 0.0153291), (20, 8.4748e-5)]:
    X = s.sol(T); revisar(f'E({T})', 2*X[0]**2 + 0.5*X[1]**2, esp, 2e-6 if T < 20 else 2e-9)
rho, th = sp.symbols('rho theta', positive=True)
z1 = rho*(sp.cos(th) - 1); z2 = rho*sp.sin(th)
z3dot = z1*sp.diff(z2, th) - z2*sp.diff(z1, th)
revisar('vuelta: z3(2 pi) = 2 pi rho^2 (rho = 1/2)', sp.integrate(z3dot, (th, 0, 2*sp.pi)).subs(rho, sp.Rational(1, 2)), np.pi/2, 1e-12)
Bm = sp.Matrix([[1, 0], [0, 1], [0, 0]]); Am = sp.zeros(3)
revisar('rango de controlabilidad de la linealización', (Bm.row_join(Am*Bm).row_join(Am*Am*Bm)).rank(), 2)

print('1.6 Control')
xx = sp.symbols('x', real=True)
eqs = sp.solve(xx - 125*xx**3, xx)
revisar('x\' = x - k^3 x^3: equilibrio positivo k^(-3/2)', max(eqs), 5**-1.5, 1e-12)
revisar('f\'(0) = 1 para todo k (origen inestable)', sp.diff(xx - k**3*xx**3, xx).subs(xx, 0), 1)
revisar('f\'(k^(-3/2)) = -2', sp.diff(xx - 125*xx**3, xx).subs(xx, max(eqs)), -2, 1e-12)
revisar('u = -(kx)^(1/3): u^3 = -kx, lazo x\' = (1 - k)x', sp.simplify(xx + (-sp.cbrt(5*xx))**3 + 4*xx).subs(xx, 2), 0, 1e-12)
revisar('estructura variable: t(2%) = pi/2 + ln 50', np.pi/2 + np.log(50), 5.4828, 1e-4)
s = solve_ivp(lambda tt, z: [z[1], -z[0] - z[1]], (0, 10), [1, 1], t_eval=np.linspace(0, 10, 10001), **o)
nx = np.linalg.norm(s.y, axis=0)
revisar('PD: t(2%)', s.t[np.where(nx > 0.02*nx[0])[0][-1]], 8.91, 2e-3)
revisar('PD: mínimo de x1', s.y[0].min(), -0.208713, 2e-6)
kP, v, w, r = sp.symbols('k_P v w r')
ye = sp.solve(sp.Eq(-kP*(P + w - r) + v - k*P, 0), P)[0]
revisar('PD: y_e = (kP(r - w) + v)/(k + kP) con los números', ye.subs({kP: 10, w: sp.Rational(1, 10), r: 1, v: sp.Rational(1, 2), k: 2}), 0.791667, 1e-6)
print(f'\n{ok} de {total} verificaciones correctas.')
