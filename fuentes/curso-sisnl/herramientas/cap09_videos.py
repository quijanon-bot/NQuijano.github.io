"""Videos de la parte 9 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C9_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap09_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V9_1_tiempo_inicial.mp4, V9_2_mathieu.mp4,
           V9_3_markus_yamabe.mp4, V9_4_cetaev.mp4
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.linalg import expm
from estilo import C
from cap04_videos import grabar

o = dict(rtol=1e-10, atol=1e-12)
COL = [C['azul'], C['verde'], C['violeta'], C['coral']]


def v9_1_tiempo():                  # C9_Video_TiempoInicial
    t0s = [0, 10, 40, 100]; s = np.linspace(0, 1000, 2001)
    fig, a = plt.subplots(figsize=(9.6, 4.4))
    nf = 160; idx = np.linspace(1, len(s) - 1, nf).astype(int)
    def act(k):
        j = idx[k]; a.cla()
        for c, t0 in zip(COL, t0s):
            a.plot(s[:j+1], (1 + t0)/(1 + t0 + s[:j+1]), color=c, lw=2, label=f'$t_0={t0}$')
            T = 9*(1 + t0)
            if s[j] >= T: a.plot(T, 0.1, 'o', color=c, ms=8)
        a.axhline(0.1, color=C['noche'], ls='--', lw=1)
        a.set_xlim(0, 1000); a.set_ylim(0, 1.05); a.grid(True); a.legend(loc='upper right')
        a.set_xlabel('$s=t-t_0$'); a.set_ylabel('$x$')
        a.set_title(f'$s={s[j]:.0f}$: asentamiento $9(1+t_0)$ = 9, 99, 369, 909')
    grabar(fig, act, nf, 'V9_1_tiempo_inicial')


def v9_2_mathieu():                 # C9_Video_Mathieu
    t = np.linspace(0, 12, 1201)
    X = solve_ivp(lambda tt, z: [z[1], -z[1] - (2 + np.sin(tt))*z[0]], (0, 12), [1.5, 0], t_eval=t, **o).y
    Vt = X[0]**2 + X[1]**2/(2 + np.sin(t)); th = np.linspace(0, 2*np.pi, 300)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.28))
    nf = 180; idx = np.linspace(0, len(t) - 1, nf).astype(int)
    def act(k):
        j = idx[k]; c = np.sqrt(Vt[j])
        a1.cla(); a1.plot(c*np.cos(th), c*np.sqrt(2 + np.sin(t[j]))*np.sin(th), color=C['azul'], ls='--', lw=1.5)
        a1.plot(X[0, :j+1], X[1, :j+1], color=C['noche'], lw=1); a1.plot(*X[:, j], 'o', color=C['coral'], ms=9)
        a1.set_xlim(-1.7, 1.7); a1.set_ylim(-2.7, 2.7); a1.set_aspect('equal'); a1.grid(True)
        a1.set_xlabel('$x_1$'); a1.set_ylabel('$x_2$'); a1.set_title(f'$t={t[j]:.1f}$: nivel $V(t,x)={Vt[j]:.3f}$')
        a2.cla(); a2.semilogy(t, 2.25*np.exp(-t), color=C['noche'], ls='--', lw=1, label='$2.25e^{-t}$')
        a2.semilogy(t[:j+1], Vt[:j+1], color=C['azul'], lw=2, label='$V(t,x(t))$')
        a2.set_xlim(0, 12); a2.set_ylim(1e-6, 4); a2.grid(True); a2.legend(loc='upper right'); a2.set_xlabel('$t$')
        a2.set_title('mesetas donde $x_2=0$')
    grabar(fig, act, nf, 'V9_2_mathieu')


def v9_3_markus():                  # C9_Video_MarkusYamabe
    A = lambda tt: np.array([[-1 + 1.5*np.cos(tt)**2, 1 - 1.5*np.sin(tt)*np.cos(tt)],
                             [-1 - 1.5*np.sin(tt)*np.cos(tt), -1 + 1.5*np.sin(tt)**2]])
    t = np.linspace(0, 6, 601); X = np.vstack([np.exp(t/2)*np.cos(t), -np.exp(t/2)*np.sin(t)])
    G1, G2 = np.meshgrid(np.linspace(-20, 20, 15), np.linspace(-20, 20, 15)); sq = np.linspace(0, 10, 300)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.28))
    nf = 160; idx = np.linspace(0, len(t) - 1, nf).astype(int)
    def act(k):
        j = idx[k]; Aj = A(t[j])
        U = Aj[0, 0]*G1 + Aj[0, 1]*G2; W = Aj[1, 0]*G1 + Aj[1, 1]*G2; L = np.hypot(U, W) + 1e-12
        a1.cla(); a1.quiver(G1, G2, U/L, W/L, color=C['gris'] if 'gris' in C else '0.6', alpha=0.6)
        Z = np.array([expm(Aj*q) @ X[:, j] for q in sq]).T
        a1.plot(Z[0], Z[1], color=C['azul'], ls='--', lw=1.2, label='congelado desde $x(t)$')
        a1.plot(X[0, :j+1], X[1, :j+1], color=C['coral'], lw=2, label='solución real'); a1.plot(*X[:, j], 'o', color=C['noche'], ms=8)
        a1.set_xlim(-20, 20); a1.set_ylim(-20, 20); a1.set_aspect('equal'); a1.grid(True); a1.legend(loc='lower left', fontsize=8)
        a1.set_title(f'campo congelado $A({t[j]:.1f})$')
        a2.cla(); a2.semilogy(t, np.exp(t/2), color=C['noche'], ls='--', lw=1, label='$e^{t/2}$')
        a2.semilogy(t, np.exp(-t/4), color=C['azul'], ls=':', lw=1.5, label='$e^{-t/4}$ (valores propios)')
        a2.semilogy(t[:j+1], np.exp(t[:j+1]/2), color=C['coral'], lw=2, label=r'$\|x(t)\|$')
        a2.set_xlim(0, 6); a2.set_ylim(0.2, 25); a2.grid(True); a2.legend(loc='upper left', fontsize=8); a2.set_xlabel('$t$')
        a2.set_title('la solución crece aunque $A(t)$ es Hurwitz')
    grabar(fig, act, nf, 'V9_3_markus_yamabe')


def v9_4_cetaev():                  # C9_Video_Cetaev
    f = lambda tt, z: [z[0]**2 + z[1]**3, -z[1] + z[0]**3]
    ev = lambda tt, z: np.hypot(*z) - 0.6; ev.terminal = True
    sols = []
    for x0 in (0.05, 0.02, 0.01, 0.005):
        s = solve_ivp(f, (0, 400), [x0, 0.15*np.sqrt(x0)], events=ev, max_step=0.05, **o); sols.append(s)
    th = np.linspace(0, 2*np.pi, 300); y = np.linspace(-0.5, 0.5, 300); xb = np.sqrt(np.maximum(0.25 - y**2, 0))
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.28))
    nf = 160
    def act(k):
        q = (k + 1)/nf
        a1.cla(); a1.fill(np.r_[y**2/2, xb[::-1]], np.r_[y, y[::-1]], color=C['verde'], alpha=0.25)
        a1.plot(0.5*np.cos(th), 0.5*np.sin(th), color=C['noche'], ls=':')
        a2.cla()
        for c, s in zip(COL, sols):
            n = max(2, int(q*len(s.t)))
            a1.plot(s.y[0, :n], s.y[1, :n], color=c, lw=1.5)
            a2.semilogy(s.t[:n], s.y[0, :n] - s.y[1, :n]**2/2, color=c, lw=1.5, label=f'$x_1(0)={s.y[0, 0]:g}$')
        a1.set_xlim(-0.6, 0.6); a1.set_ylim(-0.6, 0.6); a1.set_aspect('equal'); a1.grid(True)
        a1.set_xlabel('$x_1$'); a1.set_ylabel('$x_2$'); a1.set_title(r'$U=\{x_1>x_2^2/2\}\cap B_{1/2}$')
        a2.set_xlim(0, max(s.t[-1] for s in sols)); a2.set_ylim(1e-3, 1); a2.grid(True); a2.legend(loc='lower right', fontsize=8)
        a2.set_xlabel('$t$'); a2.set_title('$V(x(t))$ solo puede crecer en $U$')
    grabar(fig, act, nf, 'V9_4_cetaev')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
    else:
        for fn in (v9_1_tiempo, v9_2_mathieu, v9_3_markus, v9_4_cetaev): fn()
