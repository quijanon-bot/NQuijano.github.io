"""Videos de la parte 4 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C4_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap04_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V4_1_traza_determinante.mp4, V4_2_cuencas_duffing.mp4,
           V4_3_variedad_central.mp4
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
o = dict(rtol=1e-9, atol=1e-11)


def grabar(fig, actualizar, n, nombre):
    an = FuncAnimation(fig, actualizar, frames=n, blit=False)
    w = FFMpegWriter(fps=FPS, codec='libx264', bitrate=1600,
                     extra_args=['-pix_fmt', 'yuv420p', '-preset', 'veryfast', '-crf', '26'])
    ruta = os.path.join(SAL, nombre + '.mp4')
    an.save(ruta, writer=w, dpi=100)
    plt.close(fig)
    print(f'  video: {nombre}.mp4  ({os.path.getsize(ruta)/1e3:.0f} kB)')


def tipo(tau, de):
    if abs(de) < 1e-9: return 'det = 0: no aislado'
    if de < 0: return 'silla'
    if abs(tau) < 1e-9: return 'centro'
    est = 'estable' if tau < 0 else 'inestable'
    return ('foco ' if tau**2 < 4*de else 'nodo ') + est


def v4_1_traza_det():               # C4_Video_TrazaDeterminante
    # recorrido: (tau, delta) a lo largo de un camino que cruza todas las fronteras
    puntos = np.array([[-3, -1.5], [-3, 1.2], [-3, 3.5], [-1, 3.5], [0, 3.5], [1, 3.5], [3, 3.5], [3, 1.2], [3, -1.5], [-3, -1.5]])
    camino = np.vstack([np.linspace(puntos[k], puntos[k+1], 36, endpoint=False) for k in range(len(puntos) - 1)])
    th = np.linspace(0, 2*np.pi, 16, endpoint=False)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.8), gridspec_kw=dict(wspace=0.3))
    def matriz(tau, de):  # A = [[tau/2, 1], [de' , tau/2]] con det = tau^2/4 - de' = de
        return np.array([[tau/2, 1.0], [tau**2/4 - de, tau/2]])
    def act(k):
        tau, de = camino[k]; A = matriz(tau, de)
        a1.cla(); tt = np.linspace(-4, 4, 200)
        a1.plot(tt, tt**2/4, color=C['noche']); a1.axhline(0, color=C['noche']); a1.plot([0, 0], [0, 5], color=C['verde'], lw=2)
        a1.plot(camino[:k+1, 0], camino[:k+1, 1], color=C['gris'], lw=1)
        a1.plot(tau, de, 'o', color=C['coral'], ms=9)
        a1.set_xlim(-4, 4); a1.set_ylim(-2.5, 5); a1.set_xlabel(r'$\tau$'); a1.set_ylabel(r'$\delta$')
        a1.set_title(rf'$\tau={tau:.2f}$, $\delta={de:.2f}$: {tipo(tau, de)}')
        a2.cla()
        X, Y = np.meshgrid(np.linspace(-1, 1, 15), np.linspace(-1, 1, 15))
        U = A[0, 0]*X + A[0, 1]*Y; V = A[1, 0]*X + A[1, 1]*Y; N = np.hypot(U, V) + 1e-12
        a2.quiver(X, Y, U/N, V/N, color=C['claro'], scale=26, width=0.004)
        for a in th:
            x0 = 0.95*np.array([np.cos(a), np.sin(a)])
            for s in [1, -1]:
                r = solve_ivp(lambda t, x: s*(A@x), (0, 8), x0, max_step=0.05,
                              events=lambda t, x: max(abs(x)) - 1.05, **o)
                a2.plot(r.y[0], r.y[1], color=C['azul'], lw=1)
        a2.plot(0, 0, 'o', color=C['noche'] if tau < 0 and de > 0 else 'w', mec=C['noche'], ms=7)
        a2.set_xlim(-1, 1); a2.set_ylim(-1, 1); a2.set_aspect('equal'); a2.set_title('Retrato de $\\dot x=Ax$')
    grabar(fig, act, len(camino), 'V4_1_traza_determinante')


def v4_2_cuencas():                 # C4_Video_CuencasDuffing
    d = 0.5; L = 3.0
    F = lambda t, x: [x[1], x[0] - x[0]**3 - d*x[1]]
    J = np.array([[0, 1], [1, -d]]); lam, V = np.linalg.eig(J)
    vs = V[:, np.argmin(lam)]; vu = V[:, np.argmax(lam)]
    ramas_s = []; ramas_u = []
    for sg in [1, -1]:
        r = solve_ivp(lambda t, x: [-v for v in F(t, x)], (0, 40), 1e-6*sg*vs, max_step=0.01,
                      events=lambda t, x: max(abs(x)) - L*1.02, **o); ramas_s.append(r)
        r = solve_ivp(F, (0, 30), 1e-6*sg*vu, max_step=0.01, **o); ramas_u.append(r)
    from cap04_figuras import cuencas
    X1, X2, S = cuencas(d, 201, L)
    n = 150
    fig, ax = plt.subplots(figsize=(6.4, 6.0))
    def act(k):
        ax.cla(); f = (k + 1)/n
        if k > n*0.6:
            ax.contourf(X1, X2, S, levels=[-2, 0, 2], colors=[C['coral'], C['azul']], alpha=0.22*min(1, (k - 0.6*n)/(0.2*n)))
        for r in ramas_s:
            m = r.t <= f*r.t[-1]; ax.plot(r.y[0][m], r.y[1][m], color=C['noche'], lw=2)
        for r in ramas_u:
            m = r.t <= f*r.t[-1]; ax.plot(r.y[0][m], r.y[1][m], color=C['verde'], lw=1.8)
        for p, e in [((0, 0), False), ((1, 0), True), ((-1, 0), True)]:
            ax.plot(*p, 'o', color=C['noche'] if e else 'w', mec=C['noche'], ms=7)
        ax.set_xlim(-L, L); ax.set_ylim(-L, L); ax.set_aspect('equal'); ax.set_xlabel('$x_1$'); ax.set_ylabel('$x_2$')
        ax.set_title(r'Duffing, $\delta=0.5$: $W^s$ (negro) y $W^u$ (verde) de la silla')
    grabar(fig, act, n, 'V4_2_cuencas_duffing')


def v4_3_central():                 # C4_Video_VariedadCentral
    a = -1.0
    F = lambda t, x: [x[0]*x[1], -x[1] + a*x[0]**2]
    ics = [(y0, z0) for y0 in [-0.8, -0.5, -0.3, 0.3, 0.5, 0.8] for z0 in [-0.7, 0.7]]
    T = 30; tt = np.concatenate([np.linspace(0, 3, 72), np.linspace(3, T, 96)[1:]])
    sols = [solve_ivp(F, (0, T), x0, t_eval=tt, **o) for x0 in ics]
    ys = np.linspace(-0.62, 0.62, 200)
    fig, ax = plt.subplots(figsize=(9.6, 5.4))
    def act(k):
        ax.cla()
        ax.plot(ys, a*ys**2 - 2*a**2*ys**4, color=C['verde'], lw=3, label=r'variedad central $z\approx ay^2-2a^2y^4$')
        ax.axhline(0, color=C['gris'], ls=':', label='$E^c$: $z=0$')
        for s in sols:
            ax.plot(s.y[0][:k+1], s.y[1][:k+1], color=C['azul'], lw=1.2); ax.plot(s.y[0][k], s.y[1][k], 'o', color=C['coral'], ms=4)
        ax.plot(0, 0, 'o', color=C['noche'], ms=7)
        ax.set_xlim(-1, 1); ax.set_ylim(-0.8, 0.8); ax.set_xlabel('$y$'); ax.set_ylabel('$z$'); ax.legend(loc='upper right', fontsize=9)
        ax.set_title(rf'$\dot y=yz,\ \dot z=-z+ay^2$, $a={a:g}$:  $t={tt[k]:.1f}$')
    grabar(fig, act, len(tt), 'V4_3_variedad_central')


if __name__ == '__main__':
    import sys
    fns = dict(v4_1_traza_det=v4_1_traza_det, v4_2_cuencas=v4_2_cuencas, v4_3_central=v4_3_central)
    for nombre in (sys.argv[1:] or fns):
        fns[nombre]()
