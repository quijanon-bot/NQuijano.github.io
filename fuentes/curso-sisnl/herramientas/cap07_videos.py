"""Videos de la parte 7 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C7_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap07_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V7_1_formas_cuadraticas.mp4, V7_2_termino_cruzado.mp4,
           V7_3_circulos_elipses.mp4, V7_4_region_atraccion.mp4
"""
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, FFMpegWriter
from scipy.integrate import solve_ivp
from scipy.linalg import expm, solve_continuous_lyapunov
from estilo import C, RAIZ

SAL = os.path.join(RAIZ, 'sitio', 'videos')
os.makedirs(SAL, exist_ok=True)
FPS = 24
o = dict(rtol=1e-10, atol=1e-12)


def grabar(fig, actualizar, n, nombre):
    an = FuncAnimation(fig, actualizar, frames=n, blit=False)
    w = FFMpegWriter(fps=FPS, codec='libx264', bitrate=1600,
                     extra_args=['-pix_fmt', 'yuv420p', '-preset', 'veryfast', '-crf', '26'])
    ruta = os.path.join(SAL, nombre + '.mp4')
    an.save(ruta, writer=w, dpi=100)
    plt.close(fig)
    print(f'  video: {nombre}.mp4  ({os.path.getsize(ruta)/1e3:.0f} kB)')


def v7_1_formas():                 # C7_Video_FormasCuadraticas
    th = np.pi/6; R = np.array([[np.cos(th), -np.sin(th)], [np.sin(th), np.cos(th)]])
    lam2 = np.concatenate([np.linspace(1.5, 0, 96), np.zeros(30), np.linspace(0, -1.5, 96)])
    X1, X2 = np.meshgrid(np.linspace(-2, 2, 201), np.linspace(-2, 2, 201))
    fig = plt.figure(figsize=(9.6, 5.4))
    a1 = fig.add_subplot(1, 2, 1, projection='3d'); a2 = fig.add_subplot(1, 2, 2)

    def act(k):
        P = R@np.diag([2, lam2[k]])@R.T; V = P[0, 0]*X1**2 + 2*P[0, 1]*X1*X2 + P[1, 1]*X2**2
        a1.cla(); a1.plot_surface(X1, X2, V, cmap='viridis', rstride=8, cstride=8, linewidth=0, alpha=0.9)
        a1.set_zlim(-6, 10); a1.view_init(30, -35); a1.set_title('$V(x)=x^{\\top}Px$')
        a2.cla(); a2.contour(X1, X2, V, levels=[0.25, 0.5, 1, 2, 3], colors=C['azul'])
        if lam2[k] < -1e-9:
            a2.contour(X1, X2, V, levels=[-3, -2, -1, -0.5, -0.25], colors=C['coral'])
        a2.set_aspect('equal'); a2.grid(True); a2.set_xlabel('$x_1$'); a2.set_ylabel('$x_2$')
        a2.set_title(rf'$\lambda_2={lam2[k]:.2f}$:  $\Delta_1={P[0,0]:.2f}$,  $\Delta_2={np.linalg.det(P):.2f}$')
    grabar(fig, act, len(lam2), 'V7_1_formas_cuadraticas')


def v7_2_cruzado():                # C7_Video_TerminoCruzado
    a, b = 1.0, 0.5
    X1, X2 = np.meshgrid(np.linspace(-4.5, 8, 400), np.linspace(-3.6, 3.6, 260))
    Vf = lambda q: 0.5*(b*q*X1**2 + 2*q*X1*X2 + X2**2) + a*(1 - np.cos(X1))
    cst = lambda q: 2*a + np.pi**2/2*q*(b - q)
    enD = lambda Z: np.where(np.abs(X1) <= np.pi, Z, np.nan)
    s = solve_ivp(lambda t, x: [x[1], -a*np.sin(x[0]) - b*x[1]], (0, 30), [1.5, 3], t_eval=np.linspace(0, 30, 120), **o)
    q = np.concatenate([np.linspace(0, 0.95*b, 120), np.full(120, b/2)])
    fig, ax = plt.subplots(figsize=(9.6, 5.4))

    def act(k):
        ax.cla(); ax.axvspan(-np.pi, np.pi, color=C['fondo'])
        ax.contour(X1, X2, enD(Vf(q[k])), levels=[0.5, 1, 1.5], colors=C['claro'])
        ax.contour(X1, X2, enD(Vf(q[k])), levels=[cst(q[k]) - 0.01], colors=C['verde'], linewidths=3)
        if k >= 120:
            j = k - 119; ax.plot(s.y[0, :j], s.y[1, :j], color=C['coral'], lw=2.5); ax.plot(s.y[0, j-1], s.y[1, j-1], 'o', color=C['coral'], ms=9)
        ax.set_xlim(-4.5, 8); ax.set_ylim(-3.6, 3.6); ax.grid(True); ax.set_xlabel('$x_1$'); ax.set_ylabel('$x_2$')
        ax.set_title(rf'$p_{{12}}={q[k]:.3f}$:  $c^*={cst(q[k]):.3f}$' + ('   ·   arranca en $D$, sale de $D$' if k >= 120 else ''))
    grabar(fig, act, len(q), 'V7_2_termino_cruzado')


def v7_3_circulos():               # C7_Video_CirculosElipses
    A = np.array([[-1, 10], [0, -2]]); P = solve_continuous_lyapunov(A.T, -np.eye(2))
    t = np.linspace(0, 5, 160); X = np.array([expm(A*ti)@np.array([0, 1]) for ti in t])
    nx = np.linalg.norm(X, axis=1); Vx = np.einsum('ij,jk,ik->i', X, P, X)
    ang = np.linspace(0, 2*np.pi, 300); U = np.vstack([np.cos(ang), np.sin(ang)]); L = np.linalg.cholesky(P).T
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 5.0), gridspec_kw=dict(wspace=0.25))

    def act(k):
        a1.cla(); a1.plot(nx[k]*U[0], nx[k]*U[1], color=C['coral'])
        E = np.linalg.solve(L, np.sqrt(Vx[k])*U); a1.plot(E[0], E[1], color=C['verde'], lw=2.5)
        a1.plot(X[:k+1, 0], X[:k+1, 1], color=C['azul']); a1.plot(X[k, 0], X[k, 1], 'o', color=C['noche'])
        a1.set_aspect('equal'); a1.set_xlim(-3.2, 3.2); a1.set_ylim(-3.2, 3.2); a1.grid(True)
        a1.set_title('círculo por $x(t)$ (rojo) y elipse de $P$ (verde)')
        a2.cla(); a2.plot(t[:k+1], nx[:k+1], color=C['coral'], label=r'$\|x(t)\|$')
        a2.plot(t[:k+1], np.sqrt(Vx[:k+1]/Vx[0]), color=C['verde'], label=r'$\sqrt{V/V_0}$')
        a2.set_xlim(0, 5); a2.set_ylim(0, 2.8); a2.grid(True); a2.legend(loc='upper right'); a2.set_xlabel('$t$')
        a2.set_title('la norma crece; $V$ no')
    grabar(fig, act, len(t), 'V7_3_circulos_elipses')


def v7_4_region():                 # C7_Video_RegionAtraccion
    P = np.array([[1.5, -0.5], [-0.5, 1]]); cst = 2.30448; L = np.linalg.cholesky(P).T
    fv = lambda t, z: [-z[1], z[0] + (z[0]**2 - 1)*z[1]]
    cic = solve_ivp(lambda t, z: [-v for v in fv(t, z)], (0, 30), [2, 0], max_step=0.01, **o).y[:, 1500:]
    X1, X2 = np.meshgrid(np.linspace(-3, 3, 300), np.linspace(-3, 3, 300))
    V = 1.5*X1**2 - X1*X2 + X2**2; W = -X1**2 - X2**2 - X1**3*X2 + 2*X1**2*X2**2
    cs = np.concatenate([np.linspace(0.05, cst, 110), np.full(90, cst)])
    angs = np.linspace(0, 2*np.pi, 9)[:-1]
    Ys = [solve_ivp(fv, (0, 12), 0.99*np.sqrt(cst)*np.linalg.solve(L, [np.cos(t_), np.sin(t_)]), t_eval=np.linspace(0, 12, 90), **o).y for t_ in angs]
    fig, ax = plt.subplots(figsize=(7.2, 6.4))

    def act(k):
        ax.cla(); ax.plot(cic[0], cic[1], color=C['noche'], lw=1.5)
        ax.contour(X1, X2, W, levels=[0], colors=C['coral'])
        ax.contour(X1, X2, V, levels=[cs[k]], colors=C['verde'], linewidths=3)
        if k >= 110:
            for Y in Ys: ax.plot(Y[0, :k-109], Y[1, :k-109], color=C['azul'], lw=1.2)
        ax.set_aspect('equal'); ax.set_xlim(-3, 3); ax.set_ylim(-3, 3); ax.grid(True)
        ax.set_xlabel('$x_1$'); ax.set_ylabel('$x_2$'); ax.set_title(rf'$\Omega_c=\{{x^{{\top}}Px\leq c\}}$,  $c={cs[k]:.2f}$')
    grabar(fig, act, len(cs), 'V7_4_region_atraccion')


if __name__ == '__main__':
    import sys
    fns = [v7_1_formas, v7_2_cruzado, v7_3_circulos, v7_4_region]
    for fn in (fns if len(sys.argv) == 1 else [globals()[n] for n in sys.argv[1:]]):
        fn()
