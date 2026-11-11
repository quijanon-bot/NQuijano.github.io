"""Figuras del capítulo 4 (sistemas bidimensionales). PDF y SVG.
Cada figura reproduce un script de codigo/cap04_bidimensionales/ (se indica cuál).
Ejecutar:  python3 herramientas/cap04_figuras.py   [nombre_de_función ...]
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.optimize import fsolve
from estilo import C, guardar

CAP = 'cap04'
def g(fig, nombre): guardar(fig, nombre, CAP)
o = dict(rtol=1e-9, atol=1e-11)


def campo(ax, f, xl, yl, n=21, col=None):
    """Flechas normalizadas del campo f(X, Y) -> (U, V) (como retratoFase.m)."""
    X, Y = np.meshgrid(np.linspace(*xl, n), np.linspace(*yl, n))
    U, V = f(X, Y); N = np.hypot(U, V); N[N == 0] = 1
    ax.quiver(X, Y, U/N, V/N, color=col or C['claro'], scale=30, width=0.004, headwidth=4, angles='xy')


def tray(ax, F, x0, T=10, col=None, lw=1.2, atras=True, caja=None, **kw):
    """Trayectoria hacia adelante (y hacia atrás) que se detiene al salir de la caja."""
    caja = caja or (-1e3, 1e3, -1e3, 1e3)
    def sale(t, x): return min(x[0] - caja[0], caja[1] - x[0], x[1] - caja[2], caja[3] - x[1])
    sale.terminal = True
    for s in ([1, -1] if atras else [1]):
        r = solve_ivp(lambda t, x: s*np.asarray(F(x)), (0, T), x0, events=sale, max_step=0.05, **o)
        ax.plot(r.y[0], r.y[1], color=col or C['azul'], lw=lw, **kw)
    # flecha a mitad de la trayectoria hacia adelante
    r = solve_ivp(lambda t, x: np.asarray(F(x)), (0, T), x0, events=sale, max_step=0.05, **o)
    k = min(len(r.t) - 2, max(1, len(r.t)//5))
    if len(r.t) > 3:
        ax.annotate('', xy=r.y[:, k+1], xytext=r.y[:, k],
                    arrowprops=dict(arrowstyle='-|>', color=col or C['azul'], lw=lw, mutation_scale=9))


def punto(ax, x, estable):
    ax.plot(*x, 'o', ms=6, color=C['noche'] if estable else 'w', mec=C['noche'], mew=1.3, zorder=5)


def ejes(ax, xl, yl, t=None, xlab='$x_1$', ylab='$x_2$'):
    ax.set_xlim(*xl); ax.set_ylim(*yl); ax.set_aspect('equal')
    ax.set_xlabel(xlab); ax.set_ylabel(ylab)
    if t: ax.set_title(t)


def circulo(n, r=1.0, c=(0, 0)):
    th = np.linspace(0, 2*np.pi, n, endpoint=False)
    return [(c[0] + r*np.cos(a), c[1] + r*np.sin(a)) for a in th]


# ------------------------------------------------------------------ 4.2
def campo_resorte():                # C4_Ej1 [campo]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 3.1), gridspec_kw=dict(wspace=0.3))
    F = lambda x: [2*x[0]*x[1], x[0]*x[1]]
    campo(ax[0], lambda X, Y: (2*X*Y, X*Y), (-3, 3), (-3, 3), 17)
    for c in [-4, -2, 0, 2, 4]:
        xs = np.linspace(-3, 3, 50); ax[0].plot(xs, (xs - c)/2, color=C['azul'], lw=0.9, alpha=0.6)
    ax[0].axhline(0, color=C['coral'], lw=2); ax[0].axvline(0, color=C['coral'], lw=2)
    ax[0].annotate('', xy=(1 + 4*0.3, 2 + 2*0.3), xytext=(1, 2), arrowprops=dict(arrowstyle='-|>', color=C['ambar'], lw=1.8))
    ax[0].plot(1, 2, 'o', color=C['ambar'], ms=4)
    ax[0].text(1.1, 2.35, '$f(1,2)=(4,2)$', fontsize=7.5, color=C['noche'])
    ejes(ax[0], (-3, 3), (-3, 3), r'$\dot x_1=2x_1x_2,\ \dot x_2=x_1x_2$')
    w = 2.0
    campo(ax[1], lambda X, Y: (Y, -w**2*X), (-1.6, 1.6), (-3.2, 3.2), 17)
    for c in [0.4, 0.8, 1.2, 1.6, 2.0, 2.6]:
        tray(ax[1], lambda x: [x[1], -w**2*x[0]], (c/w, 0), T=2*np.pi/w, atras=False)
    punto(ax[1], (0, 0), True)
    ax[1].set_xlim(-1.6, 1.6); ax[1].set_ylim(-3.2, 3.2); ax[1].set_xlabel('$x_1$ (posición)'); ax[1].set_ylabel('$x_2$ (velocidad)')
    ax[1].set_title(r'Masa--resorte, $\omega=2$')
    g(fig, 'f_campo')


def nulclinas():                    # C4_Ej2 [nulclinas]
    F = lambda x: [-x[0] + x[0]*x[1], x[0] + x[1] - 2*x[0]*x[1]]
    fig, ax = plt.subplots(figsize=(4.6, 4.0))
    xl, yl = (-2, 3), (-2, 3); caja = (-2, 3, -2, 3)
    campo(ax, lambda X, Y: (-X + X*Y, X + Y - 2*X*Y), xl, yl, 21)
    for x0 in [(-1.5, 2.5), (-0.5, 2.8), (0.5, 2.8), (1.5, 2.8), (2.8, 2.5), (2.8, 1.2), (2.8, 0.3),
               (2.8, -1.5), (1.5, -1.9), (0.3, -1.9), (-1.0, -1.9), (-1.9, -1.0), (-1.9, 0.6), (0.05, 0.3), (-0.05, -0.3)]:
        tray(ax, F, x0, T=15, caja=caja, lw=1.0)
    ax.axvline(0, color=C['coral'], lw=2, ls='--'); ax.axhline(1, color=C['coral'], lw=2, ls='--')
    xs = np.linspace(-2, 3, 2001); y = xs/(2*xs - 1); y[np.abs(2*xs - 1) < 0.02] = np.nan
    ax.plot(xs, y, color=C['ambar'], lw=2, ls='--')
    ax.plot([], [], color=C['coral'], ls='--', label=r'$\dot x_1=0$'); ax.plot([], [], color=C['ambar'], ls='--', label=r'$\dot x_2=0$')
    punto(ax, (0, 0), False); punto(ax, (1, 1), True)
    ax.plot(0, 1, 'x', color=C['coral'], ms=7, mew=2)
    ax.text(0.08, 1.12, '$(0,1)$: no es equilibrio', fontsize=7, color=C['coral'])
    ax.legend(loc='lower right', fontsize=7.5, framealpha=0.9, frameon=True)
    ejes(ax, xl, yl, 'Nulclinas y equilibrios')
    g(fig, 'f_nulclinas')


# ------------------------------------------------------------------ 4.4
def retratos():                     # C4_Ej4 [galeria]
    casos = [('Nodo estable', [[-6, 0], [0, -2]]), ('Silla', [[-1, 0], [0, 2]]), ('Estrella', [[-1, 0], [0, -1]]),
             ('Nodo impropio', [[-1, 1], [0, -1]]), ('Foco estable', [[-0.5, -2], [2, -0.5]]), ('Centro', [[0, -2], [2, 0]])]
    fig, axs = plt.subplots(2, 3, figsize=(6.9, 4.7), gridspec_kw=dict(wspace=0.25, hspace=0.38))
    for ax, (nom, A) in zip(axs.ravel(), casos):
        A = np.array(A, float); F = lambda x, A=A: A@x
        campo(ax, lambda X, Y, A=A: (A[0, 0]*X + A[0, 1]*Y, A[1, 0]*X + A[1, 1]*Y), (-1, 1), (-1, 1), 13)
        if nom == 'Silla':
            ics = [(s1*a, s2*1) for a in [0.05, 0.2, 0.5] for s1 in [-1, 1] for s2 in [-1, 1]]
            ics = [(s1*1, s2*b) for b in [0.02, 0.1, 0.3] for s1 in [-1, 1] for s2 in [-1, 1]]
        elif nom == 'Centro':
            ics = [(r, 0) for r in [0.2, 0.4, 0.6, 0.8]]
        elif nom == 'Foco estable':
            ics = [(0.95, 0.95), (-0.95, -0.95)]
        else:
            ics = circulo(12, 1.35)
        for x0 in ics:
            tray(ax, F, x0, T=12 if nom != 'Centro' else np.pi, atras=False, lw=1.0, caja=(-1.5, 1.5, -1.5, 1.5))
        lam, V = np.linalg.eig(A)
        if np.isreal(lam).all():
            for v in V.T:
                ax.plot([-2*v[0], 2*v[0]], [-2*v[1], 2*v[1]], color=C['verde'], lw=1.6, zorder=4)
        punto(ax, (0, 0), np.real(lam).max() < 0)
        ejes(ax, (-1, 1), (-1, 1), nom, '$z_1$', '$z_2$'); ax.set_xticks([]); ax.set_yticks([])
    g(fig, 'f_retratos')


def traza_det():                    # C4_Ej5 [clasificar]
    fig, ax = plt.subplots(figsize=(5.2, 3.6))
    tau = np.linspace(-4, 4, 400)
    ax.fill_between(tau, tau**2/4, 5, color=C['violeta'], alpha=0.08)
    ax.fill_between(tau, -3, 0, color=C['coral'], alpha=0.08)
    ax.plot(tau, tau**2/4, color=C['noche'], lw=1.6)
    ax.axhline(0, color=C['noche'], lw=1.2); ax.plot([0, 0], [0, 5], color=C['verde'], lw=2.5)
    kw = dict(ha='center', fontsize=8.5, color=C['noche'])
    ax.text(0, -1.6, 'sillas  ($\\delta<0$)', **kw)
    ax.text(-1.9, 3.2, 'focos\nestables', **kw); ax.text(1.9, 3.2, 'focos\ninestables', **kw)
    ax.text(-3.3, 1.2, 'nodos\nestables', **kw); ax.text(3.3, 1.2, 'nodos\ninestables', **kw)
    ax.text(0.15, 4.4, 'centros', fontsize=8.5, color=C['verde'], ha='left')
    ax.text(2.6, 2.15, r'$\tau^2=4\delta$', fontsize=8, color=C['noche'], rotation=48)
    ax.text(-3.9, 0.15, r'$\delta=0$: equilibrios no aislados', fontsize=7, color=C['gris'])
    for (t, d, s) in [(-4, 3, 'o'), (-1, 1, 'o'), (0, 4, 'o'), (2, 1, 'o'), (5, -2, 'o')]:
        pass
    ax.set_xlim(-4, 4); ax.set_ylim(-3, 5); ax.set_xlabel(r'$\tau=\mathrm{tr}\,A$'); ax.set_ylabel(r'$\delta=\det A$')
    ax.set_title('El plano traza--determinante')
    g(fig, 'f_traza_det')


def barrido():                      # C4_Ej5 [barrido]
    fig, axs = plt.subplots(1, 5, figsize=(6.9, 1.75), gridspec_kw=dict(wspace=0.12))
    for ax, a in zip(axs, [-4, -1, -0.3, 0, 1]):
        F = lambda x, a=a: [a*x[0], -x[1]]
        ics = circulo(14, 1.35) if a <= 0 else [(sx*b, sy*1.4) for b in [0.02, 0.1, 0.3, 0.7] for sx in [-1, 1] for sy in [-1, 1]]
        for x0 in ics:
            tray(ax, F, x0, T=12, atras=False, lw=0.9, caja=(-1.5, 1.5, -1.5, 1.5))
        if a > 0:
            ax.axhline(0, color=C['verde'], lw=1.4); ax.axvline(0, color=C['verde'], lw=1.4)
        if a == 0:
            ax.axhline(0, color=C['noche'], lw=2.2)
        else:
            punto(ax, (0, 0), a < 0)
        ejes(ax, (-1, 1), (-1, 1), f'$a={a}$', '', ''); ax.set_xticks([]); ax.set_yticks([])
    g(fig, 'f_barrido')


def estructural():                  # C4_Ej6 [perturbar]
    fig, axs = plt.subplots(1, 2, figsize=(6.9, 3.0), gridspec_kw=dict(wspace=0.25))
    ax = axs[0]
    for e, col in [(0, C['gris']), (-0.05, C['azul']), (0.05, C['coral'])]:
        A = np.array([[e, -1], [1, e]])
        tray(ax, lambda x, A=A: A@x, (0.6, 0), T=40 if e else 2*np.pi, atras=False, col=col, lw=1.0, caja=(-1.2, 1.2, -1.2, 1.2))
    ax.plot([], [], color=C['gris'], label=r'centro, $\varepsilon=0$'); ax.plot([], [], color=C['azul'], label=r'$\varepsilon=-0.05$')
    ax.plot([], [], color=C['coral'], label=r'$\varepsilon=+0.05$')
    ax.legend(fontsize=7, loc='lower left'); ejes(ax, (-1.2, 1.2), (-1.2, 1.2), r'$\begin{bmatrix}\varepsilon&-1\\1&\varepsilon\end{bmatrix}$'.replace(r'\begin{bmatrix}\varepsilon&-1\\1&\varepsilon\end{bmatrix}', r'[\varepsilon\ \ -1;\ 1\ \ \varepsilon]'))
    ax = axs[1]
    for e, col in [(0, C['gris']), (0.5, C['azul'])]:
        A = np.array([[-1, 1], [-e, -1]])
        for x0 in [(-1, 1), (1, -1), (-1, 0.3), (1, -0.3), (0, 1.1), (0, -1.1)]:
            tray(ax, lambda x, A=A: A@x, x0, T=20, atras=False, col=col, lw=1.0, caja=(-1.2, 1.2, -1.2, 1.2))
    ax.plot([], [], color=C['gris'], label=r'nodo impropio, $\varepsilon=0$'); ax.plot([], [], color=C['azul'], label=r'foco, $\varepsilon=0.5$')
    ax.legend(fontsize=7, loc='lower left'); ejes(ax, (-1.2, 1.2), (-1.2, 1.2), r'$[-1\ \ 1;\ -\varepsilon\ \ -1]$')
    g(fig, 'f_estructural')


# ------------------------------------------------------------------ 4.5
def duffing_F(d=0.5):
    return lambda x: [x[1], x[0] - x[0]**3 - d*x[1]]


def hartman():                      # C4_Ej11 (silla de Duffing)
    d = 0.5; F = duffing_F(d); A = np.array([[0, 1], [1, -d]])
    fig, axs = plt.subplots(1, 2, figsize=(6.9, 3.1), gridspec_kw=dict(wspace=0.28))
    for ax, L in zip(axs, [0.35, 1.6]):
        caja = (-L, L, -L, L)
        u = np.linspace(-0.9, 0.9, 7)*L
        for x0 in [(L*0.999, v) for v in u] + [(-L*0.999, v) for v in u] + [(v, L*0.999) for v in u] + [(v, -L*0.999) for v in u]:
            tray(ax, lambda x: A@x, x0, T=10, atras=False, col=C['claro'], lw=1.2, caja=caja)
            tray(ax, F, x0, T=10, atras=False, col=C['azul'], lw=1.0, caja=caja)
        lam, V = np.linalg.eig(A)
        for v in V.T: ax.plot([-3*v[0], 3*v[0]], [-3*v[1], 3*v[1]], color=C['gris'], ls=':', lw=1)
        punto(ax, (0, 0), False)
        if L > 1: punto(ax, (1, 0), True); punto(ax, (-1, 0), True)
        ejes(ax, (-L, L), (-L, L), 'cerca de la silla' if L < 1 else 'lejos de la silla')
    axs[0].plot([], [], color=C['azul'], label='no lineal'); axs[0].plot([], [], color=C['claro'], lw=2, label='linealización')
    axs[0].legend(fontsize=7, loc='lower left', framealpha=0.9, frameon=True)
    g(fig, 'f_hartman')


def tres():                         # C4_Ej7 [tres]
    F = lambda x: [x[0] + x[0]*x[1], -x[1] + x[1]**2 + x[0]*x[1] - x[0]**3]
    fig, ax = plt.subplots(figsize=(4.6, 4.0)); xl, yl = (-2, 2.5), (-3, 2.5); caja = (-2, 2.5, -3, 2.5)
    campo(ax, lambda X, Y: (X + X*Y, -Y + Y**2 + X*Y - X**3), xl, yl, 21)
    for x0 in circulo(10, 0.15, (0, 1)) + circulo(6, 0.08, (0, 0)) + [(1.5, -2.5), (2, -1), (-1.5, -2.5), (0.5, -2.9), (-1.8, 0.5), (2.3, 0.5)]:
        tray(ax, F, x0, T=12, atras=False, caja=caja, lw=1.0)
    punto(ax, (0, 0), False); punto(ax, (0, 1), False); punto(ax, (1, -1), True)
    for (p, t) in [((0, 0), 'silla'), ((0, 1), 'nodo inestable'), ((1, -1), 'foco estable')]:
        ax.text(p[0] + 0.1, p[1] + 0.12, t, fontsize=7.5, color=C['noche'], bbox=dict(fc='w', ec='none', alpha=0.8, pad=0.5))
    ejes(ax, xl, yl, r'$\dot x_1=x_1+x_1x_2,\ \dot x_2=-x_2+x_2^2+x_1x_2-x_1^3$')
    ax.title.set_fontsize(8.5)
    g(fig, 'f_tres')


def epsilon():                      # C4_Ej8 [epsilon]
    fig, axs = plt.subplots(1, 3, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.12))
    for ax, e in zip(axs, [1, 0, -1]):
        F = lambda x, e=e: [x[1], -x[0] - e*x[0]**2*x[1]]
        T = {1: 60, 0: 2*np.pi, -1: 25}[e]
        r = solve_ivp(lambda t, x: F(x), (0, T), (0.5, 0) if e >= 0 else (0.3, 0), max_step=0.02,
                      events=(lambda t, x: np.hypot(*x) - 1.4), **o)
        ax.plot(r.y[0], r.y[1], color=C['azul'], lw=0.9)
        ax.plot(*r.y[:, 0], 'o', color=C['coral'], ms=3.5)
        punto(ax, (0, 0), e > 0)
        ejes(ax, (-1.4, 1.4), (-1.4, 1.4), rf'$\varepsilon={e}$', '$x_1$', '' if e != 1 else '$x_2$')
    g(fig, 'f_epsilon')


# ------------------------------------------------------------------ 4.6
def h_diodo(v): return 17.76*v - 103.79*v**2 + 229.62*v**3 - 226.31*v**4 + 83.72*v**5
def dh_diodo(v): return 17.76 - 2*103.79*v + 3*229.62*v**2 - 4*226.31*v**3 + 5*83.72*v**4
Ed, Rd, Cd, Ld = 1.2, 1.5, 2.0, 5.0
def F_diodo(x): return [(-h_diodo(x[0]) + x[1])/Cd, (-x[0] - Rd*x[1] + Ed)/Ld]


def variedad_silla(F, xs, J, T=40, eps=1e-5, caja=None, estable=True):
    """Las dos ramas de W^s (estable=True) o W^u de una silla xs, integrando desde xs +- eps v."""
    lam, V = np.linalg.eig(J); k = np.argmin(lam) if estable else np.argmax(lam); v = V[:, k].real
    s = -1 if estable else 1; ramas = []
    caja = caja or (-1e3, 1e3, -1e3, 1e3)
    def sale(t, x): return min(x[0] - caja[0], caja[1] - x[0], x[1] - caja[2], caja[3] - x[1])
    sale.terminal = True
    for sg in [1, -1]:
        r = solve_ivp(lambda t, x: s*np.asarray(F(x)), (0, T), np.asarray(xs) + sg*eps*v, events=sale, max_step=0.02, **o)
        ramas.append(r.y)
    return ramas


def diodo():                        # C4_Ej10 [diodo]
    eqs = [fsolve(lambda v: h_diodo(v) - (Ed - v)/Rd, v0)[0] for v0 in [0.06, 0.28, 0.88]]
    Q = [(v, (Ed - v)/Rd) for v in eqs]
    fig, ax = plt.subplots(figsize=(5.2, 3.8)); xl, yl = (-0.4, 1.6), (-0.4, 1.5); caja = (-0.4, 1.6, -0.4, 1.5)
    campo(ax, lambda X, Y: ((-h_diodo(X) + Y)/Cd, (-X - Rd*Y + Ed)/Ld), xl, yl, 23)
    vv = np.linspace(-0.4, 1.6, 400)
    ax.plot(vv, h_diodo(vv), color=C['coral'], lw=1.6, ls='--', label='$x_2=h(x_1)$')
    ax.plot(vv, (Ed - vv)/Rd, color=C['ambar'], lw=1.6, ls='--', label='recta de carga')
    for x0 in [(-0.3, 1.4), (0.2, 1.45), (0.6, 1.45), (1.0, 1.45), (1.5, 1.4), (1.55, 0.5), (1.55, -0.3), (0.9, -0.35),
               (0.4, -0.35), (-0.35, -0.35), (-0.35, 0.5), (0.4, 0.0), (0.4, 0.3)]:
        tray(ax, F_diodo, x0, T=80, atras=False, caja=caja, lw=0.9)
    J2 = np.array([[-dh_diodo(Q[1][0])/Cd, 1/Cd], [-1/Ld, -Rd/Ld]])
    for r in variedad_silla(F_diodo, Q[1], J2, T=60, caja=caja):
        ax.plot(r[0], r[1], color=C['noche'], lw=2)
    for q, est in zip(Q, [True, False, True]): punto(ax, q, est)
    for q, n in zip(Q, ['$Q_1$', '$Q_2$', '$Q_3$']): ax.text(q[0] + 0.03, q[1] + 0.06, n, fontsize=8.5)
    ax.plot([0.4, 0.4], [0, 0.3], 'o', color=C['violeta'], ms=4)
    ax.legend(fontsize=7, loc='upper right', framealpha=0.9, frameon=True)
    ax.set_xlim(*xl); ax.set_ylim(*yl); ax.set_xlabel('$x_1=v_C$ (V)'); ax.set_ylabel('$x_2=i_L$ (mA)')
    ax.set_title('Diodo túnel con inductancia')
    g(fig, 'f_diodo')


# ------------------------------------------------------------------ 4.7
def variedad():                     # C4_Ej11 [exacta]
    F = lambda x: [-x[0], x[1] + x[0]**2]
    fig, ax = plt.subplots(figsize=(4.4, 3.4)); xl, yl = (-2, 2), (-2.5, 2); caja = (-2, 2, -2.5, 2)
    campo(ax, lambda X, Y: (-X, Y + X**2), xl, yl, 19)
    for x0 in [(-2, -1.0), (-2, -1.6), (2, -1.0), (2, -1.6), (-2, 0.5), (2, 0.5), (-1, 2), (1, 2), (0.6, -2.4), (-0.6, -2.4)]:
        tray(ax, F, x0, T=6, atras=False, caja=caja, lw=0.9)
    xs = np.linspace(-2, 2, 200)
    ax.plot(xs, -xs**2/3, color=C['verde'], lw=2.4, label=r'$W^s:\ x_2=-x_1^2/3$')
    ax.axvline(0, color=C['ambar'], lw=2.4, label='$W^u$ (eje $x_2$)')
    ax.axhline(0, color=C['gris'], lw=1.2, ls=':', label='$E^s$ (eje $x_1$)')
    tray(ax, F, (1, 0), T=6, atras=False, col=C['coral'], lw=1.6, caja=caja); ax.plot(1, 0, 'o', color=C['coral'], ms=4)
    punto(ax, (0, 0), False)
    ax.legend(fontsize=7, loc='lower left', framealpha=0.9, frameon=True)
    ejes(ax, xl, yl, r'$\dot x_1=-x_1,\ \dot x_2=x_2+x_1^2$')
    g(fig, 'f_variedad')


def cuencas(d=0.5, n=241, L=3.0, T=60):
    """Pozo final de Duffing para una malla de condiciones iniciales (vectorizado, RK4)."""
    X1, X2 = np.meshgrid(np.linspace(-L, L, n), np.linspace(-L, L, n))
    x, y = X1.copy(), X2.copy(); h = 0.01
    f = lambda x, y: (y, x - x**3 - d*y)
    for _ in range(int(T/h)):
        k1 = f(x, y); k2 = f(x + h/2*k1[0], y + h/2*k1[1]); k3 = f(x + h/2*k2[0], y + h/2*k2[1]); k4 = f(x + h*k3[0], y + h*k3[1])
        x = x + h/6*(k1[0] + 2*k2[0] + 2*k3[0] + k4[0]); y = y + h/6*(k1[1] + 2*k2[1] + 2*k3[1] + k4[1])
    return X1, X2, np.sign(x)


def duffing():                      # C4_Ej11 [variedad], C4_Ej9 [duffing]
    d = 0.5; F = duffing_F(d); J0 = np.array([[0, 1], [1, -d]]); L = 3.0
    X1, X2, S = cuencas(d, 301, L)
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 3.1), gridspec_kw=dict(wspace=0.3, width_ratios=[1, 1.15]))
    ax[0].contourf(X1, X2, S, levels=[-2, 0, 2], colors=[C['coral'], C['azul']], alpha=0.22)
    for r in variedad_silla(F, (0, 0), J0, T=40, caja=(-L, L, -L, L)):
        ax[0].plot(r[0], r[1], color=C['noche'], lw=1.6)
    for r in variedad_silla(F, (0, 0), J0, T=40, estable=False):
        ax[0].plot(r[0], r[1], color=C['verde'], lw=1.4)
    punto(ax[0], (0, 0), False); punto(ax[0], (1, 0), True); punto(ax[0], (-1, 0), True)
    ax[0].plot([1.5, 2], [0, 0], 'o', color=C['ambar'], ms=4)
    ejes(ax[0], (-L, L), (-L, L), r'Cuencas, $\delta=0.5$')
    for x0, col in [((1.5, 0), C['azul']), ((2, 0), C['coral'])]:
        r = solve_ivp(lambda t, x: F(x), (0, 30), x0, max_step=0.02, **o)
        ax[1].plot(r.t, r.y[0], color=col, label=f'$x_0=({x0[0]:g},0)$')
    ax[1].axhline(1, color=C['gris'], lw=0.7, ls=':'); ax[1].axhline(-1, color=C['gris'], lw=0.7, ls=':')
    ax[1].set_xlabel('$t$'); ax[1].set_ylabel('$x_1$'); ax[1].legend(fontsize=7); ax[1].grid(True)
    ax[1].set_title('Dos condiciones iniciales vecinas')
    g(fig, 'f_duffing')


# ------------------------------------------------------------------ 4.8
def central():                      # C4_Ej12 [central]
    fig, axs = plt.subplots(1, 2, figsize=(6.9, 2.9), gridspec_kw=dict(wspace=0.25))
    for ax, a in zip(axs, [-1, 1]):
        F = lambda x, a=a: [x[0]*x[1], -x[1] + a*x[0]**2]
        caja = (-1, 1, -0.8, 0.8)
        campo(ax, lambda Y, Z, a=a: (Y*Z, -Z + a*Y**2), (-1, 1), (-0.8, 0.8), 17)
        for x0 in [(y0, z0) for y0 in [-0.8, -0.5, -0.25, 0.25, 0.5, 0.8] for z0 in [-0.75, 0.75]]:
            tray(ax, F, x0, T=30 if a < 0 else 6, atras=False, caja=caja, lw=0.9)
        ys = np.linspace(-0.62, 0.62, 200)
        ax.plot(ys, a*ys**2 - 2*a**2*ys**4, color=C['verde'], lw=2.2, label=r'$z\approx ay^2-2a^2y^4$')
        ax.axhline(0, color=C['gris'], lw=1, ls=':', label='$E^c$ ($z=0$)')
        punto(ax, (0, 0), a < 0)
        ax.legend(fontsize=6.8, loc='lower left' if a > 0 else 'upper left', framealpha=0.9, frameon=True)
        ejes(ax, (-1, 1), (-0.8, 0.8), f'$a={a}$', '$y$', '$z$')
    g(fig, 'f_central')


def unica():                        # C4_Ej12 [unica]
    fig, ax = plt.subplots(figsize=(4.4, 2.8))
    ys = np.linspace(-1.2, -1e-3, 400)
    for c in [-3, -1.5, -0.5, 0.5, 1.5, 3]:
        ax.plot(ys, c*np.exp(1/ys), color=C['azul'], lw=1.1)
    ax.plot([0, 1.2], [0, 0], color=C['verde'], lw=2.4)
    ax.plot([-1.2, 0], [0, 0], color=C['verde'], lw=2.4, alpha=0.5)
    punto(ax, (0, 0), False)
    ax.set_xlim(-1.2, 1.2); ax.set_ylim(-1.2, 1.2); ax.set_xlabel('$y$'); ax.set_ylabel('$z$')
    ax.set_title(r'$\dot y=y^2,\ \dot z=-z$: $z=c\,e^{1/y}$ para $y<0$')
    g(fig, 'f_unica')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
        sys.exit()
    for fn in [campo_resorte, nulclinas, retratos, traza_det, barrido, estructural, hartman, tres, epsilon,
               diodo, variedad, duffing, central, unica]:
        fn()
