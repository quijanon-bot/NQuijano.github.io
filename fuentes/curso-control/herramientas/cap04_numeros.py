"""Números del capítulo 4 (espacio de estado). python3 herramientas/cap04_numeros.py"""
import numpy as np, sympy as sp, control as ct
from scipy.linalg import expm
from scipy.integrate import solve_ivp
from scipy.optimize import fsolve
np.set_printoptions(precision=4, suppress=True)
s, t = sp.symbols('s t')

print('== masa-resorte M=2 k=16, b=2,4,8,16 (pulso 5 durante 20 s)')
for b in (2, 4, 8, 16):
    A = np.array([[0, 1], [-8, -b/2]]); ev = np.linalg.eigvals(A)
    z = (b/2)/(2*np.sqrt(8)); print(b, 'eig', ev, 'zeta', round(z, 3), 'x1ss', 5/16)

print('== dos masas')
M1, M2, k, b = sp.symbols('M1 M2 k b', positive=True)
A2 = sp.Matrix([[0, 0, 1, 0], [0, 0, 0, 1], [-k/M1, k/M1, -b/M1, 0], [k/M2, -k/M2, 0, 0]])
print(sp.factor((s*sp.eye(4)-A2).det()))
print('G y1/u', sp.simplify((sp.Matrix([[1, 0, 0, 0]])*(s*sp.eye(4)-A2).inv()*sp.Matrix([0, 0, 0, 1/M2]))[0]))

print('== 24/(s^3+9s^2+26s+24)')
print(np.roots([1, 9, 26, 24]))
A = np.array([[0, 1, 0], [0, 0, 1], [-24, -26, -9.]])
print('tf2ss-like', ct.ss(ct.tf([24], [1, 9, 26, 24])).A)
print('(s^2+7s+2)/(...): C =[2 7 1]', ct.ss2tf(A, [[0], [0], [1]], [[2, 7, 1]], 0))

print('== Phi(t) A=[0 1;-2 -3]')
Aa = sp.Matrix([[0, 1], [-2, -3]])
R = (s*sp.eye(2)-Aa).inv(); print(sp.simplify(R))
Ph = R.applyfunc(lambda e: sp.inverse_laplace_transform(sp.apart(e, s), s, t)); Ph = sp.simplify(Ph.subs(sp.Heaviside(t), 1)); print(Ph)
An = np.array([[0, 1], [-2, -3.]])
t1, t2 = 0.5, 1.2
print('props', np.allclose(expm(An*(t1+t2)), expm(An*t1)@expm(An*t2)), np.allclose(np.linalg.inv(expm(An*t1)), expm(-An*t1)))
print('Phi(0.5)=', expm(An*0.5))
# forced, B=[0 1], step
xf = sp.simplify(sp.integrate(Ph.subs(t, t-sp.Symbol('tau'))*sp.Matrix([0, 1]), (sp.Symbol('tau'), 0, t)))
print('x forzada escalon', xf)
x0 = sp.Matrix([1, -1]); print('x libre x0=[1,-1]', sp.simplify(Ph*x0))

print('== motor DC')
al = sp.symbols('alpha', positive=True)
Am = sp.Matrix([[0, 1], [0, -al]])
print(sp.simplify((s*sp.eye(2)-Am).inv().applyfunc(lambda e: sp.inverse_laplace_transform(e, s, t)).subs(sp.Heaviside(t), 1)))

print('== determinante ejemplo')
M = sp.Matrix([[2, 4, 1], [3, 0, 2], [2, 0, 3]]); print(M.det(), M.cofactor(0, 1), M.cofactor(1, 1), M.cofactor(2, 1))

print('== sistemas (i) y (ii)')
for A_, C_ in ((sp.Matrix([[0, 1], [-6, -5]]), sp.Matrix([[1, 0]])), (sp.Matrix([[-2, 1, 0], [0, -3, 1], [0, 0, -4]]), sp.Matrix([[1, 0, 0]]))):
    n = A_.shape[0]; B_ = sp.zeros(n, 1); B_[-1] = 1
    G = sp.factor(sp.simplify((C_*(s*sp.eye(n)-A_).inv()*B_)[0])); print(G, A_.eigenvals(), G.subs(s, 0))

print('== cancelación Ca, Cb')
A3 = sp.Matrix([[0, 1, 0], [0, 0, 1], [-6, -11, -6]]); B3 = sp.Matrix([0, 0, 1])
for Cx in (sp.Matrix([[1, 0, 0]]), sp.Matrix([[2, 3, 1]])):
    print(sp.factor((Cx*(s*sp.eye(3)-A3).inv()*B3)[0]))

print('== carbono')
kL1, kL2, kL3, kL4, kO1, kO2, kO3, kO4 = 0.0842, 0.0684, 0.0159, 0.0332, 0.0846, 0.0433, 0.0011, 0.0001
Ac = np.array([[-(kO1+kL1), kL2, kL4, kO2, 0], [kL1, -(kL2+kL3), 0, 0, 0], [0, kL3, -kL4, 0, 0],
               [kO1, 0, 0, -(kO2+kO3), kO4], [0, 0, 0, kO3, -kO4]])
print('suma columnas', Ac.sum(0)); ev = np.sort(np.linalg.eigvals(Ac).real); print('eig', ev, 'tau', -1/ev[ev < -1e-9])
x0 = np.array([590, 550, 1500, 900, 37000.]); Bc = np.array([1, 0, 0, 0, 0.])
sol = solve_ivp(lambda tt, x: Ac@x+8*Bc, (0, 500), x0, t_eval=[0, 100, 200, 500], rtol=1e-9, atol=1e-6)
print('x(t)', sol.y.T, 'suma', sol.y.sum(0))
Gc = ct.ss2tf(Ac, Bc.reshape(-1, 1), np.array([[1, 0, 0, 0, 0.]]), 0); print('polos MA/UE', np.sort(ct.poles(Gc).real))
# asymptotic distribution: equilibrium fraction = right null vector
w, V = np.linalg.eig(Ac); v0 = np.real(V[:, np.argmin(abs(w))]); v0 = v0/v0.sum(); print('fraccion equilibrio', v0)

print('== Duffing')
for d in (0.3, 3):
    for x1 in (0, 1):
        ev = np.linalg.eigvals([[0, 1], [1-3*x1**2, -d]]); print(d, x1, ev)
    wn = np.sqrt(2); print('  (1,0): wn', wn, 'zeta', d/(2*wn), 'ts', 4/(d/2))
print('delta crit (+-1)', np.sqrt(8))
w0, V0 = np.linalg.eig([[0, 1], [1, -0.3]]); print('vec propios origen', w0, V0)

print('== levitador')
Mm, R_, L_, Cm, g, yd = 0.05, 10, 0.5, 1e-3, 9.81, 0.01
i0 = np.sqrt(Mm*g*yd/Cm); u0 = R_*i0
Al = np.array([[0, 1, 0], [Cm*i0**2/(Mm*yd**2), 0, -2*Cm*i0/(Mm*yd)], [0, 0, -R_/L_]]); Bl = np.array([[0], [0], [1/L_]])
print('i*', i0, 'u*', u0, 'A', Al, 'eig', np.linalg.eigvals(Al), 'g/y', g/yd)
Gl = ct.ss2tf(Al, Bl, [[1, 0, 0]], 0); print(Gl)
def fl(tt, x): return [x[1], g-Cm/Mm*x[2]**2/x[0], -R_/L_*x[2]+u0/L_]
for tf_ in (0.05, 0.1, 0.15, 0.2):
    sn = solve_ivp(fl, (0, tf_), [yd+1e-4, 0, i0], rtol=1e-10, atol=1e-12); xl = expm(Al*tf_)@np.array([1e-4, 0, 0])
    print(tf_, 'no lineal dy', sn.y[0, -1]-yd, 'lineal', xl[0])

print('== bioreactor')
mu_m, km, k1, Y, u1, u2 = 0.53, 0.12, 0.4545, 0.4, 0.3, 4.0
x1, x2 = sp.symbols('x1 x2'); U1, U2 = sp.symbols('u1 u2')
mu = mu_m*x2/(km+x2+k1*x2**2)
f = sp.Matrix([(mu-U1)*x1, U1*(U2-x2)-mu*x1/Y])
eqs = []
# mu(x2)=u1 => quadratic
sol2 = sp.solve(sp.Eq(mu_m*x2, u1*(km+x2+k1*x2**2)), x2); print('x2 eq', sol2)
for xs2 in sol2:
    xs1 = Y*(u2-xs2); J = f.jacobian([x1, x2]).subs({x1: xs1, x2: xs2, U1: u1, U2: u2}); Bj = f.jacobian([U1, U2]).subs({x1: xs1, x2: xs2, U1: u1, U2: u2})
    Jn = np.array(J, dtype=float); print('x*', float(xs1), float(xs2), 'A', Jn, 'B', np.array(Bj, dtype=float), 'eig', np.linalg.eigvals(Jn))
    print('  dmu/dx2', float(sp.diff(mu, x2).subs(x2, xs2)))
    if xs2 > 1:
        Gb = ct.ss(Jn, np.array(Bj, dtype=float), np.eye(2), np.zeros((2, 2)))
        for i in range(2):
            for j in range(2):
                print('  G', i, j, ct.tf(Gb[i, j]))
J0 = f.jacobian([x1, x2]).subs({x1: 0, x2: u2, U1: u1, U2: u2}); print('(0,4) eig', np.linalg.eigvals(np.array(J0, dtype=float)))
print('x2 dmu=0', np.sqrt(km/k1))
fb = sp.lambdify((x1, x2), f.subs({U1: u1, U2: u2}))
sb = solve_ivp(lambda tt, x: np.array(fb(*x), dtype=float).ravel(), (0, 100), [1, 1], rtol=1e-9); print('converge a', sb.y[:, -1])
