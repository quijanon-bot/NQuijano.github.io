"""Verificación de todos los números del capítulo 5 (estabilidad).
Ejecutar:  python3 herramientas/cap05_numeros.py
Usa sympy para las tablas de Routh simbólicas y numpy/python-control para raíces y simulaciones.
"""
import itertools
import numpy as np
import sympy as sp
import control as ct

s, K, Kc, Ki, eps, a, z = sp.symbols('s K K_c K_i epsilon a z')


def routh(coefs, eps_sym=eps):
    """Tabla de Routh (listas de expresiones sympy). Maneja los dos casos especiales."""
    c = [sp.nsimplify(x) if not isinstance(x, sp.Basic) else x for x in coefs]
    n = len(c) - 1
    ancho = (n + 2) // 2
    f0 = c[0::2] + [0] * (ancho - len(c[0::2]))
    f1 = c[1::2] + [0] * (ancho - len(c[1::2]))
    T = [f0, f1]
    notas = []
    for i in range(2, n + 1):
        a_, b_ = T[-2], T[-1]
        if all(sp.simplify(x) == 0 for x in b_):            # caso 2: fila de ceros
            orden = n - (i - 2)
            aux = [a_[k] for k in range(ancho)]
            nueva = [sp.simplify(aux[k] * (orden - 2 * k)) for k in range(ancho)]
            T[-1] = nueva; b_ = nueva
            notas.append(f'fila s^{n-i+1} de ceros: polinomio auxiliar de orden {orden}')
        if sp.simplify(b_[0]) == 0:                          # caso 1: cero en la primera columna
            b_ = [eps_sym] + b_[1:]; T[-1] = b_
            notas.append(f'cero en la primera columna de s^{n-i+1}: se reemplaza por epsilon')
        fila = [sp.simplify((b_[0] * a_[k + 1] - a_[0] * b_[k + 1]) / b_[0]) if k + 1 < ancho else 0
                for k in range(ancho)]
        T.append(fila)
    return T, notas


def mostrar(T, n):
    for i, f in enumerate(T):
        print(f'   s^{n-i}:', [sp.simplify(x) for x in f if x != 0] or [0])


def signo_lim(x):
    """Signo con epsilon pequeño y positivo."""
    return sp.sign(sp.N(x.subs(eps, sp.Rational(1, 10**6)))) if x.has(eps) else sp.sign(x)


def raices(p):
    return np.roots([float(x) for x in p])


print('=== 5.1 Modos ===')
for p in ([1, 1], [1, 0, 1], [1, -1], [1, 0, 2, 0, 1]):
    print('  ', p, np.round(raices(p), 4))

print('\n=== 5.3 Routh: ejemplos ===')
for nombre, p in [('s^4+2s^3+3s^2+4s+5', [1, 2, 3, 4, 5]),
                  ('s^3+s^2+2s+8 (contraejemplo)', [1, 1, 2, 8]),
                  ('s^3+2s^2+3s+4 (pausa)', [1, 2, 3, 4])]:
    T, _ = routh(p); print(' ', nombre); mostrar(T, len(p) - 1)
    print('   raíces', np.round(raices(p), 4))

print('\n=== 5.4 Casos especiales ===')
for nombre, p in [('s^5+2s^4+4s^3+8s^2+10s+6', [1, 2, 4, 8, 10, 6]),
                  ('s^3+2s^2+s+2', [1, 2, 1, 2]),
                  ('s^4+4', [1, 0, 0, 0, 4]),
                  ('s^5+7s^4+6s^3+42s^2+8s+56', [1, 7, 6, 42, 8, 56])]:
    T, notas = routh(p); print(' ', nombre, notas); mostrar(T, len(p) - 1)
    col = [signo_lim(f[0]) for f in T]
    cambios = sum(1 for i in range(len(col) - 1) if col[i] * col[i + 1] < 0)
    print('   signos primera columna', col, 'cambios', cambios)
    print('   raíces', np.round(raices(p), 4))
print('  factorizaciones:', sp.factor(s**3 + 2*s**2 + s + 2), '|', sp.factor(s**5 + 7*s**4 + 6*s**3 + 42*s**2 + 8*s + 56),
      '|', sp.factor(s**4 + 4, extension=sp.I))

print('\n=== 5.5 Diseño: rango de Kc (tres primer orden) ===')
G = sp.Rational(16, 1000) / (3*s + 1) * 50 / (30*s + 1) / (10*s + 1)
pc = sp.Poly(sp.expand(sp.numer(sp.together(1 + Kc * G))), s)
print('  polinomio', pc.as_expr())
T, _ = routh(pc.all_coeffs()); mostrar(T, 3)
kcr = sp.solve(T[2][0], Kc)[0]; print('  Kcr =', kcr, float(kcr), ' Kmin =', sp.solve(T[3][0], Kc))
w = sp.sqrt(T[3][0].subs(Kc, kcr) / T[1][0]); print('  wcr =', w, float(w), ' Pcr =', float(2*sp.pi/w))
L = ct.tf([0.8], [900, 420, 43, 1])
gm, pm, wg, wp = ct.margin(L); print('  margin: GM =', gm, 'wgm =', wg)
for k in (0.5*float(kcr), float(kcr), 1.2*float(kcr)):
    print('   K=', round(k, 3), 'max Re polos', round(max(np.roots([900, 420, 43, 1 + 0.8*k]).real), 5))

print('\n=== 5.5 Diseño: planta inestable + compensador ===')
pc = sp.expand((s + 3)*(s - 1)*(s**2 + 2*s + 2) + K*(s + 2))
print('  polinomio', sp.Poly(pc, s).as_expr())
T, _ = routh(sp.Poly(pc, s).all_coeffs()); mostrar(T, 4)
cotas = sp.solve(sp.numer(sp.together(T[3][0])), K); print('  raíces de la fila s^1:', cotas, [float(c) for c in cotas])
for k in (2.9, 3.2, 3.48, 3.6):
    print('   K=', k, 'polos', np.round(np.roots([1, 4, 3, k - 2, 2*k - 6]), 4))
kopt = None
ks = np.linspace(3.0001, 3.4890, 4000)
m = [max(np.roots([1, 4, 3, k - 2, 2*k - 6]).real) for k in ks]
print('  mejor K (más estable):', round(ks[int(np.argmin(m))], 4), 'max Re =', round(min(m), 4))

print('\n=== 5.5 Diseño PI: 2/(s^3+4s^2+5s+2) ===')
pc = sp.expand(s*(s**3 + 4*s**2 + 5*s + 2) + 2*(Kc*s + Ki))
T, _ = routh(sp.Poly(pc, s).all_coeffs()); mostrar(T, 4)
print('  factor planta', sp.factor(s**3 + 4*s**2 + 5*s + 2))
front = sp.simplify((2 + 2*Kc)*(18 - 2*Kc)/32)
print('  frontera Ki <', sp.expand(front), ' máximo en Kc=', sp.solve(sp.diff(front, Kc), Kc), 'Ki_max =', front.subs(Kc, 4))
for kc, ki in [(5, 1), (5, 3), (5, 4)]:
    p = [1, 4, 5, 2 + 2*kc, 2*ki]
    print(f'   Kc={kc}, Ki={ki}: polos', np.round(np.roots(p), 4))
b1 = (18 - 2*5)/4; print('  en la frontera (Kc=5,Ki=3): w =', np.sqrt(2*3/b1), 'P =', 2*np.pi/np.sqrt(2*3/b1))
sys = ct.feedback(ct.tf([2*5, 2*1], [1, 4, 5, 2, 0]), 1)
info = ct.step_info(sys); print('  Kc=5, Ki=1: OS =', round(info['Overshoot'], 1), 'ts =', round(info['SettlingTime'], 1))

print('\n=== 5.5 Estabilidad relativa (s = z - 0.05) en el ejemplo de Kc ===')
pz = sp.expand(sp.Poly(900*s**3 + 420*s**2 + 43*s + 1 + sp.Rational(4, 5)*Kc, s).as_expr().subs(s, z - sp.Rational(1, 20)))
print('  s = z - 0.05:', sp.Poly(pz, z).all_coeffs())
T, _ = routh(sp.Poly(pz, z).all_coeffs()); mostrar(T, 3)
print('  rango con margen 0.05:', [sp.solve(T[2][0], Kc), sp.solve(T[3][0], Kc)], [float(x) for x in sp.solve(T[2][0], Kc) + sp.solve(T[3][0], Kc)])

print('\n=== 5.6 Espacio de estado ===')
for A in ([[0, 1], [-2, -3]], [[0, 1, 0], [0, 0, 1], [-6, -11, -6]], [[-1, 2], [3, -4]]):
    A = np.array(A, float); print('  eig', np.round(np.linalg.eigvals(A), 4), 'poly', np.round(np.poly(A), 4))
A3 = sp.Matrix([[0, 1, 0], [0, 0, 1], [-a, -3, -2]])
print('  A3(a) poly:', sp.expand((s*sp.eye(3) - A3).det()))
# péndulo: theta'' = -(g/l) sin(theta) - (b/(m l^2)) theta'
g_l, bm = 9.81, 0.5
for th in (0, np.pi):
    J = np.array([[0, 1], [-g_l*np.cos(th), -bm]]); print('  péndulo theta*=', round(th, 3), 'eig', np.round(np.linalg.eigvals(J), 4))
# modo escondido: A1 con B=[0 0 1]' y C que cancela
A1 = np.array([[0, 1, 0], [0, 0, 1], [-6, -11, -6.]]); B1 = np.array([[0], [0], [1.]])
C1 = np.array([[2, 3, 1.]])   # (s+1)(s+2) en el numerador -> 1/(s+3)
print('  TF con C=[2 3 1]:', ct.minreal(ct.ss2tf(A1, B1, C1, 0), verbose=False))
Au = np.array([[0, 1, 0], [0, 0, 1], [2, 1, -2.]])   # (s-1)(s+1)(s+2)
print('  Au eig', np.round(np.linalg.eigvals(Au), 4), 'poly', np.poly(Au))
print('  TF Au con C=[-1 0 1]... ', ct.minreal(ct.ss2tf(Au, B1, np.array([[-1, 0, 1.]]), 0), verbose=False))

print('\n=== 5.7 Kharitonov ===')


def khar(lo, hi):
    """lo, hi: coeficientes de menor a mayor potencia (a_n, a_{n-1}, ..., a_0 en la notación del texto)."""
    pat = ['--++', '++--', '-++-', '+--+']
    P = []
    for pt in pat:
        P.append([lo[i] if pt[i % 4] == '-' else hi[i] for i in range(len(lo))])
    return P


def hurwitz(asc):
    return all(np.real(np.roots(asc[::-1])) < 0)


# Ejemplo 1: C=(s+2)/(s^2+2s+2), P=q0/(r0 s^3 + r1 s^2 + r2 s + r3)
r0, r1, r2, r3, q0 = sp.symbols('r0 r1 r2 r3 q0')
pol = sp.Poly(sp.expand((s**2 + 2*s + 2)*(r0*s**3 + r1*s**2 + r2*s + r3) + q0*(s + 2)), s)
rng = dict(r0=(1, 1.1), r1=(4, 4.2), r2=(6, 8), r3=(10, 20), q0=(3, 5))
co = pol.all_coeffs(); print('  coeficientes:', co)
lo, hi = [], []
for c in co:
    vals = [float(c.subs(dict(zip((r0, r1, r2, r3, q0), v)))) for v in itertools.product(*rng.values())]
    lo.append(min(vals)); hi.append(max(vals))
print('  intervalos a0..a5 (de s^5 a s^0):', list(zip(lo, hi)))
P = khar(lo[::-1], hi[::-1])
for i, p in enumerate(P):
    print(f'   K{i+1}', p, 'Hurwitz' if hurwitz(p) else 'NO', np.round(np.roots(p[::-1]), 3))
vert = [hurwitz([float(c.subs(dict(zip((r0, r1, r2, r3, q0), v)))) for c in co][::-1]) for v in itertools.product(*rng.values())]
print('  todos los vértices de los parámetros Hurwitz:', all(vert))
for v in itertools.product(*rng.values()):
    c = [float(x.subs(dict(zip((r0, r1, r2, r3, q0), v)))) for x in co]
    if not hurwitz(c[::-1]):
        print('   vértice inestable', dict(zip('r0 r1 r2 r3 q0'.split(), v)), np.round(np.roots(c), 3)); break
nom = [float(x.subs(dict(r0=1.05, r1=4.1, r2=7, r3=15, q0=4))) for x in co]
print('  nominal', nom, np.round(np.roots(nom), 3))

# Ejemplo de diseño (figura): K/(s^2+r1 s+r2), retroalimentación 1/(r3 s+1)
r1v, r2v, r3v = (6, 7), (100, 120), (1, 2)
pol = sp.Poly(sp.expand((s**2 + r1*s + r2)*(r3*s + 1) + K), s)
print('  diseño: coeficientes', pol.all_coeffs())
lo3, hi3 = 1, 2; lo2, hi2 = 6*1 + 1, 7*2 + 1; lo1, hi1 = 100*1 + 6, 120*2 + 7
print('  a3', (lo3, hi3), 'a2', (lo2, hi2), 'a1', (lo1, hi1), 'a0 = r2+K', (100, 120))
Kmax_box = sp.solve(sp.Eq(lo2*lo1, hi3*(120 + K)), K)[0]
print('  Kharitonov (caja): -100 < K <', Kmax_box)
f = lambda R1, R2, R3: R1*R2*R3 + R1**2 + R1/R3
print('  exacto (con dependencia): K <', min(f(*v) for v in itertools.product(r1v, r2v, r3v)), ' K > -100')
print('  nominal (6.5,110,1.5): K <', f(6.5, 110, 1.5), ' K > -110')
# verificación numérica en rejilla
for KK in (250, 251.5, 600, 641, 643):
    ok = all(hurwitz([R2 + KK, R2*R3 + R1, R1*R3 + 1, R3]) for R1 in np.linspace(6, 7, 6) for R2 in np.linspace(100, 120, 6) for R3 in np.linspace(1, 2, 11))
    print('   K =', KK, 'estable para todos los parámetros de la rejilla:', ok)
# cuatro polinomios de Kharitonov del diseño con K = 200 y K = 300
for KK in (200, 300):
    P = khar([100 + KK, 106, 7, 1], [120 + KK, 247, 15, 2])
    print('   K =', KK, [hurwitz(p) for p in P])

# Ejercicio (actividad 1): a3 in [1,2], a2 in [4,5], a1 in [3,4], a0 in [1,2]
print('\n  pausa: ', [hurwitz(p) for p in khar([1, 3, 4, 1], [2, 4, 5, 2])])

print('\n=== Problemas ===')
for p in ([1, 3, 3, 2, 1], [1, 2, 3, 6, 2, 1], [1, 3, 5, 15, 4, 12], [1, 2, -3, 4, 5]):
    T, notas = routh(p); col = [signo_lim(f[0]) for f in T]
    print(' ', p, notas, 'cambios', sum(1 for i in range(len(col) - 1) if col[i]*col[i+1] < 0), np.round(raices(p), 4))
print('  factor (c):', sp.factor(s**5 + 3*s**4 + 5*s**3 + 15*s**2 + 4*s + 12))
# (i) K/(s(s+2)(s+5))
pc = sp.Poly(sp.expand(s*(s + 2)*(s + 5) + K), s); T, _ = routh(pc.all_coeffs()); mostrar(T, 3)
print('  Kcr', sp.solve(T[2][0], K), 'wcr', sp.sqrt(70/7))
# (ii) K(s+1)/(s(s-1)(s+6))
pc = sp.Poly(sp.expand(s*(s - 1)*(s + 6) + K*(s + 1)), s); T, _ = routh(pc.all_coeffs()); mostrar(T, 3)
print('  cotas (ii):', sp.solve(T[2][0], K), ' y K>0')
# PI en 1/((s+1)(s+2))
pc = sp.Poly(sp.expand(s*(s + 1)*(s + 2) + Kc*s + Ki), s); T, _ = routh(pc.all_coeffs()); mostrar(T, 3)
pz = sp.Poly(sp.expand(pc.as_expr().subs(s, z - sp.Rational(1, 2))), z); print('  s=z-0.5:', pz.all_coeffs())
T, _ = routh(pz.all_coeffs()); mostrar(T, 3)
# A3(a)
T, _ = routh([1, 2, 3, a]); mostrar(T, 3); print('  w en a=6:', np.sqrt(3))
# Kharitonov problema: a0 in [1,1.2], a1 [4,5], a2 [6,8], a3 [3,4], a4 [1,2] (de s^4 a s^0)
lo = [1, 3, 6, 4, 1][::-1]; lo = [1, 3, 6, 4, 1]  # ascendente: a4, a3, a2, a1, a0
lo = [1, 3, 6, 4, 1.0]; hi = [2, 4, 8, 5, 1.2]
print('  Kharitonov (a):', [hurwitz(p) for p in khar(lo, hi)])
lo2 = [1, 0.2, 6, 4, 1.0]
P = khar(lo2, hi); print('  Kharitonov con a3 en [0.2,4]:', [hurwitz(p) for p in P], [np.round(np.roots(p[::-1]), 3) for p in P])
# P = 1/(s^3 + r1 s^2 + r2 s + r3), C = K
print('  problema planta incierta: K <', 6*100 - 2, ' K > -1; nominal K <', 6.5*110 - 1.5)
