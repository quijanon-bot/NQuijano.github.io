"""Figuras del capítulo 3 (fundamentos matemáticos). PDF (notas) y SVG (web).
Cada figura reproduce un script de codigo/cap03_preliminares/ (se indica cuál).
Ejecutar:  python3 herramientas/cap03_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse, Polygon, FancyBboxPatch, Circle, Rectangle
from scipy.integrate import solve_ivp
from estilo import C, guardar

CAP = 'cap03'


def g(fig, nombre):
    guardar(fig, nombre, CAP)


def ode(f, T, x0, n=2001, t0=0, **kw):
    t = np.linspace(t0, T, n)
    s = solve_ivp(f, (t0, T), x0, t_eval=t, rtol=1e-10, atol=1e-12, **kw)
    return s.t, s.y


# ---------------------------------------------------------------- C3_Ej1
def distancias():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.7), gridspec_kw=dict(wspace=0.3))
    a = ax[0]
    a.plot([1, 4], [1, 1], color=C['coral'], lw=2.2); a.plot([4, 4], [1, 3], color=C['coral'], lw=2.2, label='$d_1=3+2=5$')
    a.plot([1, 4], [1, 3], color=C['azul'], lw=2.2, label=r'$d_2=\sqrt{13}\approx3.61$')
    a.plot([1, 4], [0.7, 0.7], color=C['ambar'], lw=3, label=r'$d_\infty=\max\{3,2\}=3$')
    a.plot([1, 4], [1, 3], 'o', color=C['noche'], ms=5)
    a.text(0.85, 1.15, '$x$', ha='right'); a.text(4.1, 3.05, '$y$')
    a.set_xlim(0, 5); a.set_ylim(0, 4); a.set_aspect('equal'); a.grid(True)
    a.legend(loc='upper left', fontsize=7.5); a.set_title('los mismos dos puntos')
    a = ax[1]
    t = np.linspace(0, 1, 2001); f = np.sin(2*np.pi*t); gg = t
    a.fill_between(t, f, gg, color=C['azul'], alpha=0.15, label=r'área: $d_1(f,g)=0.921$')
    a.plot(t, f, color=C['azul'], label=r'$f=\sin 2\pi t$'); a.plot(t, gg, color=C['coral'], label='$g=t$')
    k = np.argmax(abs(f - gg))
    a.plot([t[k], t[k]], [f[k], gg[k]], color=C['ambar'], lw=3, label=r'$d_\infty(f,g)=1.763$')
    a.set_xlabel('$t$'); a.grid(True); a.legend(loc='lower left', fontsize=7)
    a.set_title('dos funciones de $C[0,1]$')
    g(fig, 'f_distancias')


# ---------------------------------------------------------------- C3_Ej2
def bolas():
    fig, ax = plt.subplots(1, 2, figsize=(6.6, 3.0), gridspec_kw=dict(wspace=0.28, width_ratios=[1, 1.15]))
    a = ax[0]; th = np.linspace(0, 2*np.pi, 1441); c, s = np.cos(th), np.sin(th)
    for p, col, lab in [(0.5, C['gris'], r'$p=1/2$ (no es norma)'), (1, C['coral'], '$p=1$'),
                        (2, C['azul'], '$p=2$'), (np.inf, C['verde'], r'$p=\infty$')]:
        r = 1/np.maximum(abs(c), abs(s)) if np.isinf(p) else 1/(abs(c)**p + abs(s)**p)**(1/p)
        a.plot(r*c, r*s, color=col, lw=2 if p != 0.5 else 1.4, ls='--' if p == 0.5 else '-', label=lab)
    a.set_aspect('equal'); a.set_xlim(-1.3, 1.3); a.set_ylim(-1.3, 1.3); a.grid(True)
    a.axhline(0, color=C['gris'], lw=0.6); a.axvline(0, color=C['gris'], lw=0.6)
    a.legend(loc='upper center', bbox_to_anchor=(0.5, -0.08), fontsize=7, ncol=2)
    a.set_title(r'$\{x:\|x\|_p=1\}$')
    a = ax[1]; t = np.linspace(0, 1, 2001)
    for k, col in zip([1, 3, 10, 40], [C['azul'], C['violeta'], C['coral'], C['ambar']]):
        a.plot(t, t**k, color=col, label=fr'$t^{{{k}}}$: $\|\cdot\|_{{L_1}}={1/(k+1):.3f}$')
    a.set_xlabel('$t$'); a.grid(True); a.legend(fontsize=7, loc='upper left')
    a.set_title(r'$\|t^k\|_\infty=1$, $\|t^k\|_{L_1}\to0$')
    g(fig, 'f_bolas')


def senales():
    t = np.linspace(0, 30, 3001)
    fig, a = plt.subplots(figsize=(6.4, 2.4))
    a.plot(t, np.exp(-t/3), color=C['verde'], label=r'$e^{-t/3}$: $\mathcal{L}_1,\mathcal{L}_2,\mathcal{L}_\infty$')
    a.plot(t, 1/(1 + t), color=C['azul'], label=r'$1/(1+t)$: $\mathcal{L}_2,\mathcal{L}_\infty$, no $\mathcal{L}_1$')
    a.plot(t, np.sin(t), color=C['coral'], lw=1.2, label=r'$\sin t$: solo $\mathcal{L}_\infty$')
    a.plot(t[1:], 1/np.sqrt(t[1:])*(t[1:] < 1) + 0*(t[1:] >= 1), color=C['ambar'], lw=1.6,
           label=r'$t^{-1/2}\,(t<1)$: $\mathcal{L}_1$, no $\mathcal{L}_2$ ni $\mathcal{L}_\infty$')
    a.set_ylim(-1.1, 3.2); a.set_xlim(0, 30); a.set_xlabel('$t$'); a.grid(True)
    a.legend(fontsize=7, loc='upper center', bbox_to_anchor=(0.5, -0.28), ncol=2)
    g(fig, 'f_senales')


# ---------------------------------------------------------------- C3_Ej3
def matriz():
    A = np.array([[1, 2], [-3, 4]]); th = np.linspace(0, 2*np.pi, 400)
    U = np.vstack([np.cos(th), np.sin(th)]); Y = A @ U
    _, S, Vt = np.linalg.svd(A); v = A @ Vt[0]
    N = np.array([[0, 1], [0, 0]]); YN = N @ U
    fig, ax = plt.subplots(1, 2, figsize=(6.6, 3.0), gridspec_kw=dict(wspace=0.3))
    a = ax[0]
    a.plot(*U, color=C['gris'], lw=1.2, label=r'$\|x\|_2=1$'); a.plot(*Y, color=C['azul'], label='$Ax$')
    a.annotate('', xy=v, xytext=(0, 0), arrowprops=dict(arrowstyle='->', color=C['coral'], lw=2))
    a.text(1.6, 4.6, r'$\|A\|_2=5.12$', color=C['coral'], fontsize=8.5)
    a.add_patch(Circle((0, 0), np.sqrt(10), fill=False, ls='--', color=C['ambar']))
    a.text(-5.2, -5.1, r'$\rho(A)=\sqrt{10}=3.16$', color=C['ambar'], fontsize=8)
    a.set_aspect('equal'); a.set_xlim(-5.5, 5.5); a.set_ylim(-5.5, 5.5); a.grid(True)
    a.set_title('A = [1  2; −3  4]')
    a.legend(fontsize=7, loc='upper left')
    a = ax[1]
    a.plot(*U, color=C['gris'], lw=1.2); a.plot(*YN, color=C['coral'], lw=3, label='$Nx$ (segmento)')
    a.set_aspect('equal'); a.set_xlim(-1.5, 1.5); a.set_ylim(-1.5, 1.5); a.grid(True)
    a.set_title(r'N = [0  1; 0  0]:  $\rho(N)=0$, $\|N\|_2=1$'); a.legend(fontsize=7, loc='upper left')
    g(fig, 'f_matriz')


# ---------------------------------------------------------------- C3_Ej4
def completitud():
    t = np.linspace(0, 1, 4001)
    fig, a = plt.subplots(figsize=(5.2, 2.5))
    for k, col in zip([4, 10, 40], [C['azul'], C['violeta'], C['coral']]):
        a.plot(t, np.clip(k*(t - 0.5), 0, 1), color=col, label=f'$f_{{{k}}}$')
    a.plot(t, (t > 0.5).astype(float), '--', color=C['noche'], lw=1.4, label='escalón (no continuo)')
    a.set_xlabel('$t$'); a.grid(True); a.legend(fontsize=7.5, loc='upper left')
    a.set_title(r'Cauchy en $\mathcal{L}_2$, sin límite en $C[0,1]$')
    g(fig, 'f_completitud')


# ---------------------------------------------------------------- conjuntos
def conjuntos():
    fig, ax = plt.subplots(1, 4, figsize=(6.9, 1.9), gridspec_kw=dict(wspace=0.08))
    for a in ax:
        a.set_aspect('equal'); a.axis('off'); a.set_xlim(-1.5, 1.5); a.set_ylim(-1.3, 1.3)
    a = ax[0]; a.add_patch(Circle((0, 0), 1, fc=C['azul'], alpha=0.15, ec=C['azul'], ls='--', lw=1.4))
    a.add_patch(Circle((0.35, 0.2), 0.3, fill=False, ec=C['coral'])); a.plot(0.35, 0.2, '.', color=C['coral'])
    a.set_title('abierto: cada punto\ntiene una bola adentro', fontsize=8)
    a = ax[1]; a.add_patch(Circle((0, 0), 1, fc=C['azul'], alpha=0.15, ec=C['azul'], lw=2))
    a.set_title('cerrado y acotado:\ncompacto (Heine–Borel)', fontsize=8)
    a = ax[2]
    ang = np.linspace(0, 2*np.pi, 200); r = 1 + 0.35*np.cos(3*ang)
    a.add_patch(Polygon(np.c_[0.9*r*np.cos(ang), 0.9*r*np.sin(ang)], fc=C['coral'], alpha=0.15, ec=C['coral']))
    p, q = np.array([0.9*1.35, 0]), 0.9*1.35*np.array([np.cos(2*np.pi/3), np.sin(2*np.pi/3)])
    a.plot(*np.c_[p, q], '-o', color=C['noche'], ms=3, lw=1.2)
    a.set_title('no convexo: el segmento\nse sale del conjunto', fontsize=8)
    a = ax[3]
    a.add_patch(Circle((-0.75, 0), 0.55, fc=C['verde'], alpha=0.18, ec=C['verde'], ls='--'))
    a.add_patch(Circle((0.75, 0), 0.55, fc=C['verde'], alpha=0.18, ec=C['verde'], ls='--'))
    a.set_title('abierto, no conexo:\nno es un dominio', fontsize=8)
    g(fig, 'f_conjuntos')


# ---------------------------------------------------------------- regularidad
def regularidad():
    fig, a = plt.subplots(figsize=(6.0, 3.1))
    a.set_aspect('equal'); a.axis('off'); a.set_xlim(-6.2, 6.2); a.set_ylim(-3.2, 3.2)
    a.add_patch(FancyBboxPatch((-6.0, -3.0), 12.0, 6.0, boxstyle='round,pad=0.02,rounding_size=1.2',
                               fc=C['claro'], alpha=0.35, ec=C['gris']))
    a.text(-5.6, 2.45, r'continuas en $\mathbb{R}$', fontsize=9, color=C['noche'], weight='bold')
    # localmente Lipschitz (izquierda) y uniformemente continuas (derecha)
    a.add_patch(Ellipse((-1.4, 0.0), 7.4, 4.3, fc=C['azul'], alpha=0.10, ec=C['azul'], lw=1.4))
    a.text(-4.9, 1.2, 'localmente\nLipschitz', fontsize=8.5, color=C['azul'])
    a.add_patch(Ellipse((1.9, 0.0), 6.6, 4.1, fc=C['verde'], alpha=0.10, ec=C['verde'], lw=1.4))
    a.text(3.2, 1.35, 'uniformemente\ncontinuas', fontsize=8.5, color=C['verde'])
    # Lipschitz dentro de la intersección; C^1 dentro de loc. Lipschitz
    a.add_patch(Ellipse((0.35, -0.15), 2.7, 2.3, fc=C['coral'], alpha=0.20, ec=C['coral'], lw=1.6))
    a.text(0.0, 0.62, 'Lipschitz', fontsize=8, color=C['coral'], weight='bold')
    a.add_patch(Ellipse((-1.55, -0.35), 3.6, 2.0, fc=C['violeta'], alpha=0.18, ec=C['violeta'], lw=1.4))
    a.text(-3.0, 0.15, '$C^1$', fontsize=11, color=C['violeta'])
    a.text(-2.75, -0.75, '$x^3$', fontsize=8.5, color=C['noche'])
    a.text(-0.55, -0.35, r'$\sin x$', fontsize=8.5, color=C['noche'])
    a.text(0.75, -0.55, 'sat', fontsize=8.5, color=C['noche'])
    a.text(3.0, -0.6, '$x^{1/3}$', fontsize=8.5, color=C['noche'])
    a.text(-5.6, -2.65, r'$x^{1/3}+x^2$: continua, ni localmente Lipschitz ni uniformemente continua', fontsize=7.5, color=C['noche'])
    g(fig, 'f_regularidad')


# ---------------------------------------------------------------- C3_Ej5
def lipschitz():
    s = np.linspace(-1.5, 1.5, 601); sat = np.clip(s, -1, 1)
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.3), gridspec_kw=dict(wspace=0.3))
    def cono(a, x0, y0, L, col):
        xx = np.array([-1.5, 1.5]); a.fill_between(xx, y0 + L*(xx - x0), y0 - L*(xx - x0), color=col, alpha=0.10)
    ax[0].plot(s, s**3, color=C['azul']); cono(ax[0], 1, 1, 3, C['azul']); ax[0].plot(1, 1, 'o', color=C['azul'], ms=4)
    ax[0].set_title('$x^3$: $L=3a^2$ en $[-a,a]$'); ax[0].set_ylim(-3.5, 3.5)
    ax[1].plot(s, sat, color=C['verde']); cono(ax[1], 0.3, 0.3, 1, C['verde']); ax[1].plot(0.3, 0.3, 'o', color=C['verde'], ms=4)
    ax[1].set_title('sat: $L=1$ global'); ax[1].set_ylim(-1.6, 1.6)
    ax[2].plot(s, np.cbrt(s), color=C['coral'])
    for L in [2, 8, 40]:
        cono(ax[2], 0, 0, L, C['coral'])
    ax[2].set_title(r'$x^{1/3}$: ningún cono sirve en 0'); ax[2].set_ylim(-1.6, 1.6)
    for a in ax:
        a.axhline(0, color=C['gris'], lw=0.5); a.axvline(0, color=C['gris'], lw=0.5); a.set_xlim(-1.5, 1.5); a.grid(True)
    g(fig, 'f_lipschitz')


# ---------------------------------------------------------------- C3_Ej6
def no_unicidad():
    t = np.linspace(0, 3, 1201)
    fig, a = plt.subplots(figsize=(5.0, 2.5))
    for c, col in zip([0, 0.5, 1, 1.5, 2], [C['azul'], C['violeta'], C['coral'], C['ambar'], C['verde']]):
        a.plot(t, (t > c)*((2/3)*np.maximum(t - c, 0))**1.5, color=col, label=f'$c={c:g}$')
    a.plot(t, 0*t, color=C['noche'], lw=2.6, label='$x\\equiv0$ (ode45)')
    a.set_xlabel('$t$'); a.set_ylabel('$x(t)$'); a.grid(True); a.legend(fontsize=7, loc='upper left', ncol=2)
    a.set_title(r'$\dot x=x^{1/3}$, $x(0)=0$: infinitas soluciones')
    g(fig, 'f_no_unicidad')


# ---------------------------------------------------------------- C3_Ej7
def picard():
    t = np.linspace(0, 1, 2001); x = np.ones_like(t); err = []
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.32))
    cols = [C['claro'], C['gris'], C['violeta'], C['azul'], C['coral'], C['ambar']]
    ax[0].plot(t, x, color=cols[0], label='$x_0$')
    for k in range(1, 7):
        x = 1 + np.concatenate([[0], np.cumsum(0.5*(x[1:] + x[:-1])*np.diff(t))])
        err.append(np.max(abs(x - np.exp(t))))
        if k <= 4:
            ax[0].plot(t, x, color=cols[k], label=f'$x_{k}$')
    ax[0].plot(t, np.exp(t), '--', color=C['noche'], lw=1.4, label='$e^t$')
    ax[0].set_xlabel('$t$'); ax[0].grid(True); ax[0].legend(fontsize=7, loc='upper left')
    ax[0].set_title(r'$x_{k+1}(t)=1+\int_0^t x_k(s)\,ds$')
    from math import factorial
    ks = np.arange(1, 7)
    ax[1].semilogy(ks, err, 'o-', color=C['coral'], label='error medido')
    ax[1].semilogy(ks, [1/factorial(k + 1)*np.e for k in ks], '--', color=C['gris'], label='$e/(k+1)!$')
    ax[1].set_xlabel('iteración $k$'); ax[1].grid(True, which='both'); ax[1].legend(fontsize=7)
    ax[1].set_title(r'$\|x_k-e^t\|_C$')
    g(fig, 'f_picard')


# ---------------------------------------------------------------- C3_Ej8
def escape():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.3))
    t = np.linspace(0, 0.995, 800)
    ax[0].semilogy(t, 1/(1 - t), color=C['coral'], label=r'$x(t)=1/(1-t)$')
    ax[0].axvspan(0, (np.sqrt(2) - 1)/2, color=C['verde'], alpha=0.18, label=r'garantizado: $[0,\,0.207]$')
    ax[0].axvline(1, color=C['gris'], ls='--', lw=1); ax[0].set_xlim(0, 1.05)
    ax[0].set_xlabel('$t$'); ax[0].grid(True, which='both'); ax[0].legend(fontsize=7, loc='upper left')
    ax[0].set_title(r'$\dot x=x^2$, $x(0)=1$: escapa en $t=1$')
    t = np.linspace(0, 10, 800)
    for x0, col in [(2, C['azul']), (-1, C['violeta']), (0.5, C['ambar'])]:
        ax[1].plot(t, x0/np.sqrt(1 + 2*x0**2*t), color=col, label=f'$x_0={x0:g}$')
    ax[1].set_xlabel('$t$'); ax[1].grid(True); ax[1].legend(fontsize=7)
    ax[1].set_title(r'$\dot x=-x^3$: existe para todo $t\geq0$')
    g(fig, 'f_escape')


# ---------------------------------------------------------------- C3_Ej9
def comparacion():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.3))
    t, X = ode(lambda t, x: [-(1 + x[0]**2)*x[0]], 4, [2.0])
    ax[0].plot(t, abs(X[0]), color=C['azul'], label='$|x(t)|$, $a=2$')
    ax[0].plot(t, 2*np.exp(-t), '--', color=C['coral'], label=r'$|a|e^{-t}$')
    ax[0].set_xlabel('$t$'); ax[0].grid(True); ax[0].legend(fontsize=7.5)
    ax[0].set_title(r'$\dot x=-(1+x^2)x$')
    gf = lambda t, x: [-x[0] + 2*x[1]/(1 + x[1]**2), -x[1] + 2*x[0]/(1 + x[0]**2)]
    t, X = ode(gf, 12, [3.0, -2.0])
    nx = np.hypot(X[0], X[1]); cota = np.exp(-t)*np.sqrt(13) + np.sqrt(2)*(1 - np.exp(-t))
    ax[1].plot(t, nx, color=C['azul'], label=r'$\|x(t)\|_2$')
    ax[1].plot(t, cota, '--', color=C['coral'], label='cota de comparación')
    ax[1].axhline(np.sqrt(2), color=C['gris'], lw=0.8, ls=':')
    ax[1].set_xlabel('$t$'); ax[1].grid(True); ax[1].legend(fontsize=7.5)
    ax[1].set_title('sistema de dos estados, desde $(3,-2)$')
    g(fig, 'f_comparacion')


# ---------------------------------------------------------------- C3_Ej10
def dependencia():
    t = np.linspace(0, 5, 501)
    _, Y = ode(lambda t, y: [-y[0] + 0.5*np.sin(y[0])], 5, [1.0], n=501)
    _, Z = ode(lambda t, z: [-z[0] + 0.5*np.sin(z[0]) + 0.1*np.cos(t)], 5, [1.05], n=501)
    cota = 0.05*np.exp(1.5*t) + 0.1/1.5*(np.exp(1.5*t) - 1)
    fig, a = plt.subplots(figsize=(5.0, 2.4))
    a.semilogy(t, abs(Y[0] - Z[0]), color=C['azul'], label=r'$|y(t)-z(t)|$')
    a.semilogy(t, cota, '--', color=C['coral'], label=r'$\gamma e^{Lt}+\frac{\mu}{L}(e^{Lt}-1)$')
    a.set_xlabel('$t$'); a.grid(True, which='both'); a.legend(fontsize=7.5, loc='upper left')
    g(fig, 'f_dependencia')


if __name__ == '__main__':
    distancias(); bolas(); senales(); matriz(); completitud(); conjuntos(); regularidad()
    lipschitz(); no_unicidad(); picard(); escape(); comparacion(); dependencia()
