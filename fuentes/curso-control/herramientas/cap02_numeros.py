"""Verificación independiente de los números del capítulo 2
(Modelado I: Laplace, función de transferencia y primer orden).
Ejecutar:  python3 herramientas/cap02_numeros.py
Usa sympy (cálculo simbólico) y python-control (simulación).
"""
import numpy as np
import sympy as sp
import control as ct

t, s = sp.symbols('t s', positive=True)
ok = True


def revisar(nombre, valor, esperado, tol=1e-3):
    global ok
    v = float(valor)
    bien = abs(v - esperado) <= tol
    ok &= bien
    print(f"  {'ok  ' if bien else 'FALLA'} {nombre:<44s} {v:12.5f}  (esperado {esperado})")


def igual(nombre, a, b):
    global ok
    bien = sp.simplify(a - b) == 0
    ok &= bien
    print(f"  {'ok  ' if bien else 'FALLA'} {nombre:<44s} {sp.simplify(a)}")


print('2.1  Conversión F -> C (sistema estático)')
revisar('C(212 F)', (212 - 32)*5/9, 100)

print('2.4  Transformadas básicas')
a, w = sp.symbols('a omega', positive=True)
L = lambda f: sp.laplace_transform(f, t, s, noconds=True)
igual('L{1}', L(sp.Integer(1)), 1/s)
igual('L{e^-at}', L(sp.exp(-a*t)), 1/(s + a))
igual('L{cos wt}', L(sp.cos(w*t)), s/(s**2 + w**2))
igual('L{sin wt}', L(sp.sin(w*t)), w/(s**2 + w**2))
igual('L{t}', L(t), 1/s**2)
igual('L{t^2}', L(t**2), 2/s**3)
igual('L{t e^-at}', L(t*sp.exp(-a*t)), 1/(s + a)**2)

print('2.5  Ejemplo del motor (Chrysler): x\'\' + 5x\' + 6x = 0, x(0)=1, x\'(0)=0')
X = (s + 5)/((s + 2)*(s + 3))
print('     fracciones parciales:', sp.apart(X, s))
igual('x(t)', sp.inverse_laplace_transform(X, s, t), 3*sp.exp(-2*t) - 2*sp.exp(-3*t))
r, p, k = __import__('scipy.signal', fromlist=['residue']).residue([1, 5], [1, 5, 6])
revisar('residuo en -2', r[np.argmin(abs(p + 2))].real, 3)
revisar('residuo en -3', r[np.argmin(abs(p + 3))].real, -2)

print('2.5  Polos múltiples: 1/(s^2 (s+1)^2)')
igual('apart', sp.apart(1/(s**2*(s + 1)**2), s),
      -2/s + 1/s**2 + 2/(s + 1) + 1/(s + 1)**2)
igual('inversa', sp.inverse_laplace_transform(1/(s**2*(s + 1)**2), s, t),
      -2 + t + 2*sp.exp(-t) + t*sp.exp(-t))

print('2.5  Polos complejos: 3x\'\' + 2x\' + x = 0, x(0)=-1, x\'(0)=2')
X = (4 - 3*s)/(3*s**2 + 2*s + 1)
xt = sp.simplify(sp.inverse_laplace_transform(X, s, t))
print('     x(t) =', xt)
esperado = sp.exp(-t/3)*(-sp.cos(sp.sqrt(2)*t/3) + sp.Rational(5, 2)*sp.sqrt(2)*sp.sin(sp.sqrt(2)*t/3))
igual('x(t) forma cerrada', xt, esperado)
z = sp.symbols('z'); print('     polos:', sp.solve(3*z**2 + 2*z + 1, z))
revisar('x(0)', xt.subs(t, 0), -1)
revisar('x\'(0)', sp.diff(xt, t).subs(t, 0), 2)

print('2.5  dsolve: y\' = -2y + t, y(0) = 1')
y = sp.Function('y')
sol = sp.dsolve(sp.Eq(y(t).diff(t), -2*y(t) + t), y(t), ics={y(0): 1}).rhs
igual('y(t)', sol, t/2 - sp.Rational(1, 4) + sp.Rational(5, 4)*sp.exp(-2*t))
print('2.5  dsolve: y\'\' + y\' + y = sin t, y(0)=1, y\'(0)=0')
sol = sp.dsolve(sp.Eq(y(t).diff(t, 2) + y(t).diff(t) + y(t), sp.sin(t)), y(t),
                ics={y(0): 1, y(t).diff(t).subs(t, 0): 0}).rhs
print('     y(t) =', sp.simplify(sol))
revisar('y(10)', sol.subs(t, 10).evalf(), float(sol.subs(t, 10).evalf()))

print('2.7  Teorema del valor final: ejemplos que fallan')
H = 6*(s**2 - 2)/(s**3 + s**2 - 4*s - 4)
igual('fracciones de 6(s^2-2)/(...)', sp.apart(H, s), 2/(s + 1) + 3/(s + 2) + 1/(s - 2))
revisar('lim s->0 sH(s) (engañoso)', sp.limit(s*H, s, 0), 0)

print('2.8  Proceso térmico: tau = 5, M = 2, T* = 25')
tau, M = 5, 2
E = ct.tf([M], [tau, 1])
tt = np.linspace(0, 50, 5001)
_, e = ct.step_response(E, tt)
revisar('e(tau)', np.interp(tau, tt, e), M*(1 - np.exp(-1)))
revisar('T final', 25 + e[-1], 27, 1e-3)

print('2.9  Primer orden: porcentajes del valor final')
for n, pct in [(1, 63.2), (2, 86.5), (3, 95.0), (4, 98.2), (5, 99.3)]:
    revisar(f'1 - e^-{n}', 100*(1 - np.exp(-n)), pct, 0.05)
revisar('t_s(2%)/tau exacto = ln 50', np.log(50), 3.912)
revisar('t_s(5%)/tau exacto = ln 20', np.log(20), 2.996)
revisar('t_r(10-90%)/tau = ln 9', np.log(9), 2.197)

print('2.9  Rampa: e(t) = K1 tau (1 - e^{-t/tau})')
K1, tau = 1.0, 10.0
G = ct.tf([K1], [tau, 1])
tt = np.linspace(0, 100, 10001)
_, yr = ct.forced_response(G, tt, tt)
err = K1*tt - yr
revisar('e(100) con K1=1, tau=10', err[-1], K1*tau*(1 - np.exp(-10)), 1e-3)
revisar('e(10)', np.interp(10, tt, err), K1*tau*(1 - np.exp(-1)), 1e-3)

print('2.10 Ejercicio de identificación térmica')
K1 = (52 - 40)/(15 - 10)
revisar('K1', K1, 2.4)
tau = -30/np.log(1 - (47.6 - 40)/12)
revisar('tau (s)', tau, 29.90, 0.01)
revisar('pendiente inicial (C/s)', 12/tau, 0.401, 0.001)
revisar('t_s 2% (4 tau)', 4*tau, 119.6, 0.1)
revisar('u para 55 C', 10 + (55 - 40)/K1, 16.25)
revisar('e_ss rampa a=0.01', K1*0.01*tau, 0.718, 0.001)
revisar('tau max para e_ss<=0.5', 0.5/(K1*0.01), 20.83, 0.01)

print('2.10 Ejercicio 2y\'\' + 10y\' + 12y = 24u, y(0)=1, y\'(0)=0')
Y = (24/s + 2*s*1 + 10*1)/(2*s**2 + 10*s + 12)
yt = sp.simplify(sp.inverse_laplace_transform(sp.apart(Y, s), s, t))
print('     y(t) =', yt)
igual('y(t)', yt, 2 - 3*sp.exp(-2*t) + 2*sp.exp(-3*t))
revisar('valor final', sp.limit(s*Y, s, 0), 2)

print('\n' + ('Todo verificado.' if ok else 'HAY FALLAS.'))
