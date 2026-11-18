# Transparencia: escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
"""Videos de la parte 3 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C3_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap03_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V3_1_picard.mp4, V3_2_no_unicidad.mp4
"""
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, FFMpegWriter
from scipy.integrate import cumulative_trapezoid
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


def v3_1_picard():                  # C3_Video_Picard
    # x' = x, x(0) = 1 en [0, 1]; (P x)(t) = 1 + int_0^t x(s) ds, K = 8 iteraciones
    t = np.linspace(0, 1, 2001); K = 8; NT = 30; NP = 15
    its = [np.ones_like(t)]
    for _ in range(K):
        its.append(1 + cumulative_trapezoid(its[-1], t, initial=0))
    err = [np.max(np.abs(x - np.exp(t))) for x in its[1:]]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.6), gridspec_kw=dict(wspace=0.28))
    def act(n):
        k, r = divmod(n, NT + NP)                 # iteración k+1; r: fotograma dentro de ella
        a = min(r/(NT - 1), 1.0)
        a1.cla()
        a1.plot(t, np.exp(t), '--', color=C['noche'], lw=2.5, label='$e^t$')
        for j in range(1, k + 1):
            a1.plot(t, its[j], color=C['claro'], lw=1)
        a1.plot(t, (1 - a)*its[k] + a*its[k + 1], color=C['azul'], lw=2.5, label=f'$x_{{{k + 1}}}$')
        a1.set_xlim(0, 1); a1.set_ylim(0.9, 2.8); a1.set_xlabel('$t$'); a1.legend(loc='upper left')
        a1.set_title('Iteraciones de Picard y $e^t$'); a1.grid(alpha=0.3)
        a2.cla(); m = k + 1 if r >= NT else k
        if m:
            a2.semilogy(range(1, m + 1), err[:m], 'o-', color=C['coral'])
        a2.set_yscale('log'); a2.set_xlim(0.5, K + 0.5); a2.set_ylim(1e-6, 1)
        a2.set_xlabel('iteración $k$'); a2.set_title(r'$\|x_k-e^t\|_C$'); a2.grid(alpha=0.3, which='both')
    grabar(fig, act, K*(NT + NP), 'V3_1_picard')


def v3_2_no_unicidad():             # C3_Video_NoUnicidad
    # x' = x^(1/3), x(0) = 0: x_c(t) = 0 para t <= c y ((2/3)(t-c))^(3/2) después
    t = np.linspace(0, 3, 301); cs = [0, 0.4, 0.8, 1.2, 1.6, 2.0]
    xc = lambda c: np.where(t > c, (2/3*np.maximum(t - c, 0))**1.5, 0.0)
    cols = [C['azul'], C['coral'], C['violeta'], C['ambar'], C['verde'], C['teal']]
    pasos = list(range(0, len(t), 4)) + [len(t) - 1]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.6), gridspec_kw=dict(wspace=0.28))
    s = np.linspace(-1, 1, 801)
    a1.plot(s, np.cbrt(s), color=C['azul'], lw=2); a1.grid(alpha=0.3)
    a1.set_xlabel('$x$'); a1.set_ylabel('$f(x)=x^{1/3}$'); a1.set_title('Pendiente infinita en $x=0$')
    def act(n):
        i, j = divmod(n, len(pasos)); k = pasos[j]
        a2.cla(); a2.plot(t, 0*t, color=C['noche'], lw=3)
        for m in range(i):
            a2.plot(t, xc(cs[m]), color=cols[m], lw=2.2)
        a2.plot(t[:k + 1], xc(cs[i])[:k + 1], color=cols[i], lw=2.2)
        a2.set_xlim(0, 3); a2.set_ylim(-0.1, 3); a2.grid(alpha=0.3)
        a2.set_xlabel('$t$'); a2.set_ylabel('$x(t)$'); a2.set_title(rf'Todas parten de $x(0)=0$:  $c={cs[i]:.1f}$')
    grabar(fig, act, len(cs)*len(pasos), 'V3_2_no_unicidad')


if __name__ == '__main__':
    import sys
    fns = dict(v3_1_picard=v3_1_picard, v3_2_no_unicidad=v3_2_no_unicidad)
    for nombre in (sys.argv[1:] or fns):
        fns[nombre]()
