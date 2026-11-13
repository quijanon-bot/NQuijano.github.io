"""Verificación independiente (sympy/scipy) de los números del capítulo 6
(bifurcaciones).   Ejecutar:  python3 herramientas/cap06_numeros.py
Los mismos números se comprueban en MATLAB/Octave con codigo/cap06_bifurcaciones/verificarCap06.m.
"""
import numpy as np
import sympy as sp
from scipy.integrate import solve_ivp, quad
from scipy.optimize import brentq

ok = 0; total = 0
def revisar(nombre, valor, esperado, tol=1e-9):
    global ok, total
    total += 1
    bien = abs(float(valor) - float(esperado)) <= tol
    ok += bien
    print(f"  {'ok ' if bien else 'FALLA'} {nombre:66s} {float(valor):14.6g}" + ('' if bien else f'  (esperado {esperado})'))

x, y, x1, x2, r, th, mu, t, u, v = sp.symbols('x y x1 x2 r theta mu t u v', real=True)
eps, h, a, b = sp.symbols('epsilon h a b', real=True)
o = dict(rtol=1e-11, atol=1e-12)

# ------------------------------------------------------------------ 6.2 hiperbolicidad
print('6.2 Lo que se rompe')
# x' = mu - x^3: f_x = 0 en (0,0) pero no hay bifurcación: un solo equilibrio mu^(1/3), siempre estable
fx = sp.diff(mu - x**3, x)
revisar("x' = mu - x^3: f_x(0,0) = 0", fx.subs({x: 0, mu: 0}), 0)
for m in [-0.5, 0.5]:
    xs = np.cbrt(m)
    revisar(f"x' = mu - x^3, mu = {m}: un solo equilibrio, f_x < 0", float(fx.subs(x, xs)) < 0, 1)
revisar("x' = mu - x^3: número de raíces reales para mu = 0.3", len([z for z in np.roots([-1, 0, 0, 0.3]) if abs(z.imag) < 1e-9]), 1)

# ------------------------------------------------------------------ 6.3 silla-nodo
print('6.3 Silla-nodo')
f = mu + x**2
for m in [-1.0, -0.25]:
    for xs in [-np.sqrt(-m), np.sqrt(-m)]:
        revisar(f"x' = mu + x^2, mu = {m}: f'({xs:+.2f}) = 2x*", float(sp.diff(f, x).subs(x, xs)), 2*xs)
# forma normal de la logística con cosecha: x(1-x) - h = (1/4 - h) - (x - 1/2)^2 (exacta)
revisar('cosecha: x(1-x) - h = (1/4 - h) - (x - 1/2)^2', sp.expand(x*(1 - x) - h - ((sp.Rational(1, 4) - h) - (x - sp.Rational(1, 2))**2)), 0)
# condiciones de Sotomayor en (x*, h) = (1/2, 1/4)
g = x*(1 - x) - h
revisar('cosecha: f_x(1/2, 1/4) = 0', sp.diff(g, x).subs({x: sp.Rational(1, 2), h: sp.Rational(1, 4)}), 0)
revisar('cosecha: f_h = -1 (transversalidad)', sp.diff(g, h), -1)
revisar('cosecha: f_xx = -2 (no degeneración)', sp.diff(g, x, 2), -2)
# el fantasma: T = integral_R dx/(m + x^2) = pi/sqrt(m); de +1 a -1: 2 atan(1/sqrt m)/sqrt m
for m in [0.01, 0.1, 1.0]:
    revisar(f'fantasma m = {m}: integral sobre R = pi/sqrt(m)', quad(lambda s: 1/(m + s**2), -np.inf, np.inf, epsabs=1e-12)[0], np.pi/np.sqrt(m), 1e-7)
m = 0.01
ev = lambda tt, z: z[0] + 1; ev.terminal = True
s = solve_ivp(lambda tt, z: [-m - z[0]**2], (0, 1e3), [1.0], events=ev, **o)
revisar('fantasma m = 0.01: tránsito de +1 a -1 (simulado)', s.t_events[0][0], 2*np.arctan(10)/0.1, 1e-6)
revisar('fantasma m = 0.01: tránsito de +1 a -1 = 29.42', 2*np.arctan(10)/0.1, 29.42, 5e-3)
# lentitud crítica: x' = mu - x^2, equilibrio estable sqrt(mu), lambda = -2 sqrt(mu)
for m, tc in [(1.0, 0.5), (0.01, 5.0)]:
    revisar(f'lentitud crítica mu = {m}: constante de tiempo 1/(2 sqrt mu)', 1/(2*np.sqrt(m)), tc)

# ------------------------------------------------------------------ 6.4 transcrítica, horquilla
print('6.4 Transcrítica y horquilla')
f = mu*x - x**2
revisar("transcrítica: f'(0) = mu", sp.diff(f, x).subs(x, 0) - mu, 0)
revisar("transcrítica: f'(mu) = -mu", sp.diff(f, x).subs(x, mu) + mu, 0)
G, k, al, N0, n = sp.symbols('G k alpha N0 n', positive=True)
laser = G*n*(N0 - al*n) - k*n
revisar('láser: Gn(N0 - alpha n) - kn = (G N0 - k) n - alpha G n^2', sp.expand(laser - ((G*N0 - k)*n - al*G*n**2)), 0)
nst = sp.solve(sp.Eq(laser/n, 0), n)[0]
revisar('láser: n* = (G N0 - k)/(alpha G)', sp.simplify(nst - (G*N0 - k)/(al*G)), 0)
revisar("láser: f'(0) = G N0 - k (umbral N0 = k/G)", sp.simplify(sp.diff(laser, n).subs(n, 0) - (G*N0 - k)), 0)
f = mu*x - x**3
revisar("horquilla supercrítica: f'(±sqrt mu) = -2 mu", sp.simplify(sp.diff(f, x).subs(x, sp.sqrt(mu)) + 2*mu), 0)
f = mu*x + x**3
revisar("horquilla subcrítica: f'(±sqrt(-mu)) = -2 mu > 0 si mu < 0", sp.simplify(sp.diff(f, x).subs(x, sp.sqrt(-mu)) + 2*mu), 0)
# quíntica: x' = mu x + x^3 - x^5: ramas x^2 = (1 ± sqrt(1 + 4 mu))/2, silla-nodo en mu = -1/4, x^2 = 1/2
f = mu*x + x**3 - x**5
sn = sp.solve([f/x, sp.diff(f/x, x)], [x, mu], dict=True)
sn = [s_ for s_ in sn if s_[x] > 0][0]
revisar('quíntica: silla-nodo en mu = -1/4', sn[mu], -0.25)
revisar('quíntica: ... en x = 1/sqrt 2', sn[x], 1/np.sqrt(2))
revisar('quíntica, mu = -0.1: rama estable x = 0.9420', np.sqrt((1 + np.sqrt(1 - 0.4))/2), 0.9420, 1e-4)
revisar('quíntica, mu = -0.1: rama inestable x = 0.3357', np.sqrt((1 - np.sqrt(1 - 0.4))/2), 0.3357, 1e-4)
# imperfecciones
revisar('transcrítica + eps < 0: sillas-nodo en mu = ±2 sqrt(-eps); eps = -0.12', 2*np.sqrt(0.12), 0.6928, 1e-4)
revisar('transcrítica + eps > 0: discriminante mu^2 + 4 eps > 0 siempre', sp.discriminant(mu*x - x**2 + eps, x) - (mu**2 + 4*eps), 0)
# horquilla + h: cúspide 4 mu^3 = 27 h^2  ->  mu_c = 3 (h/2)^(2/3)
cusp = sp.solve([mu*x - x**3 + sp.Rational(1, 10), mu - 3*x**2], [x, mu], dict=True)
muc = [float(c[mu]) for c in cusp if c[x].is_real and float(c[x]) < 0][0]
revisar('horquilla + h = 0.1: silla-nodo en mu = 3 (h/2)^(2/3)', muc, 3*(0.05)**(2/3))
revisar('... = 0.4072', muc, 0.4072, 1e-4)

# ------------------------------------------------------------------ 6.5 bifurcaciones en el plano
print('6.5 En el plano')
F = sp.Matrix([mu - x1**2, -x2]); J = F.jacobian([x1, x2])
Jn = J.subs(x1, sp.sqrt(mu)); Js = J.subs(x1, -sp.sqrt(mu))
revisar('silla-nodo 2-D: nodo, tau = -2 sqrt(mu) - 1', sp.simplify(Jn.trace() + 2*sp.sqrt(mu) + 1), 0)
revisar('silla-nodo 2-D: nodo, delta = 2 sqrt(mu)', sp.simplify(Jn.det() - 2*sp.sqrt(mu)), 0)
revisar('silla-nodo 2-D: silla, delta = -2 sqrt(mu)', sp.simplify(Js.det() + 2*sp.sqrt(mu)), 0)
revisar('silla-nodo 2-D, mu = 0: x1\' = -x1^2 desde -0.5 escapa (x1(1.9) < -10)',
        solve_ivp(lambda tt, z: [-z[0]**2, -z[1]], (0, 1.9), [-0.5, 1], **o).y[0, -1] < -10, 1)
# horquilla escondida: x1' = mu x1 - x1 x2, x2' = -x2 + x1^2. Equilibrios (±sqrt mu, mu) exactos
Fh = sp.Matrix([mu*x1 - x1*x2, -x2 + x1**2])
revisar('horquilla escondida: (sqrt mu, mu) es equilibrio', sp.simplify(Fh.subs({x1: sp.sqrt(mu), x2: mu})).norm(), 0)
Jh = Fh.jacobian([x1, x2]).subs({x1: sp.sqrt(mu), x2: mu})
revisar('... tau = -1', Jh.trace(), -1)
revisar('... delta = 2 mu', sp.simplify(Jh.det() - 2*mu), 0)
# variedad central con mu = 0: h = x1^2 + ..., reducido x1' = -x1^3
hh = sp.symbols('c2 c4'); hc = hh[0]*x1**2 + hh[1]*x1**4
ecu = sp.expand(sp.diff(hc, x1)*(-x1*hc) - (-hc + x1**2))
sol = sp.solve([ecu.coeff(x1, 2), ecu.coeff(x1, 4)], hh, dict=True)[0]
revisar('horquilla escondida: h(x1) = x1^2 + ...', sol[hh[0]], 1)
revisar('... coeficiente de x1^4 = +2', sol[hh[1]], 2)
s = solve_ivp(lambda tt, z: [0.1*z[0] - z[0]*z[1], -z[1] + z[0]**2], (0, 200), [0.05, 0], **o)
revisar('horquilla escondida, mu = 0.1: x1 -> sqrt(0.1)', s.y[0, -1], np.sqrt(0.1), 1e-6)
# interruptor genético de Griffith
X, Y = sp.symbols('X Y', positive=True)
Fg = sp.Matrix([-a*X + Y, X**2/(1 + X**2) - b*Y]); Jg = Fg.jacobian([X, Y])
revisar('Griffith: tau = -(a + b)', sp.simplify(Jg.trace() + a + b), 0)
dg = sp.simplify(Jg.det().subs(a*b, X/(1 + X**2)))
revisar('Griffith: delta en el equilibrio = x(x^2 - 1)/(1 + x^2)^2',
        sp.simplify(Jg.det().subs(b, X/(a*(1 + X**2))) - X*(X**2 - 1)/(1 + X**2)**2), 0)
bb = 0.35; ac = 1/(2*bb)
revisar('Griffith b = 0.35: a_c = 1/(2b) = 1.4286', ac, 1.428571, 1e-6)
aa = 1.0
d = 1 - 4*aa**2*bb**2
xa, xb = (1 - np.sqrt(d))/(2*aa*bb), (1 + np.sqrt(d))/(2*aa*bb)
revisar('Griffith a = 1, b = 0.35: equilibrio intermedio x = 0.4084', xa, 0.4084, 1e-4)
revisar('Griffith a = 1, b = 0.35: equilibrio alto x = 2.4488', xb, 2.4488, 1e-4)
dfun = lambda xx: xx*(xx**2 - 1)/(1 + xx**2)**2
revisar('... intermedio: delta < 0 (silla)', dfun(xa) < 0, 1)
revisar('... alto: delta > 0 (nodo estable)', dfun(xb) > 0, 1)
revisar('... alto: tau^2 - 4 delta > 0 (nodo, no foco)', (aa + bb)**2 - 4*dfun(xb) > 0, 1)
revisar('Griffith en a = a_c: x* = 1 para cualquier b', (1/(2*ac*bb)), 1)
revisar('Griffith origen: valores propios -a y -b', sp.Matrix(Jg.subs({X: 0})).eigenvals() == {-a: 1, -b: 1}, 1)
# histéresis: con a = 1.3 desde el estado alto se queda arriba; con a = 1.6 cae; al volver a 1.3 sigue abajo
def gen(aa_, z0, T=400):
    return solve_ivp(lambda tt, z: [-aa_*z[0] + z[1], z[0]**2/(1 + z[0]**2) - bb*z[1]], (0, T), z0, **o).y[:, -1]
z = gen(1.3, [2.0, 2.6])
revisar('Griffith a = 1.3: sigue encendido (x > 1)', z[0] > 1, 1)
z = gen(1.6, z)
revisar('Griffith a = 1.6: se apaga (x -> 0)', z[0] < 1e-3, 1)
z = gen(1.3, z)
revisar('Griffith de vuelta a a = 1.3: sigue apagado (histéresis)', z[0] < 1e-3, 1)

# ------------------------------------------------------------------ 6.6 Hopf
print('6.6 Hopf')
# el circuito: x1' = x2 - (x1^3 - mu x1), x2' = -x1
Jc = sp.Matrix([x2 - (x1**3 - mu*x1), -x1]).jacobian([x1, x2]).subs({x1: 0, x2: 0})
revisar('circuito: tau = mu', Jc.trace() - mu, 0)
revisar('circuito: delta = 1', Jc.det(), 1)
revisar('circuito: d Re(lambda)/d mu = 1/2 (transversalidad)', sp.diff(Jc.trace()/2, mu), 0.5)
# coeficiente de Lyapunov (Guckenheimer y Holmes, ec. 3.4.11), para u' = -w v + f, v' = w u + g
def l1(f, g, w=1):
    dd = lambda Fn, *z: sp.diff(Fn, *z).subs({u: 0, v: 0})
    return sp.nsimplify(sp.Rational(1, 16)*(dd(f, u, u, u) + dd(f, u, v, v) + dd(g, u, u, v) + dd(g, v, v, v))
                        + sp.Rational(1, 16)/w*(dd(f, u, v)*(dd(f, u, u) + dd(f, v, v)) - dd(g, u, v)*(dd(g, u, u) + dd(g, v, v))
                                                - dd(f, u, u)*dd(g, u, u) + dd(f, v, v)*dd(g, v, v)))
revisar('l1 de la forma normal supercrítica = -1', l1(-u*(u**2 + v**2), -v*(u**2 + v**2)), -1)
revisar('l1 de la forma normal subcrítica = +1', l1(u*(u**2 + v**2), v*(u**2 + v**2)), 1)
revisar('l1 del circuito (u = x1, v = -x2) = -3/8', l1(-u**3, 0*u), -0.375)
revisar('circuito: amplitud predicha sqrt(-(1/2) mu / l1) = 2 sqrt(mu/3), mu = 0.1', np.sqrt(0.5*0.1/0.375), 2*np.sqrt(0.1/3))
def ciclo(mm):
    Fc = lambda tt, z: [z[1] - (z[0]**3 - mm*z[0]), -z[0]]
    s = solve_ivp(Fc, (0, 600), [0.1, 0], **o)
    e = lambda tt, z: z[1]; e.direction = 1
    s2 = solve_ivp(Fc, (0, 40), s.y[:, -1], events=e, dense_output=True, **o)
    te = s2.t_events[0]; tt = np.linspace(te[-2], te[-1], 6000)
    return s2.sol(tt)[0].max(), te[-1] - te[-2]
A01, T01 = ciclo(0.1)
revisar('circuito mu = 0.1: amplitud de x1 = 0.3652', A01, 0.3652, 2e-4)
revisar('circuito mu = 0.1: período = 6.287', T01, 6.287, 2e-3)
A1, T1 = ciclo(1.0)
revisar('circuito mu = 1 (van der Pol): amplitud = 1.160', A1, 1.160, 2e-3)
revisar('circuito mu = 1 (van der Pol): período = 6.663', T1, 6.663, 2e-3)
# forma normal: r' = r(mu - r^2); ciclo r = sqrt(mu); con mu = 0, r(t) = r0/sqrt(1 + 2 r0^2 t)
rs = sp.Function('rr')
revisar("mu = 0: r(t) = r0/sqrt(1 + 2 r0^2 t) resuelve r' = -r^3",
        sp.simplify(sp.diff(1/sp.sqrt(1 + 2*t), t) + (1/sp.sqrt(1 + 2*t))**3), 0)
s = solve_ivp(lambda tt, z: [-z[1] - z[0]*(z[0]**2 + z[1]**2), z[0] - z[1]*(z[0]**2 + z[1]**2)], (0, 100), [1, 0], **o)
revisar('mu = 0, r0 = 1: r(100) = 1/sqrt(201) = 0.0705', np.hypot(*s.y[:, -1]), 1/np.sqrt(201), 1e-7)
# polares de la forma normal cartesiana
X1 = r*sp.cos(th); X2 = r*sp.sin(th)
f1 = -X2 + X1*(mu - r**2); f2 = X1 + X2*(mu - r**2)
revisar("polares: r' = r(mu - r^2)", sp.simplify(sp.cos(th)*f1 + sp.sin(th)*f2 - r*(mu - r**2)), 0)
revisar("polares: theta' = 1", sp.simplify((sp.cos(th)*f2 - sp.sin(th)*f1)/r), 1)
# histéresis de ciclos: r' = r(mu + r^2 - r^4)
revisar('histéresis: silla-nodo de ciclos en mu = -1/4, r = 1/sqrt 2', (1/np.sqrt(2))**4 - (1/np.sqrt(2))**2, -0.25)
revisar('histéresis, mu = -0.1: ciclo estable r = 0.9420', np.sqrt((1 + np.sqrt(0.6))/2), 0.9420, 1e-4)
revisar('histéresis, mu = 0: salto al ciclo r = 1', np.sqrt((1 + np.sqrt(1))/2), 1.0)
# rampa lenta: subir mu de -0.4 a 0.1 y bajar: salta arriba cerca de 0, abajo cerca de -1/4
def rampa(m0, m1, r0, T=3000):
    ff = lambda tt, z: [z[0]*((m0 + (m1 - m0)*tt/T) + z[0]**2 - z[0]**4) + 1e-6]   # 1e-6: piso de ruido
    s_ = solve_ivp(ff, (0, T), [r0], dense_output=True, max_step=1, **o)
    tt = np.linspace(0, T, 30001); rr = s_.sol(tt)[0]; mm = m0 + (m1 - m0)*tt/T
    return mm, rr
mm, rr = rampa(-0.4, 0.1, 1e-3)
msub = mm[np.argmax(rr > 0.5)]; print('     (salto al subir en mu = %.4f)' % msub)
revisar('rampa subiendo: el salto ocurre con mu > 0 (retardo)', msub > 0, 1)
mm, rr = rampa(0.1, -0.4, rr[-1])
mbaj = mm[np.argmax(rr < 0.3)]; print('     (caída al bajar en mu = %.4f)' % mbaj)
revisar('rampa bajando: el ciclo se apaga cerca de mu = -1/4', mbaj, -0.25, 0.01)

# ------------------------------------------------------------------ 6.7 bifurcaciones de ciclos
print('6.7 Bifurcaciones de ciclos')
f1 = -x*sp.sin(mu) - y*sp.cos(mu) + (1 - x**2 - y**2)**2*(x*sp.cos(mu) - y*sp.sin(mu))
f2 = x*sp.cos(mu) - y*sp.sin(mu) + (1 - x**2 - y**2)**2*(x*sp.sin(mu) + y*sp.cos(mu))
P = {x: r*sp.cos(th), y: r*sp.sin(th)}
rd = sp.simplify((sp.cos(th)*f1.subs(P) + sp.sin(th)*f2.subs(P)))
td = sp.simplify((sp.cos(th)*f2.subs(P) - sp.sin(th)*f1.subs(P))/r)
revisar("pliegue de ciclos: r' = r((1 - r^2)^2 cos mu - sin mu)", sp.simplify(rd - r*((1 - r**2)**2*sp.cos(mu) - sp.sin(mu))), 0)
revisar("pliegue de ciclos: theta' = (1 - r^2)^2 sin mu + cos mu", sp.simplify(td - ((1 - r**2)**2*sp.sin(mu) + sp.cos(mu))), 0)
# con (1 - r^2) sin cuadrado (versión anterior) sale otra cosa
f1h = -x*sp.sin(mu) - y*sp.cos(mu) + (1 - x**2 - y**2)*(x*sp.cos(mu) - y*sp.sin(mu))
f2h = x*sp.cos(mu) - y*sp.sin(mu) + (1 - x**2 - y**2)*(x*sp.sin(mu) + y*sp.cos(mu))
rdh = sp.simplify(sp.cos(th)*f1h.subs(P) + sp.sin(th)*f2h.subs(P))
revisar("sin el cuadrado: r' = r((1 - r^2) cos mu - sin mu) (un solo ciclo)", sp.simplify(rdh - r*((1 - r**2)*sp.cos(mu) - sp.sin(mu))), 0)
m = 0.1
rin, rout = np.sqrt(1 - np.sqrt(np.tan(m))), np.sqrt(1 + np.sqrt(np.tan(m)))
revisar('pliegue, mu = 0.1: ciclo interior r = 0.8266', rin, 0.8266, 1e-4)
revisar('pliegue, mu = 0.1: ciclo exterior r = 1.1475', rout, 1.1475, 1e-4)
gq = lambda rr_: (1 - rr_**2)**2*np.cos(m) - np.sin(m)
dgr = lambda rr_: -4*rr_*(1 - rr_**2)*np.cos(m)
revisar('... interior estable (dg/dr < 0)', dgr(rin) < 0, 1)
revisar('... exterior inestable (dg/dr > 0)', dgr(rout) > 0, 1)
revisar("mu < 0: r' > 0 para todo r > 0 (no hay ciclos)", min(((1 - rr_**2)**2*np.cos(-0.1) - np.sin(-0.1)) for rr_ in np.linspace(0.01, 3, 500)) > 0, 1)
# oscilador no uniforme (capítulo 5): período 2 pi / sqrt(w^2 - a^2)
revisar('SNIC (cap. 5): período con w = 2, a = 1.9 = 10.06', 2*np.pi/np.sqrt(4 - 1.9**2), 10.06, 5e-3)

# ------------------------------------------------------------------ 6.8 mapas de Poincaré
print('6.8 Mapas de Poincaré')
r0 = sp.symbols('r0', positive=True)
Pm = (1 + (1/r0**2 - 1)*sp.exp(-4*sp.pi))**sp.Rational(-1, 2)
revisar('ejemplo 1: P(1) = 1', Pm.subs(r0, 1), 1)
revisar('ejemplo 1: P\'(1) = e^{-4 pi} = 3.49e-6', sp.diff(Pm, r0).subs(r0, 1), np.exp(-4*np.pi), 1e-15)
# contra la simulación: r' = r(1 - r^2), theta' = -1, desde r0 = 0.3 durante 2 pi
s = solve_ivp(lambda tt, z: [z[0]*(1 - z[0]**2)], (0, 2*np.pi), [0.3], **o)
revisar('ejemplo 1: P(0.3) simulado = fórmula', s.y[0, -1], float(Pm.subs(r0, 0.3)), 1e-9)
# ejemplo 2 (Jordan y Smith): r' = r(mu - r), theta' = -1
mm_ = 0.2
P2 = lambda q: mm_*q/(q + (mm_ - q)*np.exp(-2*np.pi*mm_))
s = solve_ivp(lambda tt, z: [z[0]*(mm_ - z[0])], (0, 2*np.pi), [0.1], **o)
revisar('ejemplo 2, mu = 0.2: P(0.1) simulado = fórmula', s.y[0, -1], P2(0.1), 1e-10)
revisar('ejemplo 2: P(mu) = mu', P2(mm_), mm_, 1e-14)
dP2 = (P2(mm_ + 1e-6) - P2(mm_ - 1e-6))/2e-6
revisar("ejemplo 2: P'(mu) = e^{-2 pi mu} = 0.2846", dP2, np.exp(-2*np.pi*mm_), 1e-7)
revisar("... = 0.2846", np.exp(-2*np.pi*mm_), 0.2846, 1e-4)
# divergencia: x1' = mu x1 + x2 - x1 r, x2' = -x1 + mu x2 - x2 r: div = 2 mu - 3 r
dv = sp.diff(mu*x1 + x2 - x1*sp.sqrt(x1**2 + x2**2), x1) + sp.diff(-x1 + mu*x2 - x2*sp.sqrt(x1**2 + x2**2), x2)
revisar('ejemplo 2: div f = 2 mu - 3 r', sp.simplify(dv - (2*mu - 3*sp.sqrt(x1**2 + x2**2))), 0)
revisar('ejemplo 2: exp(integral de div sobre el ciclo) = P\'(mu)', np.exp(2*np.pi*(2*mm_ - 3*mm_)), np.exp(-2*np.pi*mm_), 1e-14)
# el circuito con mu = 1 (van der Pol): mapa numérico en Sigma = {x2 = 0, x1 > 0}
Fc = lambda tt, z: [z[1] - (z[0]**3 - z[0]), -z[0]]
def Pvdp(q):
    e = lambda tt, z: z[1]; e.direction = -1           # en x1 > 0, x2' = -x1 < 0: cruza bajando
    s_ = solve_ivp(Fc, (0, 30), [q, 0], events=e, **o)
    te = [tt for tt in s_.t_events[0] if tt > 1e-6]
    k_ = list(s_.t_events[0]).index(te[0])
    return s_.y_events[0][k_][0], te[0]
qs = brentq(lambda q: Pvdp(q)[0] - q, 1.0, 3.0, xtol=1e-12)
Tq = Pvdp(qs)[1]
revisar('van der Pol: punto fijo de P en x1 = 1.1081', qs, 1.1081, 2e-4)
revisar('van der Pol: tiempo de retorno en el punto fijo = período 6.663', Tq, 6.663, 2e-3)
dPq = (Pvdp(qs + 1e-5)[0] - Pvdp(qs - 1e-5)[0])/2e-5
s_ = solve_ivp(lambda tt, z: Fc(tt, z[:2]) + [1 - 3*z[0]**2], (0, Tq), [qs, 0, 0], **o)
revisar("van der Pol: P'(x*) = exp(integral de div f) (Floquet)", dPq, np.exp(s_.y[2, -1]), 1e-5)
revisar("van der Pol: P'(x*) = 8.60e-4 < 1 (ciclo estable)", dPq, 8.60e-4, 1e-5)
T1q, T2q = Pvdp(0.5)[1], Pvdp(2.5)[1]
revisar('van der Pol: el tiempo de retorno no es constante (0.5 vs 2.5)', abs(T1q - T2q) > 0.1, 1)

# ------------------------------------------------------------------ problemas
print('Problemas')
f = 1 + mu*x + x**2
revisar('P6.1a: raíz doble cuando mu^2 = 4', sp.discriminant(f, x) - (mu**2 - 4), 0)
f = mu*x - x/(1 + x**2)
revisar("P6.1c: expansión -x/(1+x^2) = -x + x^3 - ...", sp.series(-x/(1 + x**2), x, 0, 4).removeO() - (-x + x**3), 0)
xr_ = sp.sqrt(1/mu - 1)
revisar("P6.1c: f_x en la rama no nula = 2 mu (1 - mu) (inestable)", sp.simplify(sp.diff(f, x).subs(x, xr_) - 2*mu*(1 - mu)), 0)
revisar('P6.2a: h = 0.26, tiempo de 1 a 0 = 20 atan 5 = 27.47', quad(lambda s_: 1/(0.01 + (s_ - 0.5)**2), 0, 1)[0], 27.47, 5e-3)
aa_ = np.sqrt(0.05)
revisar('P6.2b: h = 0.3, tiempo de 1 a 0 = 10.29', (2/aa_)*np.arctan(0.5/aa_), 10.29, 5e-3)
bb2, aa2 = 0.5, 0.8
d2 = 1 - 4*aa2**2*bb2**2
revisar('P6.4: b = 0.5, a = 0.8: equilibrio alto = 2', (1 + np.sqrt(d2))/(2*aa2*bb2), 2, 1e-12)
revisar('P6.4: ... intermedio = 0.5', (1 - np.sqrt(d2))/(2*aa2*bb2), 0.5, 1e-12)
revisar('P6.4: delta en x = 2 = 0.24', dfun(2.0), 0.24, 1e-12)
revisar('P6.4: delta en x = 0.5 = -0.24', dfun(0.5), -0.24, 1e-12)
revisar('P6.5: l1 de u\' = -v + a u^3 = 3a/8 (a = -1)', l1(-u**3, 0*u), -0.375)
K_ = sp.symbols('K', positive=True)
p_, v_ = sp.symbols('p v', positive=True)
Frm = sp.Matrix([v_*(1 - v_/K_) - v_*p_/(1 + v_), p_*(2*v_/(1 + v_) - 1)])
Jrm = Frm.jacobian([v_, p_]).subs({v_: 1, p_: 2 - 2/K_})
revisar('P6.6: tau = (K - 3)/(2K)', sp.simplify(Jrm.trace() - (K_ - 3)/(2*K_)), 0)
revisar('P6.6: delta = (K - 1)/(2K)', sp.simplify(Jrm.det() - (K_ - 1)/(2*K_)), 0)
revisar('P6.6: d tau/dK = 1/6 en K = 3', sp.diff(Jrm.trace(), K_).subs(K_, 3), sp.Rational(1, 6))
revisar('P6.6: período al nacer 2 pi sqrt 3 = 10.88', 2*np.pi/np.sqrt(float(Jrm.det().subs(K_, 3))), 10.88, 5e-3)
# l1 de Rosenzweig-MacArthur con la normalización de primerLyapunov.m: P = [e1, A e1/w0]
Fr3 = Frm.subs(K_, 3); A3 = np.array(Jrm.subs(K_, 3), dtype=float); w3 = np.sqrt(np.linalg.det(A3))
Pm3 = np.column_stack([[1, 0], A3 @ [1, 0]/w3])
zz = sp.Matrix([1, sp.Rational(4, 3)]) + sp.Matrix(Pm3.tolist())*sp.Matrix([u, v])
Gz = sp.Matrix(np.linalg.inv(Pm3).tolist())*Fr3.subs({v_: zz[0], p_: zz[1]})
Bm = np.linalg.inv(Pm3) @ A3 @ Pm3
Fn_ = sp.expand(Gz[0] - (Bm[0, 0]*u + Bm[0, 1]*v)); Gn_ = sp.expand(Gz[1] - (Bm[1, 0]*u + Bm[1, 1]*v))
revisar('P6.6: l1 (normalización de primerLyapunov) = -1/24', l1(Fn_, Gn_, w=w3), -1/24, 1e-6)
revisar('P6.7: silla-nodo de ciclos mu = -c^2/4 (c = 1)', min(rr_**4 - rr_**2 for rr_ in np.linspace(0, 1.5, 15001)), -0.25, 1e-6)
gq2 = lambda rr_: -2*rr_ + 3*rr_**2 - rr_**3
revisar('P6.8: g(r) = -r(1-r)(2-r): g\'(1) = 1, g\'(2) = -2', (-2 + 6*1 - 3*1) + 10*(-2 + 6*2 - 3*4), 1 - 20)
def Pcir(mm, q):
    Fc_ = lambda tt, z: [z[1] - (z[0]**3 - mm*z[0]), -z[0]]
    e = lambda tt, z: z[1]; e.direction = -1
    s_ = solve_ivp(Fc_, (0, 40), [q, 0], events=e, **o)
    k_ = [i for i, tt in enumerate(s_.t_events[0]) if tt > 1e-6][0]
    return s_.y_events[0][k_][0]
for mm, qe, de in [(0.1, 0.3650, 0.5331), (0.5, 0.8068, 0.0392)]:
    qq_ = brentq(lambda q: Pcir(mm, q) - q, 0.05, 3, xtol=1e-12)
    dd_ = (Pcir(mm, qq_ + 1e-5) - Pcir(mm, qq_ - 1e-5))/2e-5
    revisar(f'P6.9: circuito mu = {mm}: punto fijo', qq_, qe, 2e-4)
    revisar(f"P6.9: circuito mu = {mm}: P'(q*)", dd_, de, 2e-4)
def retardo(eps_):
    a0 = 1.0; T_ = 0.8/eps_
    ff = lambda tt, z: [-(a0 + eps_*tt)*z[0] + z[1], z[0]**2/(1 + z[0]**2) - 0.35*z[1]]
    e = lambda tt, z: z[0] - 0.7; e.terminal = True
    s_ = solve_ivp(ff, (0, T_), [2.4, 2.4], events=e, **o)
    return a0 + eps_*s_.t_events[0][0] - 1/0.7
r1_, r2_, r3_ = retardo(1e-3), retardo(1.25e-4), retardo(1.5625e-5)
revisar('P6.10: retardo con eps = 1e-3 = 0.059', r1_, 0.059, 1e-3)
revisar('P6.10: retardo con eps = 1.25e-4 = 0.017', r2_, 0.017, 1e-3)
revisar('P6.10: retardo con eps = 1.56e-5 = 0.0045', r3_, 0.0045, 2e-4)
revisar('P6.10: razones 3.5 y 3.7 (tienden a 8^(2/3) = 4)', round(r1_/r2_, 1) + round(r2_/r3_, 1), 3.5 + 3.7, 1e-9)

print(f'\n{ok}/{total} verificaciones correctas')
