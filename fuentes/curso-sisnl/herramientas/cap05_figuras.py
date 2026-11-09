"""Figuras del capítulo 5 (órbitas, osciladores y ciclos límite). PDF y SVG.
Cada figura reproduce un script de codigo/cap05_orbitas_ciclos/ (se indica cuál).
Ejecutar:  python3 herramientas/cap05_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Polygon, FancyArrowPatch
from scipy.integrate import solve_ivp
from estilo import C, guardar

CAP = 'cap05'


def g(fig, nombre):
    guardar(fig, nombre, CAP)


def ode(f, T, x0, n=4001, **kw):
    t = np.linspace(0, T, n)
    s = solve_ivp(f, (0, T), x0, t_eval=t, rtol=1e-10, atol=1e-12, **kw)
    return s.t, s.y


def flechas(a, x, y, cada=None, col=C['noche'], n=3):
    """Pone n flechas de dirección sobre la curva (x, y)."""
    m = len(x)
    for k in np.linspace(m*0.12, m*0.88, n).astype(int):
        a.annotate('', xy=(x[k+1], y[k+1]), xytext=(x[k], y[k]),
                   arrowprops=dict(arrowstyle='-|>', color=col, lw=1.2, mutation_scale=10))


def ejes0(a):
    a.axhline(0, color=C['gris'], lw=0.6); a.axvline(0, color=C['gris'], lw=0.6)


# ---------------------------------------------------------------- C5_Ej1
def duffing():
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.9), gridspec_kw=dict(wspace=0.3, width_ratios=[1.25, 1]))
    a = ax[0]
    x1, x2 = np.meshgrid(np.linspace(-2, 2, 400), np.linspace(-1.5, 1.5, 400))
    H = x2**2/2 - x1**2/2 + x1**4/4
    a.contour(x1, x2, H, levels=[-0.2, -0.1, -0.03, 0.1, 0.3, 0.6], colors=C['azul'], linewidths=1.1, linestyles='solid')
    a.contour(x1, x2, H, levels=[0], colors=C['coral'], linewidths=2)
    a.plot([-1, 1], [0, 0], 'o', color=C['noche'], ms=5); a.plot(0, 0, 'o', mfc='white', mec=C['noche'], ms=5)
    a.text(0.08, 0.12, 'silla', fontsize=7.5); a.text(1.0, 0.14, 'centro', fontsize=7.5, ha='center')
    a.text(-1.95, 1.25, 'homoclínicas ($H=0$)', color=C['coral'], fontsize=7.5)
    a.set_xlabel('$x_1$'); a.set_ylabel('$x_2$'); a.set_aspect('equal'); a.set_title('curvas de nivel de $H$')
    a = ax[1]
    from scipy.integrate import quad
    hs = np.linspace(-0.2499, -0.0005, 120)
    T = []
    for h in hs:
        lo, hi = np.sqrt(1 - np.sqrt(1 + 4*h)), np.sqrt(1 + np.sqrt(1 + 4*h))
        T.append(2*quad(lambda x: 1/np.sqrt(2*(h + x**2/2 - x**4/4)), lo, hi, limit=400)[0])
    a.plot(hs, T, color=C['azul']); a.axhline(2*np.pi/np.sqrt(2), color=C['gris'], ls='--', lw=1)
    a.text(-0.245, 4.6, r'$2\pi/\sqrt{2}$ (linealización)', fontsize=7.5, color=C['gris'])
    a.set_xlabel('nivel $H$ de la órbita'); a.set_ylabel('período'); a.grid(True); a.set_ylim(4, 14)
    a.set_title('el período depende de la órbita')
    g(fig, 'f_duffing')


def centro_falso():
    fig, ax = plt.subplots(1, 2, figsize=(6.4, 2.9), gridspec_kw=dict(wspace=0.25))
    for a, signo, tit in [(ax[0], 0, r'linealización: $\dot x=Ax$, centro'), (ax[1], 1, r'no lineal: $\dot r=r^3$, foco inestable')]:
        if signo == 0:
            th = np.linspace(0, 2*np.pi, 300)
            for r in [0.2, 0.35, 0.5]:
                a.plot(r*np.cos(th), r*np.sin(th), color=C['azul'])
        else:
            t, X = ode(lambda t, x: [-x[1] + x[0]*(x[0]**2 + x[1]**2), x[0] + x[1]*(x[0]**2 + x[1]**2)], 11.5, [0.2, 0])
            a.plot(X[0], X[1], color=C['coral']); flechas(a, X[0], X[1], col=C['coral'])
        a.set_aspect('equal'); a.set_xlim(-0.75, 0.75); a.set_ylim(-0.75, 0.75); ejes0(a); a.set_title(tit, fontsize=9)
    g(fig, 'f_centro_falso')


def lineal_vs_ciclo():
    fig, ax = plt.subplots(1, 2, figsize=(6.4, 2.9), gridspec_kw=dict(wspace=0.25))
    th = np.linspace(0, 2*np.pi, 300)
    for r in [0.4, 0.8, 1.2, 1.6]:
        ax[0].plot(r*np.cos(th), r*np.sin(th), color=C['azul'])
    ax[0].set_title(r'$\ddot x+x=0$: familia de órbitas', fontsize=9)
    f = lambda t, x: [-x[1] + x[0]*(1 - x[0]**2 - x[1]**2), x[0] + x[1]*(1 - x[0]**2 - x[1]**2)]
    for x0, col in [([0.12, 0], C['azul']), ([1.9, 0], C['violeta'])]:
        t, X = ode(f, 14, x0); ax[1].plot(X[0], X[1], color=col, lw=1.2)
    ax[1].plot(np.cos(th), np.sin(th), color=C['coral'], lw=2.6)
    ax[1].set_title('ciclo límite: una órbita aislada', fontsize=9)
    for a in ax:
        a.set_aspect('equal'); a.set_xlim(-2, 2); a.set_ylim(-2, 2); ejes0(a)
    g(fig, 'f_lineal_vs_ciclo')


def tipos_ciclo():
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.4), gridspec_kw=dict(wspace=0.1))
    casos = [(lambda r: r*(1 - r**2), 'estable', [(0.35, 8), (1.7, 8)]),
             (lambda r: -r*(1 - r**2), 'inestable', [(0.92, 7), (1.04, 1.0)]),
             (lambda r: r*(1 - r)**2, 'semiestable', [(0.5, 14), (1.08, 2.2)])]
    th = np.linspace(0, 2*np.pi, 300)
    for a, (F, tit, inis) in zip(ax, casos):
        a.plot(np.cos(th), np.sin(th), color=C['noche'], lw=2.4)
        for r0, T in inis:
            t, Y = ode(lambda t, y: [F(y[0]), 1], T, [r0, 0])
            ok = Y[0] < 2.2
            xx, yy = Y[0][ok]*np.cos(Y[1][ok]), Y[0][ok]*np.sin(Y[1][ok])
            a.plot(xx, yy, color=C['coral'] if r0 < 1 else C['azul'], lw=1.2)
            flechas(a, xx, yy, col=C['coral'] if r0 < 1 else C['azul'], n=2)
        a.set_aspect('equal'); a.set_xlim(-2.1, 2.1); a.set_ylim(-2.1, 2.1); a.axis('off'); a.set_title(tit)
    g(fig, 'f_tipos_ciclo')


# ---------------------------------------------------------------- C5_Ej3
def vanderpol():
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.35, width_ratios=[1, 1, 1.3]))
    for a, mu in [(ax[0], 1), (ax[1], 5)]:
        f = lambda t, x: [x[1], -x[0] - mu*(x[0]**2 - 1)*x[1]]
        for x0, col in [([0.1, 0], C['azul']), ([3, 3], C['violeta']), ([-3, -3], C['ambar'])]:
            t, X = ode(f, 40, x0); a.plot(X[0], X[1], color=col, lw=1)
        t, X = ode(f, 200, [2, 0]); k = t > 150
        a.plot(X[0][k], X[1][k], color=C['coral'], lw=2.4)
        a.set_title(fr'$\mu={mu}$'); a.set_xlabel('$x$'); a.grid(True)
        a.set_xlim(-3.5, 3.5)
    ax[0].set_ylabel(r'$\dot x$'); ax[0].set_ylim(-4, 4); ax[1].set_ylim(-9, 9)
    a = ax[2]
    for mu, col in [(1, C['azul']), (5, C['coral'])]:
        t, X = ode(lambda t, x: [x[1], -x[0] - mu*(x[0]**2 - 1)*x[1]], 40, [0.1, 0])
        a.plot(t, X[0], color=col, label=fr'$\mu={mu}$')
    a.set_xlabel('$t$'); a.set_ylabel('$x$'); a.grid(True)
    a.set_title(r'$x(t)$: $\mu=1$ (azul), $\mu=5$ (coral)', fontsize=8.5)
    g(fig, 'f_vanderpol')


# ---------------------------------------------------------------- C5_Ej4
def circulo_seno():
    fig, ax = plt.subplots(1, 2, figsize=(6.2, 2.6), gridspec_kw=dict(wspace=0.35, width_ratios=[1.3, 1]))
    a = ax[0]; th = np.linspace(0, 2*np.pi, 400)
    a.plot(th, np.sin(th), color=C['azul']); a.axhline(0, color=C['gris'], lw=0.8)
    for x0, d in [(np.pi/2, 1), (3*np.pi/2, -1)]:
        a.annotate('', xy=(x0 + 0.35*d, 0), xytext=(x0 - 0.35*d, 0), arrowprops=dict(arrowstyle='-|>', color=C['noche'], lw=1.5))
    a.plot([0, 2*np.pi], [0, 0], 'o', mfc='white', mec=C['noche'], ms=7); a.plot(np.pi, 0, 'o', color=C['noche'], ms=7)
    a.set_xticks([0, np.pi/2, np.pi, 3*np.pi/2, 2*np.pi]); a.set_xticklabels(['0', r'$\pi/2$', r'$\pi$', r'$3\pi/2$', r'$2\pi$'])
    a.set_xlabel(r'$\theta$'); a.set_ylabel(r'$\dot\theta=\sin\theta$'); a.grid(True)
    a.set_title('en la recta (con $0\\equiv2\\pi$)')
    a = ax[1]; a.add_patch(Circle((0, 0), 1, fill=False, ec=C['azul'], lw=2))
    for ang0, ang1 in [(0.35, 1.2), (1.9, 2.8), (-0.35, -1.2), (-1.9, -2.8)]:
        a.add_patch(FancyArrowPatch((np.cos(ang0), np.sin(ang0)), (np.cos(ang1), np.sin(ang1)),
                                    connectionstyle='arc3,rad=0.25' if ang1 > ang0 else 'arc3,rad=-0.25',
                                    arrowstyle='-|>', mutation_scale=12, color=C['noche'], lw=1.3))
    a.plot(1, 0, 'o', mfc='white', mec=C['noche'], ms=8); a.plot(-1, 0, 'o', color=C['noche'], ms=8)
    a.text(1.12, -0.05, r'$\theta^*=0$' + '\ninestable', fontsize=7.5, va='center')
    a.text(-1.12, -0.05, r'$\theta^*=\pi$' + '\nestable', fontsize=7.5, va='center', ha='right')
    a.set_aspect('equal'); a.set_xlim(-2.1, 2.1); a.set_ylim(-1.3, 1.3); a.axis('off'); a.set_title('en el círculo')
    g(fig, 'f_circulo_seno')


def no_uniforme():
    fig, ax = plt.subplots(1, 4, figsize=(6.9, 2.2), gridspec_kw=dict(wspace=0.38, width_ratios=[1, 1, 1, 1.2]))
    th = np.linspace(0, 2*np.pi, 400); w = 2
    for a, A, tit in [(ax[0], 1, r'$a<\omega$: deriva'), (ax[1], 2, r'$a=\omega$'), (ax[2], 3, r'$a>\omega$: enganche')]:
        a.plot(th, w - A*np.sin(th), color=C['azul']); a.axhline(0, color=C['gris'], lw=0.8)
        if A == 2:
            a.plot(np.pi/2, 0, 'o', color=C['ambar'], ms=6)
        if A == 3:
            s = np.arcsin(w/A); a.plot(s, 0, 'o', mfc='white', mec=C['noche'], ms=6); a.plot(np.pi - s, 0, 'o', color=C['noche'], ms=6)
        a.set_xticks([0, np.pi, 2*np.pi]); a.set_xticklabels(['0', r'$\pi$', r'$2\pi$']); a.set_title(tit, fontsize=9)
        a.set_ylim(-1.5, 5.2); a.grid(True); a.set_xlabel(r'$\theta$')
    ax[0].set_ylabel(r'$\dot\theta$')
    a = ax[3]; As = np.linspace(0, 1.995, 300)
    a.plot(As, 2*np.pi/np.sqrt(w**2 - As**2), color=C['coral']); a.axvline(2, color=C['gris'], ls='--', lw=1)
    a.set_xlabel('$a$ (con $\\omega=2$)'); a.set_ylabel('período'); a.set_ylim(0, 40); a.grid(True)
    a.set_title(r'$T=2\pi/\sqrt{\omega^2-a^2}$', fontsize=9)
    g(fig, 'f_no_uniforme')


# ---------------------------------------------------------------- C5_Ej5
def luciernagas():
    w, A = 1, 0.5
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.32))
    a = ax[0]
    for Om, col in [(1.3, C['verde']), (1.6, C['azul']), (2.0, C['coral'])]:
        t, P = ode(lambda t, p: [Om - w - A*np.sin(p[0])], 40, [0.0])
        a.plot(t, P[0], color=col, label=fr'$\Omega={Om}$')
    a.axhline(np.arcsin(0.6), color=C['verde'], ls=':', lw=1)
    a.set_xlabel('$t$'); a.set_ylabel(r'$\varphi=\psi-\theta$'); a.grid(True); a.legend(fontsize=7, loc='upper left')
    a.set_title('arrastre (verde) y deriva')
    a = ax[1]; Om = np.linspace(0, 2, 801); mu = (Om - w)/A
    Td = np.where(abs(mu) > 1, 2*np.pi/np.sqrt(np.maximum((Om - w)**2 - A**2, 1e-12)), np.nan)
    a.plot(Om, Td, color=C['coral']); a.axvspan(w - A, w + A, color=C['verde'], alpha=0.18)
    a.text(1.0, 32, 'rango de\narrastre', ha='center', fontsize=8, color=C['verde'])
    a.set_ylim(0, 40); a.set_xlabel(r'$\Omega$ (con $\omega=1$, $A=0.5$)'); a.set_ylabel(r'$T_{\mathrm{deriva}}$'); a.grid(True)
    a.set_title('período de la deriva')
    g(fig, 'f_luciernagas')


# ---------------------------------------------------------------- C5_Ej6
def kuramoto():
    N, gam = 400, 0.5
    i = np.arange(1, N + 1); w = gam*np.tan(np.pi*(i - 0.5)/N - np.pi/2)
    th0 = 2*np.pi*np.mod(i*0.6180339887, 1)
    def f(t, th, K):
        z = np.mean(np.exp(1j*th)); return w + K*abs(z)*np.sin(np.angle(z) - th)
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.4), gridspec_kw=dict(wspace=0.3, width_ratios=[1, 1, 1.4]))
    for a, K, tit in [(ax[0], 0.5, '$K=0.5<K_c$'), (ax[1], 2.0, '$K=2>K_c$')]:
        s = solve_ivp(f, (0, 100), th0, args=(K,), rtol=1e-6, atol=1e-8)
        th = s.y[:, -1]; z = np.mean(np.exp(1j*th))
        a.add_patch(Circle((0, 0), 1, fill=False, ec=C['claro'], lw=1.5))
        a.scatter(np.cos(th[::4]), np.sin(th[::4]), s=6, c=w[::4], cmap='coolwarm', vmin=-3, vmax=3)
        a.annotate('', xy=(z.real, z.imag), xytext=(0, 0), arrowprops=dict(arrowstyle='-|>', color=C['noche'], lw=2))
        a.set_aspect('equal'); a.set_xlim(-1.25, 1.25); a.set_ylim(-1.25, 1.25); a.axis('off')
        a.set_title(tit + f', $r={abs(z):.2f}$', fontsize=9)
    a = ax[2]; Ks = [0.5, 1.5, 2.0, 2.5, 3.0]; rs = []
    for K in Ks:
        s = solve_ivp(f, (0, 100), th0, args=(K,), rtol=1e-6, atol=1e-8)
        s2 = solve_ivp(f, (100, 200), s.y[:, -1], args=(K,), rtol=1e-6, atol=1e-8, t_eval=np.linspace(100, 200, 101))
        rs.append(np.mean(abs(np.mean(np.exp(1j*s2.y), axis=0))))
    Kt = np.linspace(0, 3.2, 400)
    a.plot(Kt, np.sqrt(np.maximum(0, 1 - 2*gam/Kt)), color=C['noche'], label=r'$\sqrt{1-K_c/K}$')
    a.plot(Ks, rs, 'o', color=C['coral'], label='simulación, $N=400$')
    a.axvline(2*gam, color=C['gris'], ls='--', lw=1); a.text(1.03, 0.9, '$K_c=2\\gamma$', fontsize=7.5)
    a.set_xlabel('$K$'); a.set_ylabel('$r$'); a.grid(True); a.legend(fontsize=7, loc='lower right')
    g(fig, 'f_kuramoto')


# ---------------------------------------------------------------- C5_Ej7
def indice_anclas():
    fig, ax = plt.subplots(2, 4, figsize=(6.9, 3.5), gridspec_kw=dict(wspace=0.08, hspace=0.25))
    casos = [('nodo: $f=-x$', lambda x: -x, +1), ('silla: $f=(x_1,-x_2)$', lambda x: np.array([x[0], -x[1]]), -1)]
    for fila, (tit, f, I) in enumerate(casos):
        a = ax[fila, 0]; a.add_patch(Circle((0, 0), 1, fill=False, ec=C['gris']))
        thk = np.linspace(0, 2*np.pi, 13)[:-1]
        cols = plt.cm.viridis(np.linspace(0, 0.95, len(thk)))
        for k, t in enumerate(thk):
            x = np.array([np.cos(t), np.sin(t)]); v = f(x); v = 0.35*v/np.linalg.norm(v)
            a.annotate('', xy=x + v, xytext=x, arrowprops=dict(arrowstyle='-|>', color=cols[k], lw=1.5))
            a.text(1.28*np.cos(t), 1.28*np.sin(t), str(k + 1), fontsize=6, ha='center', va='center', color=cols[k])
        a.set_aspect('equal'); a.set_xlim(-1.6, 1.6); a.set_ylim(-1.6, 1.6); a.axis('off'); a.set_title(tit, fontsize=8.5)
        a = ax[fila, 1]
        for k, t in enumerate(thk):
            x = np.array([np.cos(t), np.sin(t)]); v = f(x); v = v/np.linalg.norm(v)
            a.annotate('', xy=v, xytext=(0, 0), arrowprops=dict(arrowstyle='-|>', color=cols[k], lw=1.3))
            a.text(1.18*v[0], 1.18*v[1], str(k + 1), fontsize=6, ha='center', va='center', color=cols[k])
        a.set_aspect('equal'); a.set_xlim(-1.4, 1.4); a.set_ylim(-1.4, 1.4); a.axis('off')
        a.set_title('trasladados al origen', fontsize=8.5)
        a = ax[fila, 2]; s = np.linspace(0, 2*np.pi, 400)
        ang = np.unwrap(np.array([np.arctan2(*f(np.array([np.cos(t), np.sin(t)]))[::-1]) for t in s]))
        a.plot(s, (ang - ang[0])/(2*np.pi), color=C['coral']); a.set_ylim(-1.3, 1.3)
        a.set_xticks([0, 2*np.pi]); a.set_xticklabels(['0', r'$2\pi$']); a.set_yticks([-1, 0, 1]); a.grid(True)
        a.set_title(r'$\frac{\theta_f-\theta_f(0)}{2\pi}$', fontsize=8.5)
        a = ax[fila, 3]; a.axis('off')
        a.text(0.05, 0.5, f'$I={I:+d}$', fontsize=16, color=C['coral'] if I < 0 else C['azul'], va='center')
    g(fig, 'f_indice_anclas')


def indice_ejemplo():
    fig, a = plt.subplots(figsize=(4.2, 3.4))
    x1, x2 = np.meshgrid(np.linspace(-1.6, 2.6, 23), np.linspace(-1.6, 2.6, 23))
    U = -x1 + x1*x2; V = x1 + x2 - 2*x1*x2; L = np.hypot(U, V) + 1e-12
    a.quiver(x1, x2, U/L, V/L, color=C['claro'], scale=30, width=0.004)
    f = lambda t, x: [-x[0] + x[0]*x[1], x[0] + x[1] - 2*x[0]*x[1]]
    for x0 in [[1.4, 1.3], [0.6, 0.8], [0.05, -0.05]]:
        s = solve_ivp(f, (0, 12), x0, rtol=1e-9, max_step=0.02); ok = (abs(s.y) < 3).all(0)
        a.plot(s.y[0][ok], s.y[1][ok], color=C['azul'], lw=1)
    th = np.linspace(0, 2*np.pi, 300)
    a.plot(0.5 + 2*np.cos(th), 0.5 + 2*np.sin(th), color=C['coral'], ls='--', lw=1.4, label='rodea ambos: $I=0$')
    a.plot(1 + 0.35*np.cos(th), 1 + 0.35*np.sin(th), color=C['verde'], lw=1.8, label='solo el foco: $I=+1$')
    a.plot(0, 0, 'o', mfc='white', mec=C['noche'], ms=6); a.plot(1, 1, 'o', color=C['noche'], ms=6)
    a.text(0.08, -0.25, 'silla', fontsize=7.5); a.text(1.1, 0.72, 'foco estable', fontsize=7.5)
    a.set_aspect('equal'); a.set_xlim(-1.6, 2.6); a.set_ylim(-1.6, 2.6)
    a.legend(fontsize=7, loc='upper left')
    g(fig, 'f_indice_ejemplo')


# ---------------------------------------------------------------- C5_Ej9
def pb_khalil():
    f = lambda t, x: [x[0] + x[1] - x[0]*(x[0]**2 + x[1]**2), -2*x[0] + x[1] - x[1]*(x[0]**2 + x[1]**2)]
    fig, ax = plt.subplots(1, 2, figsize=(6.6, 2.9), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; th = np.linspace(0, 2*np.pi, 400)
    a.fill(np.sqrt(1.5)*np.cos(th), np.sqrt(1.5)*np.sin(th), color=C['verde'], alpha=0.12)
    a.plot(np.sqrt(1.5)*np.cos(th), np.sqrt(1.5)*np.sin(th), color=C['verde'], lw=1.6, label=r'$V=3/2$: $\dot V\leq0$')
    a.fill(0.12*np.cos(th), 0.12*np.sin(th), color='white'); a.plot(0.12*np.cos(th), 0.12*np.sin(th), color=C['ambar'], lw=1.2, label='se excluye el foco')
    for x0, col in [([0.01, 0], C['azul']), ([1.2, 0], C['violeta'])]:
        t, X = ode(f, 25, x0); a.plot(X[0], X[1], color=col, lw=1)
    t, X = ode(f, 60, [1, 0]); k = t > 50; a.plot(X[0][k], X[1][k], color=C['coral'], lw=2.4, label='ciclo límite')
    a.set_aspect('equal'); a.set_xlim(-1.6, 1.6); a.set_ylim(-1.6, 1.6); ejes0(a); a.legend(fontsize=6.8, loc='upper left')
    a.set_title('el anillo atrapa al ciclo', fontsize=9)
    a = ax[1]; c = np.linspace(0, 2.2, 300)
    a.plot(c, 3*c - 2*c**2, color=C['azul']); a.axhline(0, color=C['gris'], lw=0.8); a.axvline(1.5, color=C['verde'], ls='--')
    a.set_xlabel('$c$'); a.set_ylabel(r'$\max_{V=c}\dot V=3c-2c^2$'); a.grid(True); a.set_title('frontera de $\\{V\\leq c\\}$', fontsize=9)
    g(fig, 'f_pb_khalil')


# ---------------------------------------------------------------- C5_Ej10
def lotka():
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; A, B, Cc, D = 6, 3, 2, 1
    v, p = np.meshgrid(np.linspace(0.02, 9, 500), np.linspace(0.02, 9, 500))
    K = D*v - Cc*np.log(v) + B*p - A*np.log(p)
    K0 = D*2 - Cc*np.log(2) + B*2 - A*np.log(2)
    a.contour(v, p, K, levels=K0 + np.array([0.3, 0.8, 1.5, 3.0, 5.0]), colors=C['azul'], linewidths=1, linestyles='solid')
    a.set_xlim(0, 8); a.set_ylim(0, 7)
    a.plot(2, 2, 'o', color=C['noche'], ms=4); a.set_title('clásico: centros', fontsize=9)
    a = ax[1]; prm = (1, 1, 0.5, 1, 0.5, 0.2)
    def fc(t, x, a_=1, b_=1, c_=0.5, d_=1, e_=0.5, f_=0.2):
        return [x[0]*(a_ - e_*x[0] - b_*x[1]), x[1]*(-c_ + d_*x[0] - f_*x[1])]
    for x0 in [[0.2, 2], [1.8, 0.1], [0.1, 0.3]]:
        t, X = ode(fc, 60, x0); a.plot(X[0], X[1], color=C['verde'], lw=1)
    a.plot(0.6364, 0.6818, 'o', color=C['noche'], ms=4); a.set_title('con competencia: GAS', fontsize=9)
    a.set_xlim(0, 2); a.set_ylim(0, 2.2)
    a = ax[2]; Kc = 5
    rm = lambda t, x: [x[0]*(1 - x[0]/Kc) - x[0]*x[1]/(1 + x[0]), x[1]*(2*x[0]/(1 + x[0]) - 1)]
    t, X = ode(rm, 120, [1.1, 1.6], max_step=0.2); a.plot(X[0], X[1], color=C['claro'], lw=0.8)
    t, X = ode(rm, 400, [3, 3], max_step=0.2); k = t > 300; a.plot(X[0][k], X[1][k], color=C['coral'], lw=2.2)
    a.plot(1, 1.6, 'o', mfc='white', mec=C['noche'], ms=4); a.set_title('Rosenzweig–MacArthur: ciclo', fontsize=9)
    for a in ax:
        a.set_xlabel('$v$ (presa)'); a.grid(True)
    ax[0].set_ylabel('$p$ (depredador)')
    g(fig, 'f_lotka')


# ---------------------------------------------------------------- C5_Ej11
def nowak():
    B = 0.2*np.ones((3, 3)) + 0.68*np.eye(3)
    Qc = lambda c: np.array([[0.8 - c, 0.2, c], [c, 0.8 - c, 0.2], [0.2, c, 0.8 - c]])
    def f(t, x, Q):
        F = B @ x; return Q.T @ (F*x) - (x @ F)*x
    P = lambda X: (X[1] + 0.5*X[2], np.sqrt(3)/2*X[2])           # coordenadas del triángulo
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.5), gridspec_kw=dict(wspace=0.2, width_ratios=[1, 1, 1.15]))
    tri = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3)/2], [0, 0]])
    for a, c, tit in [(ax[0], 0.01, '$c=0.01$: ciclo límite'), (ax[1], 0.04, '$c=0.04$: foco estable')]:
        a.plot(*tri.T, color=C['gris'], lw=1)
        for x0, col in [([0.8, 0.15, 0.05], C['azul']), ([0.34, 0.33, 0.33], C['violeta'])]:
            s = solve_ivp(f, (0, 1500), x0, args=(Qc(c),), rtol=1e-9, atol=1e-11, max_step=1)
            a.plot(*P(s.y), color=col, lw=0.8)
        a.plot(*P(np.ones(3)/3), 'o', color=C['noche'], ms=3)
        a.set_aspect('equal'); a.axis('off'); a.set_title(tit, fontsize=8.5)
        a.text(-0.05, -0.08, '$G_1$', fontsize=7.5); a.text(1.0, -0.08, '$G_2$', fontsize=7.5); a.text(0.47, 0.9, '$G_3$', fontsize=7.5)
    a = ax[2]; cs = np.linspace(0, 0.06, 61)
    re = [(0.092 - 2.94*c)/3 for c in cs]
    a.plot(cs, re, color=C['coral']); a.axhline(0, color=C['gris'], lw=0.8); a.axvline(0.031293, color=C['noche'], ls='--', lw=1)
    a.text(0.0325, 0.02, r'$c^*\approx0.0313$', fontsize=7.5)
    a.set_xlabel('$c$'); a.set_ylabel(r'$\mathrm{Re}\,\lambda$ en $x^*$'); a.grid(True); a.set_title('Hopf', fontsize=9)
    g(fig, 'f_nowak')


if __name__ == '__main__':
    duffing(); centro_falso(); lineal_vs_ciclo(); tipos_ciclo(); vanderpol(); circulo_seno()
    no_uniforme(); luciernagas(); kuramoto(); indice_anclas(); indice_ejemplo(); pb_khalil(); lotka(); nowak()
