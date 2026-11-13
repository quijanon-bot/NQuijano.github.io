"""Figuras del capítulo 6 (bifurcaciones). PDF (notas) y SVG (web).
Cada figura reproduce un script de codigo/cap06_bifurcaciones/ (se indica cuál).
Ejecutar:  python3 herramientas/cap06_figuras.py   [nombre_de_función ...]
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.optimize import brentq
from estilo import C, guardar
from cap02_figuras import linea_fase
from cap04_figuras import campo, tray, punto, ejes

CAP = 'cap06'
def g(fig, nombre): guardar(fig, nombre, CAP)
o = dict(rtol=1e-10, atol=1e-12)


def rama(ax, x, y, estable, **kw):
    ax.plot(x, y, color=C['noche'] if estable else C['coral'], lw=2 if estable else 1.8,
            ls='-' if estable else '--', **kw)


def flecha(ax, x0, y0, x1, y1, col=None):
    ax.annotate('', xy=(x1, y1), xytext=(x0, y0),
                arrowprops=dict(arrowstyle='-|>', color=col or C['azul'], lw=1.4, mutation_scale=10))


def retorno(F, q, sentido=-1, T=60):
    """Primer retorno a Sigma = {x2 = 0, x1 > 0} (como comun/mapaPoincare.m)."""
    s0 = solve_ivp(lambda t, z: F(z), (0, 1e-3), [q, 0], **o)
    e = lambda t, z: z[1]; e.direction = sentido; e.terminal = True
    s = solve_ivp(lambda t, z: F(z), (1e-3, T), s0.y[:, -1], events=e, **o)
    return s.y_events[0][0][0], s.t_events[0][0]


# ------------------------------------------------------------------ 6.2
def rutas():                        # (plano traza-determinante)
    fig, ax = plt.subplots(figsize=(5.4, 3.6))
    tt = np.linspace(-3.4, 3.4, 300)
    ax.fill_between(tt, -2.2, 0, color=C['coral'], alpha=0.06)
    ax.plot(tt, tt**2/4, color=C['gris'], lw=1, ls=':')
    ax.axhline(0, color=C['noche'], lw=2.2); ax.plot([0, 0], [0, 3.2], color=C['verde'], lw=2.6)
    m = np.linspace(0, 1, 60)
    ax.plot(-2*np.sqrt(m) - 1, 2*np.sqrt(m), color=C['azul'], lw=2, label='silla-nodo: rama del nodo')
    ax.plot(2*np.sqrt(m) - 1, -2*np.sqrt(m), color=C['violeta'], lw=2, label='silla-nodo: rama de la silla')
    flecha(ax, -2.6, 1.6, -2.2, 1.1, C['azul']); flecha(ax, 0.6, -1.6, 0.2, -1.1, C['violeta'])
    ax.plot([-1, 1], [1, 1], color=C['ambar'], lw=2.4, label=r'circuito: $(\tau,\delta)=(\mu,1)$')
    flecha(ax, -0.9, 1, 0.9, 1, C['ambar'])
    punto(ax, (-1, 0), False); punto(ax, (0, 1), False)
    ax.text(-1.05, -0.32, 'Ruta 1\n$\\delta\\to0$', fontsize=8, color=C['noche'], ha='right', va='top')
    ax.text(0.12, 2.4, 'Ruta 2\n$\\tau\\to0,\\ \\delta>0$', fontsize=8, color=C['verde'])
    ax.text(2.2, -1.6, 'sillas', fontsize=8, color=C['coral']); ax.text(-3.2, 2.6, 'nodos', fontsize=8, color=C['gris'])
    ax.text(-1.6, 2.8, 'focos', fontsize=8, color=C['gris']); ax.text(1.0, 2.8, 'focos', fontsize=8, color=C['gris'])
    ax.set_xlim(-3.4, 3.4); ax.set_ylim(-2.2, 3.2); ax.set_xlabel(r'$\tau=\mathrm{tr}\,J$'); ax.set_ylabel(r'$\delta=\det J$')
    ax.legend(loc='lower left', fontsize=7, frameon=True, framealpha=0.9)
    g(fig, 'f_rutas')


# ------------------------------------------------------------------ 6.3
def sillanodo():                    # C6_Ej1 [sillanodo]
    fig = plt.figure(figsize=(6.9, 2.5))
    gs = fig.add_gridspec(1, 4, width_ratios=[1, 1, 1, 1.4], wspace=0.35)
    for k, mu in enumerate([-1, 0, 1]):
        a = fig.add_subplot(gs[k])
        eqs = [-np.sqrt(-mu), np.sqrt(-mu)] if mu < 0 else ([0.0] if mu == 0 else [])
        linea_fase(a, lambda x: mu + x**2, (-2, 2), eqs=eqs)
        a.set_ylim(-1.5, 4); a.set_title(f'$\\mu={mu}$'); a.set_xlabel('$x$')
        if k == 0: a.set_ylabel(r'$\dot x=\mu+x^2$')
    a = fig.add_subplot(gs[3]); m = np.linspace(-2, 0, 200)
    rama(a, m, -np.sqrt(-m), True); rama(a, m, np.sqrt(-m), False)
    a.plot(0, 0, 'o', mfc='#AAAAAA', mec=C['noche'], ms=6)
    a.text(0.25, 0.9, 'sin\nequilibrios', fontsize=7.5, color=C['gris'])
    a.set_xlim(-2, 1); a.set_ylim(-1.6, 1.6); a.grid(True)
    a.set_xlabel(r'$\mu$'); a.set_ylabel('$x^*$'); a.set_title('diagrama')
    g(fig, 'f_sillanodo')


def fantasma():                     # C6_Ej2 [fantasma]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.7), gridspec_kw=dict(wspace=0.32))
    cols = [C['coral'], C['ambar'], C['azul'], C['gris']]
    for m, c in zip([0.02, 0.08, 0.3, 1.0], cols):
        e = lambda t, x: x[0] + 4; e.terminal = True
        s = solve_ivp(lambda t, x: [-m - x[0]**2], (0, 60), [4.0], events=e, max_step=0.05, **o)
        ax[0].plot(s.t, s.y[0], color=c, label=f'$\\mu=-{m:g}$')
    ax[0].axhline(0, color=C['noche'], lw=0.6, ls=':'); ax[0].set_xlim(0, 26); ax[0].set_ylim(-4.2, 4.2)
    ax[0].set_xlabel('$t$'); ax[0].set_ylabel('$x$'); ax[0].legend(fontsize=7); ax[0].grid(True)
    ax[0].set_title('una pausa sin equilibrio')
    mm = np.logspace(-3, 0, 25); Ts = []
    for m in mm:
        e = lambda t, x: x[0] + 1; e.terminal = True
        Ts.append(solve_ivp(lambda t, x: [-m - x[0]**2], (0, 1e5), [1.0], events=e, **o).t_events[0][0])
    ax[1].loglog(mm, Ts, 'o', mfc='white', mec=C['azul'], ms=4.5, label='simulado')
    ax[1].loglog(mm, np.pi/np.sqrt(mm), color=C['coral'], label=r'$\pi/\sqrt{|\mu|}$')
    ax[1].set_xlabel(r'$|\mu|$'); ax[1].set_ylabel('tiempo de $+1$ a $-1$'); ax[1].legend(fontsize=7); ax[1].grid(True, which='both', alpha=0.5)
    ax[1].set_title('pendiente $-1/2$')
    g(fig, 'f_fantasma')


# ------------------------------------------------------------------ 6.4
def transcritica():                 # C6_Ej3 [laser]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.32))
    m = np.linspace(-1, 1, 100); a = ax[0]
    rama(a, m[m <= 0], 0*m[m <= 0], True); rama(a, m[m >= 0], 0*m[m >= 0], False)
    rama(a, m[m <= 0], m[m <= 0], False); rama(a, m[m >= 0], m[m >= 0], True)
    a.set_xlabel(r'$\mu$'); a.set_ylabel('$x^*$'); a.set_title(r'$\dot x=\mu x-x^2$'); a.grid(True)
    a = ax[1]; N0 = np.linspace(0, 3, 200); ns = (N0 - 1)/0.5
    rama(a, N0[N0 <= 1], 0*N0[N0 <= 1], True); rama(a, N0[N0 >= 1], 0*N0[N0 >= 1], False)
    rama(a, N0[N0 >= 1], ns[N0 >= 1], True); rama(a, N0[N0 <= 1], ns[N0 <= 1], False)
    a.axvspan(0, 1, color=C['claro'], alpha=0.35); a.text(0.12, 3.2, 'lámpara', fontsize=8, color=C['gris'])
    a.text(1.7, 3.2, 'láser', fontsize=8, color=C['noche']); a.axvline(1, color=C['verde'], lw=1, ls=':')
    a.text(1.04, -1.6, r'$N_0=k/G$', fontsize=7.5, color=C['verde'])
    a.set_xlim(0, 3); a.set_ylim(-2, 4); a.set_xlabel('$N_0$ (bombeo)'); a.set_ylabel('$n^*$'); a.grid(True)
    a.set_title('umbral del láser')
    g(fig, 'f_transcritica')


def horquillas():                   # C6_Ej4 [horquillas], [quintica]
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.32))
    m = np.linspace(-1, 1, 200); mn, mp = m[m <= 0], m[m >= 0]
    a = ax[0]; rama(a, mn, 0*mn, True); rama(a, mp, 0*mp, False); rama(a, mp, np.sqrt(mp), True); rama(a, mp, -np.sqrt(mp), True)
    a.set_title('supercrítica'); a.set_ylabel('$x^*$')
    a = ax[1]; rama(a, mn, 0*mn, True); rama(a, mp, 0*mp, False); rama(a, mn, np.sqrt(-mn), False); rama(a, mn, -np.sqrt(-mn), False)
    a.fill_between(mn, -np.sqrt(-mn), np.sqrt(-mn), color=C['verde'], alpha=0.12)
    a.text(-0.95, -0.25, 'cuenca\ndel origen', fontsize=6.5, color=C['verde'])
    a.set_title('subcrítica')
    a = ax[2]; r = np.linspace(0, 1.3, 600); mu = r**4 - r**2; est = (2*r**2 - 4*r**4) < 0
    a.plot(mu[est], r[est], color=C['noche'], lw=2); a.plot(mu[~est], r[~est], color=C['coral'], lw=1.8, ls='--')
    a.plot([-0.5, 0], [0, 0], color=C['noche'], lw=2); a.plot([0, 0.3], [0, 0], color=C['coral'], lw=1.8, ls='--')
    T = 4000.
    f = lambda t, x, m0, m1: [(m0 + (m1 - m0)*t/T)*x[0] + x[0]**3 - x[0]**5 + 1e-6]
    s1 = solve_ivp(f, (0, T), [0.01], args=(-0.5, 0.3), max_step=2, **o)
    s2 = solve_ivp(f, (0, T), [s1.y[0, -1]], args=(0.3, -0.5), max_step=2, **o)
    a.plot(-0.5 + 0.8*s1.t/T, s1.y[0], color=C['azul'], lw=1.2); a.plot(0.3 - 0.8*s2.t/T, s2.y[0], color=C['ambar'], lw=1.2)
    flecha(a, -0.3, 0.06, -0.15, 0.06); flecha(a, -0.1, 0.98, -0.2, 0.96, C['ambar'])
    a.set_xlim(-0.5, 0.3); a.set_ylim(-0.08, 1.3); a.set_title('con $-x^5$: histéresis')
    for a in ax: a.set_xlabel(r'$\mu$'); a.grid(True)
    g(fig, 'f_horquillas')


def imperfectas():                  # C6_Ej5 [imperfecta]
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.3))
    mu = np.linspace(-1.5, 1.5, 700)
    casos = [(lambda m, e: [-1, 0, m + e], [0.4, -0.4], 'silla-nodo $+\\varepsilon$'),
             (lambda m, e: [-1, m, e], [0.12, -0.12], 'transcrítica $+\\varepsilon$'),
             (lambda m, e: [-1, 0, m, e], [0.1], 'horquilla $+h$')]
    for a, (cf, pert, tit) in zip(ax, casos):
        for e, col in [(0, C['claro'])] + list(zip(pert, [C['azul'], C['coral']])):
            pts = [(m, z.real) for m in mu for z in np.roots(cf(m, e)) if abs(z.imag) < 1e-9]
            pts = np.array(pts); a.plot(pts[:, 0], pts[:, 1], '.', color=col, ms=1.6 if e else 2.4)
        a.set_title(tit); a.set_xlabel(r'$\mu$'); a.set_xlim(-1.5, 1.5); a.set_ylim(-1.6, 1.6); a.grid(True)
    ax[0].set_ylabel('$x^*$')
    ax[0].text(-1.4, 1.3, r'$\varepsilon=0.4$', color=C['azul'], fontsize=7); ax[0].text(-1.4, 1.0, r'$\varepsilon=-0.4$', color=C['coral'], fontsize=7)
    ax[1].text(-1.4, 1.3, r'$\varepsilon=0.12$', color=C['azul'], fontsize=7); ax[1].text(-1.4, 1.0, r'$\varepsilon=-0.12$', color=C['coral'], fontsize=7)
    ax[2].text(-1.4, 1.3, r'$h=0.1$', color=C['azul'], fontsize=7)
    g(fig, 'f_imperfectas')


# ------------------------------------------------------------------ 6.5
def sillanodo2d():                  # C6_Ej6 [sillanodo2d]
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.3))
    for a, mu in zip(ax, [-1, 0, 1]):
        F = lambda x, mu=mu: [mu - x[0]**2, -x[1]]
        caja = (-2, 2, -2, 2)
        campo(a, lambda X, Y: (mu - X**2, -Y), (-2, 2), (-2, 2), 15)
        for x0 in [(-1.8, 1.8), (-0.8, 1.8), (0.4, 1.8), (1.6, 1.8), (-1.8, -1.8), (-0.8, -1.8), (0.4, -1.8), (1.6, -1.8),
                   (1.9, 0.6), (1.9, -0.6), (-1.9, 0.02), (1.9, 0.0)]:
            tray(a, F, x0, T=6, caja=caja, lw=0.9, atras=False)
        a.axhline(0, color=C['ambar'], lw=1.6, ls='--')
        if mu >= 0:
            a.axvline(np.sqrt(mu), color=C['verde'], lw=1.6, ls='--'); a.axvline(-np.sqrt(mu), color=C['verde'], lw=1.6, ls='--')
        if mu > 0: punto(a, (np.sqrt(mu), 0), True); punto(a, (-np.sqrt(mu), 0), False)
        if mu == 0: a.plot(0, 0, 'o', mfc='#AAAAAA', mec=C['noche'], ms=6, zorder=6)
        ejes(a, (-2, 2), (-2, 2), f'$\\mu={mu}$')
    g(fig, 'f_sillanodo2d')


def escondida():                    # C6_Ej6 [escondida]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.9), gridspec_kw=dict(wspace=0.3, width_ratios=[1.15, 1]))
    mu = 0.1; F = lambda x: [mu*x[0] - x[0]*x[1], -x[1] + x[0]**2]
    a = ax[0]; caja = (-0.8, 0.8, -0.4, 0.8)
    campo(a, lambda X, Y: (mu*X - X*Y, -Y + X**2), (-0.8, 0.8), (-0.4, 0.8), 17)
    for x0 in [(0.05, 0.75), (-0.05, 0.75), (0.4, 0.75), (-0.4, 0.75), (0.75, 0.75), (-0.75, 0.75),
               (0.02, -0.35), (-0.02, -0.35), (0.5, -0.35), (-0.5, -0.35), (0.78, 0.2), (-0.78, 0.2)]:
        tray(a, F, x0, T=80, caja=caja, lw=0.9, atras=False)
    xx = np.linspace(-0.8, 0.8, 200); a.plot(xx, xx**2, color=C['verde'], lw=2, alpha=0.8, label=r'$x_2=x_1^2$')
    a.axhline(0, color=C['gris'], lw=0.8, ls=':')
    punto(a, (0, 0), False); punto(a, (np.sqrt(mu), mu), True); punto(a, (-np.sqrt(mu), mu), True)
    a.legend(fontsize=7, loc='upper center'); a.set_xlim(-0.8, 0.8); a.set_ylim(-0.4, 0.8)
    a.set_xlabel('$x_1$'); a.set_ylabel('$x_2$'); a.set_title(r'$\mu=0.1$')
    a = ax[1]; m = np.linspace(-0.3, 0.3, 200); mn, mp = m[m <= 0], m[m >= 0]
    rama(a, mn, 0*mn, True); rama(a, mp, 0*mp, False); rama(a, mp, np.sqrt(mp), True); rama(a, mp, -np.sqrt(mp), True)
    a.set_xlabel(r'$\mu$'); a.set_ylabel('$x_1^*$'); a.grid(True); a.set_title('horquilla supercrítica')
    g(fig, 'f_escondida')


def griffith():                     # C6_Ej7 [genetico], [histeresis]
    b = 0.35; ac = 1/(2*b)
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.36))
    a = ax[0]; xx = np.linspace(0, 3.6, 300)
    a.plot(xx, xx**2/(b*(1 + xx**2)), color=C['noche'], lw=2)
    for aa, c, lab in [(0.93, C['azul'], '$a<a_c$'), (ac, C['coral'], '$a=a_c$'), (2.4, C['verde'], '$a>a_c$')]:
        a.plot(xx, aa*xx, color=c, ls='--', lw=1.4, label=lab)
    a.plot(1, ac, 'o', color=C['coral'], ms=4)
    a.set_xlim(0, 3.6); a.set_ylim(0, 3.2); a.legend(fontsize=6.5, loc='lower right'); a.grid(True)
    a.set_xlabel('$x$'); a.set_ylabel('$y$'); a.set_title('nulclinas')
    a = ax[1]; aa = 1.0; F = lambda z: [-aa*z[0] + z[1], z[0]**2/(1 + z[0]**2) - b*z[1]]
    caja = (0, 3.5, 0, 3.5)
    campo(a, lambda X, Y: (-aa*X + Y, X**2/(1 + X**2) - b*Y), (0, 3.5), (0, 3.5), 13)
    for x0 in [(0.3, 3.4), (1.2, 3.4), (2.4, 3.4), (3.4, 3.4), (3.4, 0.3), (3.4, 1.5), (0.5, 0.05), (1.5, 0.05), (2.5, 0.05)]:
        tray(a, F, x0, T=60, caja=caja, lw=0.8, atras=False)
    d = 1 - 4*aa**2*b**2; xm, xp = (1 - np.sqrt(d))/(2*aa*b), (1 + np.sqrt(d))/(2*aa*b)
    J = np.array([[-aa, 1], [2*xm/(1 + xm**2)**2, -b]]); lam, V = np.linalg.eig(J); v = V[:, np.argmin(lam)]
    for sg in [1, -1]:
        s = solve_ivp(lambda t, z: [-c for c in F(z)], (0, 40), [xm + sg*1e-4*v[0], xm + sg*1e-4*v[1]],
                      events=lambda t, z: min(z[0], z[1], 3.5 - z[0], 3.5 - z[1]), max_step=0.05, **o)
        a.plot(s.y[0], s.y[1], color=C['noche'], lw=2)
    punto(a, (0, 0), True); punto(a, (xm, xm), False); punto(a, (xp, xp), True)
    a.text(0.08, 0.55, 'apagado', fontsize=7, color=C['noche'], bbox=dict(fc='white', ec='none', alpha=0.8, pad=1))
    a.text(2.35, 1.45, 'encendido', fontsize=7, color=C['noche'], bbox=dict(fc='white', ec='none', alpha=0.8, pad=1))
    a.set_xlim(0, 3.5); a.set_ylim(0, 3.5); a.set_xlabel('$x$'); a.set_ylabel('$y$'); a.set_title('$a=1$')
    a = ax[2]; A = np.linspace(0.5, 2.2, 400); dd = 1 - 4*A**2*b**2; ok = dd >= 0
    rama(a, A[ok], (1 + np.sqrt(dd[ok]))/(2*A[ok]*b), True); rama(a, A[ok], (1 - np.sqrt(dd[ok]))/(2*A[ok]*b), False)
    rama(a, A, 0*A, True); a.plot(ac, 1, 'o', mfc='#AAAAAA', mec=C['noche'], ms=5)
    flecha(a, 1.0, 2.6, 1.35, 1.35, C['azul']); flecha(a, ac + 0.02, 0.9, ac + 0.02, 0.1, C['azul']); flecha(a, 1.9, 0.12, 1.1, 0.12, C['azul'])
    a.set_xlim(0.5, 2.2); a.set_ylim(-0.1, 3.4); a.set_xlabel('$a$'); a.set_ylabel('$x^*$'); a.grid(True)
    a.set_title(f'$a_c={ac:.3f}$')
    g(fig, 'f_griffith')


# ------------------------------------------------------------------ 6.6
def circuito_F(mu): return lambda x: [x[1] - (x[0]**3 - mu*x[0]), -x[0]]


def ciclo(mu):
    F = circuito_F(mu)
    s = solve_ivp(lambda t, z: F(z), (0, 600), [0.1, 0], **o)
    e = lambda t, z: z[1]; e.direction = -1
    s2 = solve_ivp(lambda t, z: F(z), (0, 40), s.y[:, -1], events=e, dense_output=True, **o)
    te = s2.t_events[0]; tt = np.linspace(te[-2], te[-1], 1500)
    return s2.sol(tt), te[-1] - te[-2]


def circuito():                     # C6_Ej8 [circuito]
    fig = plt.figure(figsize=(6.9, 4.9)); gs = fig.add_gridspec(2, 4, hspace=0.45, wspace=0.35)
    for k, mu in enumerate([-0.5, 0, 0.5, 1]):
        a = fig.add_subplot(gs[0, k]); F = circuito_F(mu); caja = (-2, 2, -2, 2)
        campo(a, lambda X, Y: (Y - (X**3 - mu*X), -X), (-2, 2), (-2, 2), 13)
        for x0 in [(0.05, 0), (1.5, 1.5), (-1.5, -1.5)]:
            tray(a, F, x0, T=40, caja=caja, lw=0.9, atras=False)
        if mu > 0:
            X, _ = ciclo(mu); a.plot(X[0], X[1], color=C['verde'], lw=2.2)
        punto(a, (0, 0), mu < 0)
        ejes(a, (-2, 2), (-2, 2), f'$\\mu={mu:g}$')
        if k: a.set_ylabel('')
    mus = np.array([0.01, 0.02, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.7, 0.85, 1.0])
    res = [ciclo(m) for m in mus]; amp = [X[0].max() for X, _ in res]; per = [T for _, T in res]
    a = fig.add_subplot(gs[1, :2])
    a.loglog(mus, amp, 'o', mfc='white', mec=C['azul'], ms=4.5, label='simulada')
    a.loglog(mus, 2*np.sqrt(mus/3), color=C['coral'], label=r'$2\sqrt{\mu/3}$')
    a.set_xlabel(r'$\mu$'); a.set_ylabel('amplitud'); a.legend(fontsize=7); a.grid(True, which='both', alpha=0.5)
    a = fig.add_subplot(gs[1, 2:])
    a.plot(mus, per, 'o-', color=C['azul'], mfc='white', ms=4.5); a.axhline(2*np.pi, color=C['coral'], ls='--', lw=1.2)
    a.text(0.55, 6.31, r'$2\pi$', color=C['coral'], fontsize=8)
    a.set_xlabel(r'$\mu$'); a.set_ylabel('período'); a.grid(True)
    g(fig, 'f_circuito')


def supersub():                     # C6_Ej9 [supersub]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.3))
    m = np.linspace(-1, 1, 200); mn, mp = m[m <= 0], m[m >= 0]
    a = ax[0]; rama(a, mn, 0*mn, True); rama(a, mp, 0*mp, False)
    a.plot(mp, np.sqrt(mp), color=C['verde'], lw=2.4); a.text(0.15, 1.05, 'ciclo estable', color=C['verde'], fontsize=7.5)
    a.set_title(r'supercrítica: $\dot r=r(\mu-r^2)$')
    a = ax[1]; rama(a, mn, 0*mn, True); rama(a, mp, 0*mp, False)
    a.plot(mn, np.sqrt(-mn), color=C['coral'], lw=2, ls='--'); a.text(-0.98, 1.05, 'ciclo inestable\n(umbral)', color=C['coral'], fontsize=7.5)
    flecha(a, 0.3, 0.05, 0.75, 1.15, C['coral']); a.text(0.45, 0.35, 'escapa', fontsize=7.5, color=C['coral'])
    a.set_title(r'subcrítica: $\dot r=r(\mu+r^2)$')
    for a in ax: a.set_xlabel(r'$\mu$'); a.set_ylabel('$r$'); a.set_ylim(-0.05, 1.3); a.grid(True)
    g(fig, 'f_supersub')


def histeresis():                   # C6_Ej10 [rampa]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.7), gridspec_kw=dict(wspace=0.3))
    r = np.linspace(0, 1.3, 600); mu = r**4 - r**2; est = (2*r - 4*r**3) < 0
    for a in ax:
        a.plot(mu[est], r[est], color=C['verde'], lw=2.2); a.plot(mu[~est], r[~est], color=C['coral'], lw=1.8, ls='--')
        a.plot([-0.45, 0], [0, 0], color=C['noche'], lw=2); a.plot([0, 0.15], [0, 0], color=C['coral'], lw=1.8, ls='--')
        a.set_xlim(-0.45, 0.15); a.set_ylim(-0.05, 1.3); a.set_xlabel(r'$\mu$'); a.set_ylabel('$r$'); a.grid(True)
    ax[0].plot(-0.25, 1/np.sqrt(2), 'o', mfc='#AAAAAA', mec=C['noche'], ms=5); ax[0].plot(0, 0, 'o', mfc='#AAAAAA', mec=C['noche'], ms=5)
    ax[0].text(-0.43, 0.82, 'silla-nodo\nde ciclos', fontsize=7); ax[0].text(0.01, 0.12, 'Hopf\nsub', fontsize=7)
    ax[0].axvspan(-0.25, 0, color=C['claro'], alpha=0.35); ax[0].set_title('biestable en $[-1/4,0]$')
    T = 3000.
    gg = lambda t, x, m0, m1: [x[0]*((m0 + (m1 - m0)*t/T) + x[0]**2 - x[0]**4) + 1e-6]
    s1 = solve_ivp(gg, (0, T), [1e-3], args=(-0.4, 0.1), max_step=1, **o)
    s2 = solve_ivp(gg, (0, T), [s1.y[0, -1]], args=(0.1, -0.4), max_step=1, **o)
    ax[1].plot(-0.4 + 0.5*s1.t/T, s1.y[0], color=C['azul'], lw=1.4, label='subiendo')
    ax[1].plot(0.1 - 0.5*s2.t/T, s2.y[0], color=C['ambar'], lw=1.4, label='bajando')
    ax[1].legend(fontsize=7, loc='center left'); ax[1].set_title('rampa lenta')
    g(fig, 'f_histeresis')


# ------------------------------------------------------------------ 6.7
def pliegue():                      # (sección 6.7)
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.35))
    r = np.linspace(0, 1.6, 400)
    for m, c in [(-0.1, C['coral']), (0, C['gris']), (0.1, C['azul'])]:
        ax[0].plot(r, r*((1 - r**2)**2*np.cos(m) - np.sin(m)), color=c, label=f'$\\mu={m:g}$')
    ax[0].axhline(0, color=C['noche'], lw=0.7); ax[0].set_ylim(-0.3, 0.6); ax[0].legend(fontsize=7)
    ax[0].set_xlabel('$r$'); ax[0].set_ylabel(r'$\dot r$'); ax[0].grid(True)
    m = 0.1
    F = lambda x: [-x[0]*np.sin(m) - x[1]*np.cos(m) + (1 - x[0]**2 - x[1]**2)**2*(x[0]*np.cos(m) - x[1]*np.sin(m)),
                   x[0]*np.cos(m) - x[1]*np.sin(m) + (1 - x[0]**2 - x[1]**2)**2*(x[0]*np.sin(m) + x[1]*np.cos(m))]
    a = ax[1]; th = np.linspace(0, 2*np.pi, 300)
    rin, rout = np.sqrt(1 - np.sqrt(np.tan(m))), np.sqrt(1 + np.sqrt(np.tan(m)))
    for x0 in [(0.15, 0), (1.12, 0), (1.17, 0)]:
        s = solve_ivp(lambda t, z: F(z), (0, 25), x0, max_step=0.05, events=lambda t, z: np.hypot(*z) - 1.6, **o)
        a.plot(s.y[0], s.y[1], color=C['azul'], lw=0.8)
    a.plot(rin*np.cos(th), rin*np.sin(th), color=C['verde'], lw=2.2); a.plot(rout*np.cos(th), rout*np.sin(th), color=C['coral'], lw=1.8, ls='--')
    ejes(a, (-1.6, 1.6), (-1.6, 1.6), r'$\mu=0.1$')
    a = ax[2]; mm = np.linspace(0, 0.6, 200)
    a.plot(mm, np.sqrt(1 - np.sqrt(np.tan(mm))), color=C['verde'], lw=2.2); a.plot(mm, np.sqrt(1 + np.sqrt(np.tan(mm))), color=C['coral'], lw=1.8, ls='--')
    a.plot(0, 1, 'o', mfc='#AAAAAA', mec=C['noche'], ms=5); a.set_xlim(-0.3, 0.6); a.set_ylim(0, 1.6)
    a.text(-0.28, 0.35, 'sin ciclos:\ntodo escapa', fontsize=7, color=C['coral'])
    a.set_xlabel(r'$\mu$'); a.set_ylabel('radio del ciclo'); a.grid(True)
    g(fig, 'f_pliegue')


# ------------------------------------------------------------------ 6.8
def seccion():                      # C6_Ej11 [mapa]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 3.1), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; mu = 0.1; F = circuito_F(mu)
    X, _ = ciclo(mu); a.plot(X[0], X[1], color=C['verde'], lw=2.2, label='ciclo')
    q = [0.12]
    s = solve_ivp(lambda t, z: F(z), (0, 4*6.29), [q[0], 0], max_step=0.02, **o)
    a.plot(s.y[0], s.y[1], color=C['azul'], lw=0.9)
    for k in range(3): q.append(retorno(F, q[-1])[0])
    a.plot([0, 0.52], [0, 0], color=C['ambar'], lw=3, alpha=0.8)
    a.text(0.47, -0.07, r'$\Sigma$', color=C['ambar'], fontsize=10)
    for k, qk in enumerate(q):
        a.plot(qk, 0, 'o', color=C['coral'], ms=4.5, zorder=6); a.text(qk, 0.05 if k % 2 == 0 else -0.11, f'$A_{k}$', fontsize=7.5, ha='center')
    qs = brentq(lambda z: retorno(F, z)[0] - z, 0.1, 0.9)
    a.plot(qs, 0, 's', color=C['noche'], ms=4.5, zorder=7); a.text(qs + 0.03, 0.05, '$B$', fontsize=8)
    ejes(a, (-0.5, 0.55), (-0.5, 0.5), r'circuito, $\mu=0.1$')
    a = ax[1]; m = 0.2; P = lambda r: m*r/(r + (m - r)*np.exp(-2*np.pi*m)); rr = np.linspace(0.001, 0.34, 200)
    a.plot(rr, P(rr), color=C['noche'], lw=2, label='$P(r)$'); a.plot(rr, rr, color=C['gris'], lw=1, ls=':')
    for r0, c in [(0.1, C['azul']), (0.3, C['coral'])]:
        x = r0; xs, ys = [x], [0]
        for _ in range(6):
            y = P(x); xs += [x, y]; ys += [y, y]; x = y
        a.plot(xs, ys, color=c, lw=1)
    a.plot(m, m, 'o', color=C['noche'], ms=5); a.text(m + 0.01, m - 0.03, r'$(\mu,\mu)$', fontsize=8)
    a.set_xlim(0, 0.34); a.set_ylim(0, 0.34); a.set_aspect('equal'); a.grid(True)
    a.set_xlabel('$r_k$'); a.set_ylabel('$r_{k+1}$'); a.set_title(r'telaraña, $\mu=0.2$')
    g(fig, 'f_seccion')


def vdp_poincare():                 # C6_Ej12 [vdp]
    F = circuito_F(1.0)
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.38))
    a = ax[0]
    for q0, c in [(0.2, C['azul']), (2.6, C['violeta'])]:
        s = solve_ivp(lambda t, z: F(z), (0, 14), [q0, 0], max_step=0.02, **o); a.plot(s.y[0], s.y[1], color=c, lw=0.9)
        q = [q0]
        for _ in range(2): q.append(retorno(F, q[-1])[0])
        a.plot(q, [0]*len(q), 'o', color=C['coral'], ms=3.5, zorder=6)
    X, _ = ciclo(1.0); a.plot(X[0], X[1], color=C['verde'], lw=2)
    a.plot([0, 2.8], [0, 0], color=C['ambar'], lw=2.4, alpha=0.8)
    ejes(a, (-2.8, 2.8), (-2.8, 2.8), r'van der Pol, $\Sigma$')
    qq = np.linspace(0.1, 3, 40); RT = [retorno(F, q) for q in qq]; PP = [r for r, _ in RT]; TT = [t for _, t in RT]
    qs = brentq(lambda z: retorno(F, z)[0] - z, 0.5, 2)
    a = ax[1]; a.plot(qq, PP, color=C['noche'], lw=2); a.plot(qq, qq, color=C['gris'], lw=1, ls=':')
    x = 0.2; xs, ys = [x], [0]
    for _ in range(3):
        y = retorno(F, x)[0]; xs += [x, y]; ys += [y, y]; x = y
    a.plot(xs, ys, color=C['coral'], lw=1); a.plot(qs, qs, 'o', color=C['noche'], ms=4.5)
    a.set_xlim(0, 3); a.set_ylim(0, 3); a.set_aspect('equal'); a.grid(True)
    a.set_xlabel('$q$'); a.set_ylabel('$P(q)$'); a.set_title(f'$q^*={qs:.4f}$')
    a = ax[2]; a.plot(qq, TT, color=C['azul'], lw=2); a.axvline(qs, color=C['gris'], ls=':', lw=1)
    a.set_xlabel('$q$'); a.set_ylabel(r'$\tau(q)$'); a.grid(True); a.set_title('tiempo de retorno')
    g(fig, 'f_vdp_poincare')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
        sys.exit()
    for fn in [rutas, sillanodo, fantasma, transcritica, horquillas, imperfectas, sillanodo2d, escondida, griffith,
               circuito, supersub, histeresis, pliegue, seccion, vdp_poincare]:
        fn()
