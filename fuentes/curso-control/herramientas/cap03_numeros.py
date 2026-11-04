"""Verificación independiente de los números del capítulo 3
(Modelado II: linealización, segundo orden, diagramas en bloques, Mason,
orden superior y reducción de orden).
Ejecutar:  python3 herramientas/cap03_numeros.py
"""
import numpy as np
import sympy as sp
import control as ct
from scipy.optimize import fsolve, brentq

ok = True


def revisar(nombre, valor, esperado, tol=1e-3):
    global ok
    v = float(valor)
    bien = abs(v - esperado) <= tol
    ok &= bien
    print(f"  {'ok  ' if bien else 'FALLA'} {nombre:<46s} {v:12.5f}  (esperado {esperado})")


def info(G, T=None, n=200001):
    """Sobrepico (%), tiempo de pico, establecimiento 2 % y subida 10-90 % exactos."""
    if T is None:
        p = ct.poles(G)
        T = 12/min(abs(p.real[p.real < 0]))
    t = np.linspace(0, T, n)
    _, y = ct.step_response(G, t)
    yf = float(ct.dcgain(G))
    os_ = max(0, (y.max() - yf)/yf*100)
    tp = t[np.argmax(y)]
    fuera = np.where(abs(y - yf) > 0.02*abs(yf))[0]
    ts = t[fuera[-1] + 1] if len(fuera) else 0
    t10 = t[np.argmax(y >= 0.1*yf)]
    t90 = t[np.argmax(y >= 0.9*yf)]
    return dict(OS=os_, tp=tp, ts=ts, tr=t90 - t10, yf=yf)


s = ct.tf('s')

print('3.2  Linealización: x\' = x sqrt(x^2+5x) alrededor de x0 = 5 (NO es equilibrio)')
x = sp.symbols('x')
f = x*sp.sqrt(x**2 + 5*x)
revisar('f(5)', f.subs(x, 5), 35.355, 1e-3)
revisar('df/dx(5)', sp.diff(f, x).subs(x, 5), 12.374, 1e-3)
print('     equilibrios:', sp.solve(f, x))

print('3.2  Reactor: x\' = -k x^2 + u (c - x)/V, x*=1, u*=1')
xx, uu = sp.symbols('x u')
k, V, c = 1, 1, 2
F = -k*xx**2 + uu*(c - xx)/V
revisar('f(x*,u*)', F.subs({xx: 1, uu: 1}), 0)
revisar('df/dx', sp.diff(F, xx).subs({xx: 1, uu: 1}), -3)
revisar('df/du', sp.diff(F, uu).subs({xx: 1, uu: 1}), 1)

print('3.3  Dos tanques interactuantes (valores físicos)')
A1, A2, Cv1, Cv2, h2 = 2.0, 3.0, 0.1, 0.05, 4.0
fe = Cv2*np.sqrt(h2)
h1 = h2 + (fe/Cv1)**2
C1 = Cv1/(2*np.sqrt(h1 - h2)); C2 = -C1; C3 = Cv2/(2*np.sqrt(h2))
K1, tau1 = 1/C1, A1/C1
K2, tau2 = C1/(C3 - C2), A2/(C3 - C2)
revisar('f*', fe, 0.1); revisar('h1*', h1, 5.0)
revisar('C1', C1, 0.05); revisar('C3', C3, 0.0125)
revisar('K1', K1, 20); revisar('tau1', tau1, 40)
revisar('K2', K2, 0.8); revisar('tau2', tau2, 48)
G = K1*K2/((tau1*s + 1)*(tau2*s + 1) + K1*K2*C2)
revisar('ganancia DC (=1/C3)', ct.dcgain(G), 80)
wn = np.sqrt((1 + K1*K2*C2)/(tau1*tau2)); z = (tau1 + tau2)/(tau1*tau2)/(2*wn)
revisar('wn', wn, 0.010206, 1e-6)
revisar('zeta', z, 2.245, 1e-3)
p = np.sort(ct.poles(G).real)
revisar('polo rápido', p[0], -0.04344, 1e-5)
revisar('polo lento', p[1], -0.002398, 1e-6)
I = info(0.01*G, T=4000)
revisar('Delta h2 final (m) con escalón 0.01', I['yf'], 0.8)
revisar('t_s 2 % (s)', I['ts'], 1655, 1.0)
# fórmula general: wn^2 = C1 C3/(A1 A2), 2 zeta wn = (C1+C3)/A2 + C1/A1
revisar('wn^2 fórmula', C1*C3/(A1*A2), wn**2, 1e-9)
revisar('2 zeta wn fórmula', (C1 + C3)/A2 + C1/A1, 2*z*wn, 1e-9)
# estado estacionario no lineal vs lineal
for df, h2l, h1l, h2n, h1n in [(0.01, 4.8, 6.0, 4.84, 6.05), (0.05, 8.0, 10.0, 9.0, 11.25)]:
    f2 = fe + df
    revisar(f'h2 no lineal (df={df})', (f2/Cv2)**2, h2n)
    revisar(f'h1 no lineal (df={df})', (f2/Cv2)**2 + (f2/Cv1)**2, h1n)
    revisar(f'h2 lineal (df={df})', h2 + df/C3, h2l)
    revisar(f'h1 lineal (df={df})', h1 + df/C1 + df/C3, h1l)
# zeta >= 1 para cualquier parámetro positivo (muestra aleatoria)
rng = np.random.default_rng(1)
zmin = min(((c1 + c3)/a2 + c1/a1)/(2*np.sqrt(c1*c3/(a1*a2)))
           for a1, a2, c1, c3 in rng.uniform(0.01, 10, size=(20000, 4)))
revisar('min zeta en 20 000 casos aleatorios (>1)', zmin > 1, 1)
# el ejemplo viejo (tau1=1, tau2=4, C2=2, K1=K2=1): subamortiguado pero no físico
Gv = 1/((s + 1)*(4*s + 1) + 2)
Iv = info(Gv)
revisar('ej. viejo: %OS', Iv['OS'], 3.78, 0.01)
revisar('ej. viejo: DC', Iv['yf'], 1/3)

print('3.4  Masa-resorte-amortiguador m=1, b=1.2, k=4')
G = 1/(s**2 + 1.2*s + 4)
revisar('wn', 2, 2); revisar('zeta', 1.2/(2*2), 0.3)
I = info(G)
revisar('%OS', I['OS'], 37.23, 0.01)
revisar('t_p', I['tp'], np.pi/(2*np.sqrt(1 - 0.09)), 1e-3)

print('3.5  Fórmulas del subamortiguado (zeta = 0.5, wn = 1)')
for zz in [0.2, 0.5, 0.7]:
    G = 1/(s**2 + 2*zz*s + 1)
    I = info(G, T=60)
    revisar(f'z={zz}: %OS fórmula', 100*np.exp(-zz*np.pi/np.sqrt(1 - zz**2)), I['OS'], 0.01)
    revisar(f'z={zz}: t_p = pi/wd', np.pi/np.sqrt(1 - zz**2), I['tp'], 1e-3)
    tr0 = (np.pi - np.arccos(zz))/np.sqrt(1 - zz**2)
    t = np.linspace(0, 20, 200001); _, y = ct.step_response(G, t)
    revisar(f'z={zz}: t_r(0-100) = (pi - acos z)/wd', tr0, t[np.argmax(y >= 1)], 1e-3)
print('     t_r(10-90 %) exacto vs aproximaciones (wn = 1):')
print('      zeta   exacto  (1-0.4167z+2.917z^2)  (2.3z^2-0.078z+1.12)  (0.8+2.5z)')
err_nise, err_viejo = [], []
for zz in np.arange(0.1, 0.91, 0.1):
    tr = info(1/(s**2 + 2*zz*s + 1), T=80)['tr']
    a1 = 1 - 0.4167*zz + 2.917*zz**2
    a2 = 2.3*zz**2 - 0.078*zz + 1.12
    a3 = 0.8 + 2.5*zz
    err_nise.append(abs(a1 - tr)/tr); err_viejo.append(abs(a2 - tr)/tr)
    print(f'      {zz:.1f}   {tr:.3f}      {a1:.3f}                {a2:.3f}               {a3:.3f}')
revisar('error máx. aprox. 1-0.4167z+2.917z^2 (%)', 100*max(err_nise), 14.1, 0.1)
revisar('error máx. aprox. 2.3z^2-0.078z+1.12 (%)', 100*max(err_viejo), 3.1, 0.1)
revisar('t_s(2 %) exacto zeta=0.5, wn=1', info(1/(s**2 + s + 1), T=60)['ts'], 8.08, 0.02)

print('3.7  Diseño K y Kh: %OS = 20 %, t_p = 1 s')
OS = 0.2
z = -np.log(OS)/np.sqrt(np.pi**2 + np.log(OS)**2)
wn = np.pi/np.sqrt(1 - z**2)
K = wn**2; Kh = (2*z*wn - 1)/K
revisar('zeta', z, 0.4559, 1e-4); revisar('wn', wn, 3.5299, 1e-4)
revisar('K', K, 12.46, 0.01); revisar('Kh', Kh, 0.1781, 1e-4)
T = ct.feedback(K/s*1/(s + 1), 1 + Kh*s)
I = info(T, T=10)
revisar('%OS simulado', I['OS'], 20.0, 0.01); revisar('t_p simulado', I['tp'], 1.0, 1e-3)
revisar('coef. s del denominador', 1 + K*Kh, 3.219, 1e-3)

print('3.6  Bloques: equivalente de lazo abierto G_OL = G/(1+GH-G)')
g, h = sp.symbols('G H')
Gol = g/(1 + g*h - g)
revisar('Gol/(1+Gol) - G/(1+GH)', sp.simplify(Gol/(1 + Gol) - g/(1 + g*h)), 0)

print('3.8  Mason (grafo de 4 lazos): comparación con resolver el sistema de ecuaciones')
G1, G2, G3, G4, G5, G6, G7, G8, G9, H1, H2, H3, H4 = sp.symbols('G1:10 H1:5')
n = sp.symbols('x1:10')
R = sp.symbols('R')
ecs = [sp.Eq(n[0], R),
       sp.Eq(n[1], G1*n[0] - H1*n[2] - H4*n[4]),
       sp.Eq(n[2], G2*n[1]),
       sp.Eq(n[3], G3*n[2] - H2*n[4]),
       sp.Eq(n[4], G4*n[3]),
       sp.Eq(n[5], G5*n[4]),
       sp.Eq(n[6], G7*n[2] - H3*n[7]),
       sp.Eq(n[7], G8*n[6]),
       sp.Eq(n[8], G6*n[5] + G9*n[7])]
sol = sp.solve(ecs, n)
Tm = sp.simplify(sol[n[8]]/R)
L1, L2, L3, L4 = -G2*H1, -G2*G3*G4*H4, -G4*H2, -G8*H3
D = 1 - (L1 + L2 + L3 + L4) + (L1*L3 + L1*L4 + L2*L4 + L3*L4) - L1*L3*L4
P1, P2 = G1*G2*G3*G4*G5*G6, G1*G2*G7*G8*G9
Tmason = (P1*(1 - L4) + P2*(1 - L3))/D
revisar('Mason - solución directa', sp.simplify(Tm - Tmason), 0)

print('3.6  Problema multilazo')
T = ct.minreal(ct.feedback(1/(s + 1)*ct.feedback(2/s, 1)*5/(s + 3), 0.5), verbose=False)
print('     T(s) =', T)
pol = np.roots([1, 6, 11, 11])
print('     polos:', np.round(pol, 4))
revisar('polo real', min(pol.real), -3.9042, 1e-4)

print('3.9  Orden superior: 20/((s+10)(s^2+2s+2))')
ss_ = sp.symbols('s')
Y = 20/(ss_*(ss_ + 10)*(ss_**2 + 2*ss_ + 2))
print('     fracciones:', sp.apart(Y, ss_))
tt = sp.symbols('t', positive=True)
yt = sp.inverse_laplace_transform(Y, ss_, tt)
yesp = 1 - sp.Rational(40, 41)*sp.exp(-tt)*sp.cos(tt) - sp.Rational(50, 41)*sp.exp(-tt)*sp.sin(tt) - sp.Rational(1, 41)*sp.exp(-10*tt)
revisar('y(t) coincide (en t=0.7)', (yt - yesp).subs(tt, 0.7).evalf(), 0, 1e-12)
I3 = info(20/((s + 10)*(s**2 + 2*s + 2)), T=15)
I2 = info(2/(s**2 + 2*s + 2), T=15)
revisar('%OS tercer orden', I3['OS'], 4.27, 0.01)
revisar('%OS aproximación 2/(s^2+2s+2)', I2['OS'], 4.32, 0.02)
revisar('t_s tercer orden', I3['ts'], 4.32, 0.01)
revisar('t_s aproximación', I2['ts'], 4.22, 0.01)

print('3.9  Polo y cero cerca de los dominantes: 62.5(s+2.5)/((s^2+6s+25)(s+6.25))')
Tc = 62.5*(s + 2.5)/((s**2 + 6*s + 25)*(s + 6.25))
Ta = 10*(s + 2.5)/(s**2 + 6*s + 25)
Tb = 25/(s**2 + 6*s + 25)
Ic, Ia, Ib = info(Tc, T=6), info(Ta, T=6), info(Tb, T=6)
revisar('DC', ct.dcgain(Tc), 1)
revisar('%OS sin polo (cero + dominantes)', Ia['OS'], 54.5, 0.1)
revisar('%OS sistema completo', Ic['OS'], 38.0, 0.1)
revisar('%OS solo dominantes', Ib['OS'], 9.48, 0.01)
revisar('t_s sin polo', Ia['ts'], 1.47, 0.01)
revisar('t_s completo', Ic['ts'], 1.59, 0.02)
revisar('t_s solo dominantes', Ib['ts'], 1.19, 0.02)
for nombre, I in [('completo', Ic), ('sin polo', Ia), ('dominantes', Ib)]:
    print(f'     {nombre:11s} OS={I["OS"]:.1f} %  tp={I["tp"]:.3f}  ts={I["ts"]:.3f}  tr={I["tr"]:.3f}')

print('3.10 Reducción: K/(s(s+2)(s+30)) -> (K/30)/(s(s+2)), lazo unitario, K = 60 (y 300)')
for K, os1, os2 in [(60, 5.30, 4.32), (300, 42.29, 35.09)]:
    I1 = info(ct.feedback(K/(s*(s + 2)*(s + 30)), 1), T=15)
    I2 = info(ct.feedback(K/30/(s*(s + 2)), 1), T=15)
    revisar(f'K={K}: %OS completo', I1['OS'], os1, 0.01)
    revisar(f'K={K}: %OS reducido', I2['OS'], os2, 0.01)

print('3.10 Igualación de momentos: 6/(s^3+6s^2+11s+6) -> 1/(1 + d1 s + d2 s^2)')


def momentos(coef, q):
    """M_{2q} = sum_k (-1)^(k+q) M^(k)(0) M^(2q-k)(0) / (k!(2q-k)!) con coef = [a0,a1,...] (potencias crecientes).
    Como M^(k)(0)/k! = a_k, queda M_{2q} = sum_k (-1)^(k+q) a_k a_{2q-k}."""
    a = lambda k: coef[k] if 0 <= k < len(coef) else 0
    return sum((-1)**(k + q)*a(k)*a(2*q - k) for k in range(2*q + 1))


Dc = [1, 11/6, 1, 1/6]
D2, D4 = momentos(Dc, 1), momentos(Dc, 2)
revisar('Delta_2', D2, 49/36, 1e-9); revisar('Delta_4', D4, 7/18, 1e-9)
d2 = np.sqrt(D4); d1 = np.sqrt(D2 + 2*d2)
revisar('d1', d1, 1.615, 1e-3); revisar('d2', d2, 0.6236, 1e-4)
GL = 1/(d2*s**2 + d1*s + 1)
pl = np.sort(ct.poles(GL).real)
revisar('polo 1', pl[1], -1.025, 1e-3); revisar('polo 2', pl[0], -1.565, 1e-3)
revisar('wn^2 = 1/d2', 1/d2, 1.604, 1e-3); revisar('2 zeta wn = d1/d2', d1/d2, 2.590, 1e-3)
GH = 6/(s**3 + 6*s**2 + 11*s + 6)
t = np.linspace(0, 10, 2001)
_, yh = ct.step_response(GH, t); _, yl = ct.step_response(GL, t)
revisar('error máx. entre escalones', max(abs(yh - yl)), 0.104, 0.001)

print('3.10 Ejercicio: (s^3+7s^2+24s+24)/((s+1)(s+2)(s+3)(s+4)) -> 1/(1 + d1 s + d2 s^2)')
Nh = [1, 1, 7/24, 1/24]
Dh = list(np.poly1d(np.poly([-1, -2, -3, -4])).coeffs[::-1]/24)  # [1, 50/24, 35/24, 10/24, 1/24]
# G_H/G_L = N_h (1 + d1 s + d2 s^2)/D_h:  M_{2q}(d1,d2) = Delta_{2q}, q = 1, 2.


def residuo(v):
    d1, d2 = v
    M = np.polynomial.polynomial.polymul(Nh, [1, d1, d2])
    return [momentos(M, q) - momentos(Dh, q) for q in (1, 2)]


d1, d2 = fsolve(residuo, [1.0, 0.3])
GL = 1/(1 + d1*s + d2*s**2)
p_ = np.sort(ct.poles(GL).real)
print(f'     d1={d1:.4f} d2={d2:.4f}  polos {p_}')
revisar('residuo', max(abs(np.array(residuo([d1, d2])))), 0, 1e-10)
revisar('d1', d1, 1.2107, 1e-4); revisar('d2', d2, 0.2295, 1e-4)
GHx = (s**3 + 7*s**2 + 24*s + 24)/((s + 1)*(s + 2)*(s + 3)*(s + 4))
t = np.linspace(0, 10, 2001)
_, yh = ct.step_response(GHx, t); _, yl = ct.step_response(GL, t)
print(f'     error máx. entre escalones: {max(abs(yh - yl)):.4f}')

print('3.12 Ejercicios')
revisar('(a) x* = 4, a = -1 + 1/sqrt(x*)', -1 + 1/np.sqrt(4), -0.5)
revisar('(b) tanque: h* = 4, K = 1/(c/(2 sqrt h*))', 1/(0.5/(2*2)), 8)
revisar('(b) tau = A K', 2*8, 16)
revisar('(c) x* = 2: df/dx = -3x^2 + 2u', -12 + 4, -8)
for nombre, num, den, Kexp, wexp, zexp in [('T1', 50, [1, 6, 25], 2, 5, 0.6), ('T2', 16, [1, 0, 16], 1, 4, 0),
                                           ('T3', 9, [1, 6, 9], 1, 3, 1), ('T4', 100, [1, 30, 100], 1, 10, 1.5)]:
    wn_ = np.sqrt(den[2]); z_ = den[1]/(2*wn_)
    revisar(f'{nombre}: K', num/den[2], Kexp); revisar(f'{nombre}: wn', wn_, wexp); revisar(f'{nombre}: zeta', z_, zexp)
z, wn = 0.6, 5
revisar('T1 t_p', np.pi/(wn*np.sqrt(1 - z**2)), 0.7854, 1e-4)
revisar('T1 %OS', 100*np.exp(-z*np.pi/np.sqrt(1 - z**2)), 9.48, 0.01)
revisar('T1 t_r(0-100)', (np.pi - np.arccos(z))/(wn*np.sqrt(1 - z**2)), 0.5536, 1e-4)
revisar('T1 t_r(10-90) exacto', info(ct.tf(50, [1, 6, 25]), T=6)['tr'], 0.3708, 1e-3)
t = np.linspace(0, 3, 300001); _, y = ct.step_response(ct.tf(9, [1, 6, 9]), t)
revisar('T3: t al 95 %', t[np.argmax(y >= 0.95)], 1.5813, 1e-3)
p4 = np.sort(np.roots([1, 30, 100]).real)
revisar('T4: polo lento', p4[1], -3.820, 1e-3)
t = np.linspace(0, 5, 50001)
_, ye = ct.step_response(ct.tf(100, [1, 30, 100]), t)
_, ya = ct.step_response(ct.tf(-p4[1], [1, -p4[1]]), t)
revisar('T4: error máx. aprox. 1er orden', max(abs(ye - ya)), 0.105, 1e-3)
# diseño con K/(s(s+4))
z = -np.log(0.1)/np.sqrt(np.pi**2 + np.log(0.1)**2); wn = 4/(z*1.5)
revisar('dis. zeta', z, 0.5912, 1e-4); revisar('dis. wn', wn, 4.511, 1e-3)
revisar('dis. K', wn**2, 20.35, 0.01); revisar('dis. Kh', (2*z*wn - 4)/wn**2, 0.0655, 1e-4)
revisar('dis. t_p', np.pi/(wn*np.sqrt(1 - z**2)), 0.8636, 1e-3)
revisar('dis. t_s máx. para t_p <= 0.8', 4*0.8*np.sqrt(1 - z**2)/(np.pi*z), 1.3897, 1e-3)
# masa-resorte no lineal
revisar('x* (F=5): 4x + x^3 = 5', brentq(lambda v: 4*v + v**3 - 5, 0, 3), 1.0)
revisar('wn (F=5)', np.sqrt(4 + 3*1**2), 2.6458, 1e-4)
revisar('wn (F=16)', np.sqrt(4 + 3*2**2), 4.0)
# tercer orden del multilazo: aproximaciones
pol = np.roots([1, 6, 11, 11]); pc = pol[np.argmax(pol.imag)]
revisar('|1/gamma| / |zeta wn|', abs(min(pol.real))/abs(pc.real), 3.73, 0.01)
Dc = [1, 1, 6/11, 1/11]
d2 = np.sqrt(momentos(Dc, 2)); d1 = np.sqrt(momentos(Dc, 1) + 2*d2)
revisar('momentos d1', d1, 0.7677, 1e-3); revisar('momentos d2', d2, 0.3401, 1e-3)


print('3.12 Problema de tanques con otros datos: A1=1, A2=2, Cv1=0.2, Cv2=0.1, h2*=1')
A1, A2, Cv1, Cv2, h2 = 1.0, 2.0, 0.2, 0.1, 1.0
fe = Cv2*np.sqrt(h2); h1 = h2 + (fe/Cv1)**2
C1 = Cv1/(2*np.sqrt(h1 - h2)); C3 = Cv2/(2*np.sqrt(h2))
G = (1/C1)*(C1/(C3 + C1))/((A1/C1*s + 1)*(A2/(C3 + C1)*s + 1) - (1/C1)*(C1/(C3 + C1))*C1)
wn = np.sqrt(C1*C3/(A1*A2)); z = ((C1 + C3)/A2 + C1/A1)/(2*wn)
revisar('f*', fe, 0.1); revisar('h1*', h1, 1.25); revisar('C1', C1, 0.2); revisar('C3', C3, 0.05)
revisar('K1', 1/C1, 5); revisar('tau1', A1/C1, 5); revisar('K2', C1/(C1 + C3), 0.8); revisar('tau2', A2/(C1 + C3), 8)
revisar('DC', ct.dcgain(G), 20); revisar('wn', wn, 0.07071, 1e-5); revisar('zeta', z, 2.298, 1e-3)
p = np.sort(ct.poles(G).real)
revisar('polo lento', p[1], -0.01619, 1e-5); revisar('polo rápido', p[0], -0.3088, 1e-4)
I = info(0.01*G, T=1500)
revisar('t_s 2 % exacto', I['ts'], 244.9, 0.5)
revisar('Delta h2 final', I['yf'], 0.2)

print('3.12 Multilazo 10/(s^3+6s^2+11s+11): aproximaciones')
T = ct.tf(10, [1, 6, 11, 11])
pol = np.roots([1, 6, 11, 11]); pr = pol[np.argmin(pol.real)].real; pc = pol[np.argmax(pol.imag)]
a1, a0 = -2*pc.real, abs(pc)**2
Ta = ct.tf(10/11*a0, [1, a1, a0])
d1, d2 = 0.76772, 0.34015
Tb = ct.tf(10/11, [d2, d1, 1])
for nombre, G_, os_e in [('original', T, 7.15), ('dominantes', Ta, 8.12), ('momentos', Tb, 6.42)]:
    I = info(G_, T=15)
    revisar(f'{nombre}: %OS', I['OS'], os_e, 0.02)
    print(f'       t_s = {I["ts"]:.2f}')
revisar('dominantes: wn', np.sqrt(a0), 1.6785, 1e-3); revisar('dominantes: zeta', a1/(2*np.sqrt(a0)), 0.6243, 1e-3)

print('3.12 Problema 1(c): rango de validez del tanque linealizado (error < 5 %)')
h = np.linspace(0.01, 20, 200000); nl = 0.5*np.sqrt(h); li = 1 + 0.125*(h - 4)
rng_ = h[np.abs(li - nl)/nl < 0.05]
revisar('h mínimo', rng_.min(), 2.13, 0.01); revisar('h máximo', rng_.max(), 7.51, 0.01)

print('\n' + ('Todo verificado.' if ok else 'HAY FALLAS.'))
