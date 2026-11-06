"""Figuras del capítulo 4 (espacio de estado). python3 herramientas/cap04_figuras.py"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.linalg import expm
from estilo import C, guardar
g = lambda fig, n: guardar(fig, n, 'cap04')


def masa_resorte():
    M, k = 2, 16
    fig, axs = plt.subplots(2, 2, figsize=(6.6, 4.0), sharex=True, gridspec_kw=dict(hspace=0.4, wspace=0.25))
    for a, b in zip(axs.flat, (2, 4, 8, 16)):
        f = lambda t, x: [x[1], (-k*x[0]-b*x[1]+(5 if t < 20 else 0))/M]
        s = solve_ivp(f, (0, 40), [0, 0], max_step=0.01)
        a.plot(s.t, s.y[0], color=C['coral'], label='posición $x_1$')
        a.plot(s.t, s.y[1], '--', color=C['azul'], label='velocidad $x_2$')
        a.set_title(f'$b={b}$'); a.grid(True)
    axs[0, 0].legend(fontsize=7.5, loc='upper right')
    for a in axs[1]:
        a.set_xlabel('t (s)')
    g(fig, 'f_masa_resorte')


def carbono():
    kL1, kL2, kL3, kL4, kO1, kO2, kO3, kO4 = 0.0842, 0.0684, 0.0159, 0.0332, 0.0846, 0.0433, 0.0011, 0.0001
    A = np.array([[-(kO1+kL1), kL2, kL4, kO2, 0], [kL1, -(kL2+kL3), 0, 0, 0], [0, kL3, -kL4, 0, 0],
                  [kO1, 0, 0, -(kO2+kO3), kO4], [0, 0, 0, kO3, -kO4]])
    x0 = np.array([590, 550, 1500, 900, 37000.])
    s = solve_ivp(lambda t, x: A@x + 8*np.array([1, 0, 0, 0, 0]), (0, 500), x0, max_step=1)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.8), gridspec_kw=dict(wspace=0.32))
    nombres = ['atmósfera', 'vegetación', 'suelo', 'océano superficial', 'océano profundo']
    cols = [C['coral'], C['verde'], C['ambar'], C['azul'], C['violeta']]
    for i in range(4):
        a1.plot(s.t, s.y[i], color=cols[i], label=nombres[i])
    a1.set_title('reservorios (GtC)'); a1.legend(fontsize=7); a1.set_xlabel('años')
    a2.plot(s.t, s.y[4], color=cols[4], label='océano profundo')
    a2.plot(s.t, s.y.sum(0), '--', color=C['noche'], label='total: crece 8 GtC/año')
    a2.set_title('océano profundo y total (GtC)'); a2.legend(fontsize=7); a2.set_xlabel('años')
    for a in (a1, a2):
        a.grid(True)
    g(fig, 'f_carbono')


def duffing():
    d = 0.3
    f = lambda t, x: [x[1], x[0]-x[0]**3-d*x[1]]
    fig, ax = plt.subplots(figsize=(4.6, 4.0))
    X, Y = np.meshgrid(np.linspace(-2, 2, 25), np.linspace(-2, 2, 25))
    ax.streamplot(X, Y, Y, X-X**3-d*Y, color=C['claro'], density=1.1, linewidth=0.7, arrowsize=0.7)
    # separatrices: stable manifold of the origin (integrate backwards)
    w, V = np.linalg.eig([[0, 1], [1, -d]]); vs = np.real(V[:, np.argmin(np.real(w))])
    for sg in (1, -1):
        s = solve_ivp(lambda t, x: [-v for v in f(t, x)], (0, 12), sg*1e-4*vs, max_step=0.01)
        m = (abs(s.y[0]) < 2.2) & (abs(s.y[1]) < 2.2); ax.plot(s.y[0][m], s.y[1][m], color=C['noche'], lw=1.6)
    for x0, c in (((0.9, 0), C['azul']), ((0.5, 0), C['verde']), ((-0.1, 0.05), C['coral'])):
        s = solve_ivp(f, (0, 60), x0, max_step=0.02); ax.plot(s.y[0], s.y[1], color=c, lw=1.3); ax.plot(*x0, 'o', color=c, ms=4)
    ax.plot([-1, 0, 1], [0, 0, 0], 'o', color=C['noche'], mfc='white', ms=6)
    ax.set_xlim(-2, 2); ax.set_ylim(-2, 2); ax.set_xlabel('$x_1$'); ax.set_ylabel('$x_2$'); ax.set_aspect('equal')
    g(fig, 'f_duffing')


def levitador():
    M, R, L, Cm, gg, yd = 0.05, 10, 0.5, 1e-3, 9.81, 0.01
    i0 = np.sqrt(M*gg*yd/Cm); u0 = R*i0
    A = np.array([[0, 1, 0], [Cm*i0**2/(M*yd**2), 0, -2*Cm*i0/(M*yd)], [0, 0, -R/L]])
    f = lambda t, x: [x[1], gg-Cm/M*x[2]**2/x[0], -R/L*x[2]+u0/L]
    t = np.linspace(0, 0.2, 401)
    s = solve_ivp(f, (0, 0.2), [yd+1e-4, 0, i0], t_eval=t, rtol=1e-10, atol=1e-12)
    yl = np.array([(expm(A*tt)@np.array([1e-4, 0, 0]))[0] for tt in t])
    fig, ax = plt.subplots(figsize=(5.6, 2.6))
    ax.plot(t, 1e3*(s.y[0]-yd), color=C['noche'], label='modelo no lineal')
    ax.plot(t, 1e3*yl, '--', color=C['coral'], label='modelo linealizado')
    ax.set_xlabel('t (s)'); ax.set_ylabel('$\\hat y$ (mm)'); ax.legend(); ax.grid(True); ax.set_ylim(0, 20)
    g(fig, 'f_levitador')


def bioreactor():
    mu_m, km, k1, Y, u1, u2 = 0.53, 0.12, 0.4545, 0.4, 0.3, 4.0
    mu = lambda x2: mu_m*x2/(km+x2+k1*x2**2)
    f = lambda t, x: [(mu(x[1])-u1)*x[0], u1*(u2-x[1])-mu(x[1])*x[0]/Y]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.8), gridspec_kw=dict(wspace=0.3))
    x2 = np.linspace(0, 4, 400); a1.plot(x2, mu(x2), color=C['noche'])
    a1.axhline(u1, color=C['coral'], ls='--', lw=1); a1.text(3.0, 0.31, '$\\mu=u_1=0.3$', color=C['coral'], fontsize=8)
    for xs, c in ((0.1746, C['verde']), (1.5122, C['coral'])):
        a1.plot(xs, mu(xs), 'o', color=c)
    a1.set_xlabel('sustrato $x_2$ (g/L)'); a1.set_ylabel('$\\mu$ (1/h)'); a1.set_title('tasa de crecimiento'); a1.grid(True)
    for x0, c in (((1, 1), C['azul']), ((0.9951, 1.53), C['ambar']), ((0.9951, 1.49), C['violeta'])):
        s = solve_ivp(f, (0, 60), x0, max_step=0.05); a2.plot(s.y[1], s.y[0], color=c, lw=1.2); a2.plot(x0[1], x0[0], 'o', color=c, ms=3)
    a2.plot([0.1746, 1.5122, 4], [1.5302, 0.9951, 0], 'o', color=C['noche'], mfc='white', ms=6)
    a2.set_xlabel('sustrato $x_2$'); a2.set_ylabel('biomasa $x_1$'); a2.set_title('trayectorias'); a2.grid(True)
    g(fig, 'f_bioreactor')


if __name__ == '__main__':
    masa_resorte(); carbono(); duffing(); levitador(); bioreactor()
