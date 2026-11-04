"""Figuras del capítulo 10 (Respuesta frecuencial y diagramas de Bode).
Genera notas/figuras/cap10/*.pdf (para LaTeX) y sitio/figuras/cap10/*.svg (web).
Ejecutar desde la raíz del repositorio:  python3 herramientas/cap10_figuras.py

Los scripts de MATLAB de codigo/cap10_respuesta_frecuencial reproducen las
mismas figuras (con el estilo de MATLAB); estas versiones existen para que el
libro y la web tengan un estilo gráfico uniforme y se puedan regenerar sin
licencia de MATLAB.
"""
import numpy as np
import control as ct
from scipy.optimize import brentq
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from estilo import C, COMP, guardar, ejes_bode, figura_bode, bode_asintotico, bode_real

s = ct.tf('s')


def leyenda(ax, **kw):
    ax.legend(loc=kw.pop('loc', 'best'), **kw)


# ---------------------------------------------------------------- 10.1
def f_linea_tiempo():
    ev = [(1927, 'H. S. Black', 'amplificador retroalimentado', 1),
          (1932, 'H. Nyquist', 'criterio de estabilidad', -1),
          (1934, 'H. S. Black', 'publica la retroalimentación negativa', 2),
          (1940, 'H. W. Bode', 'atenuación, fase y asíntotas', -2),
          (1942, 'Ziegler y Nichols', 'reglas de sintonización del PID', 1),
          (1945, 'H. W. Bode', 'libro de redes y amplificadores', -1),
          (1947, 'James, Nichols, Phillips', 'teoría de servomecanismos', 2),
          (1948, 'W. R. Evans', 'lugar de las raíces', -2)]
    fig, ax = plt.subplots(figsize=(7.2, 2.6))
    ax.axhline(0, color=C['gris'], lw=1.4, zorder=1)
    for a, q, t, nivel in ev:
        col = C['ambar'] if 'Bode' in q else C['azul']
        y = 0.62*nivel
        ax.plot([a, a], [0, y], color=col, lw=0.9, zorder=1)
        ax.plot(a, 0, 'o', ms=7, color=col, zorder=3)
        va = 'bottom' if nivel > 0 else 'top'
        ax.text(a, y, f'{a} · {q}\n{t}', ha='center', va=va, fontsize=7.4, color=C['noche'],
                bbox=dict(boxstyle='round,pad=0.25', fc='white', ec=col, lw=0.8))
    ax.set_xlim(1923.5, 1951.5)
    ax.set_ylim(-1.75, 1.75)
    ax.axis('off')
    guardar(fig, 'f_linea_tiempo')


# ---------------------------------------------------------------- 10.2
def f_seno_primer_orden():
    G = 1/(s + 10)
    t = np.linspace(0, 12, 4000)
    x = np.sin(t)
    _, z = ct.forced_response(G, t, x)
    M = abs(ct.evalfr(G, 1j)); ph = np.angle(ct.evalfr(G, 1j))
    fig, (a1, a2) = plt.subplots(2, 1, figsize=(6.2, 3.6), sharex=True,
                                 gridspec_kw=dict(height_ratios=[1, 1.25], hspace=0.15))
    a1.plot(t, x, color=C['gris'], lw=1.4)
    a1.set_ylabel('$x(t)$'); a1.set_ylim(-1.2, 1.2); a1.grid(True)
    a1.set_title('Entrada  $x(t)=\\sin t$', loc='left')
    a2.plot(t, z, color=C['azul'], lw=2.2, label='$z(t)$ (simulación completa)')
    a2.plot(t, M*np.sin(t + ph), '--', color=C['coral'], lw=1.4,
            label='$0.0995\\,\\sin(t-5.71°)$')
    a2.set_ylabel('$z(t)$'); a2.set_xlabel('$t$ (s)'); a2.grid(True)
    a2.annotate('transitorio: $e^{-10t}$\nse apaga en ~0.4 s', xy=(0.25, 0.012), xytext=(1.6, -0.075),
                fontsize=8, color=C['noche'], arrowprops=dict(arrowstyle='->', color=C['gris']))
    leyenda(a2, loc='upper right', ncol=1)
    a2.set_ylim(-0.12, 0.14)
    guardar(fig, 'f_seno_primer_orden')


# ---------------------------------------------------------------- 10.4
def f_factores_simples():
    w = np.logspace(-2, 2, 600)
    fig, axs = plt.subplots(2, 2, figsize=(7.0, 4.4), sharex=True,
                            gridspec_kw=dict(hspace=0.15, wspace=0.28))
    # ganancia
    for K, c in [(10, C['azul']), (0.5, C['coral'])]:
        axs[0, 0].plot(w, 20*np.log10(K)*np.ones_like(w), color=c, label=f'$K_b={K:g}$')
        axs[1, 0].plot(w, 0*w, color=c)
    axs[1, 0].plot(w, 0*w - 180, ':', color=C['violeta'], label='$K_b<0$')
    axs[0, 0].set_title('Factor 1: ganancia', loc='left'); leyenda(axs[0, 0], loc='center right')
    leyenda(axs[1, 0], loc='center right')
    axs[0, 0].set_ylim(-20, 30); axs[1, 0].set_ylim(-200, 20)
    # origen
    for N, c, lab in [(1, C['azul'], '$1/s$'), (2, C['violeta'], '$1/s^2$'), (-1, C['coral'], '$s$')]:
        axs[0, 1].plot(w, -20*N*np.log10(w), color=c, label=lab)
        axs[1, 1].plot(w, -90*N + 0*w, color=c)
    axs[0, 1].plot(1, 0, 'o', color=C['noche'], ms=5)
    axs[0, 1].annotate('todas pasan por\n0 dB en ω = 1', xy=(1, 0), xytext=(0.02, -55), fontsize=8,
                       arrowprops=dict(arrowstyle='->', color=C['gris']))
    axs[0, 1].set_title('Factor 2: polos y ceros en el origen', loc='left')
    leyenda(axs[0, 1], loc='upper right'); axs[0, 1].set_ylim(-80, 80); axs[1, 1].set_ylim(-200, 110)
    for a in axs[0]:
        ejes_bode(a, (0.01, 100))
    for a in axs[1]:
        ejes_bode(a, (0.01, 100), fase=True); a.set_xlabel('ω (rad/s)')
    axs[1, 0].set_yticks([-180, -90, 0]); axs[1, 1].set_yticks([-180, -90, 0, 90])
    axs[0, 1].set_ylabel('')
    axs[1, 1].set_ylabel('')
    guardar(fig, 'f_factores_simples')


def f_polo_real():
    w = np.logspace(-2, 2, 800)
    G = 1/(s + 1)
    m, f = bode_real(G, w)
    ma, fa = bode_asintotico(w, 1, 0, [(1, -1)])
    fig, a1, a2 = figura_bode(6.0, 4.0)
    a1.plot(w, ma, color=C['noche'], lw=2.6, label='asíntotas')
    a1.plot(w, m, '--', color=C['verde'], lw=2, label='real')
    a1.annotate('−3 dB en la esquina\n(error máximo)', xy=(1, -3.01), xytext=(0.03, -26), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    a1.annotate('−20 dB/dec', xy=(10, -20), xytext=(12, -8), fontsize=8.5, color=C['noche'])
    a1.set_ylim(-42, 6)
    ejes_bode(a1, (0.01, 100), paso=10)
    a2.plot(w, fa, color=C['noche'], lw=2.6)
    a2.plot(w, f, '--', color=C['verde'], lw=2)
    for x in [0.1, 10]:
        a2.axvline(x, color=C['claro'], lw=1)
    a2.annotate('−45° en ω₁', xy=(1, -45), xytext=(2.2, -25), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    a2.annotate('ω₁/10', xy=(0.1, -88), fontsize=8, color=C['gris'], ha='center')
    a2.annotate('10ω₁', xy=(10, 2), fontsize=8, color=C['gris'], ha='center')
    a2.set_ylim(-95, 8)
    ejes_bode(a2, (0.01, 100), fase=True, paso=45)
    leyenda(a1, loc='lower left')
    a1.set_title("Polo real  $1/(s/\\omega_1+1)$  con  $\\omega_1=1$", loc='left')
    guardar(fig, 'f_polo_real')


def f_complejos():
    w = np.logspace(-1, 1, 900)
    fig, a1, a2 = figura_bode(6.0, 4.4)
    ma, fa = bode_asintotico(w, 1, 0, [(1, -2)])
    cols = [C['coral'], C['ambar'], C['violeta'], C['azul'], C['verde']]
    for z, c in zip([0.05, 0.1, 0.2, 0.5, 1.0], cols):
        m, f = bode_real(1/(s**2 + 2*z*s + 1), w)
        a1.plot(w, m, color=c, lw=1.7, label=f'ζ = {z:g}')
        a2.plot(w, f, color=c, lw=1.7)
    a1.plot(w, ma, color=C['noche'], lw=2.4, label='asíntotas')
    a1.set_ylim(-40, 24); ejes_bode(a1, (0.1, 10), paso=10)
    a1.annotate('pico ≈ 1/(2ζ) en $\\omega=\\omega_n$', xy=(1, 20), xytext=(1.6, 15), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    a2.set_ylim(-190, 10); ejes_bode(a2, (0.1, 10), fase=True, paso=45)
    a2.axhline(-90, color=C['claro'], lw=1)
    a2.set_xlabel('$\\omega/\\omega_n$')
    leyenda(a1, loc='lower left', ncol=2)
    a1.set_title('Polos complejos  $\\omega_n^2/(s^2+2\\zeta\\omega_n s+\\omega_n^2)$', loc='left')
    guardar(fig, 'f_complejos')


def f_sorpresa():
    G = 1000/((s + 1)*(s**2 + 4*s + 100))
    w = np.logspace(-1, 2.5, 900)
    m, f = bode_real(G, w)
    ma, fa = bode_asintotico(w, 10, 0, [(1, -1), (10, -2)])
    fig, a1, a2 = figura_bode(6.0, 4.2)
    a1.plot(w, ma, color=C['noche'], lw=2.4, label='asíntotas')
    a1.plot(w, m, '--', color=C['verde'], lw=2, label='real')
    a1.axhline(0, color=C['gris'], lw=0.9)
    a1.plot(10, 7.92, 'o', color=C['coral'])
    a1.annotate('+7.96 dB por\nla resonancia (ζ = 0.2)', xy=(10, 7.92), xytext=(18, 14), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    a1.set_ylim(-60, 30); ejes_bode(a1, (0.1, 300), paso=20)
    a2.plot(w, f, '--', color=C['verde'], lw=2)
    a2.axhline(-180, color=C['gris'], lw=0.9)
    a2.axvline(12.66, color=C['coral'], lw=1, ls=':')
    a2.annotate('cruce real 12.7 rad/s:\nfase −225°, PM = −45.5°', xy=(12.66, -225), xytext=(25, -140),
                fontsize=8, arrowprops=dict(arrowstyle='->', color=C['gris']))
    a2.set_ylim(-280, 10); ejes_bode(a2, (0.1, 300), fase=True, paso=90)
    leyenda(a1, loc='lower left')
    a1.set_title("$G'(s)=1000/[(s+1)(s^2+4s+100)]$", loc='left')
    guardar(fig, 'f_sorpresa')


# ---------------------------------------------------------------- 10.5
def f_ej_s_s10():
    w = np.logspace(-1, 3, 800)
    G = s/(s + 10)
    comps = [((0.1, 0, []), '$1/10$'), ((1, -1, []), '$s$'), ((1, 0, [(10, -1)]), '$1/(s/10+1)$')]
    fig, a1, a2 = figura_bode(6.2, 4.6)
    for (args, lab), c in zip(comps, COMP):
        m, f = bode_asintotico(w, args[0], args[1], args[2])
        a1.plot(w, m, color=c, lw=1.5, label=lab)
        a2.plot(w, f, color=c, lw=1.5)
    ms, fs = bode_asintotico(w, 0.1, -1, [(10, -1)])
    mr, fr = bode_real(G, w)
    a1.plot(w, ms, color=C['noche'], lw=3, label='suma asintótica')
    a1.plot(w, mr, '--', color=C['verde'], lw=2, label='real')
    a2.plot(w, fs, color=C['noche'], lw=3)
    a2.plot(w, fr, '--', color=C['verde'], lw=2)
    a1.plot(10, -3.01, 'o', color=C['coral'], ms=5)
    a1.annotate('−3 dB', xy=(10, -3.01), xytext=(16, -14), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    a2.plot(10, 45, 'o', color=C['coral'], ms=5)
    a1.set_ylim(-45, 45); ejes_bode(a1, (0.1, 1000), paso=20)
    a2.set_ylim(-100, 110); ejes_bode(a2, (0.1, 1000), fase=True, paso=45)
    leyenda(a1, loc='upper left', ncol=2)
    a1.set_title("$G'(s)=s/(s+10)$: tres factores, su suma y la curva real", loc='left')
    guardar(fig, 'f_ej_s_s10')


def f_pasaaltos():
    G = s/(s + 10)
    t = np.linspace(0, 6.3, 5000)
    x = np.sin(t) + 0.3*np.sin(20*t)
    _, y = ct.forced_response(G, t, x)
    fig, ax = plt.subplots(figsize=(6.2, 2.5))
    ax.plot(t, x, color=C['gris'], lw=1.1, label='entrada  $\\sin t + 0.3\\sin 20t$')
    ax.plot(t, y, color=C['coral'], lw=1.7, label="salida de $s/(s+10)$")
    ax.set_xlabel('$t$ (s)'); ax.grid(True); ax.set_ylim(-1.6, 1.9)
    leyenda(ax, loc='upper right', ncol=2)
    guardar(fig, 'f_pasaaltos')


# ---------------------------------------------------------------- 10.6
def f_identificacion():
    w = np.logspace(-1, 3, 800)
    K = 10**(36/20)
    ma, fa = bode_asintotico(w, K, 1, [(1, 1), (10, -2)])
    G = K*(s + 1)/(s*(s/10 + 1)**2)
    mr, fr = bode_real(G, w)
    fig, a1, a2 = figura_bode(6.0, 4.3)
    a1.plot(w, ma, color=C['noche'], lw=2.6, label='asintótico (dato)')
    a1.plot(w, mr, '--', color=C['verde'], lw=1.8, label='real (reconstruida)')
    for x, txt in [(0.3, '−20'), (3, '0'), (60, '−40')]:
        a1.text(x, np.interp(x, w, ma) + 5, txt + ' dB/dec', fontsize=8, color=C['azul'], ha='center')
    a1.axhline(36, color=C['claro'], lw=1, ls=':')
    a1.text(0.105, 38, '36 dB', fontsize=8, color=C['gris'])
    a1.set_ylim(-40, 70); ejes_bode(a1, (0.1, 1000), paso=20)
    a2.plot(w, fa, color=C['noche'], lw=2.6)
    a2.plot(w, fr, '--', color=C['verde'], lw=1.8)
    a2.set_ylim(-190, -30); ejes_bode(a2, (0.1, 1000), fase=True, paso=45)
    leyenda(a1, loc='upper right')
    a1.set_title('Leer un Bode al revés: pendientes, esquinas y ganancia', loc='left')
    guardar(fig, 'f_identificacion')


def f_fase_no_minima():
    w = np.logspace(-2, 2, 800)
    G1 = (1 + s)/(1 + 2*s); G2 = (1 - s)/(1 + 2*s)
    m1, f1 = bode_real(G1, w); m2, f2 = bode_real(G2, w)
    fig, a1, a2 = figura_bode(5.8, 3.8)
    a1.plot(w, m1, color=C['azul'], lw=2.4, label='$(1+s)/(1+2s)$  fase mínima')
    a1.plot(w, m2, '--', color=C['coral'], lw=2, label='$(1-s)/(1+2s)$  fase no mínima')
    a1.set_ylim(-8, 2); ejes_bode(a1, (0.01, 100), paso=2)
    a2.plot(w, f1, color=C['azul'], lw=2.4); a2.plot(w, f2, '--', color=C['coral'], lw=2)
    a2.set_ylim(-190, 10); ejes_bode(a2, (0.01, 100), fase=True, paso=45)
    leyenda(a1, loc='lower left')
    a1.set_title('Misma magnitud, distinta fase', loc='left')
    guardar(fig, 'f_fase_no_minima')


# ---------------------------------------------------------------- 10.7
def f_margenes_def():
    G = 1e4/((s + 1)*(s + 10)*(s + 100))
    w = np.logspace(-1, 3, 900)
    m, f = bode_real(G, w)
    gm, pm, wcg, wcp = ct.margin(G)
    fig, a1, a2 = figura_bode(6.0, 4.4)
    a1.plot(w, m, color=C['azul'], lw=2.2)
    a1.axhline(0, color=C['gris'], lw=0.9)
    a1.axvline(wcp, color=C['verde'], lw=0.9, ls=':'); a1.axvline(wcg, color=C['coral'], lw=0.9, ls=':')
    mg = 20*np.log10(abs(ct.evalfr(G, 1j*wcg)))
    a1.annotate('', xy=(wcg, 0), xytext=(wcg, mg),
                arrowprops=dict(arrowstyle='<->', color=C['coral'], lw=2))
    a1.text(wcg*1.15, mg/2, f'GM = {20*np.log10(gm):.1f} dB', color=C['coral'], fontsize=9, fontweight='bold')
    a1.text(wcp*0.97, 12, f'$\\omega_{{PM}}$ = {wcp:.2f}', color=C['verde'], fontsize=8.5, ha='right')
    a1.set_ylim(-80, 30); ejes_bode(a1, (0.1, 1000), paso=20)
    a2.plot(w, f, color=C['azul'], lw=2.2)
    a2.axhline(-180, color=C['gris'], lw=0.9)
    a2.axvline(wcp, color=C['verde'], lw=0.9, ls=':'); a2.axvline(wcg, color=C['coral'], lw=0.9, ls=':')
    fpm = np.degrees(np.angle(ct.evalfr(G, 1j*wcp)))
    a2.annotate('', xy=(wcp, -180), xytext=(wcp, fpm),
                arrowprops=dict(arrowstyle='<->', color=C['verde'], lw=2))
    a2.text(wcp*0.88, -160, f'PM = {pm:.1f}°', color=C['verde'], fontsize=9, fontweight='bold', ha='right')
    a2.text(wcg*1.1, -200, f'$\\omega_{{GM}}$ = {wcg:.1f}', color=C['coral'], fontsize=8.5)
    a2.set_ylim(-275, 5); ejes_bode(a2, (0.1, 1000), fase=True, paso=45)
    a1.set_title("Márgenes de $G'(s)=10\\,000/[(s+1)(s+10)(s+100)]$", loc='left')
    guardar(fig, 'f_margenes_def')


def f_margenes_asint():
    G = 1e4/((s + 1)*(s + 10)*(s + 100))
    w = np.logspace(-1, 3.3, 900)
    terms = [((10, 0, []), '$10$'), ((1, 0, [(1, -1)]), '$1/(s+1)$'),
             ((1, 0, [(10, -1)]), '$1/(s/10+1)$'), ((1, 0, [(100, -1)]), '$1/(s/100+1)$')]
    fig, a1, a2 = figura_bode(6.2, 4.6)
    for (args, lab), c in zip(terms, COMP):
        m, f = bode_asintotico(w, *args)
        a1.plot(w, m, color=c, lw=1.3, label=lab); a2.plot(w, f, color=c, lw=1.3)
    ma, fa = bode_asintotico(w, 10, 0, [(1, -1), (10, -1), (100, -1)])
    mr, fr = bode_real(G, w)
    a1.plot(w, ma, color=C['noche'], lw=3, label='suma'); a1.plot(w, mr, '--', color=C['verde'], lw=1.8, label='real')
    a2.plot(w, fa, color=C['noche'], lw=3); a2.plot(w, fr, '--', color=C['verde'], lw=1.8)
    a1.axhline(0, color=C['gris'], lw=0.9); a2.axhline(-180, color=C['gris'], lw=0.9)
    a1.plot(10, 0, 'o', color=C['verde']); a2.plot(10, -135, 'o', color=C['verde'])
    a1.plot(31.62, -20, 'o', color=C['coral']); a2.plot(31.62, -180, 'o', color=C['coral'])
    a1.annotate('GM ≈ 20 dB', xy=(31.62, -20), xytext=(60, -5), fontsize=8.5, color=C['coral'],
                arrowprops=dict(arrowstyle='->', color=C['coral']))
    a2.annotate('PM ≈ 45°', xy=(10, -135), xytext=(1.2, -200), fontsize=8.5, color=C['verde'],
                arrowprops=dict(arrowstyle='->', color=C['verde']))
    a1.set_ylim(-110, 35); ejes_bode(a1, (0.1, 2000), paso=20)
    a2.set_ylim(-285, 15); ejes_bode(a2, (0.1, 2000), fase=True, paso=45)
    leyenda(a1, loc='lower left', ncol=2)
    a1.set_title('Asintótico (a mano) contra real', loc='left')
    guardar(fig, 'f_margenes_asint')


def f_rango_kc():
    G0 = 1/((s + 1)*(s + 10)*(s + 100))
    t = np.linspace(0, 1.5, 3000)
    fig, ax = plt.subplots(figsize=(6.0, 2.7))
    for K, c in [(50000, C['azul']), (100000, C['violeta']), (122210, C['coral'])]:
        T = ct.feedback(K*G0, 1)
        _, y = ct.step_response(T, t)
        ax.plot(t, y, color=c, lw=1.6, label=f'$K_c$ = {K:,}'.replace(',', ' '))
    ax.set_xlabel('$t$ (s)'); ax.set_ylabel('$y(t)$'); ax.grid(True)
    leyenda(ax, loc='lower right', ncol=3)
    ax.set_title('Escalón en lazo cerrado: en $K_c=K_{cr}$ aparece la oscilación sostenida', loc='left')
    ax.set_ylim(0, 2.1)
    guardar(fig, 'f_rango_kc')


def f_sensor():
    G = 1e4/((s + 1)*(s + 10)*(s + 100))
    t = np.linspace(0, 2.5, 4000)
    w = np.logspace(-1, 3, 900)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.2, 3.0), gridspec_kw=dict(wspace=0.3))
    _, y = ct.step_response(ct.feedback(G, 1), t)
    a1.plot(t, y, color=C['noche'], lw=2.2, label='sin sensor: PM = 54.9°')
    m, f = bode_real(G, w)
    a2.plot(w, f, color=C['noche'], lw=2.2)
    for a, c in [(50, C['azul']), (20, C['violeta']), (10, C['coral'])]:
        H = a/(s + a)
        _, pm, _, _ = ct.margin(G*H)
        _, y = ct.step_response(ct.feedback(G, H), t)
        a1.plot(t, y, color=c, lw=1.5, label=f'a = {a}: PM = {pm:.1f}°')
        _, f = bode_real(G*H, w)
        a2.plot(w, f, color=c, lw=1.5)
    a1.set_xlabel('$t$ (s)'); a1.grid(True); a1.set_title('Escalón en lazo cerrado', loc='left')
    leyenda(a1, loc='lower right', fontsize=7.5)
    a2.axhline(-180, color=C['gris'], lw=0.9); a2.axvline(7.8, color=C['claro'], lw=1, ls=':')
    a2.set_ylim(-360, 5); ejes_bode(a2, (0.1, 1000), fase=True, paso=90); a2.set_xlabel('ω (rad/s)')
    a2.set_title("Fase de $G'H$: el sensor gasta fase", loc='left')
    guardar(fig, 'f_sensor')


# ---------------------------------------------------------------- 10.8
def f_lazo_cerrado_zeta():
    w = np.logspace(-1, 1, 800)
    fig, ax = plt.subplots(figsize=(5.8, 2.9))
    for z, c in zip([0.1, 0.25, 0.5, 0.707, 1.0], [C['coral'], C['ambar'], C['violeta'], C['azul'], C['verde']]):
        m, _ = bode_real(1/(s**2 + 2*z*s + 1), w)
        ax.plot(w, m, color=c, lw=1.7, label=f'ζ = {z:g}')
    ax.axhline(-3, color=C['gris'], lw=0.9, ls=':')
    ax.text(0.105, -5.5, '−3 dB: define $\\omega_{BW}$', fontsize=8, color=C['gris'])
    ax.set_ylim(-25, 16); ejes_bode(ax, (0.1, 10), paso=5)
    ax.set_xlabel('$\\omega/\\omega_n$'); leyenda(ax, loc='lower left', ncol=2)
    ax.set_title('Lazo cerrado $|T(j\\omega)|$: pico $M_r$ y ancho de banda', loc='left')
    guardar(fig, 'f_lazo_cerrado_zeta')


def f_pm_zeta():
    z = np.linspace(0.01, 1, 400)
    pm = np.degrees(np.arctan(2*z/np.sqrt(-2*z**2 + np.sqrt(1 + 4*z**4))))
    os_ = 100*np.exp(-z*np.pi/np.sqrt(1 - np.minimum(z, 0.9999)**2))
    fig, ax = plt.subplots(figsize=(5.8, 3.1))
    ax.plot(z, pm, color=C['azul'], lw=2.4, label='PM(ζ) exacto')
    ax.plot(z, 100*z, '--', color=C['ambar'], lw=1.6, label='aproximación PM ≈ 100ζ')
    ax.set_xlabel('ζ'); ax.set_ylabel('PM (°)', color=C['azul']); ax.set_ylim(0, 90); ax.grid(True)
    ax2 = ax.twinx(); ax2.plot(z, os_, color=C['coral'], lw=1.6, label='%OS')
    ax2.set_ylabel('%OS', color=C['coral']); ax2.set_ylim(0, 100)
    ax2.spines['right'].set_visible(True)
    for zz in [0.25, 0.4, 0.5, 0.6, 0.707]:
        p = np.degrees(np.arctan(2*zz/np.sqrt(-2*zz**2 + np.sqrt(1 + 4*zz**4))))
        ax.plot(zz, p, 'o', color=C['azul'], ms=4)
    h1, l1 = ax.get_legend_handles_labels(); h2, l2 = ax2.get_legend_handles_labels()
    ax.legend(h1 + h2, l1 + l2, loc='center right')
    ax.set_title('La curva que usaremos todo el capítulo', loc='left')
    guardar(fig, 'f_pm_zeta')


def f_ej_pm_zeta():
    G = 100/(s*(s + 10))
    w = np.logspace(-1, 3, 800)
    mr, fr = bode_real(G, w); ma, fa = bode_asintotico(w, 10, 1, [(10, -1)])
    fig = plt.figure(figsize=(7.2, 3.3))
    gs = fig.add_gridspec(2, 2, width_ratios=[1.2, 1], hspace=0.12, wspace=0.3)
    a1 = fig.add_subplot(gs[0, 0]); a2 = fig.add_subplot(gs[1, 0], sharex=a1); a3 = fig.add_subplot(gs[:, 1])
    a1.plot(w, ma, color=C['noche'], lw=2.4, label='asintótico'); a1.plot(w, mr, '--', color=C['verde'], lw=1.8, label='real')
    a1.axhline(0, color=C['gris'], lw=0.9); a1.set_ylim(-60, 40); ejes_bode(a1, (0.1, 1000), paso=20)
    a1.plot(7.86, 0, 'o', color=C['verde']); a1.plot(10, 0, 'o', color=C['noche'])
    plt.setp(a1.get_xticklabels(), visible=False)
    a2.plot(w, fa, color=C['noche'], lw=2.4); a2.plot(w, fr, '--', color=C['verde'], lw=1.8)
    a2.axhline(-180, color=C['gris'], lw=0.9); a2.set_ylim(-185, -85); ejes_bode(a2, (0.1, 1000), fase=True, paso=45)
    a2.set_xlabel('ω (rad/s)')
    a2.annotate('PM real 51.8°\n(asint. 45°)', xy=(7.86, -128.2), xytext=(0.15, -170), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    leyenda(a1, loc='upper right')
    t = np.linspace(0, 1.4, 2000)
    _, y = ct.step_response(ct.feedback(G, 1), t)
    a3.plot(t, y, color=C['azul'], lw=2.2)
    a3.axhline(1.163, color=C['coral'], lw=0.9, ls=':'); a3.axvline(0.363, color=C['coral'], lw=0.9, ls=':')
    a3.text(0.42, 1.18, '%OS = 16.3 %  ($t_p$ = 0.363 s)', fontsize=8, color=C['coral'])
    a3.set_xlabel('$t$ (s)'); a3.grid(True); a3.set_ylim(0, 1.3)
    a3.set_title('Lazo cerrado: escalón', loc='left')
    a1.set_title("$G'(s)=100/[s(s+10)]$", loc='left')
    guardar(fig, 'f_ej_pm_zeta')


# ---------------------------------------------------------------- 10.9
def f_tipos():
    w = np.logspace(-2, 3, 800)
    casos = [(0.01/(s/10 + 1), 'Tipo 0', (-60, 10), 'nivel = 20 log κp = −40 dB'),
             (1/(s*(s/10 + 1)), 'Tipo 1', (-80, 50), 'cruza 0 dB en ω = κv = 1'),
             (100/(s**2*(s/100 + 1)), 'Tipo 2', (-80, 130), 'cruza 0 dB en ω = √κa = 10')]
    fig, axs = plt.subplots(1, 3, figsize=(7.4, 2.6), gridspec_kw=dict(wspace=0.35))
    for ax, (G, tit, yl, txt) in zip(axs, casos):
        m, _ = bode_real(G, w)
        ax.plot(w, m, color=C['azul'], lw=2)
        ax.axhline(0, color=C['gris'], lw=0.9)
        ax.set_ylim(*yl); ejes_bode(ax, (0.01, 1000))
        ax.set_title(tit, loc='left'); ax.set_xlabel('ω (rad/s)')
        ax.text(0.012, yl[0] + 0.08*(yl[1] - yl[0]), txt, fontsize=7.4, color=C['noche'])
    axs[0].plot(w, -40 + 0*w, ':', color=C['coral'])
    axs[1].plot(1, 0, 'o', color=C['coral'])
    axs[2].plot(10, 0, 'o', color=C['coral'])
    for a in axs[1:]:
        a.set_ylabel('')
    guardar(fig, 'f_tipos')


# ---------------------------------------------------------------- 10.10
def f_ajuste_ganancia():
    G0 = 1/(s*(s + 20)*(s + 100))
    w = np.logspace(-1, 3, 900)
    fig = plt.figure(figsize=(7.2, 3.4))
    gs = fig.add_gridspec(2, 2, width_ratios=[1.2, 1], hspace=0.12, wspace=0.3)
    a1 = fig.add_subplot(gs[0, 0]); a2 = fig.add_subplot(gs[1, 0], sharex=a1); a3 = fig.add_subplot(gs[:, 1])
    m0, f0 = bode_real(2000*G0, w); m1, _ = bode_real(33056*G0, w)
    a1.plot(w, m0, color=C['gris'], lw=1.6, label='$K_c=2000$')
    a1.plot(w, m1, color=C['azul'], lw=2.2, label='$K_c=33\\,056$')
    a1.axhline(0, color=C['gris'], lw=0.9); a1.axvline(13.56, color=C['verde'], ls=':', lw=1)
    a1.annotate('', xy=(13.56, 0), xytext=(13.56, -24.36), arrowprops=dict(arrowstyle='->', color=C['coral'], lw=1.8))
    a1.text(17, -30, '+24.36 dB', color=C['coral'], fontsize=8.5, fontweight='bold')
    a1.set_ylim(-90, 40); ejes_bode(a1, (0.1, 1000), paso=30); leyenda(a1, loc='lower left')
    plt.setp(a1.get_xticklabels(), visible=False)
    a2.plot(w, f0, color=C['azul'], lw=2.2)
    a2.axhline(-131.85, color=C['verde'], lw=1, ls='--'); a2.axvline(13.56, color=C['verde'], ls=':', lw=1)
    a2.text(0.12, -125, '−180° + 48.15° = −131.85°', fontsize=8, color=C['verde'])
    a2.set_ylim(-275, -80); ejes_bode(a2, (0.1, 1000), fase=True, paso=45); a2.set_xlabel('ω (rad/s)')
    t = np.linspace(0, 0.8, 3000)
    _, y = ct.step_response(ct.feedback(33056*G0, 1), t)
    a3.plot(t, y, color=C['azul'], lw=2.2); a3.axhline(1.2, color=C['coral'], ls=':', lw=1)
    a3.text(0.3, 1.23, 'meta: 20 %  (logrado 19.9 %)', fontsize=8, color=C['coral'])
    a3.set_ylim(0, 1.35); a3.grid(True); a3.set_xlabel('$t$ (s)'); a3.set_title('Escalón', loc='left')
    a1.set_title('La ganancia sube la curva, no toca la fase', loc='left')
    guardar(fig, 'f_ajuste_ganancia')


# ---------------------------------------------------------------- 10.11
def f_compensadores_bode():
    w = np.logspace(-2, 2, 800)
    a = 10; wL = 0.316; wH = a*wL
    lead = a*(s + wL)/(s + wH)          # Gc(0)=1
    lag = (1/a)*(s + wH)/(s + wL)
    fig, axs = plt.subplots(2, 2, figsize=(7.2, 4.2), sharex=True, gridspec_kw=dict(hspace=0.12, wspace=0.3))
    for j, (G, tit, c) in enumerate([(lead, 'Adelanto  $\\alpha(s+\\omega_L)/(s+\\omega_H)$', C['azul']),
                                     (lag, 'Atraso  $(1/\\alpha)(s+\\omega_H)/(s+\\omega_L)$', C['coral'])]):
        m, f = bode_real(G, w)
        axs[0, j].plot(w, m, color=c, lw=2.2); axs[1, j].plot(w, f, color=c, lw=2.2)
        axs[0, j].set_title(tit, loc='left')
        for k in range(2):
            axs[k, j].axvline(wL, color=C['claro'], lw=1, ls=':'); axs[k, j].axvline(wH, color=C['claro'], lw=1, ls=':')
        ejes_bode(axs[0, j], (0.01, 100)); ejes_bode(axs[1, j], (0.01, 100), fase=True)
        axs[1, j].set_xlabel('ω (rad/s)')
    wM = np.sqrt(wL*wH)
    axs[1, 0].plot(wM, 54.9, 'o', color=C['noche'])
    axs[1, 0].annotate('$\\phi_M$ = 54.9° en $\\omega_M=(\\omega_L\\omega_H)^{1/2}$', xy=(wM, 54.9), xytext=(0.012, 30), fontsize=8,
                       arrowprops=dict(arrowstyle='->', color=C['gris']))
    axs[0, 0].text(15, 14, '+20 log α', fontsize=8, color=C['azul'])
    axs[0, 1].text(0.012, -17, '−20 log α', fontsize=8, color=C['coral'])
    axs[0, 0].set_ylim(-3, 23); axs[0, 1].set_ylim(-23, 3)
    axs[1, 0].set_ylim(-5, 65); axs[1, 1].set_ylim(-65, 5)
    axs[0, 1].set_ylabel(''); axs[1, 1].set_ylabel('')
    for x, lab in [(wL, 'ω_L'), (wH, 'ω_H')]:
        axs[0, 0].text(x, 21.5 if lab == 'ω_L' else 1, lab.replace('_', ''), fontsize=7.5, color=C['gris'], ha='center')
    guardar(fig, 'f_compensadores_bode')


def f_phimax():
    a = np.linspace(1, 30, 400)
    phi = np.degrees(np.arcsin((a - 1)/(a + 1)))
    fig, ax = plt.subplots(figsize=(5.4, 2.7))
    ax.plot(a, phi, color=C['azul'], lw=2.4)
    for aa in [4.03, 10, 20]:
        p = np.degrees(np.arcsin((aa - 1)/(aa + 1)))
        ax.plot(aa, p, 'o', color=C['coral']); ax.text(aa + 0.5, p - 7, f'α = {aa:g}: {p:.1f}°', fontsize=8)
    ax.axhline(90, color=C['gris'], ls=':', lw=1)
    ax.set_xlabel('α'); ax.set_ylabel('$\\phi_M$ (°)'); ax.set_ylim(0, 95); ax.grid(True)
    ax.set_title('Rendimientos decrecientes: más α, poca fase extra', loc='left')
    guardar(fig, 'f_phimax')


def _diseno_lead_lag():
    Gp = 40/(s*(s + 2))
    alpha = 4.0291; wL = 4.4085; wH = alpha*wL
    lead = alpha*(s + wL)/(s + wH)
    a2 = 9.1263; wH2 = 0.16815; wL2 = wH2/a2
    lag = (1/a2)*(s + wH2)/(s + wL2)
    return Gp, lead, lag


def f_adelanto_ej():
    Gp, lead, lag = _diseno_lead_lag()
    w = np.logspace(-1, 2.5, 900)
    fig = plt.figure(figsize=(7.2, 3.5))
    gs = fig.add_gridspec(2, 2, width_ratios=[1.2, 1], hspace=0.12, wspace=0.3)
    a1 = fig.add_subplot(gs[0, 0]); a2 = fig.add_subplot(gs[1, 0], sharex=a1); a3 = fig.add_subplot(gs[:, 1])
    for G, c, lab, lw in [(Gp, C['gris'], '$G_p$ ($K=40$)', 1.6), (lead, C['ambar'], '$G_c$', 1.4), (lead*Gp, C['azul'], '$G_cG_p$', 2.3)]:
        m, f = bode_real(G, w)
        a1.plot(w, m, color=c, lw=lw, label=lab); a2.plot(w, f, color=c, lw=lw)
    a1.axhline(0, color=C['gris'], lw=0.9); a2.axhline(-180, color=C['gris'], lw=0.9)
    a1.plot(6.17, 0, 'o', color=C['gris']); a1.plot(8.85, 0, 'o', color=C['azul'])
    a2.text(0.12, -168, 'PM: 18.0° → 49.8°', fontsize=8.5, color=C['azul'], fontweight='bold')
    a1.set_ylim(-40, 50); ejes_bode(a1, (0.1, 300), paso=20); leyenda(a1, loc='lower left', ncol=3)
    plt.setp(a1.get_xticklabels(), visible=False)
    a2.set_ylim(-185, 45); ejes_bode(a2, (0.1, 300), fase=True, paso=45); a2.set_xlabel('ω (rad/s)')
    t = np.linspace(0, 5, 4000)
    for G, c, lab in [(Gp, C['gris'], 'sin compensar (60 %)'), (lead*Gp, C['azul'], 'adelanto (22 %)')]:
        _, y = ct.step_response(ct.feedback(G, 1), t)
        a3.plot(t, y, color=c, lw=2, label=lab)
    a3.set_ylim(0, 1.7); a3.grid(True); a3.set_xlabel('$t$ (s)'); leyenda(a3, loc='upper right')
    a3.set_title('Escalón', loc='left')
    a1.set_title('Adelanto: fase extra justo en el cruce', loc='left')
    guardar(fig, 'f_adelanto_ej')


def f_atraso_ej():
    Gp, lead, lag = _diseno_lead_lag()
    w = np.logspace(-3, 2, 900)
    fig, a1, a2 = figura_bode(6.2, 4.2)
    for G, c, lab, lw in [(Gp, C['gris'], '$G_p$ ($K=40$)', 1.6), (lag*Gp, C['coral'], '$G_cG_p$ (atraso)', 2.3)]:
        m, f = bode_real(G, w)
        a1.plot(w, m, color=c, lw=lw, label=lab); a2.plot(w, f, color=c, lw=lw)
    a1.axhline(0, color=C['gris'], lw=0.9); a2.axhline(-180, color=C['gris'], lw=0.9)
    a1.plot(1.68, 0, 'o', color=C['coral']); a1.plot(6.17, 0, 'o', color=C['gris'])
    a1.annotate('cruce: 6.17 → 1.68 rad/s', xy=(1.68, 0), xytext=(2.5, 30), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    a1.text(0.0012, 62, 'misma ganancia en bajas: κv = 20', fontsize=8, color=C['noche'])
    a2.axhline(-130, color=C['verde'], lw=0.9, ls='--'); a2.axvline(1.68, color=C['verde'], lw=0.9, ls=':')
    a2.text(0.0012, -125, '−180° + 45° + 5° = −130°', fontsize=8, color=C['verde'])
    a2.set_ylim(-185, -80); ejes_bode(a2, (0.001, 100), fase=True, paso=45)
    a1.set_ylim(-40, 90); ejes_bode(a1, (0.001, 100), paso=20); leyenda(a1, loc='lower left')
    a1.set_title('Atraso: baja la curva en el cruce sin tocar las bajas frecuencias', loc='left')
    guardar(fig, 'f_atraso_ej')


def f_comparacion():
    Gp, lead, lag = _diseno_lead_lag()
    fig, axs = plt.subplots(1, 3, figsize=(7.4, 2.6), gridspec_kw=dict(wspace=0.33))
    t = np.linspace(0, 12, 6000); t2 = np.linspace(0, 40, 8000); t3 = np.linspace(0, 3, 3000)
    for Gc, c, lab in [(ct.tf(1, 1), C['gris'], 'sin compensar'), (lead, C['azul'], 'adelanto'), (lag, C['coral'], 'atraso')]:
        L = Gc*Gp
        _, y = ct.step_response(ct.feedback(L, 1), t); axs[0].plot(t, y, color=c, lw=1.7, label=lab)
        _, yr = ct.forced_response(ct.feedback(L, 1), t2, t2); axs[1].plot(t2, t2 - yr, color=c, lw=1.7)
        _, u = ct.step_response(ct.feedback(Gc, Gp), t3); axs[2].plot(t3, u, color=c, lw=1.7)
    axs[0].set_title('Escalón', loc='left'); axs[0].set_ylim(0, 1.7)
    axs[1].set_title('Error ante rampa', loc='left'); axs[1].axhline(0.05, color=C['noche'], ls=':', lw=1); axs[1].set_ylim(0, 0.35)
    axs[2].set_title('Esfuerzo $u(t)$', loc='left'); axs[2].set_ylim(-1.5, 4.5)
    for a in axs:
        a.grid(True); a.set_xlabel('$t$ (s)')
    leyenda(axs[0], loc='lower right', fontsize=7.5)
    guardar(fig, 'f_comparacion')


def f_atraso_adelanto():
    Gp = 20/(s*(s + 1)*(s + 2))
    wc = 1.2; a = 10; wL = wc/np.sqrt(a); wH = wc*np.sqrt(a)
    lead = a*(s + wL)/(s + wH)
    MdB = 20*np.log10(abs(ct.evalfr(lead*Gp, 1j*wc)))
    b = 10**(MdB/20); zl = wc/10; pl = zl/b
    lag = (1/b)*(s + zl)/(s + pl)
    w = np.logspace(-3, 2, 900)
    fig = plt.figure(figsize=(7.2, 3.4))
    gs = fig.add_gridspec(2, 2, width_ratios=[1.2, 1], hspace=0.12, wspace=0.3)
    a1 = fig.add_subplot(gs[0, 0]); a2 = fig.add_subplot(gs[1, 0], sharex=a1); a3 = fig.add_subplot(gs[:, 1])
    for G, c, lab, lw in [(Gp, C['gris'], '$G_p$ (κv = 10)', 1.6), (lead*lag*Gp, C['violeta'], 'atraso-adelanto', 2.3)]:
        m, f = bode_real(G, w)
        a1.plot(w, m, color=c, lw=lw, label=lab); a2.plot(w, f, color=c, lw=lw)
    a1.axhline(0, color=C['gris'], lw=0.9); a2.axhline(-180, color=C['gris'], lw=0.9)
    a1.set_ylim(-60, 90); ejes_bode(a1, (0.001, 100), paso=30); leyenda(a1, loc='lower left')
    plt.setp(a1.get_xticklabels(), visible=False)
    a2.set_ylim(-275, -80); ejes_bode(a2, (0.001, 100), fase=True, paso=45); a2.set_xlabel('ω (rad/s)')
    a2.text(0.0012, -265, 'PM: −28.1° → 58.2°   GM: −10.5 → 13.2 dB', fontsize=8, color=C['violeta'], fontweight='bold')
    t = np.linspace(0, 30, 6000)
    _, y = ct.step_response(ct.feedback(lead*lag*Gp, 1), t)
    a3.plot(t, y, color=C['violeta'], lw=2.2); a3.grid(True); a3.set_xlabel('$t$ (s)'); a3.set_ylim(0, 1.4)
    a3.set_title('Escalón (compensado)', loc='left')
    a1.set_title('Atraso-adelanto: κv = 10 y PM ≥ 50°', loc='left')
    guardar(fig, 'f_atraso_adelanto')


def f_pid_frecuencia():
    Gp = 1/((s + 1)*(s + 10)*(s + 100))
    Kcr = 122210; Pcr = 2*np.pi/np.sqrt(1110)
    Czn = 0.6*Kcr*(1 + 1/(Pcr/2*s) + Pcr/8*s)
    wc = 20; N = 10; Ti = 10/wc; Td = 0.04651
    C0 = (1 + 1/(Ti*s))*(1 + Td*s)/(1 + Td*s/N)
    Kc = 1/abs(ct.evalfr(C0*Gp, 1j*wc)); Cls = Kc*C0
    t = np.linspace(0, 1.2, 6000)
    fig, ax = plt.subplots(figsize=(6.0, 2.7))
    for Cc, c, lab in [(Czn, C['coral'], 'Ziegler–Nichols (PM ≈ 20°)'), (Cls, C['azul'], 'moldeo del lazo (PM = 50°)')]:
        _, y = ct.step_response(ct.feedback(Cc*Gp, 1), t)
        ax.plot(t, y, color=c, lw=2, label=lab)
    ax.grid(True); ax.set_xlabel('$t$ (s)'); ax.set_ylim(0, 1.8); leyenda(ax, loc='upper right')
    ax.set_title('PID para $1/[(s+1)(s+10)(s+100)]$', loc='left')
    guardar(fig, 'f_pid_frecuencia')


if __name__ == '__main__':
    for fn in [f_linea_tiempo, f_seno_primer_orden, f_factores_simples, f_polo_real, f_complejos,
               f_sorpresa, f_ej_s_s10, f_pasaaltos, f_identificacion, f_fase_no_minima,
               f_margenes_def, f_margenes_asint, f_rango_kc, f_sensor, f_lazo_cerrado_zeta,
               f_pm_zeta, f_ej_pm_zeta, f_tipos, f_ajuste_ganancia, f_compensadores_bode,
               f_phimax, f_adelanto_ej, f_atraso_ej, f_comparacion, f_atraso_adelanto, f_pid_frecuencia]:
        fn()
