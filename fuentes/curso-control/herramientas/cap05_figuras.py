"""Figuras del capítulo 5 (estabilidad). PDF (notas) y SVG (web).
Ejecutar:  python3 herramientas/cap05_figuras.py
"""
import itertools
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import control as ct
from estilo import C, guardar

CAP = 'cap05'
s = ct.tf('s')


def g(fig, nombre):
    guardar(fig, nombre, CAP)


def paso(G, t):
    return ct.step_response(G, t).outputs


def plano(ax, polos, lim=1.6):
    ax.axhline(0, color=C['gris'], lw=0.7); ax.axvline(0, color=C['gris'], lw=0.7)
    ax.axvspan(0, lim, color=C['coral'], alpha=0.08)
    for p in polos:
        ax.plot(p.real, p.imag, 'x', color=C['noche'], ms=7, mew=2)
    ax.set_xlim(-lim, lim); ax.set_ylim(-lim, lim); ax.set_xticks([]); ax.set_yticks([])
    ax.set_aspect('equal')


# ------------------------------------------------------------- modos y polos
def modos():
    t = np.linspace(0, 15, 1501)
    casos = [(1/(s + 1), '$1/(s+1)$\nasintóticamente estable', C['verde']),
             (1/(s**2 + 1), '$1/(s^2+1)$\nmarginalmente estable', C['ambar']),
             (1/(s - 1), '$1/(s-1)$\ninestable', C['coral']),
             (1/(s**2 + 1)**2, '$1/(s^2+1)^2$\ninestable', C['coral'])]
    fig, axs = plt.subplots(2, 4, figsize=(7.0, 3.6), gridspec_kw=dict(height_ratios=[1, 1.25], hspace=0.45, wspace=0.35))
    for k, (G, tit, col) in enumerate(casos):
        polos = ct.poles(G)
        plano(axs[0, k], polos)
        if k == 3:
            axs[0, k].text(0.12, 1.0, '×2', color=C['noche'], fontsize=8); axs[0, k].text(0.12, -1.25, '×2', color=C['noche'], fontsize=8)
        axs[0, k].set_title(tit, color=col, fontsize=8.5)
        y = ct.impulse_response(G, t).outputs
        axs[1, k].plot(t, y, color=col)
        axs[1, k].axhline(0, color=C['gris'], lw=0.6); axs[1, k].grid(True); axs[1, k].set_xlabel('t (s)')
        if k == 2:
            axs[1, k].set_ylim(-0.5, 20)
    axs[1, 0].set_ylabel('respuesta natural')
    g(fig, 'f_modos')


# ---------------------------------------------------- rango de Kc: simulación
def rango_kc():
    G = 0.8/((3*s + 1)*(30*s + 1)); H = 1/(10*s + 1)
    Kcr = 143/6; t = np.linspace(0, 300, 3001)
    fig, axs = plt.subplots(1, 3, figsize=(7.0, 2.4), sharex=True, gridspec_kw=dict(wspace=0.3))
    for ax, f, c, tit in zip(axs, (0.5, 1, 1.2), (C['azul'], C['ambar'], C['coral']),
                             ('$K_c=0.5\\,K_{cr}$', '$K_c=K_{cr}=23.83$', '$K_c=1.2\\,K_{cr}$')):
        ax.plot(t, paso(ct.feedback(f*Kcr*G, H), t), color=c)
        ax.set_title(tit, color=c); ax.grid(True); ax.set_xlabel('t (s)')
    axs[0].set_ylabel('$y(t)$')
    y = paso(ct.feedback(Kcr*G, H), t)
    ym = y[t > 150].min()
    axs[1].set_ylim(ym - 1.0, y.max()*1.08)
    axs[1].annotate('', xy=(150 + 28.75, ym - 0.35), xytext=(150, ym - 0.35), arrowprops=dict(arrowstyle='<->', color=C['noche']))
    axs[1].text(185, ym - 0.55, '$P_{cr}=28.7$ s', color=C['noche'], fontsize=8.5)
    g(fig, 'f_rango_kc')


# ------------------------------------------ planta inestable: max Re vs K
def inestable():
    ks = np.linspace(2.5, 4.0, 1501)
    m = np.array([max(np.roots([1, 4, 3, k - 2, 2*k - 6]).real) for k in ks])
    fig, ax = plt.subplots(figsize=(6.2, 2.6))
    ax.axvspan(3, -8 + 2*np.sqrt(33), color=C['verde'], alpha=0.15)
    ax.plot(ks, m, color=C['azul'])
    ax.axhline(0, color=C['coral'], lw=1)
    ax.set_xlabel('$K$'); ax.set_ylabel('máx Re(polos)'); ax.grid(True)
    ax.text(3.03, 0.2, 'estable:\n$3<K<3.489$', color=C['verde'], fontsize=8.5)
    i = np.argmin(m); ax.plot(ks[i], m[i], 'o', color=C['noche'], ms=4)
    ax.text(ks[i] + 0.05, m[i] + 0.0, f'el más amortiguado: $K\\approx{ks[i]:.2f}$', fontsize=8, color=C['noche'])
    g(fig, 'f_inestable')


# --------------------------------------------------------------- región PI
def region_pi():
    Kc = np.linspace(-1, 9, 400); Kim = (1 + Kc)*(9 - Kc)/8
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.9), gridspec_kw=dict(width_ratios=[1, 1.4], wspace=0.3))
    a1.fill_between(Kc, 0, Kim, color=C['azul'], alpha=0.15)
    a1.plot(Kc, Kim, color=C['azul'])
    for ki, c in zip((1, 3, 4), (C['verde'], C['ambar'], C['coral'])):
        a1.plot(5, ki, 'o', color=c, ms=6)
    a1.text(-0.6, 0.5, 'estable', color=C['azul'])
    a1.text(4.2, 3.4, '$K_i=\\frac{(1+K_c)(9-K_c)}{8}$', color=C['azul'], fontsize=8.5)
    a1.set_xlabel('$K_c$'); a1.set_ylabel('$K_i$'); a1.set_xlim(-1.5, 9.5); a1.set_ylim(0, 4.5); a1.grid(True)
    Gp = 2/(s**3 + 4*s**2 + 5*s + 2); t = np.linspace(0, 40, 4001)
    for ki, c in zip((1, 3, 4), (C['verde'], C['ambar'], C['coral'])):
        a2.plot(t, paso(ct.feedback((5 + ki/s)*Gp, 1), t), color=c, label=f'$K_i={ki}$' + (' (frontera)' if ki == 3 else ''))
    a2.set_ylim(-0.3, 2.6); a2.grid(True); a2.set_xlabel('t (s)'); a2.set_title('$K_c=5$')
    a2.legend(loc='upper center', bbox_to_anchor=(0.5, -0.2), ncol=3, fontsize=8)
    g(fig, 'f_region_pi')


# ----------------------------------------- estabilidad relativa: región en s
def relativa():
    fig, ax = plt.subplots(figsize=(3.4, 2.6))
    ax.axvspan(-0.05, 0.02, color=C['coral'], alpha=0.12)
    ax.axhline(0, color=C['gris'], lw=0.7); ax.axvline(0, color=C['gris'], lw=0.7)
    ax.axvline(-0.05, color=C['coral'], ls='--', lw=1)
    for kc, c, mk in ((17/64, C['violeta'], 'x'), (10/3, C['azul'], 'x'), (23.83, C['ambar'], '+')):
        p = np.roots([900, 420, 43, 1 + 0.8*kc])
        ax.plot(p.real, p.imag, mk, color=c, ms=7, mew=2, label=f'$K_c={kc:.3g}$' if kc < 20 else '$K_c=K_{cr}=23.83$')
    ax.set_xlim(-0.42, 0.02); ax.set_ylim(-0.26, 0.26)
    ax.text(-0.135, -0.235, '$\\sigma=-0.05$', color=C['coral'], fontsize=8)
    ax.set_xlabel('Re $s$'); ax.set_ylabel('Im $s$'); ax.legend(fontsize=7.5, loc='lower left')
    g(fig, 'f_relativa')


# ---------------------------------- Kharitonov: rectángulos de valores p(jw)
def kharitonov_rect():
    lo = np.array([1, 3, 4, 1.]); hi = np.array([2, 4, 5, 2.])   # a0 + a1 s + a2 s^2 + a3 s^3 (ascendente)
    pats = ['--++', '++--', '-++-', '+--+']
    fig, ax = plt.subplots(figsize=(6.0, 3.3))
    ws = np.linspace(0, 1.45, 400)
    nom = (lo + hi)/2
    v = np.polyval(nom[::-1], 1j*ws); ax.plot(v.real, v.imag, color=C['gris'], lw=1, ls=':', label='polinomio nominal')
    for w in (0.25, 0.5, 0.75, 1.0, 1.25):
        pts = []
        for p in ('--++', '+--+', '++--', '-++-'):     # vértices en orden alrededor del rectángulo
            c = np.array([lo[i] if p[i % 4] == '-' else hi[i] for i in range(4)])
            pts.append(np.polyval(c[::-1], 1j*w))
        pts = np.array(pts)
        ax.add_patch(Polygon(np.c_[pts.real, pts.imag], closed=True, fc=C['azul'], alpha=0.12, ec=C['azul']))
        for k, p in enumerate(pts):
            ax.plot(p.real, p.imag, 'o', color=[C['azul'], C['coral'], C['violeta'], C['ambar']][k], ms=3.5)
        ax.text(pts.real.min(), pts.imag.max() + 0.12, f'$\\omega={w}$', fontsize=7.5, color=C['noche'])
    ax.plot(0, 0, '+', color=C['coral'], ms=12, mew=2); ax.text(0.15, -0.6, 'origen', color=C['coral'], fontsize=8)
    ax.axhline(0, color=C['gris'], lw=0.6); ax.axvline(0, color=C['gris'], lw=0.6)
    ax.set_xlim(-8, 2.6); ax.set_ylim(-0.9, 4.0)
    ax.set_xlabel('Re $p(j\\omega)$'); ax.set_ylabel('Im $p(j\\omega)$'); ax.set_aspect('equal'); ax.grid(True)
    ax.legend(loc='upper left', fontsize=8)
    g(fig, 'f_kharitonov')


# ----------------------------------------- diseño robusto: conservadurismo
def khar_diseno():
    Ks = np.linspace(0, 750, 301)
    grid = list(itertools.product(np.linspace(6, 7, 5), np.linspace(100, 120, 5), np.linspace(1, 2, 9)))
    peor = []
    for K in Ks:
        peor.append(max(max(np.roots([r3, r1*r3 + 1, r2*r3 + r1, r2 + K]).real) for r1, r2, r3 in grid))
    fig, ax = plt.subplots(figsize=(6.2, 2.7))
    ax.plot(Ks, peor, color=C['azul'], label='peor caso de la familia real')
    ax.axhline(0, color=C['coral'], lw=1)
    ax.axvline(251, color=C['violeta'], ls='--', lw=1.2); ax.text(256, 0.25, 'Kharitonov:\n$K<251$', color=C['violeta'], fontsize=8.5)
    ax.axvline(642, color=C['verde'], ls='--', lw=1.2); ax.text(560, 0.25, 'exacto:\n$K<642$', color=C['verde'], fontsize=8.5)
    ax.set_xlabel('$K$'); ax.set_ylabel('máx Re(polos)'); ax.grid(True)
    ax.legend(loc='lower left', fontsize=8)
    g(fig, 'f_khar_diseno')


# ------------------------------------------------- retardo y Padé
def kmax_exacto(T, a=1.0):
    from scipy.optimize import brentq
    w = brentq(lambda w: w*T + np.arctan(w/a) - np.pi, 1e-9, np.pi/T + 10)
    return np.hypot(w, a)


def kmax_pade(T, n, a=1.0):
    num, den = ct.pade(T, n)
    lo, hi = 0.0, 1e4
    for _ in range(100):
        m = (lo + hi)/2
        p = np.polyadd(np.polymul([1, a], den), m*np.array(num))
        lo, hi = (m, hi) if all(np.roots(p).real < 0) else (lo, m)
    return lo


def lazo_retardo_exacto(K, T, tf_, dt=1e-3):
    """y' = -y + K e(t-T), e = 1 - y (Euler con memoria)."""
    n = int(tf_/dt); d = int(round(T/dt)); y = np.zeros(n + 1); e = np.ones(n + 1)
    for k in range(n):
        ed = e[k - d] if k >= d else 0.0
        y[k + 1] = y[k] + dt*(-y[k] + K*ed); e[k + 1] = 1 - y[k + 1]
    return np.arange(n + 1)*dt, y


def pade_fig():
    fig, axs = plt.subplots(1, 3, figsize=(7.0, 2.5), gridspec_kw=dict(wspace=0.38))
    t = np.linspace(0, 4, 2001); T = 1.0
    axs[0].plot(t, (t >= T).astype(float), color=C['noche'], label='$e^{-s}$ exacto')
    for n, c in ((1, C['coral']), (2, C['azul'])):
        num, den = ct.pade(T, n)
        axs[0].plot(t, ct.step_response(ct.tf(num, den), t).outputs, color=c, label=f'Padé {n}')
    axs[0].set_title('escalón retrasado $T=1$'); axs[0].set_xlabel('t (s)'); axs[0].grid(True); axs[0].legend(fontsize=7, loc='lower right')
    Ts = np.logspace(-1, np.log10(5), 30)
    axs[1].plot(Ts, [kmax_exacto(x) for x in Ts], color=C['noche'], label='exacto')
    axs[1].plot(Ts, [kmax_pade(x, 1) for x in Ts], color=C['coral'], ls='--', label='Padé 1: $1+2/T$')
    axs[1].plot(Ts, [kmax_pade(x, 2) for x in Ts], color=C['azul'], ls=':', label='Padé 2')
    axs[1].set_xscale('log'); axs[1].set_yscale('log'); axs[1].grid(True, which='both')
    axs[1].set_xlabel('$T$ (s)'); axs[1].set_title('$K_{\\max}$'); axs[1].legend(fontsize=7)
    tt, y = lazo_retardo_exacto(2.5, 1.0, 30)
    num, den = ct.pade(1.0, 1)
    yp = ct.step_response(ct.feedback(2.5*ct.tf(num, den)/(s + 1), 1), tt).outputs
    axs[2].plot(tt, yp, color=C['coral'], ls='--', label='modelo Padé 1')
    axs[2].plot(tt, y, color=C['noche'], label='retardo exacto')
    axs[2].set_ylim(-2.5, 5.5); axs[2].set_title('$K=2.5$, $T=1$'); axs[2].set_xlabel('t (s)'); axs[2].grid(True)
    axs[2].legend(fontsize=7, loc='upper left', ncol=1)
    g(fig, 'f_pade')


if __name__ == '__main__':
    modos(); rango_kc(); inestable(); region_pi(); relativa(); kharitonov_rect(); khar_diseno(); pade_fig()
