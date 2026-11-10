"""Videos de las partes 1 y 2 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C1_Video_* y C2_Video_* (mismos modelos y
parámetros); los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap01_02_videos.py      (requiere ffmpeg)
Salida:    sitio/videos/V1_1_lorenz.mp4, V1_2_logistica.mp4, V2_1_linea_fase.mp4, V2_2_histeresis.mp4
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


def v1_1_lorenz():
    lor = lambda t, x: [10*(x[1] - x[0]), x[0]*(28 - x[2]) - x[1], x[0]*x[1] - 8/3*x[2]]
    t = np.linspace(0, 40, 4001)
    A = solve_ivp(lor, (0, 40), [1, 1, 1], t_eval=t, rtol=1e-12, atol=1e-12).y
    B = solve_ivp(lor, (0, 40), [1 + 1e-9, 1, 1], t_eval=t, rtol=1e-12, atol=1e-12).y
    d = np.linalg.norm(A - B, axis=0) + 1e-16
    fig = plt.figure(figsize=(9.6, 5.4))
    a1 = fig.add_axes([0.06, 0.38, 0.9, 0.56]); a2 = fig.add_axes([0.06, 0.08, 0.9, 0.22])
    a1.set_xlim(-22, 22); a1.set_ylim(0, 50); a1.set_xlabel('$x$'); a1.set_ylabel('$z$')
    la, = a1.plot([], [], color=C['azul'], lw=2.8); lb, = a1.plot([], [], color=C['coral'], lw=1.1)
    pa, = a1.plot([], [], 'o', color=C['azul'], ms=8); pb, = a1.plot([], [], 'o', color=C['coral'], ms=8)
    tit = a1.set_title('')
    a2.set_xlim(0, 40); a2.set_ylim(1e-10, 1e2); a2.set_yscale('log'); a2.grid(True)
    a2.set_xlabel('$t$'); a2.set_ylabel(r'$\|\Delta x\|$'); ld, = a2.plot([], [], color=C['violeta'])

    def act(j):
        k = 5*j; i0 = max(0, k - 600)
        la.set_data(A[0, i0:k+1], A[2, i0:k+1]); lb.set_data(B[0, i0:k+1], B[2, i0:k+1])
        pa.set_data([A[0, k]], [A[2, k]]); pb.set_data([B[0, k]], [B[2, k]])
        ld.set_data(t[:k+1], d[:k+1])
        tit.set_text(rf'Lorenz: dos condiciones iniciales a $10^{{-9}}$  ·  $t={t[k]:.1f}$')
    grabar(fig, act, len(t)//5, 'V1_1_lorenz')


def v1_2_logistica():
    K = 32; Rs = np.linspace(1.6, 3.95, 300); P = np.linspace(0, K, 300)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.6), gridspec_kw=dict(wspace=0.25))
    a2.set_xlim(1.6, 4); a2.set_ylim(0, K); a2.set_xlabel('$R$'); a2.set_ylabel('valores visitados'); a2.grid(True)
    a2.set_title('diagrama de bifurcación')

    def act(k):
        R = Rs[k]; F = lambda p: R*p*(1 - p/K)
        a1.cla(); a1.plot(P, F(P), color=C['azul']); a1.plot([0, K], [0, K], color=C['gris'], lw=1)
        q = 1.0; xs, ys = [q], [0]
        for i in range(40):
            xs += [q, F(q)]; ys += [F(q), F(q)]; q = F(q)
        a1.plot(xs, ys, color=C['coral'], lw=1); a1.set_xlim(0, K); a1.set_ylim(0, K); a1.grid(True)
        a1.set_xlabel('$P[k]$'); a1.set_ylabel('$P[k+1]$'); a1.set_title(f'telaraña, $R={R:.3f}$')
        p = 1.0
        for i in range(600):
            p = F(p)
        orb = []
        for i in range(60):
            p = F(p); orb.append(p)
        a2.plot([R]*60, orb, ',', color=C['noche'])
    grabar(fig, act, len(Rs), 'V1_2_logistica')


def v2_1_linea_fase():
    t = np.linspace(0, 6, 289); x0 = [-5.8, -2.0, 0.3, 2.6, 4.0]
    X = np.array([solve_ivp(lambda s, y: np.sin(y), (0, 6), [a], t_eval=t, rtol=1e-10).y[0] for a in x0])
    cols = [C['azul'], C['coral'], C['violeta'], C['ambar'], C['verde']]
    fig, (a1, a2) = plt.subplots(2, 1, figsize=(9.6, 5.4), gridspec_kw=dict(hspace=0.45))
    s = np.linspace(-2*np.pi, 2*np.pi, 600)
    a1.plot(s, np.sin(s), color=C['azul']); a1.axhline(0, color=C['noche'], lw=0.8)
    for k in range(-2, 3):
        a1.plot(k*np.pi, 0, 'o', mfc=C['noche'] if k % 2 else 'white', mec=C['noche'], ms=8)
    a1.set_xlim(-2*np.pi, 2*np.pi); a1.set_ylabel(r'$\dot x=\sin x$'); a1.grid(True)
    pts = [a1.plot([], [], 'o', color=c, ms=11)[0] for c in cols]
    a2.set_xlim(0, 6); a2.set_ylim(-2*np.pi, 2*np.pi); a2.grid(True); a2.set_xlabel('$t$'); a2.set_ylabel('$x(t)$')
    for k in range(-2, 3):
        a2.axhline(k*np.pi, color=C['gris'], ls='--', lw=0.8)
    ls = [a2.plot([], [], color=c)[0] for c in cols]
    tit = a1.set_title('')

    def act(k):
        for i in range(5):
            pts[i].set_data([X[i, k]], [0]); ls[i].set_data(t[:k+1], X[i, :k+1])
        tit.set_text(f'partículas sobre la recta: velocidad = sin x  ·  $t={t[k]:.1f}$')
    grabar(fig, act, len(t), 'V2_1_linea_fase')


def v2_2_histeresis():
    h = lambda v: 17.76*v - 103.79*v**2 + 229.62*v**3 - 226.31*v**4 + 83.72*v**5
    R, Cp, Tm, Em = 1.5, 2.0, 4000.0, 1.8
    E = lambda t: Em*min(t, 2*Tm - t)/Tm
    s = solve_ivp(lambda t, v: ((E(t) - v)/R - h(v))/Cp, (0, 2*Tm), [0.0], max_step=0.5, rtol=1e-9, atol=1e-11, dense_output=True)
    t = np.linspace(0, 2*Tm, 337); v = s.sol(t)[0]; Et = np.array([E(x) for x in t])
    vv = np.linspace(-0.05, 1.2, 600)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.6), gridspec_kw=dict(wspace=0.28))
    a2.plot(vv + R*h(vv), vv, color=C['claro'], lw=5); a2.set_xlim(0, 1.8); a2.set_ylim(-0.05, 1.2); a2.grid(True)
    a2.set_xlabel('$E$ [V]'); a2.set_ylabel('$v$ [V]'); a2.set_title('estado sobre la curva de equilibrios')
    lr, = a2.plot([], [], color=C['coral']); pr, = a2.plot([], [], 'o', color=C['coral'], ms=9)

    def act(k):
        a1.cla(); Ek = Et[k]; f = ((Ek - vv)/R - h(vv))/Cp
        a1.plot(vv, f, color=C['azul']); a1.axhline(0, color=C['noche'], lw=0.8)
        a1.plot(v[k], 0, 'o', color=C['coral'], ms=11); a1.set_ylim(-0.6, 0.9); a1.set_xlim(-0.05, 1.2); a1.grid(True)
        a1.set_xlabel('$v$ [V]'); a1.set_ylabel(r'$\dot v$ [V/ns]'); a1.set_title(f'$E={Ek:.2f}$ V ({"sube" if t[k] < Tm else "baja"})')
        lr.set_data(Et[:k+1], v[:k+1]); pr.set_data([Ek], [v[k]])
    grabar(fig, act, len(t), 'V2_2_histeresis')


if __name__ == '__main__':
    import sys
    pedidos = sys.argv[1:] or ['v1_1_lorenz', 'v1_2_logistica', 'v2_1_linea_fase', 'v2_2_histeresis']
    for nombre in pedidos:
        globals()[nombre]()
