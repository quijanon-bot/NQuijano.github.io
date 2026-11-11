"""Verificación independiente (sympy/scipy) de los números del capítulo 4
(sistemas bidimensionales).   Ejecutar:  python3 herramientas/cap04_numeros.py
Los mismos números se comprueban en MATLAB/Octave con codigo/cap04_bidimensionales/verificarCap04.m.
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp
from scipy.linalg import expm
from scipy.optimize import fsolve, brentq

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:62s} {float(valor):14.6g}" + ('' if bien else f'  (esperado {esperado})'))

x1, x2, t, y, z, a, d, eps = sp.symbols('x1 x2 t y z a delta epsilon', real=True)
X = sp.Matrix([x1, x2])
o = dict(rtol=1e-11, atol=1e-12)

def equilibrios(f):
    J = sp.Matrix(f).jacobian(X)
    return [(s, J.subs(s)) for s in sp.solve(f, [x1, x2], dict=True)]

# ------------------------------------------------------------------ 4.2 plano de fase
print('4.2 Plano de fase')
f = sp.Matrix([2*x1*x2, x1*x2])
revisar('campo 2x1x2, x1x2 en (1,2): componente 1', f.subs({x1: 1, x2: 2})[0], 4)
revisar('... componente 2', f.subs({x1: 1, x2: 2})[1], 2)
# las trayectorias son rectas x1 - 2 x2 = cte: d/dt (x1 - 2x2) = 0
revisar('d/dt(x1 - 2x2) = 0 (rectas)', sp.simplify(f[0] - 2*f[1]), 0)
s = solve_ivp(lambda tt, w: [2*w[0]*w[1], w[0]*w[1]], (0, 0.3), [1, 2], **o)
revisar('desde (1,2): x1 - 2x2 se conserva', s.y[0, -1] - 2*s.y[1, -1], -3, 1e-8)
# masa-resorte: elipses w^2 x1^2 + x2^2 = cte
w = 2.0
s = solve_ivp(lambda tt, q: [q[1], -w**2*q[0]], (0, 10), [1, 0], **o)
Ener = w**2*s.y[0]**2 + s.y[1]**2
revisar('masa-resorte: w^2 x1^2 + x2^2 constante', np.ptp(Ener), 0, 1e-8)
# sistema del cuaderno de la clase A
fA = [-x1 + x1*x2, x1 + x2 - 2*x1*x2]
eqA = equilibrios(fA)
revisar('cuaderno: número de equilibrios', len(eqA), 2)
J00 = dict((tuple(sorted(s.items(), key=str)), J) for s, J in eqA)
for s, J in eqA:
    if s[x1] == 0:
        ev = sorted([complex(v) for v in J.eigenvals()], key=lambda c: c.real)
        revisar('cuaderno (0,0): valores propios -1 y 1 (silla)', ev[0].real*ev[1].real, -1)
    else:
        revisar('cuaderno (1,1): traza', J.trace(), -1)
        revisar('cuaderno (1,1): determinante', J.det(), 1)
# nulclina x2' = 0: x2 = -x1/(1 - 2x1)
revisar('nulclina x2: x1 + x2 - 2x1x2 = 0 con x2 = x1/(2x1-1)', sp.simplify(fA[1].subs(x2, x1/(2*x1 - 1))), 0)
# tiempo para llegar a un equilibrio: x' = -x desde 1 nunca llega; x' = -sqrt|x| llega en 2
revisar("x' = -sqrt(x) desde 1 llega en t = 2", sp.integrate(1/sp.sqrt(x1), (x1, 0, 1)), 2)

# ------------------------------------------------------------------ 4.3 sistemas lineales
print('4.3 Sistemas lineales')
A = sp.Matrix([[-1, -3], [0, 2]])
eA = sp.simplify((A*t).exp())
revisar('e^{At}[0,1] = e^{-t} - e^{2t} (no e^{-t} - e^{-2t})', sp.simplify(eA[0, 1] - (sp.exp(-t) - sp.exp(2*t))), 0)
revisar('e^{At}[0,0] = e^{-t}', sp.simplify(eA[0, 0] - sp.exp(-t)), 0)
P = sp.Matrix([[1, -1], [0, 1]])        # columnas: v1 (lambda=-1), v2 (lambda=2)
revisar('P^{-1} A P = diag(-1, 2): elemento (0,0)', (P.inv()*A*P)[0, 0], -1)
revisar('P^{-1} A P = diag(-1, 2): elemento (1,1)', (P.inv()*A*P)[1, 1], 2)
revisar('P^{-1} A P: fuera de la diagonal', (P.inv()*A*P)[0, 1], 0)
An = np.array([[-1., -3], [0, 2]])
revisar('expm(A t) contra la fórmula en t = 0.7', np.max(np.abs(expm(0.7*An) - np.array(eA.subs(t, 0.7)).astype(float))), 0, 1e-12)
# solución desde (1,1): x1 = 2e^{-t} - e^{2t}; cruza x1 = 0 en t = ln2/3
revisar('desde (1,1): x1(t) = 0 en t = ln(2)/3', brentq(lambda tt: (expm(tt*An)@[1, 1])[0], 0.01, 1), np.log(2)/3, 1e-10)
# la serie y la derivada
revisar('d/dt e^{At} = A e^{At} (sympy)', sp.simplify(sp.diff(eA, t) - A*eA).norm(), 0)

# ------------------------------------------------------------------ 4.4 clasificación
print('4.4 Clasificación de los retratos lineales')
def tipo(M):
    M = np.array(M, float); tau = np.trace(M); de = np.linalg.det(M); dis = tau**2 - 4*de
    if de < 0: return 'silla'
    if de == 0: return 'no aislado'
    if tau == 0: return 'centro'
    if dis < 0: return 'foco'
    return 'nodo'
casos = {'nodo': [[-6, 0], [0, -2]], 'silla': [[-1, 0], [0, 2]], 'foco': [[-0.5, -2], [2, -0.5]],
         'centro': [[0, 1], [-4, 0]], 'nodo2': [[-1, 1], [0, -1]]}
revisar('diag(-6,-2) es nodo', tipo(casos['nodo']) == 'nodo', 1)
revisar('diag(-1,2) es silla', tipo(casos['silla']) == 'silla', 1)
revisar('[-0.5 -2; 2 -0.5] es foco', tipo(casos['foco']) == 'foco', 1)
revisar('[0 1; -4 0] es centro', tipo(casos['centro']) == 'centro', 1)
revisar('Jordan [-1 1; 0 -1] es nodo (degenerado)', tipo(casos['nodo2']) == 'nodo', 1)
# nodo: z2 = c z1^{lambda2/lambda1}: lambda1=-6, lambda2=-2 -> z2 ~ z1^{1/3}: tangente a z2 (la dirección lenta)
revisar('nodo diag(-6,-2): exponente lambda2/lambda1 = 1/3', -2/-6, 1/3, 1e-15)
# nodo impropio: z1 = z2 [z10/z20 + ln(z2/z20)/lambda]
lam = -1.0; z10, z20 = 0.5, 1.0; tt = 1.3
z2t = z20*np.exp(lam*tt); z1t = (z10 + z20*tt)*np.exp(lam*tt)
revisar('nodo impropio: relación sin t', z1t - z2t*(z10/z20 + np.log(z2t/z20)/lam), 0, 1e-14)
# foco: forma real con P = [Re v, -Im v]
Af = np.array(casos['foco']); lamf, V = np.linalg.eig(Af); k = np.argmax(lamf.imag); v = V[:, k]
Pf = np.column_stack([v.real, -v.imag]); Jf = np.linalg.solve(Pf, Af@Pf)
revisar('foco: P = [Re v, -Im v] da J = [alpha -beta; beta alpha] (J11)', Jf[0, 0], -0.5, 1e-12)
revisar('... J21 = beta = 2', Jf[1, 0], 2, 1e-12)
revisar('... J12 = -beta', Jf[0, 1], -2, 1e-12)
# sentido de giro: el signo de a21
Ah = np.array([[1., -5], [1, -1]])   # tau=0, det=4: centro; a21 > 0 -> antihorario
s = solve_ivp(lambda tt, q: Ah@q, (0, 0.05), [1, 0], **o)
revisar('[1 -5; 1 -1]: centro (traza 0, det 4)', np.trace(Ah) == 0 and np.linalg.det(Ah) > 0, 1)
revisar('... desde (1,0) sube: x2 > 0 (antihorario, a21 = 1 > 0)', s.y[1, -1] > 0, 1)
# barrido x1' = a x1, x2' = -x2
revisar('a = -10: nodo, dirección lenta x2 (exponente 1/10)', (-1)/(-10), 0.1, 1e-15)
# perturbaciones: centro y nodo degenerado
for e in [0.01, -0.01]:
    revisar(f'centro + eps I (eps={e}): Re lambda = eps', np.linalg.eigvals(np.array([[e, 1], [-1, e]])).real.max(), e, 1e-14)
lamp = np.linalg.eigvals(np.array([[-1, 1], [-0.01, -1]]))
revisar('nodo degenerado + 0.01 abajo: foco, Im lambda = 0.1', abs(lamp.imag).max(), 0.1, 1e-12)
# sin equilibrios: alpha + sin(x1+x2) +- x1
fsin = lambda q, al: [al + np.sin(q[0] + q[1]) + q[0], al + np.sin(q[0] + q[1]) - q[0]]
qs = fsolve(lambda q: fsin(q, 0.5), [0, -0.5])
revisar('alpha = 0.5 (handout): SÍ hay equilibrio, x2 = -asin(0.5)', qs[1], -np.arcsin(0.5), 1e-9)
xx = np.linspace(-np.pi, np.pi, 20001)
revisar('alpha = 1.5: min |f| sobre x1 = 0 (único candidato) = 0.5 > 0', np.min(np.abs(1.5 + np.sin(xx))), 0.5, 1e-6)

# ------------------------------------------------------------------ 4.5 linealización
print('4.5 Linealización y Hartman--Grobman')
fK = [x1 + x1*x2, -x2 + x2**2 + x1*x2 - x1**3]
eqK = equilibrios(fK)
revisar('ejemplo de las diapositivas: tres equilibrios', len(eqK), 3)
for s, J in eqK:
    if s[x1] == 0 and s[x2] == 0:
        revisar('(0,0): J = diag(1,-1), silla', J.det(), -1)
    elif s[x1] == 0:
        revisar('(0,1): valores propios 2 y 1 (nodo inestable): traza', J.trace(), 3)
        revisar('(0,1): determinante', J.det(), 2)
    else:
        revisar('(1,-1): traza -2', J.trace(), -2)
        revisar('(1,-1): det 4 -> foco estable (-1 +- j sqrt3)', J.det(), 4)
# epsilon: d/dt (x1^2 + x2^2) = -2 eps x1^2 x2^2
fe = sp.Matrix([x2, -x1 - eps*x1**2*x2])
revisar('d/dt(x1^2+x2^2) = -2 eps x1^2 x2^2', sp.simplify((sp.Matrix([x1**2 + x2**2]).jacobian(X)*fe)[0] + 2*eps*x1**2*x2**2), 0)
for e, sig in [(1, -1), (-1, 1)]:
    s = solve_ivp(lambda tt, q: [q[1], -q[0] - e*q[0]**2*q[1]], (0, 60), [0.5, 0], **o)
    r = np.hypot(s.y[0, -1], s.y[1, -1])
    revisar(f'eps = {e}: r(60) {"<" if sig < 0 else ">"} r(0) = 0.5', (r < 0.5) if sig < 0 else (r > 0.5), 1)
s = solve_ivp(lambda tt, q: [q[1], -q[0] - q[0]**2*q[1]], (0, 60), [0.5, 0], **o)
revisar('eps = 1: r(60) desde 0.5', np.hypot(*s.y[:, -1]), 0.2297, 1e-3)
# equilibrio aislado con jacobiana singular: x' = x^3
revisar("x' = x^3: aislado con f'(0) = 0", sp.diff(x1**3, x1).subs(x1, 0), 0)
# x1' = 2x1x2: los ejes son equilibrios (no aislados)
revisar('2x1x2, x1x2: todo el eje x2 = 0 son equilibrios', f.subs(x2, 0).norm(), 0)

# ------------------------------------------------------------------ 4.6 ejemplos
print('4.6 Duffing y diodo túnel')
for dd in [0.5, 1.0, 3.0]:
    ls = np.roots([1, dd, 2])
    tipo_d = 'foco' if np.iscomplex(ls).any() else 'nodo'
    revisar(f'Duffing delta={dd}: (+-1,0) {tipo_d} estable (max Re < 0)', ls.real.max() < 0, 1)
revisar('Duffing: frontera foco/nodo en delta = 2 sqrt2', np.sqrt(8), 2.828427, 1e-6)
revisar('Duffing delta=0.5: silla en 0, lambda+ = (-0.5 + sqrt(4.25))/2', max(np.roots([1, 0.5, -1])), (-0.5 + np.sqrt(4.25))/2, 1e-12)
revisar('Duffing delta=0.5: Im lambda en (1,0) = sqrt(7.75)/2', np.roots([1, 0.5, 2]).imag.max(), np.sqrt(7.75)/2, 1e-12)
# energía de Duffing: E = x2^2/2 - x1^2/2 + x1^4/4, dE/dt = -delta x2^2
fD = sp.Matrix([x2, x1 - x1**3 - d*x2]); ED = x2**2/2 - x1**2/2 + x1**4/4
revisar('Duffing: dE/dt = -delta x2^2', sp.simplify((sp.Matrix([ED]).jacobian(X)*fD)[0] + d*x2**2), 0)
# cuenca: desde (2,0) con delta = 0.5 termina en ...
s = solve_ivp(lambda tt, q: [q[1], q[0] - q[0]**3 - 0.5*q[1]], (0, 80), [2, 0], **o)
revisar('Duffing delta=0.5: desde (2,0) termina en (-1,0)', s.y[0, -1], -1, 1e-6)
s = solve_ivp(lambda tt, q: [q[1], q[0] - q[0]**3 - 0.5*q[1]], (0, 80), [1.5, 0], **o)
revisar('Duffing delta=0.5: desde (1.5,0) termina en (1,0)', s.y[0, -1], 1, 1e-6)
# sin amortiguamiento no hay caos: E se conserva (integrable)
s = solve_ivp(lambda tt, q: [q[1], q[0] - q[0]**3], (0, 100), [0.3, 0.8], **o)
EE = s.y[1]**2/2 - s.y[0]**2/2 + s.y[0]**4/4
revisar('Duffing sin amortiguar: E conservada (máx |E - E0|)', np.ptp(EE), 0, 1e-7)
# diodo túnel de segundo orden (Khalil, sec. 1.2.2): E=1.2, R=1.5, C=2, L=5
h = lambda v: 17.76*v - 103.79*v**2 + 229.62*v**3 - 226.31*v**4 + 83.72*v**5
dh = lambda v: 17.76 - 2*103.79*v + 3*229.62*v**2 - 4*226.31*v**3 + 5*83.72*v**4
Ed, Rd, Cd, Ld = 1.2, 1.5, 2.0, 5.0
esperados = [(0.0626, 0.7582, 'nodo estable'), (0.2854, 0.6098, 'silla'), (0.8844, 0.2104, 'nodo estable')]
for v0, i0, nom in esperados:
    v = fsolve(lambda vv: h(vv) - (Ed - vv)/Rd, v0)[0]; i = (Ed - v)/Rd
    J = np.array([[-dh(v)/Cd, 1/Cd], [-1/Ld, -Rd/Ld]]); ls = np.linalg.eigvals(J).astype(complex)
    revisar(f'diodo: equilibrio {nom}: v', v, v0, 1e-4)
    revisar(f'diodo: equilibrio {nom}: i = (E - v)/R', i, i0, 1e-4)
    if nom == 'silla':
        revisar('diodo Q2: det J < 0 (silla)', np.linalg.det(J) < 0, 1)
        revisar('diodo Q2: lambda+ = 1.772', ls.real.max(), 1.7719, 1e-3)
    else:
        revisar(f'diodo {nom}: valores propios reales negativos', (ls.real.max() < 0) and (abs(ls.imag).max() == 0), 1)
revisar('diodo Q1: lambda = -3.592, -0.330 (el más rápido)', min(np.real(np.linalg.eigvals(np.array([[-dh(0.0626360)/Cd, 1/Cd], [-1/Ld, -Rd/Ld]])))), -3.5919, 1e-3)

fd = lambda tt, q: [(-h(q[0]) + q[1])/Cd, (-q[0] - Rd*q[1] + Ed)/Ld]
fin = lambda v0, i0: solve_ivp(fd, (0, 300), [v0, i0], **o).y[0, -1]
for v0, hv in [(0.0626360, 7.24), (0.2853687, -3.64), (0.8844296, 2.87)]:
    revisar(f"diodo: h'({v0:.3f}) (tabla)", dh(v0), hv, 6e-3)
revisar('diodo: desde (0.4, 0) termina en Q1', fin(0.4, 0), 0.0626, 1e-3)
revisar('diodo: umbral de i_L(0) en v = 0.4 (0.189 mA)', brentq(lambda i0: fin(0.4, i0) - 0.47, 0, 0.2, xtol=1e-8), 0.1887, 1e-3)
revisar('diodo: desde (0.15, 1.5) termina en Q3', fin(0.15, 1.5), 0.8844, 1e-3)
# problemas
revisar('competencia (1,1): det = -1 (silla)', np.linalg.det([[-1, -2], [-1, -1]]), -1, 1e-12)
revisar('problema clasificar (c): [2 1; -1 0] valor propio doble 1', max(abs(np.linalg.eigvals([[2, 1], [-1, 0]]) - 1)), 0, 1e-6)
hy2 = y**2
revisar('problema central a=-1: h = y^2 exacta', sp.simplify(sp.diff(hy2, y)*(-y**3 + y*hy2) + hy2 - y**2), 0)

# ------------------------------------------------------------------ 4.7 variedades
print('4.7 Variedades estable e inestable')
fW = sp.Matrix([-x1, x2 + x1**2])
hS = -x1**2/3
revisar("W^s: x2 = -x1^2/3 es invariante (x2' - h'(x1) x1' = 0)", sp.simplify(fW[1].subs(x2, hS) - sp.diff(hS, x1)*fW[0]), 0)
s = solve_ivp(lambda tt, q: [-q[0], q[1] + q[0]**2], (0, 15), [1, -1/3], **o)
revisar('desde (1, -1/3) (en W^s) converge: |x(15)|', np.hypot(*s.y[:, -1]), 0, 1e-5)
s = solve_ivp(lambda tt, q: [-q[0], q[1] + q[0]**2], (0, 15), [1, 0], **o)
revisar('desde (1, 0) (fuera de W^s) diverge: x2(15) > 1e5', s.y[1, -1] > 1e5, 1)
s = solve_ivp(lambda tt, q: [-q[0], q[1] + q[0]**2], (0, 15), [1, -0.5], **o)
revisar('desde (1, -0.5) diverge hacia -infinito', s.y[1, -1] < -1e5, 1)
# solución exacta: x2(t) = (x20 + x10^2/3) e^t - x10^2 e^{-2t}/3
revisar('solución exacta x2(1) desde (1, 0)', (1/3)*np.e - np.exp(-2)/3,
        solve_ivp(lambda tt, q: [-q[0], q[1] + q[0]**2], (0, 1), [1, 0], **o).y[1, -1], 1e-9)

# ------------------------------------------------------------------ 4.8 variedad central
print('4.8 Variedad central')
hh = sp.symbols('h2 h4'); hy = hh[0]*y**2 + hh[1]*y**4
ecu = sp.expand(-hy + a*y**2 - sp.diff(hy, y)*y*hy)
sol = sp.solve([ecu.coeff(y, 2), ecu.coeff(y, 4)], hh, dict=True)[0]
revisar('h2 = a', sp.simplify(sol[hh[0]] - a), 0)
revisar('h4 = -2 a^2', sp.simplify(sol[hh[1]] + 2*a**2), 0)
red = sp.expand(y*hy.subs(sol))
revisar('sistema reducido: y\' = a y^3 - 2 a^2 y^5', sp.simplify(red - (a*y**3 - 2*a**2*y**5)), 0)
for aa in [-1, 1]:
    s = solve_ivp(lambda tt, q: [q[0]*q[1], -q[1] + aa*q[0]**2], (0, 40), [0.3, 0.2],
                  events=lambda tt, q: abs(q[0]) - 5, **o)
    if aa < 0:
        revisar('a = -1: y(40) (converge, lento)', s.y[0, -1], 0.1054, 2e-3)
        yr = 0.3/np.sqrt(1 + 2*0.09*40)     # solución de y' = -y^3
        revisar('a = -1: y(40) cerca del reducido y\' = -y^3 (error rel. < 10 %)', abs(s.y[0, -1] - yr)/yr < 0.1, 1)
    else:
        revisar('a = 1: |y| crece (inestable)', abs(s.y[0, -1]) > 0.3, 1)
# a = 0: z -> 0, y queda en y0 exp(z0(1 - e^{-t}))
s = solve_ivp(lambda tt, q: [q[0]*q[1], -q[1]], (0, 30), [0.3, 0.2], **o)
revisar('a = 0: y(inf) = y0 e^{z0} (estable, no asintóticamente)', s.y[0, -1], 0.3*np.exp(0.2), 1e-6)
# la trampa: z = 0 "porque es rápida" daría y' = 0 para cualquier a
# no unicidad: x' = x^2, y' = -y: y = C e^{1/x} es invariante para x < 0
C1 = sp.symbols('C1')
revisar('x\'=x^2, y\'=-y: y = C e^{1/x} invariante', sp.simplify(-C1*sp.exp(1/x1) - sp.diff(C1*sp.exp(1/x1), x1)*x1**2), 0)
revisar('... es plana en 0^-: lim e^{1/x}/x^5 = 0', sp.limit(sp.exp(1/x1)/x1**5, x1, 0, '-'), 0)

print(f'\n{ok}/{total} verificaciones correctas')
