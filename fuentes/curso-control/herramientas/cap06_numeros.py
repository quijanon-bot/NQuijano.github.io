"""Números del capítulo 6 (error en estado estacionario). python3 herramientas/cap06_numeros.py"""
import numpy as np, sympy as sp, control as ct
np.set_printoptions(precision=4, suppress=True)
s = sp.symbols('s'); st = ct.tf('s')

def info(T, tf=60):
    t = np.linspace(0, tf, 60001); y = np.asarray(ct.step_response(T, t).outputs).ravel(); yf = float(ct.dcgain(T))
    k = np.where(abs(y-yf) > 0.02*abs(yf))[0]; ts = t[k[-1]+1] if len(k) and k[-1]+1 < len(t) else float('nan')
    return round(100*(y.max()-yf)/yf, 2), round(ts, 2)

print('== ejemplo DoBi08: K Km/(s(s+0.01+Kb Km))')
K = sp.symbols('K'); Km, Kb = 10, sp.Rational(5, 100)
kv = K*Km/(sp.Rational(1, 100)+Kb*Km); print('kv', kv, 'K para ess=1', sp.solve(sp.Eq(1/kv, 1), K))

print('== G=100/(s+1), H=1/(s+5)')
G = 100/(s+1); H = 1/(s+5)
T = sp.factor(sp.simplify(G/(1+G*H))); print('T', T, 'polos', sp.solve(sp.denom(T), s), 'T(0)', T.subs(s, 0), float(T.subs(s, 0)))
GH = G*H; kpm = GH.subs(s, 0); print('malla abierta kp', kpm, 'e_act', 1/(1+kpm), float(1/(1+kpm)))
Gol = sp.factor(sp.simplify(G/(1+G*H-G))); print('Gol', Gol, 'polos', [sp.N(r, 5) for r in sp.solve(sp.denom(Gol), s)], 'kp', Gol.subs(s, 0), float(Gol.subs(s, 0)))
print('ess', float(1-T.subs(s, 0)), float(1/(1+Gol.subs(s, 0))))
k = sp.symbols('k'); Tk = G/(1+G*k/(s+5)); print('k para ess=0', sp.solve(sp.Eq(Tk.subs(s, 0), 1), k))

print('== ejercicio tipos')
for Gs in (20*(s+2)/((s+1)*(s+5)), 50/(s*(s+3)*(s+10)), 100*(s+4)*(s+6)/(s**2*(s+5)*(s+8)), 5*(s+1)/(s**3*(s+2))):
    num, den = sp.fraction(sp.together(Gs)); cp = sp.Poly(sp.expand(den+num), s); r = [complex(x) for x in sp.Poly(cp, s).nroots()]
    N = 0
    while sp.limit(Gs*s**N, s, 0) in (sp.oo, -sp.oo, sp.zoo): N += 1
    while sp.limit(Gs*s**N, s, 0) == 0 and N < 0: N += 1
    kp_, kv_, ka_ = [sp.limit(s**i*Gs, s, 0) for i in (0, 1, 2)]
    print(Gs, 'polcar', cp.as_expr(), 'max Re', max(x.real for x in r).__round__(4), 'kp kv ka', kp_, kv_, ka_)
    print('   ess r=5:', 5/(1+kp_) if kp_ != sp.oo else 0, ' r=2t:', 2/kv_ if kv_ not in (0, sp.oo) else ('oo' if kv_ == 0 else 0), ' r=1.5t^2:', 3/ka_ if ka_ not in (0, sp.oo) else ('oo' if ka_ == 0 else 0))

print('== posicion K/(s(s+4)(s+8))')
print('K min ess<=0.1: 320; Routh: 12*32 =', 12*32)
for Kx in (320, 350):
    T = ct.feedback(Kx/(st*(st+4)*(st+8)), 1); p = ct.poles(T); print(Kx, 'polos', p)
    pd = p[np.argmax(p.imag)]; wn = abs(pd); z = -pd.real/wn; print('  zeta', z, 'wn', wn, 'OS est', 100*np.exp(-z*np.pi/np.sqrt(1-z**2)), 'ts est', 4/(z*wn), 'sim', info(T, 120))

print('== perturbación Gp=1/((s+1)(s+2)), D=0.5')
for Kx in (1, 10, 100):
    print('P K=', Kx, 'entrada', -0.5/(2+Kx), 'salida', -1/(2+Kx))
print('PI K=10: s^3+3s^2+12s+Ki -> Ki<36')

print('== estado: A=[0 1;-2 -3],B=[0;1],C=[2 0]')
A = np.array([[0, 1], [-2, -3.]]); B = np.array([[0], [1.]]); C = np.array([[2, 0.]])
Acl = A-B@C; xss = -np.linalg.solve(Acl, B); print('xss', xss.ravel(), 'yss', (C@xss).item(), 'ess', 1-(C@xss).item())
Ki = sp.symbols('Ki'); Aa = sp.Matrix([[0, 1, 0], [-4, -3, Ki], [-2, 0, 0]]); print('char', sp.expand((s*sp.eye(3)-Aa).det()))
Aan = np.array([[0, 1, 0], [-4, -3, 3], [-2, 0, 0.]]); Ban = np.array([[0], [1], [1.]]); Can = np.array([[2, 0, 0.]])
xs = -np.linalg.solve(Aan, Ban); print('Ki=3 xss', xs.ravel(), 'yss', (Can@xs).item(), 'polos', np.linalg.eigvals(Aan))

print('== atraso G=1/(s(s+4)(s+8)), ess<=0.05, OS<=20%')
z20 = -np.log(0.2)/np.sqrt(np.pi**2+np.log(0.2)**2); print('zeta 20%', z20)
# find K with dominant zeta = z20
from scipy.optimize import brentq
def zd(Kx):
    p = np.roots([1, 12, 32, Kx]); pd = p[np.argmax(p.imag)]; return -pd.real/abs(pd)
Kos = brentq(lambda Kx: zd(Kx)-z20, 20, 380); print('K para OS 20% (zeta dominante)', Kos)
T = ct.feedback(Kos/(st*(st+4)*(st+8)), 1); print('  sim OS ts', info(T, 60), 'kv', Kos/32, 'ess', 32/Kos)
ratio = 640/Kos; print('a/b necesario', ratio)
for b in (0.005, 0.01):
    a = round(ratio*b*1.1, 4)
    Gc = Kos*(st+a)/(st+b); L = Gc/(st*(st+4)*(st+8)); T = ct.feedback(L, 1)
    print(' a', a, 'b', b, 'kv', Kos*a/b/32, 'ess', 32*b/(Kos*a), 'polos', np.round(ct.poles(T), 4), 'OS ts', info(T, 400))
    # ramp error check
    t = np.linspace(0, 600, 60001); e = t - ct.forced_response(T, t, t).outputs; print('   e rampa final', e[-1])
    print('   char poly', np.round(np.poly(ct.poles(T)), 4))

print('== S+T=1, Gp=1/((s+1)(s+10))')
for Kx in (10, 200):
    L = Kx/((st+1)*(st+10)); S = 1/(1+L); Tt = L/(1+L)
    for w in (0.1, 1, 10, 100):
        print(Kx, w, 'S', round(abs(ct.evalfr(S, 1j*w)), 4), 'T', round(abs(ct.evalfr(Tt, 1j*w)), 4))
    w = np.logspace(-2, 3, 200001); Sw = abs(1/(1+Kx/((1j*w+1)*(1j*w+10)))); Tw = abs(1-1/(1+Kx/((1j*w+1)*(1j*w+10))))
    i = np.argmin(abs(Sw-Tw)); Lw = abs(Kx/((1j*w+1)*(1j*w+10))); ic = np.argmin(abs(Lw-1))
    print('  |S|=|T| en', w[i], ' cruce |L|=1 en', w[ic])
    SGp = abs(ct.evalfr(S*1/((st+1)*(st+10)), 0.2j)); Tn = abs(ct.evalfr(Tt, 50j))
    print('  aporte pert', 0.5*SGp, 'aporte ruido', 0.01*Tn, 'total suma', 0.5*SGp+0.01*Tn)
    print('  |T(j50)|', Tn, '|SGp(j0.2)|', SGp)
