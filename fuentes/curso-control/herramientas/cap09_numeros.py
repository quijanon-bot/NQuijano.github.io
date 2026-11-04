"""Verificación independiente de los números del capítulo 9
(retroalimentación de estado, observadores y control integral).
Ejecutar:  python3 herramientas/cap09_numeros.py
"""
import numpy as np
import sympy as sp
import control as ct
from scipy.signal import tf2ss, place_poles

ok = True
np.set_printoptions(precision=4, suppress=True)


def revisar(nombre, valor, esperado, tol=1e-3):
    global ok
    v = float(np.real(valor))
    bien = abs(v - esperado) <= tol
    ok &= bien
    print(f"  {'ok  ' if bien else 'FALLA'} {nombre:<48s} {v:14.5f}  (esperado {esperado})")


def info(sys, T=20, n=40001):
    t = np.linspace(0, T, n)
    _, y = ct.step_response(sys, t)
    y = np.squeeze(y); yf = y[-1]
    os_ = max(0, (y.max() - yf)/abs(yf)*100)
    fuera = np.where(abs(y - yf) > 0.02*abs(yf))[0]
    return dict(OS=os_, tp=t[np.argmax(y)], ts=t[fuera[-1] + 1] if len(fuera) else 0, yf=yf, umax=None)


def ackermann(A, B, polos):
    n = A.shape[0]
    q = np.real(np.poly(polos))
    qA = sum(c*np.linalg.matrix_power(A, n - i) for i, c in enumerate(q))
    Cc = np.hstack([np.linalg.matrix_power(A, i) @ B for i in range(n)])
    e = np.zeros((1, n)); e[0, -1] = 1
    return e @ np.linalg.solve(Cc, qA)


def polos_esp(OS, tp=None, ts=None):
    z = -np.log(OS)/np.sqrt(np.pi**2 + np.log(OS)**2)
    wn = np.pi/(tp*np.sqrt(1 - z**2)) if tp else 4/(z*ts)
    return z, wn, np.roots([1, 2*z*wn, wn**2])


s = sp.symbols('s')

print('9.1  Ejemplo de Friedland: 4 estados, función de transferencia de primer orden')
A = np.array([[2, 3, 2, 1], [-2, -3, 0, 0], [-2, -2, -4, 0], [-2, -2, -2, -5]], float)
B = np.array([[1], [-2], [2], [-1]], float)
C = np.array([[7, 6, 4, 2]], float)
As, Bs, Cs = sp.Matrix(A.astype(int)), sp.Matrix(B.astype(int)), sp.Matrix(C.astype(int))
H = sp.simplify((Cs*(s*sp.eye(4) - As).adjugate()*Bs)[0])
D4 = sp.expand((s*sp.eye(4) - As).det())
print('     N(s) =', sp.factor(H), '   D(s) =', D4, '=', sp.factor(D4))
revisar('H(s) = 1/(s+1)', sp.simplify(H/D4 - 1/(s + 1)), 0)
revisar('coef. N s^2 (sin cancelar)', sp.Poly(sp.expand(H), s).all_coeffs()[1], 9)
G = ct.minreal(ct.ss2tf(A, B, C, 0), verbose=False)
print('     minreal:', G)
revisar('valores propios: suma', np.sum(np.linalg.eigvals(A)).real, -10)
revisar('rango ctrb', np.linalg.matrix_rank(ct.ctrb(A, B)), 2)
revisar('rango obsv', np.linalg.matrix_rank(ct.obsv(A, C)), 2)
# forma modal: A = T diag T^-1
lam, V = np.linalg.eig(A)
idx = np.argsort(-lam.real); lam = lam[idx]; V = V[:, idx]
Bm = np.linalg.solve(V, B); Cm = C @ V
print('     modos:', np.round(lam.real, 4), ' B modal ~', np.round((Bm.ravel()*0 + abs(Bm.ravel()) > 1e-9).astype(int)),
      ' C modal ~', np.round((abs(Cm.ravel()) > 1e-9).astype(int)))
revisar('modo -1: controlable y observable', (abs(Bm[0, 0]) > 1e-9) and (abs(Cm[0, 0]) > 1e-9), 1)
revisar('modo -2: no controlable, observable', (abs(Bm[1, 0]) < 1e-9) and (abs(Cm[0, 1]) > 1e-9), 1)
revisar('modo -3: controlable, no observable', (abs(Bm[2, 0]) > 1e-9) and (abs(Cm[0, 2]) < 1e-9), 1)
revisar('modo -4: ni lo uno ni lo otro', (abs(Bm[3, 0]) < 1e-9) and (abs(Cm[0, 3]) < 1e-9), 1)

print('9.2  Ejemplo motivador A = [-1 a; 3 -2], polos en -2 y -3')
a = 2
A = np.array([[-1, a], [3, -2]], float); B = np.array([[0], [1]], float)
revisar('valor propio inestable (a=2)', max(np.linalg.eigvals(A).real), 1)
K = np.array([[3 + 2/a, 2]])
revisar('K1 = 3 + 2/a', K[0, 0], 4)
pc = np.sort(np.linalg.eigvals(A - B @ K).real)
revisar('polo 1', pc[0], -3); revisar('polo 2', pc[1], -2)
aa, k1, k2, lm = sp.symbols('a K1 K2 lambda')
Ab = sp.Matrix([[-1, aa], [3 - k1, -2 - k2]])
print('     polinomio:', sp.expand((lm*sp.eye(2) - Ab).det()))
revisar('det ctrb (a) = -a', sp.Matrix([[0, aa], [1, -2]]).det().subs(aa, 2), -2)
# simulación desde x(0)=[1,1]
t = np.linspace(0, 5, 5001)
sysc = ct.ss(A - B @ K, np.zeros((2, 1)), np.eye(2), 0)
_, xs = ct.initial_response(sysc, t, X0=[1, 1])
u = -(K @ xs)
revisar('u(0) = -(4+2)', u[0, 0], -6)
revisar('max|u| (a=2)', np.abs(u).max(), 6)
for av in [2, 1, 0.1, 0.01]:
    Av = np.array([[-1, av], [3, -2]]); Kv = np.array([[3 + 2/av, 2]])
    _, xv = ct.initial_response(ct.ss(Av - B @ Kv, np.zeros((2, 1)), np.eye(2), 0), t, X0=[1, 1])
    print(f'     a={av:5}: K={Kv.ravel()}, |K|={np.linalg.norm(Kv):8.2f}, cond(C)={np.linalg.cond(ct.ctrb(Av, B)):9.1f}, max|u|={np.abs(Kv @ xv).max():8.2f}')

print('9.3  diag(-1,-3), B=[1;1]: polos en -2, -2')
A = np.diag([-1., -3.]); B = np.array([[1.], [1.]])
K = ackermann(A, B, [-2, -2])
revisar('K1', K[0, 0], 0.5); revisar('K2', K[0, 1], -0.5)
revisar('polos', np.linalg.eigvals(A - B @ K).real.max(), -2, 1e-6)

print('9.4  Ackermann: 1/s^2, polos -1 ± j')
A = np.array([[0, 1], [0, 0]], float); B = np.array([[0], [1]], float)
K = ackermann(A, B, [-1 + 1j, -1 - 1j])
revisar('K1', K[0, 0], 2); revisar('K2', K[0, 1], 2)

print('9.5  Tercer orden 10/((s+10)(s^2+0.5s+1)): OS 10 %, tp 1 s, tercer polo 10x')
G0 = ct.tf(10, np.polymul([1, 10], [1, 0.5, 1]))
I0 = info(G0, T=30)
revisar('original: %OS', I0['OS'], 44.13, 0.01); revisar('original: tp', I0['tp'], 3.35, 0.01)
z, wn, p2 = polos_esp(0.1, tp=1)
p3 = 10*p2[0].real
Ac, Bc, Cc, Dc = tf2ss([10], np.polymul([1, 10], [1, 0.5, 1]))
K = ackermann(Ac, Bc, [p2[0], p2[1], p3])
print('     K (tf2ss) =', K.ravel())
revisar('K1 (tf2ss)', K[0, 0], 17.1310, 1e-3); revisar('K2', K[0, 1], 115.2095, 1e-3); revisar('K3', K[0, 2], 339.3368, 1e-3)
T = ct.ss(Ac - Bc @ K, Bc, Cc, Dc)
I = info(T, T=5)
revisar('diseño: %OS', I['OS'], 9.84, 0.01); revisar('diseño: tp', I['tp'], 1.048, 0.002)
revisar('diseño: valor final', I['yf'], 10/(-p3*wn**2), 1e-3)
print('     valor final =', I['yf'])
# variables de fase: A=[0 1 0;0 0 1;-a0 -a1 -a2], B=[0;0;1], C=[10 0 0]
d = np.polymul([1, 10], [1, 0.5, 1])
Af = np.array([[0, 1, 0], [0, 0, 1], [-d[3], -d[2], -d[1]]]); Bf = np.array([[0], [0], [1.]])
Kf = ackermann(Af, Bf, [p2[0], p2[1], p3])
print('     K (variables de fase) =', Kf.ravel())
revisar('Kf1', Kf[0, 0], 339.3368, 1e-3); revisar('Kf3', Kf[0, 2], 17.1310, 1e-3)

print('9.5  Servo 1/(s(s+1)(s+2)), polos -2 ± j3.464 y -10, u = -(K2x2+K3x3)+K1(r-x1)')
desired = np.real(np.poly([-2 + 3.4641j, -2 - 3.4641j, -10]))
revisar('a2', desired[1], 14); revisar('a1', desired[2], 56, 1e-3); revisar('a0', desired[3], 160, 1e-2)
A = np.array([[0, 1, 0], [0, 0, 1], [0, -2, -3]], float); B = np.array([[0], [0], [1.]])
K = ackermann(A, B, [-2 + 3.4641j, -2 - 3.4641j, -10])
revisar('K1', K[0, 0], 160, 0.01); revisar('K2', K[0, 1], 54, 0.01); revisar('K3', K[0, 2], 11, 1e-6)
T = ct.ss(A - B @ K, B*K[0, 0], [[1, 0, 0]], 0)
revisar('valor final (servo, tipo 1)', ct.dcgain(T), 1, 1e-6)
I = info(T, T=6)
print(f'     servo: OS={I["OS"]:.2f} %, tp={I["tp"]:.3f}, ts={I["ts"]:.3f}')

print('9.5  100(s+1)/(s(s+2)(s+3)): OS 10 %, tp 1, tercer polo en -1 (cancela el cero)')
Ac, Bc, Cc, Dc = tf2ss([100, 100], np.polymul([1, 0], np.polymul([1, 2], [1, 3])))
K = ackermann(Ac, Bc, [p2[0], p2[1], -1])
print('     K (tf2ss) =', K.ravel())
T = ct.minreal(ct.ss2tf(ct.ss(Ac - Bc @ K, Bc, Cc, Dc)), verbose=False)
print('     T =', T)
I = info(T, T=5)
revisar('%OS', I['OS'], 10.0, 0.15); revisar('valor final', I['yf'], 100/wn**2, 1e-3)

print('9.6  Observador A=[2 3;-1 4], C=[1 0], zeta=0.8, wn=10')
A = np.array([[2, 3], [-1, 4]], float); C = np.array([[1, 0]], float)
L = ackermann(A.T, C.T, np.roots([1, 16, 100])).T
revisar('L1', L[0, 0], 22); revisar('L2', L[1, 0], 59)
print('9.6  Observador A=[0 1;-10 -2]')
A = np.array([[0, 1], [-10, -2]], float)
L = ackermann(A.T, C.T, np.roots([1, 16, 100])).T
revisar('L1', L[0, 0], 14); revisar('L2', L[1, 0], 62)
# simulación del observador con u = 0: x(0)=[1,0], xt(0)=[0,0]
Aobs = np.block([[A, np.zeros((2, 2))], [L @ C, A - L @ C]])
t = np.linspace(0, 3, 3001)
_, X = ct.initial_response(ct.ss(Aobs, np.zeros((4, 1)), np.eye(4), 0), t, X0=[1, 0, 0, 0])
err = np.linalg.norm(X[:2] - X[2:], axis=0)
print(f'     error del observador en t=0.5: {err[500]:.4f}, t=1: {err[1000]:.5f}')

print('9.7  Compensador completo: A=[0 1;-2 -3], K: -2±2j, L: -10 doble')
A = np.array([[0, 1], [-2, -3]], float); B = np.array([[0], [1.]]); C = np.array([[1, 0.]])
K = ackermann(A, B, [-2 + 2j, -2 - 2j]); L = ackermann(A.T, C.T, [-10, -10]).T
revisar('K1', K[0, 0], 6); revisar('K2', K[0, 1], 1)
revisar('L1', L[0, 0], 17); revisar('L2', L[1, 0], 47)
Aa = np.block([[A - B @ K, B @ K], [np.zeros((2, 2)), A - L @ C]])
ev = np.sort_complex(np.linalg.eigvals(Aa))
print('     valores propios (x, e):', np.round(ev, 4))
Acomp = A - B @ K - L @ C
Gc = ct.ss2tf(ct.ss(Acomp, L, -K, 0))
print('     compensador U/Y =', Gc)
zc = ct.zeros(Gc); pcmp = ct.poles(Gc)
print('     ceros', np.round(zc, 4), ' polos', np.round(pcmp, 4))
revisar('ganancia DC del compensador', ct.dcgain(Gc), -(K @ np.linalg.solve(-Acomp, L))[0, 0], 1e-9)

print('9.8  Control integral: A=[0 1;-3 -5], OS 10 %, ts 0.5 s')
A = np.array([[0, 1], [-3, -5]], float); B = np.array([[0], [1.]]); C = np.array([[1, 0.]])
z, wn, p2 = polos_esp(0.1, ts=0.5)
revisar('wn^2', wn**2, 183.1, 0.05); revisar('2 zeta wn', 2*z*wn, 16, 1e-9); revisar('wd', abs(p2[0].imag), 10.91, 0.01)
K = ackermann(A, B, p2)
revisar('K1 sin integrador', K[0, 0], 180.1, 0.05); revisar('K2', K[0, 1], 11, 1e-6)
T = ct.ss(A - B @ K, B, C, 0)
revisar('valor final sin integrador', ct.dcgain(T), 1/183.1, 1e-4)
revisar('e_ss sin integrador', 1 - ct.dcgain(T), 0.9945, 1e-4)
# aumentado: [x; z], u = -K x + Ke z,  z' = r - Cx
Aa = np.block([[A, np.zeros((2, 1))], [-C, np.zeros((1, 1))]]); Ba = np.vstack([B, [[0]]])
Ka = ackermann(Aa, Ba, [p2[0], p2[1], -100])   # Ka = [K, -Ke]
revisar('K1 con integrador', Ka[0, 0], 1780.1, 0.1); revisar('K2', Ka[0, 1], 111, 1e-6); revisar('Ke', -Ka[0, 2], 18313.7, 0.1)
Tcl = ct.ss(Aa - Ba @ Ka, np.array([[0], [0], [1.]]), np.hstack([C, [[0]]]), 0)
revisar('valor final con integrador', ct.dcgain(Tcl), 1, 1e-9)
I = info(Tcl, T=2)
print(f'     con integrador: OS={I["OS"]:.2f} %, ts={I["ts"]:.3f}')
# u(0+) del diseño con integrador ante escalón: u = -Kx + Ke z -> 0 en 0+; pico de u
t = np.linspace(0, 1.5, 15001)
_, X = ct.step_response(ct.ss(Aa - Ba @ Ka, np.array([[0], [0], [1.]]), np.eye(3), 0), t)
u = (-Ka @ np.squeeze(X)).ravel()
print(f'     max u con integrador: {u.max():.1f};   sin integrador u(0+) = 1')

print('9.8  Ejercicio: A=[0 1;-7 -9], C=[4 1], OS 10 %, tp 2 s, con integrador')
A = np.array([[0, 1], [-7, -9]], float); C = np.array([[4, 1.]])
z, wn, p2 = polos_esp(0.1, tp=2)
G = ct.ss2tf(ct.ss(A, B, C, 0)); print('     G =', G)
Aa = np.block([[A, np.zeros((2, 1))], [-C, np.zeros((1, 1))]]); Ba = np.vstack([B, [[0]]])
Ka = ackermann(Aa, Ba, [p2[0], p2[1], -4])
print('     cancelando el cero en -4: K =', Ka[0, :2], ' Ke =', -Ka[0, 2])
k1, k2, ke = sp.symbols('K1 K2 Ke')
Aas = sp.Matrix([[0, 1, 0], [-7 - k1, -9 - k2, ke], [-4, -1, 0]])
print('     polinomio aumentado:', sp.collect(sp.expand((lm*sp.eye(3) - Aas).det()), lm))
Tcl = ct.ss(Aa - Ba @ Ka, np.array([[0], [0], [1.]]), np.hstack([C, [[0]]]), 0)
I = info(Tcl, T=10)
revisar('ejercicio: %OS (cancela el cero)', I['OS'], 10.0, 0.15); revisar('ejercicio: tp', I['tp'], 2.0, 0.02)
revisar('ejercicio: valor final', I['yf'], 1, 1e-4)
K0 = ackermann(A, B, p2)
I0 = info(ct.ss(A - B @ K0, B, C, 0), T=10)
print(f'     sin integrador: K={K0.ravel()}, valor final={I0["yf"]:.4f}')
for p3 in [-8, -20]:
    Kx = ackermann(Aa, Ba, [p2[0], p2[1], p3]); Ix = info(ct.ss(Aa - Ba @ Kx, np.array([[0], [0], [1.]]), np.hstack([C, [[0]]]), 0), T=10)
    print(f'     tercer polo {p3}: K={Kx[0, :2]}, Ke={-Kx[0, 2]:.4f}, OS={Ix["OS"]:.2f} %, tp={Ix["tp"]:.3f}')

print('9.9  Problemas: 1/(s(s+3)) con polos -4 ± 4j (Ackermann)')
A = np.array([[0, 1], [0, -3]], float)
K = ackermann(A, B, [-4 + 4j, -4 - 4j])
revisar('K1', K[0, 0], 32); revisar('K2', K[0, 1], 5)
print('9.9  1/(s(s+1)(s+2)), OS <= 5 %, ts = 2 s, tercer polo 10x')
z, wn, p2 = polos_esp(0.05, ts=2)
print(f'     zeta={z:.4f}, wn={wn:.4f}, polos {p2}')
A = np.array([[0, 1, 0], [0, 0, 1], [0, -2, -3]], float); B3 = np.array([[0], [0], [1.]])
for m in [5, 10, 50]:
    K = ackermann(A, B3, [p2[0], p2[1], m*p2[0].real])
    T = ct.ss(A - B3 @ K, B3*K[0, 0], [[1, 0, 0]], 0)
    t = np.linspace(0, 5, 50001); _, X = ct.step_response(ct.ss(A - B3 @ K, B3*K[0, 0], np.eye(3), 0), t)
    u = K[0, 0]*(1 - X[0]) - K[0, 1]*X[1] - K[0, 2]*X[2]
    I = info(T, T=6)
    print(f'     {m:2d}x: K={np.round(K.ravel(), 3)}, OS={I["OS"]:.2f} %, ts={I["ts"]:.3f}, max|u|={np.abs(u).max():.1f}')
print('9.9  Observador A=[0 1;-2 -3] con polos en -4, -10, -25, -50')
A = np.array([[0, 1], [-2, -3]], float)
for p in [-4, -10, -25, -50]:
    L = ackermann(A.T, C[:, :2].T*0 + np.array([[1], [0]]), [p, p]).T
    print(f'     polo {p}: L = {L.ravel()}')
print('9.9  I-PD: 1/((s+1)(s+2)), OS 10 %, ts 2 s, tercer polo 5x')
A = np.array([[0, 1], [-2, -3]], float); C = np.array([[1, 0.]])
z, wn, p2 = polos_esp(0.1, ts=2)
Aa = np.block([[A, np.zeros((2, 1))], [-C, np.zeros((1, 1))]]); Ba = np.vstack([B, [[0]]])
Ka = ackermann(Aa, Ba, [p2[0], p2[1], 5*p2[0].real])
print(f'     K1={Ka[0, 0]:.4f}, K2={Ka[0, 1]:.4f}, Ke={-Ka[0, 2]:.4f}  -> I-PD: Kc=K1, Ki=Ke, Kd=K2')

print('9.9  Problema del compensador: K -3±3j, L doble en -15')
A = np.array([[0, 1], [-2, -3.]]); B = np.array([[0], [1.]]); C = np.array([[1, 0.]])
K = ackermann(A, B, [-3 + 3j, -3 - 3j]); L = ackermann(A.T, C.T, [-15, -15]).T
revisar('K1', K[0, 0], 16); revisar('K2', K[0, 1], 3); revisar('L1', L[0, 0], 27); revisar('L2', L[1, 0], 142)
print('     compensador:', ct.ss2tf(ct.ss(A - B @ K - L @ C, L, -K, 0)))

print('\n' + ('Todo verificado.' if ok else 'HAY FALLAS.'))
