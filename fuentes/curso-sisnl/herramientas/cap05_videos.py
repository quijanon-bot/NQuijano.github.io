# Transparencia: escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
"""Videos del capítulo 5 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C5_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap05_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V5_1_kuramoto.mp4, V5_2_indice.mp4, V5_3_vanderpol.mp4
"""
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, FFMpegWriter
from scipy.integrate import solve_ivp
from estilo import C, RAIZ

SAL = os.path.join(RAIZ, 'sitio', 'videos')
os.makedirs(SAL, exist_ok=True)
FPS = 24


def grabar(fig, actualizar, n, nombre):
    an = FuncAnimation(fig, actualizar, frames=n, blit=False)
    w = FFMpegWriter(fps=FPS, codec='libx264', bitrate=1600,
                     extra_args=['-pix_fmt', 'yuv420p', '-preset', 'veryfast', '-crf', '26'])
    ruta = os.path.join(SAL, nombre + '.mp4')
    an.save(ruta, writer=w, dpi=100)
    plt.close(fig)
    print(f'  video: {nombre}.mp4  ({os.path.getsize(ruta)/1e3:.0f} kB)')


def v5_1_kuramoto():                # C5_Video_Kuramoto
    N, gam, K = 60, 0.5, 2.0
    i = np.arange(1, N + 1)
    w = gam*np.tan(np.pi*(i - 0.5)/N - np.pi/2)          # cuantiles de Lorentz
    th0 = 2*np.pi*np.mod(i*0.6180339887, 1)
    def f(t, th):
        z = np.mean(np.exp(1j*th))
        return w + K*abs(z)*np.sin(np.angle(z) - th)
    t = np.linspace(0, 40, 401)
    TH = solve_ivp(f, (0, 40), th0, t_eval=t, rtol=1e-8, atol=1e-10).y.T
    z = np.mean(np.exp(1j*TH), axis=1)
    rteo = np.sqrt(1 - 2*gam/K)
    s = np.linspace(0, 2*np.pi, 200)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.8), gridspec_kw=dict(wspace=0.25))
    a1.plot(np.cos(s), np.sin(s), color=C['claro'], lw=2)
    pts = a1.scatter(np.cos(th0), np.sin(th0), s=40, c=np.clip(w, -2, 2), cmap='coolwarm', vmin=-2, vmax=2, zorder=3)
    fl, = a1.plot([0, 0], [0, 0], color=C['noche'], lw=3)
    a1.set_xlim(-1.2, 1.2); a1.set_ylim(-1.4, 1.2); a1.set_aspect('equal'); a1.axis('off')
    a1.set_title(rf'$K={K:g}$, $K_c={2*gam:g}$ (color: frecuencia natural)')
    tx = a1.text(0, -1.3, '', ha='center', fontsize=11, color=C['noche'])
    a2.plot([0, 40], [rteo, rteo], '--', color=C['noche'], lw=1.2, label=r'$\sqrt{1-K_c/K}$')
    lr, = a2.plot([], [], color=C['coral'], lw=2.2, label=r'$r(t)$, $N=60$')
    a2.set_xlim(0, 40); a2.set_ylim(0, 1); a2.grid(True); a2.set_xlabel('$t$'); a2.legend(loc='lower right')
    a2.set_title('Parámetro de orden')
    def act(k):
        pts.set_offsets(np.c_[np.cos(TH[k]), np.sin(TH[k])])
        fl.set_data([0, z[k].real], [0, z[k].imag])
        lr.set_data(t[:k+1], abs(z[:k+1]))
        tx.set_text(f'$t={t[k]:.1f}$')
    grabar(fig, act, len(t), 'V5_1_kuramoto')


def v5_2_indice():                  # C5_Video_Indice
    casos = [(r'nodo: $I=+1$', lambda x: -x, (0, 0), 1),
             (r'silla: $I=-1$', lambda x: np.array([x[0], -x[1]]), (0, 0), 1),
             (r'$z^2$: $I=+2$', lambda x: np.array([x[0]**2 - x[1]**2, 2*x[0]*x[1]]), (0, 0), 1),
             (r'silla y foco: $I=0$', lambda x: np.array([-x[0] + x[0]*x[1], x[0] + x[1] - 2*x[0]*x[1]]), (0.5, 0.5), 2)]
    npos, pausa = 91, 24
    s = np.linspace(0, 2*np.pi, 300)
    cuadros = [(c, j) for c in range(len(casos)) for j in range(npos + pausa)]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.8), gridspec_kw=dict(wspace=0.25))
    estado = dict(c=-1, prev=None, vueltas=0.0)
    def act(k):
        c, j = cuadros[k]; tit, f, x0, R = casos[c]
        if c != estado['c']:
            estado.update(c=c, prev=None, vueltas=0.0)
            a1.cla(); a1.plot(x0[0] + R*np.cos(s), x0[1] + R*np.sin(s), color=C['noche'], lw=1.2)
            if c == 3:
                a1.plot([0, 1], [0, 1], 'o', color=C['noche'], ms=6)
            else:
                a1.plot(0, 0, 'o', color=C['noche'], ms=6)
            a1.set_aspect('equal'); a1.grid(True); a1.set_title(tit)
            m = 1.45*R; a1.set_xlim(x0[0] - m, x0[0] + m); a1.set_ylim(x0[1] - m, x0[1] + m)
        jj = min(j, npos - 1)
        th = 2*np.pi*jj/(npos - 1)
        x = np.array(x0) + R*np.array([np.cos(th), np.sin(th)]); v = f(x); u = v/np.linalg.norm(v)
        if j < npos:
            a = np.arctan2(v[1], v[0])
            if estado['prev'] is not None:
                estado['vueltas'] += (np.mod(a - estado['prev'] + np.pi, 2*np.pi) - np.pi)/(2*np.pi)
            estado['prev'] = a
            a1.quiver(x[0], x[1], 0.35*R*u[0], 0.35*R*u[1], angles='xy', scale_units='xy', scale=1,
                      color=C['azul'], width=0.006)
        a2.cla(); a2.plot(np.cos(s), np.sin(s), color=C['claro'], lw=1.5)
        a2.quiver(0, 0, u[0], u[1], angles='xy', scale_units='xy', scale=1, color=C['coral'], width=0.02)
        a2.text(-1.15, -1.12, f'vueltas = {estado["vueltas"]:+.2f}', fontsize=13, color=C['noche'])
        a2.set_xlim(-1.25, 1.25); a2.set_ylim(-1.25, 1.25); a2.set_aspect('equal'); a2.grid(True)
        a2.set_title(r'$f(x)/\|f(x)\|$ desde el origen')
    grabar(fig, act, len(cuadros), 'V5_2_indice')


def v5_3_vanderpol():               # C5_Video_VanDerPol
    mu = 1.0
    f = lambda t, x: [x[1], -x[0] - mu*(x[0]**2 - 1)*x[1]]
    X0 = [(0.05, 0), (-0.05, 0), (0, 0.1), (3.5, 3), (-3.5, -3), (0, 4), (0, -4), (4, 0)]
    t = np.linspace(0, 25, 376)
    Xs = [solve_ivp(f, (0, 25), x0, t_eval=t, rtol=1e-9, atol=1e-11).y for x0 in X0]
    cols = [C['azul'], C['violeta'], C['teal'], C['coral'], C['ambar'], C['verde'], C['gris'], C['noche']]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.8), gridspec_kw=dict(wspace=0.25))
    ls = [a1.plot([], [], color=cl, lw=1.6)[0] for cl in cols]
    ps = [a1.plot([], [], 'o', color=cl, ms=5)[0] for cl in cols]
    a1.set_xlim(-4.5, 4.5); a1.set_ylim(-4.5, 4.5); a1.set_aspect('equal'); a1.grid(True)
    a1.set_xlabel('$x$'); a1.set_ylabel(r'$\dot x$'); a1.set_title(r'van der Pol, $\mu=1$')
    l1, = a2.plot([], [], color=cols[0], lw=2, label='desde $(0.05,0)$')
    l2, = a2.plot([], [], color=cols[7], lw=2, label='desde $(4,0)$')
    a2.set_xlim(0, 25); a2.set_ylim(-4.5, 4.5); a2.grid(True); a2.set_xlabel('$t$'); a2.legend(loc='upper right')
    a2.set_title('$x(t)$: la misma amplitud ($\\approx 2$)')
    def act(k):
        for X, l, p in zip(Xs, ls, ps):
            l.set_data(X[0][:k+1], X[1][:k+1]); p.set_data([X[0][k]], [X[1][k]])
        l1.set_data(t[:k+1], Xs[0][0][:k+1]); l2.set_data(t[:k+1], Xs[7][0][:k+1])
    grabar(fig, act, len(t), 'V5_3_vanderpol')


if __name__ == '__main__':
    import sys
    fns = dict(v5_1_kuramoto=v5_1_kuramoto, v5_2_indice=v5_2_indice, v5_3_vanderpol=v5_3_vanderpol)
    for nombre in (sys.argv[1:] or fns):
        fns[nombre]()
