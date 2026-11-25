# Transparencia: escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
"""Videos de la parte 8 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C8_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap08_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V8_1_pendulo_lasalle.mp4, V8_2_ciclo_sombrero.mp4,
           V8_3_gradiente_barrido.mp4, V8_4_zubov_vdp.mp4
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from estilo import C
from cap04_videos import grabar
from cap08_figuras import zubov_malla, _cstarG

o = dict(rtol=1e-9, atol=1e-11)


def v8_1_pendulo():                 # C8_Video_PenduloLaSalle
    a, b, c = 1.0, 0.3, 1.8; xE = np.arccos(1 - c/a)
    t = np.linspace(0, 25, 2501)
    s = solve_ivp(lambda tt, z: [z[1], -a*np.sin(z[0]) - b*z[1]], (0, 25), [2, 0.8], t_eval=t, **o)
    V = a*(1 - np.cos(s.y[0])) + s.y[1]**2/2; Vd = -b*s.y[1]**2
    X, Y = np.meshgrid(np.linspace(-3.2, 3.2, 300), np.linspace(-2.2, 2.2, 200)); VV = a*(1 - np.cos(X)) + Y**2/2
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.28))
    nf = 180; idx = np.linspace(0, len(t) - 1, nf).astype(int)
    def act(k):
        j = idx[k]; enE = abs(s.y[1, j]) < 0.04
        a1.cla(); a1.contourf(X, Y, (VV <= c) & (np.abs(X) < np.pi), levels=[0.5, 1.5], colors=[C['azul']], alpha=0.18)
        a1.plot([-xE, xE], [0, 0], color=C['coral'], lw=4, solid_capstyle='butt')
        a1.plot(s.y[0, :j+1], s.y[1, :j+1], color=C['noche'], lw=1)
        a1.plot(*s.y[:, j], 'o', ms=10, color=C['coral'] if enE else C['verde'])
        a1.set_xlim(-3.2, 3.2); a1.set_ylim(-2.2, 2.2); a1.grid(True); a1.set_xlabel('$x_1$'); a1.set_ylabel('$x_2$')
        a1.set_title(r'$\Omega_c$ (azul) y $E$ (coral)' + ('   ¡en $E$!' if enE else ''))
        a2.cla(); a2.plot(t[:j+1], V[:j+1], color=C['azul'], label='$V$'); a2.plot(t[:j+1], Vd[:j+1], color=C['coral'], label=r'$\dot V$')
        a2.set_xlim(0, 25); a2.set_ylim(-0.7, 2); a2.grid(True); a2.legend(loc='upper right'); a2.set_xlabel('$t$')
        a2.set_title(r'en $E$: $\dot V=0$, pero $V$ no se detiene')
    grabar(fig, act, nf, 'V8_1_pendulo_lasalle')


def v8_2_ciclo():                   # C8_Video_CicloSombrero
    f = lambda tt, z: [z[0]*(1 - z[0]**2 - z[1]**2) - z[1], z[1]*(1 - z[0]**2 - z[1]**2) + z[0]]
    t = np.linspace(0, 12, 1201)
    A = solve_ivp(f, (0, 12), [1.3, 0.3], t_eval=t, **o).y; B = solve_ivp(f, (0, 12), [0, -0.4], t_eval=t, **o).y
    rA, rB = np.hypot(*A), np.hypot(*B); Vr = lambda r: (r**2 - 1)**2/4
    th = np.linspace(0, 2*np.pi, 300); r1, r2 = np.sqrt(1 - 2*np.sqrt(0.2)), np.sqrt(1 + 2*np.sqrt(0.2)); rr = np.linspace(0, 1.6, 300)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.28))
    nf = 160; idx = np.linspace(0, len(t) - 1, nf).astype(int)
    def act(k):
        j = idx[k]
        a1.cla(); a1.fill(np.r_[r2*np.cos(th), r1*np.cos(th[::-1])], np.r_[r2*np.sin(th), r1*np.sin(th[::-1])], color=C['azul'], alpha=0.15)
        a1.plot(np.cos(th), np.sin(th), color=C['coral'], lw=2.4)
        a1.plot(A[0, :j+1], A[1, :j+1], color=C['noche'], lw=1); a1.plot(B[0, :j+1], B[1, :j+1], color=C['violeta'], lw=1)
        a1.plot(*A[:, j], 'o', color=C['noche'], ms=9); a1.plot(*B[:, j], 's', color=C['violeta'], ms=9)
        a1.set_xlim(-1.6, 1.6); a1.set_ylim(-1.6, 1.6); a1.set_aspect('equal'); a1.grid(True); a1.set_title(r'anillo $\Omega_{0.2}$ y $E=M$')
        a2.cla(); a2.plot(rr, Vr(rr), color=C['noche']); a2.axvspan(r1, r2, color=C['azul'], alpha=0.12)
        a2.plot(rA[j], Vr(rA[j]), 'o', color=C['noche'], ms=10); a2.plot(rB[j], Vr(rB[j]), 's', color=C['violeta'], ms=10)
        a2.set_xlim(0, 1.6); a2.set_ylim(0, 0.6); a2.grid(True); a2.set_xlabel('$r$'); a2.set_ylabel('$V$')
        a2.set_title(r'$V(0)=1/4$ es un máximo; el fondo es el ciclo')
    grabar(fig, act, nf, 'V8_2_ciclo_sombrero')


def v8_3_barrido():                 # C8_Video_GradienteBarrido
    X, Y = np.meshgrid(np.linspace(-7, 7, 351), np.linspace(-7, 7, 351))
    Xs, Ys = np.meshgrid(np.linspace(-12, 12, 601), np.linspace(-12, 12, 601))
    aa = np.r_[np.linspace(1.1, 4, 90), np.linspace(4, 1.48, 40)]
    cs = np.array([_cstarG(a, Xs, Ys)[2] for a in aa]); area = np.pi*cs/np.sqrt(aa/4 - 1/4)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.28))
    def act(k):
        a = aa[k]; VV, Vd, _ = _cstarG(a, X, Y)
        a1.cla(); a1.contourf(X, Y, (Vd > 0).astype(float), levels=[0.5, 1.5], colors=[C['coral']], alpha=0.25)
        if cs[k] > 1e-3: a1.contour(X, Y, VV, levels=[cs[k]], colors=[C['azul']], linewidths=2.2)
        a1.set_xlim(-7, 7); a1.set_ylim(-7, 7); a1.set_aspect('equal'); a1.grid(True)
        a1.set_title(f'$a_{{11}}={a:.2f}$: $\\dot V>0$ (coral) y $\\Omega_{{c^*}}$ (azul)')
        a2.cla(); a2.plot(aa[:k+1], area[:k+1], '.-', color=C['azul'], ms=4); a2.plot(2, np.pi**3, 'o', color=C['coral'])
        a2.plot(aa[k], area[k], 'o', color=C['ambar'], ms=9)
        a2.set_xlim(1, 4.2); a2.set_ylim(0, 42); a2.grid(True); a2.set_xlabel('$a_{11}$'); a2.set_ylabel('área del estimado')
        a2.set_title('la elección limpia ($a_{11}=2$) no es la mejor')
    grabar(fig, act, len(aa), 'V8_3_gradiente_barrido')


def v8_4_zubov():                   # C8_Video_ZubovVanDerPol
    g_, W = zubov_malla(n=81)
    X, Y = np.meshgrid(g_, g_); VV = np.where(np.isinf(W), 1.0, 1 - np.exp(-W))
    s = solve_ivp(lambda tt, z: [z[1], -z[0] + (1 - z[0]**2)*z[1]], (0, 40), [2, 0], t_eval=np.linspace(30, 40, 2000), **o)
    P = np.array([[1.5, -0.5], [-0.5, 1]]); th = np.linspace(0, 2*np.pi, 300); U = np.vstack([np.cos(th), np.sin(th)])
    R = np.sqrt(2.30/np.einsum('ij,ik,kj->j', U, P, U))
    cc = np.r_[np.linspace(0.05, 0.9, 60), 1 - np.logspace(-1, -3, 40)]
    fig, ax = plt.subplots(figsize=(5.6, 5.2))
    def act(k):
        c = cc[k]; ax.cla()
        ax.contourf(X, Y, (VV <= c).astype(float), levels=[0.5, 1.5], colors=[C['azul']], alpha=0.25)
        ax.plot(s.y[0], s.y[1], color=C['coral'], lw=2); ax.plot(U[0]*R, U[1]*R, color=C['verde'], lw=1.8)
        ax.set_xlim(-3, 3); ax.set_ylim(-3, 3); ax.set_aspect('equal'); ax.grid(True)
        ax.set_title(f'$\\{{V\\leq {c:.3f}\\}}$, ciclo (coral) y mejor elipse (verde)', fontsize=9.5)
    grabar(fig, act, len(cc), 'V8_4_zubov_vdp')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
        sys.exit()
    for fn in [v8_1_pendulo, v8_2_ciclo, v8_3_barrido, v8_4_zubov]:
        fn()
