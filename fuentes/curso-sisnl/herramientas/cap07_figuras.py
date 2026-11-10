"""Figuras del capítulo 7 (estabilidad de Lyapunov). PDF y SVG.
Cada figura reproduce un script de codigo/cap07_lyapunov/ (se indica cuál).
Ejecutar:  python3 herramientas/cap07_figuras.py   [nombre_de_función ...]
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.linalg import expm, solve_continuous_lyapunov
from estilo import C, guardar

CAP = 'cap07'
def g(fig, nombre): guardar(fig, nombre, CAP)
o = dict(rtol=1e-10, atol=1e-12)
a, b = 1.0, 0.5
def pend(t, z, bb=b): return [z[1], -a*np.sin(z[0]) - bb*z[1]]
def lyapP(A, Q): return solve_continuous_lyapunov(np.array(A, float).T, -np.array(Q, float))
def campo(ax, f, xl, yl, n=21, col=None):
    X, Y = np.meshgrid(np.linspace(*xl, n), np.linspace(*yl, n))
    U, V = f(X, Y); N = np.hypot(U, V) + 1e-12
    ax.quiver(X, Y, U/N, V/N, color=col or C['claro'], scale=34, width=0.0035, headwidth=4)


def pendulos():                     # C7_Ej1 [pendulo]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.8), gridspec_kw=dict(wspace=0.25))
    for k, bb in enumerate([0.0, b]):
        X1, X2 = np.meshgrid(np.linspace(-1.5*np.pi, 1.5*np.pi, 300), np.linspace(-3, 3, 240))
        E = a*(1 - np.cos(X1)) + X2**2/2
        ax[k].contour(X1, X2, E, levels=[0.25, 0.75, 1.5, 2, 2.6, 3.5], colors=C['claro'], linewidths=0.8)
        campo(ax[k], lambda X, Y: (Y, -a*np.sin(X) - bb*Y), (-1.5*np.pi, 1.5*np.pi), (-3, 3), 19)
        for x0 in [(0.6, 0), (1.6, 0), (2.6, 0), (-2.0, 2.4)]:
            s = solve_ivp(pend, (0, 30), x0, args=(bb,), max_step=0.02, **o)
            ax[k].plot(s.y[0], s.y[1], color=C['azul'], lw=1.3)
            ax[k].plot(*x0, 'o', color=C['coral'], ms=3.5)
        for e in [-np.pi, 0, np.pi]:
            ax[k].plot(e, 0, 'o', ms=5, color=C['noche'] if e == 0 else 'w', mec=C['noche'])
        ax[k].set_xlim(-1.5*np.pi, 1.5*np.pi); ax[k].set_ylim(-3, 3)
        ax[k].set_xlabel('$x_1$'); ax[k].set_ylabel('$x_2$')
        ax[k].set_xticks([-np.pi, 0, np.pi]); ax[k].set_xticklabels([r'$-\pi$', '0', r'$\pi$'])
    ax[0].set_title('Sin fricción: estable, no asintóticamente')
    ax[1].set_title('Con fricción: asintóticamente estable')
    g(fig, 'f_pendulos')


def polar():                        # C7_Ej1 [polar]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.8), gridspec_kw=dict(wspace=0.3, width_ratios=[1, 1.25]))
    fp = lambda t, z: [z[0]*(1 - z[0]), np.sin(z[1]/2)**2]
    th = np.linspace(0, 2*np.pi, 200); ax[0].plot(np.cos(th), np.sin(th), color=C['claro'], lw=3)
    for z0, col in [((1, 0.1), C['coral']), ((0.4, 2.5), C['azul']), ((1.6, 4.0), C['violeta'])]:
        s = solve_ivp(fp, (0, 400), z0, max_step=0.2, **o)
        ax[0].plot(s.y[0]*np.cos(s.y[1]), s.y[0]*np.sin(s.y[1]), color=col, lw=1.3)
        ax[0].plot(z0[0]*np.cos(z0[1]), z0[0]*np.sin(z0[1]), 'o', color=col, ms=3.5)
        if col == C['coral']:
            d = np.hypot(s.y[0]*np.cos(s.y[1]) - 1, s.y[0]*np.sin(s.y[1]))
            ax[1].plot(s.t, d, color=col)
    ax[0].plot(1, 0, 'o', color=C['noche'], ms=5); ax[0].plot(0, 0, 'o', color='w', mec=C['noche'], ms=5)
    ax[0].set_aspect('equal'); ax[0].set_xlim(-1.8, 1.8); ax[0].set_ylim(-1.6, 1.6)
    ax[0].set_xlabel('$x_1$'); ax[0].set_ylabel('$x_2$'); ax[0].set_title('Todas llegan a $(1,0)$...')
    ax[1].set_xlim(0, 120); ax[1].set_xlabel('$t$'); ax[1].set_ylabel(r'$\|x(t)-(1,0)\|$')
    ax[1].set_title(r'...pero desde $\theta_0=0.1$ se aleja hasta 2'); ax[1].grid(True)
    g(fig, 'f_polar')


def indirecto():                    # C7_Ej2 [cubico]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.32))
    xx = np.linspace(-1.6, 1.6, 300)
    for aa, col in [(-1, C['azul']), (0, C['violeta']), (1, C['coral'])]:
        ax[0].plot(xx, aa*xx - xx**3, color=col, label=f'$a={aa}$')
    ax[0].axhline(0, color=C['gris'], lw=0.7); ax[0].set_ylim(-2.5, 2.5)
    ax[0].set_xlabel('$x$'); ax[0].set_ylabel(r'$\dot x$'); ax[0].legend(fontsize=7); ax[0].grid(True)
    ax[0].set_title(r'$\dot x=ax-x^3$')
    t = np.linspace(0, 10, 400)
    ax[1].semilogy(t, 1/np.sqrt(1 + 2*t), color=C['violeta'], label=r'$\dot x=-x^3$: $1/\sqrt{1+2t}$')
    ax[1].semilogy(t, np.exp(-t), color=C['azul'], label=r'$\dot x=-x$: $e^{-t}$')
    ax[1].set_xlabel('$t$'); ax[1].set_ylabel('$x(t)$'); ax[1].legend(fontsize=7); ax[1].grid(True)
    ax[1].set_title('Asintótica no es exponencial')
    g(fig, 'f_indirecto')


def energia():                      # C7_Ej3 [energia]
    t = np.linspace(0, 20, 2001)
    s = solve_ivp(pend, (0, 20), [2.5, 0], t_eval=t, **o)
    V = a*(1 - np.cos(s.y[0])) + s.y[1]**2/2
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.3))
    ax[0].plot(t, V, color=C['verde'], label='$V(x(t))$'); ax[0].plot(t, s.y[1], color=C['azul'], lw=1, label='$x_2(t)$')
    ceros = t[1:][np.diff(np.sign(s.y[1])) != 0]
    for c_ in ceros: ax[0].axvline(c_, color=C['coral'], lw=0.6, ls=':')
    ax[0].axhline(0, color=C['gris'], lw=0.6); ax[0].legend(fontsize=7); ax[0].grid(True)
    ax[0].set_xlabel('$t$'); ax[0].set_title(r'$\dot V=-bx_2^2$: se detiene si $x_2=0$')
    ax[1].plot(t, -b*s.y[1]**2, color=C['coral']); ax[1].grid(True); ax[1].set_xlabel('$t$')
    ax[1].set_title(r'$\dot V(x(t))\leq 0$, con ceros aislados')
    g(fig, 'f_energia')


def no_acotada():                   # C7_Ej4 [noacotada]
    f = lambda t, x: [-6*x[0]/(1 + x[0]**2)**2 + 2*x[1], -2*(x[0] + x[1])/(1 + x[0]**2)**2]
    X1, X2 = np.meshgrid(np.linspace(-7, 7, 400), np.linspace(-3, 3, 300))
    V = X1**2/(1 + X1**2) + X2**2
    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    cs = ax.contour(X1, X2, V, levels=[0.3, 0.6, 0.9, 1.0, 1.5, 2.5], colors=[C['claro']]*3 + [C['ambar']] + [C['claro']]*2, linewidths=[0.9]*3 + [1.8] + [0.9]*2)
    ax.clabel(cs, fmt='%.1f', fontsize=6)
    for x0, col in [((2, 2), C['coral']), ((-2, -2), C['coral']), ((0.5, 0.5), C['azul']), ((-1.5, 0.6), C['azul'])]:
        s = solve_ivp(f, (0, 400), x0, max_step=0.05, **o)
        m = np.abs(s.y[0]) < 7
        ax.plot(s.y[0][m], s.y[1][m], color=col, lw=1.4); ax.plot(*x0, 'o', color=col, ms=3.5)
    ax.set_xlim(-7, 7); ax.set_ylim(-3, 3); ax.set_xlabel('$x_1$'); ax.set_ylabel('$x_2$')
    ax.set_title(r'$\dot V<0$ en todo $x\neq0$, y aun así hay soluciones que se van')
    g(fig, 'f_no_acotada')


def formas():                       # C7_Ej5, C7_Video_FormasCuadraticas
    th = np.pi/6; R = np.array([[np.cos(th), -np.sin(th)], [np.sin(th), np.cos(th)]])
    X1, X2 = np.meshgrid(np.linspace(-2, 2, 241), np.linspace(-2, 2, 241))
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.4), gridspec_kw=dict(wspace=0.15))
    for k, (l2, tit) in enumerate([(0.5, '$P>0$: elipses'), (0.0, r'$P\geq 0$ singular: franjas'), (-0.8, '$P$ indefinida: hipérbolas')]):
        P = R@np.diag([2, l2])@R.T
        V = P[0, 0]*X1**2 + 2*P[0, 1]*X1*X2 + P[1, 1]*X2**2
        ax[k].contour(X1, X2, V, levels=[0.25, 0.5, 1, 2, 3], colors=C['azul'], linewidths=1)
        if l2 < 0:
            ax[k].contour(X1, X2, V, levels=[-3, -2, -1, -0.5, -0.25], colors=C['coral'], linewidths=1)
            ax[k].contour(X1, X2, V, levels=[0], colors=C['gris'], linewidths=0.8, linestyles='--')
        for j, col in [(0, C['noche']), (1, C['verde'])]:
            v = R[:, j]*1.8; ax[k].plot([-v[0], v[0]], [-v[1], v[1]], color=col, lw=0.8, ls=':')
        ax[k].set_aspect('equal'); ax[k].set_title(tit, fontsize=9); ax[k].set_xticks([]); ax[k].set_yticks([])
    g(fig, 'f_formas')


def cruzado():                      # C7_Ej6 [cruzado] [sale]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.8), gridspec_kw=dict(wspace=0.28, width_ratios=[1.7, 1]))
    X1, X2 = np.meshgrid(np.linspace(-4.5, 8, 500), np.linspace(-3.6, 3.6, 300))
    V = lambda q: 0.5*(b*q*X1**2 + 2*q*X1*X2 + X2**2) + a*(1 - np.cos(X1))
    cst = lambda q: 2*a + np.pi**2/2*q*(b - q)
    ax[0].axvspan(-np.pi, np.pi, color=C['fondo'])
    enD = lambda Z: np.where(np.abs(X1) <= np.pi, Z, np.nan)
    ax[0].contour(X1, X2, enD(V(0)), levels=[cst(0) - 0.01], colors=C['ambar'], linewidths=1.6, linestyles='--')
    ax[0].contour(X1, X2, enD(V(b/2)), levels=[0.5, 1, 1.5], colors=C['claro'], linewidths=0.8)
    ax[0].contour(X1, X2, enD(V(b/2)), levels=[cst(b/2) - 0.01], colors=C['verde'], linewidths=2)
    s = solve_ivp(pend, (0, 60), [1.5, 3], max_step=0.02, **o)
    ax[0].plot(s.y[0], s.y[1], color=C['coral'], lw=1.4); ax[0].plot(1.5, 3, 'o', color=C['coral'], ms=4)
    ax[0].plot(2*np.pi, 0, 'o', color=C['coral'], ms=5)
    for e in [0]: ax[0].plot(e, 0, 'o', color=C['noche'], ms=4)
    for xv in [-np.pi, np.pi]: ax[0].axvline(xv, color=C['gris'], lw=0.7, ls=':')
    ax[0].text(-3.0, 3.1, '$D$', color=C['gris'], fontsize=9)
    ax[0].set_xlim(-4.5, 8); ax[0].set_ylim(-3.6, 3.6); ax[0].set_xlabel('$x_1$'); ax[0].set_ylabel('$x_2$')
    ax[0].set_title(r'$\Omega_{c^*}$: energía y $p_{12}=b/2$')
    q = np.linspace(0, b, 200)
    ax[1].plot(q, cst(q), color=C['verde']); ax[1].axvline(b/2, color=C['gris'], ls=':', lw=0.8)
    ax[1].set_xlabel('$p_{12}$'); ax[1].set_ylabel('$c^*(p_{12})$'); ax[1].grid(True)
    ax[1].set_title('El mejor nivel, en $b/2$')
    g(fig, 'f_cruzado')


def jordan():                       # C7_Ej7 [jordan]
    A = np.array([[0, 1], [-1, 0]]); B = np.array([[0], [1]]); Cc = np.array([[1, 0]])
    AP = np.block([[A, np.zeros((2, 2))], [np.zeros((2, 2)), A]]); AS = np.block([[A, np.zeros((2, 2))], [B@Cc, A]])
    t = np.linspace(0, 30, 900)
    yP = [(expm(AP*ti)@np.array([1, 0, 1, 0]))[2] for ti in t]
    yS = [(expm(AS*ti)@np.array([1, 0, 0, 0]))[2] for ti in t]
    fig, ax = plt.subplots(figsize=(6.0, 2.3))
    ax.plot(t, yP, color=C['azul'], label='paralelo'); ax.plot(t, yS, color=C['coral'], label='serie')
    ax.plot(t, t/2, ':', color=C['gris'], lw=0.8); ax.plot(t, -t/2, ':', color=C['gris'], lw=0.8)
    ax.set_xlabel('$t$'); ax.set_ylabel('$y_2(t)$'); ax.legend(fontsize=7, loc='upper left'); ax.grid(True)
    ax.set_title(r'Mismo espectro $\{\pm j,\pm j\}$: en serie, $y=\frac{t}{2}\sin t$')
    g(fig, 'f_jordan')


def no_normal():                    # C7_Ej8 [nonormal], C7_Video_CirculosElipses
    A = np.array([[-1, 10], [0, -2]]); P = lyapP(A, np.eye(2)); l = np.linalg.eigvalsh(P)
    t = np.linspace(0, 6, 600); X = np.array([expm(A*ti)@np.array([0, 1]) for ti in t])
    nx = np.linalg.norm(X, axis=1); Vx = np.einsum('ij,jk,ik->i', X, P, X)
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.7), gridspec_kw=dict(wspace=0.3))
    X1, X2 = np.meshgrid(np.linspace(-3, 3, 300), np.linspace(-1.5, 1.5, 200))
    Q = (A + A.T); W = Q[0, 0]*X1**2 + 2*Q[0, 1]*X1*X2 + Q[1, 1]*X2**2
    ax[0].contourf(X1, X2, W, levels=[0, 1e9], colors=[C['coral']], alpha=0.12)
    ang = np.linspace(0, 2*np.pi, 300); U = np.vstack([np.cos(ang), np.sin(ang)]); L = np.linalg.cholesky(P).T
    for k in [0, 69, 150]:
        ax[0].plot(nx[k]*U[0], nx[k]*U[1], color=C['coral'], lw=0.8)
        E = np.linalg.solve(L, np.sqrt(Vx[k])*U); ax[0].plot(E[0], E[1], color=C['verde'], lw=1.2)
    ax[0].plot(X[:, 0], X[:, 1], color=C['azul']); ax[0].plot(0, 1, 'o', color=C['azul'], ms=4)
    ax[0].set_aspect('equal'); ax[0].set_xlim(-3, 3); ax[0].set_ylim(-1.5, 1.5)
    ax[0].set_xlabel('$x_1$'); ax[0].set_ylabel('$x_2$'); ax[0].set_title('Círculos (rojo) y elipses de $P$')
    ax[1].plot(t, nx, color=C['coral'], label=r'$\|x(t)\|$')
    ax[1].plot(t, np.sqrt(Vx/Vx[0]), color=C['verde'], label=r'$\sqrt{V(x(t))/V(x_0)}$')
    ax[1].plot(t, np.sqrt(l[1]/l[0])*np.exp(-t/(2*l[1])), '--', color=C['gris'], lw=1, label='cota de Lyapunov')
    ax[1].set_xlabel('$t$'); ax[1].legend(fontsize=7); ax[1].grid(True); ax[1].set_ylim(0, 8)
    ax[1].set_title('Hurwitz, pero la norma crece')
    g(fig, 'f_no_normal')


def costo():                        # C7_Ej8 [lyap]
    A = np.array([[0, -1], [1, -1]]); P = lyapP(A, np.eye(2))
    t = np.linspace(0, 12, 1200); x0 = np.array([1.2, 1.0])
    X = np.array([expm(A*ti)@x0 for ti in t]); q = np.sum(X**2, axis=1)
    from scipy.integrate import cumulative_trapezoid
    acum = cumulative_trapezoid(q, t, initial=0); Vx = np.einsum('ij,jk,ik->i', X, P, X)
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.3))
    ax[0].stackplot(t, Vx, acum, colors=[C['verde'], C['claro']], labels=[r'$V(x(t))$: lo que falta', r'$\int_0^t x^{\top}x\,d\tau$: lo pagado'])
    ax[0].axhline(x0@P@x0, color=C['noche'], lw=0.8, ls='--')
    ax[0].set_xlabel('$t$'); ax[0].legend(fontsize=7, loc='center right'); ax[0].set_title(r'$x_0^{\top}Px_0=1.96$: el costo total')
    th = np.linspace(0, 2*np.pi, 60)
    for th_ in th:
        d = np.array([np.cos(th_), np.sin(th_)]); J = d@P@d
        ax[1].plot(*(d/np.sqrt(J)), 'o', color=C['azul'], ms=2.5)
    ang = np.linspace(0, 2*np.pi, 300); U = np.vstack([np.cos(ang), np.sin(ang)]); L = np.linalg.cholesky(P).T
    E = np.linalg.solve(L, U); ax[1].plot(E[0], E[1], color=C['verde'], lw=1.2)
    ax[1].set_aspect('equal'); ax[1].set_xlabel('$x_1$'); ax[1].set_ylabel('$x_2$')
    ax[1].set_title('Costo 1: puntos simulados y\n la elipse $x^{\\top}Px=1$', fontsize=9)
    g(fig, 'f_costo')


def inercia():                      # C7_Ej9 [inercia]
    mus = np.linspace(-1.5, 1.8, 3301); lam = np.full((2, mus.size), np.nan)
    for k, mu in enumerate(mus):
        if abs(mu) > 2e-3 and abs(mu - 1) > 2e-3:
            lam[:, k] = np.sort(np.linalg.eigvalsh(lyapP(np.array([[-1, 2], [0, mu]]), np.eye(2))))
    sl = lambda z: np.sign(z)*np.log10(1 + np.abs(z))
    fig, ax = plt.subplots(figsize=(6.0, 2.5))
    ax.axvspan(-1.5, 0, color=C['fondo'])
    ax.plot(mus, sl(lam[0]), color=C['coral']); ax.plot(mus, sl(lam[1]), color=C['azul'])
    ax.axhline(0, color=C['gris'], lw=0.7)
    for v in [0, 1]: ax.axvline(v, color=C['gris'], ls=':', lw=0.8)
    ax.set_xlabel(r'$\mu$'); ax.set_ylabel(r'$\mathrm{sgn}(\lambda)\log_{10}(1+|\lambda|)$')
    ax.set_title(r'Valores propios de $P$ para $A(\mu)=[-1\ 2;\ 0\ \mu]$')
    ax.text(-1.4, 2.2, r'$A$ Hurwitz: $P>0$', fontsize=8, color=C['noche'])
    ax.text(0.15, -2.2, r'$A$ inestable: $P$ indefinida', fontsize=8, color=C['coral']); ax.grid(True)
    g(fig, 'f_inercia')


def masas():                        # C7_Ej9 [masas]
    k1 = k2 = 1; bm = 0.3; t = np.linspace(0, 80, 1600)
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.4), gridspec_kw=dict(wspace=0.25), sharey=True)
    for j, ka in enumerate([0, 0.4]):
        A = np.array([[0, 1, 0, 0], [-(k1 + ka), -bm, ka, 0], [0, 0, 0, 1], [ka, 0, -(k2 + ka), 0]])
        X = np.array([expm(A*ti)@np.array([1, 0, 1, 0]) for ti in t])
        ax[j].plot(t, X[:, 0], color=C['azul'], lw=1, label='$q_1$ (con amortiguador)')
        ax[j].plot(t, X[:, 2], color=C['coral'], lw=1, label='$q_2$')
        ax[j].set_xlabel('$t$'); ax[j].grid(True)
    ax[0].set_title(r'$\kappa=0$: $(A,C)$ no observable'); ax[1].set_title(r'$\kappa=0.4$: observable, Hurwitz')
    ax[0].legend(fontsize=7, loc='lower right')
    g(fig, 'f_masas')


def region():                       # C7_Ej10 [region], C7_Video_RegionAtraccion
    P = np.array([[1.5, -0.5], [-0.5, 1]]); cst = 2.30448; cb = np.linalg.eigvalsh(P)[0]*2/np.sqrt(5)
    fv = lambda t, z: [-z[1], z[0] + (z[0]**2 - 1)*z[1]]
    X1, X2 = np.meshgrid(np.linspace(-3, 3, 400), np.linspace(-3, 3, 400))
    V = 1.5*X1**2 - X1*X2 + X2**2; W = -X1**2 - X2**2 - X1**3*X2 + 2*X1**2*X2**2
    fig, ax = plt.subplots(figsize=(4.2, 3.6))
    ax.contourf(X1, X2, W, levels=[0, 1e9], colors=[C['coral']], alpha=0.1)
    ax.contour(X1, X2, W, levels=[0], colors=C['coral'], linewidths=1)
    s = solve_ivp(lambda t, z: [-v for v in fv(t, z)], (0, 30), [2, 0], max_step=0.01, **o)
    m = s.t > 15; ax.plot(s.y[0][m], s.y[1][m], color=C['noche'], lw=1.3, label='ciclo límite (inestable)')
    ax.contour(X1, X2, V, levels=[cst], colors=C['verde'], linewidths=2)
    ax.contour(X1, X2, V, levels=[cb], colors=C['ambar'], linewidths=1.4, linestyles='--')
    ax.plot([], [], color=C['verde'], lw=2, label=r'$\Omega_{c^*}$, $c^*=2.30$')
    ax.plot([], [], color=C['ambar'], lw=1.4, ls='--', label=r'con bolas, $c=0.62$')
    ax.plot([], [], color=C['coral'], lw=1, label=r'$\dot V=0$ ($\dot V>0$ sombreado)')
    ax.set_aspect('equal'); ax.set_xlim(-3, 3); ax.set_ylim(-3, 3); ax.set_xlabel('$x_1$'); ax.set_ylabel('$x_2$')
    ax.legend(fontsize=6.5, loc='lower left'); ax.set_title('Van der Pol en tiempo invertido')
    g(fig, 'f_region')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
        sys.exit()
    for fn in [pendulos, polar, indirecto, energia, no_acotada, formas, cruzado, jordan, no_normal,
               costo, inercia, masas, region]:
        fn()
