"""Figuras del capítulo 2 (Modelado I). Genera PDF (notas) y SVG (web).
Ejecutar:  python3 herramientas/cap02_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
import control as ct
from estilo import C, guardar

CAP = 'cap02'


def g(fig, nombre):
    guardar(fig, nombre, CAP)


# ---------------------------------------------------------------- señal
def senal_temperatura():
    t = np.linspace(0, 60, 600)
    fig, ax = plt.subplots(figsize=(5.4, 2.5))
    ax.plot(t, 20 - 3*np.exp(-0.15*t), color=C['azul'])
    ax.axhline(20, color=C['gris'], lw=0.8, ls=':')
    ax.annotate('$T(t)=20-3e^{-0.15t}$', xy=(12, 20 - 3*np.exp(-1.8)), xytext=(22, 18.2),
                color=C['azul'], arrowprops=dict(arrowstyle='->', color=C['gris']))
    ax.plot([0], [17], 'o', color=C['coral'], ms=4)
    ax.annotate('$T(0)=17$', xy=(0, 17), xytext=(4, 17.1), color=C['coral'])
    ax.set_xlabel('t (s)'); ax.set_ylabel('temperatura (°C)'); ax.grid(True)
    ax.set_xlim(0, 60)
    g(fig, 'f_senal_temperatura')


# ---------------------------------------------------- ejemplo del motor
def chrysler():
    t = np.linspace(0, 4, 400)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.7), gridspec_kw=dict(width_ratios=[1, 1.6], wspace=0.3))
    a1.axhline(0, color=C['gris'], lw=0.8); a1.axvline(0, color=C['gris'], lw=0.8)
    a1.plot([-2, -3], [0, 0], 'x', color=C['coral'], ms=9, mew=2)
    a1.plot([-5], [0], 'o', mfc='none', color=C['azul'], ms=8, mew=1.8)
    a1.annotate('$-2$', (-2, 0), xytext=(-2.2, 0.35), color=C['coral'])
    a1.annotate('$-3$', (-3, 0), xytext=(-3.25, 0.35), color=C['coral'])
    a1.annotate('cero $-5$', (-5, 0), xytext=(-5.6, -0.55), color=C['azul'])
    a1.set_xlim(-6, 1); a1.set_ylim(-1, 1); a1.set_xlabel('Re $s$'); a1.set_ylabel('Im $s$')
    a1.set_title('polos y ceros de $X(s)$')
    a2.plot(t, 3*np.exp(-2*t), color=C['coral'], ls='--', lw=1.4, label='$3e^{-2t}$ (polo en $-2$)')
    a2.plot(t, -2*np.exp(-3*t), color=C['violeta'], ls='--', lw=1.4, label='$-2e^{-3t}$ (polo en $-3$)')
    a2.plot(t, 3*np.exp(-2*t) - 2*np.exp(-3*t), color=C['noche'], lw=2.2, label='$x(t)$')
    a2.axhline(0, color=C['gris'], lw=0.8)
    a2.set_xlabel('t (s)'); a2.grid(True); a2.legend(loc='upper right')
    a2.set_title('cada polo aporta un modo')
    g(fig, 'f_chrysler')


# -------------------------------------------- polos complejos (ej. 2.x)
def polos_complejos():
    t = np.linspace(0, 20, 800)
    x = np.exp(-t/3)*(-np.cos(np.sqrt(2)*t/3) + 2.5*np.sqrt(2)*np.sin(np.sqrt(2)*t/3))
    env = np.exp(-t/3)*np.sqrt(1 + 12.5)
    fig, ax = plt.subplots(figsize=(5.6, 2.5))
    ax.fill_between(t, -env, env, color=C['azul'], alpha=0.07)
    ax.plot(t, env, color=C['azul'], lw=0.9, ls=':', label='envolvente $\\pm3.67e^{-t/3}$')
    ax.plot(t, -env, color=C['azul'], lw=0.9, ls=':')
    ax.plot(t, x, color=C['noche'], lw=2)
    ax.plot([0], [-1], 'o', color=C['coral'], ms=4)
    ax.set_xlabel('t (s)'); ax.set_ylabel('$x(t)$'); ax.grid(True); ax.legend(loc='upper right')
    ax.set_xlim(0, 20)
    g(fig, 'f_polos_complejos')


# --------------------------------------------------- proceso térmico
def termico():
    tau, M, Ts = 5, 2, 25
    t = np.linspace(-5, 40, 900)
    paso = (t >= 0).astype(float)
    e = M*(1 - np.exp(-np.maximum(t, 0)/tau))*paso
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.6), gridspec_kw=dict(wspace=0.32))
    a1.plot(t, M*paso, color=C['azul'], label='$\\hat{T}_i(t)$ (entrada)')
    a1.plot(t, e, color=C['coral'], label='$\\hat{T}(t)$ (salida)')
    a1.axvline(tau, color=C['gris'], ls=':', lw=0.8); a1.axhline(M*0.632, color=C['gris'], ls=':', lw=0.8)
    a1.annotate('63.2 % en $t=\\tau$', (tau, M*0.632), xytext=(9, 0.75), color=C['gris'],
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    a1.set_title('variables desviación'); a1.set_xlabel('t (s)'); a1.grid(True)
    a1.set_ylim(-0.2, 2.5); a1.legend(loc='lower right')
    a2.plot(t, Ts + M*paso, color=C['azul'], label='$T_i(t)$')
    a2.plot(t, Ts + e, color=C['coral'], label='$T(t)$')
    a2.axhline(Ts, color=C['gris'], lw=0.8, ls='--'); a2.text(-4, 25.1, '$T^*=T_i^*=25$', color=C['gris'])
    a2.set_title('variables físicas (°C)'); a2.set_xlabel('t (s)'); a2.grid(True)
    a2.set_ylim(24.8, 27.5); a2.legend(loc='center right')
    g(fig, 'f_termico')


# ------------------------------------------------ primer orden: escalón
def primer_orden_escalon():
    K1, tau = 10, 5
    t = np.linspace(0, 30, 600)
    y = K1*(1 - np.exp(-t/tau))
    fig, ax = plt.subplots(figsize=(6.2, 3.0))
    ax.plot(t, y, color=C['azul'], lw=2.2)
    ax.plot([0, tau], [0, K1], color=C['coral'], ls='--', lw=1.2)
    ax.annotate('pendiente inicial $K_1/\\tau$', (tau*0.55, K1*0.55), xytext=(6.5, 4.0), color=C['coral'],
                arrowprops=dict(arrowstyle='->', color=C['coral']))
    for n, col in zip(range(1, 6), [C['ambar'], C['violeta'], C['verde'], C['teal'], C['gris']]):
        yn = K1*(1 - np.exp(-n))
        ax.plot([n*tau, n*tau], [0, yn], ls=':', color=col, lw=1)
        ax.plot([n*tau], [yn], 'o', color=col, ms=4)
        ax.text(n*tau + 0.3, yn - 0.95, f'{100*(1-np.exp(-n)):.1f} %', color=col, fontsize=8.5)
    ax.axhline(K1, color=C['gris'], lw=0.8)
    ax.set_xticks([0, 5, 10, 15, 20, 25, 30])
    ax.set_xticklabels(['0', '$\\tau$', '$2\\tau$', '$3\\tau$', '$4\\tau$', '$5\\tau$', '$6\\tau$'])
    ax.set_ylabel('$y(t)$'); ax.set_xlabel('t'); ax.grid(True); ax.set_xlim(0, 30); ax.set_ylim(0, 11)
    ax.text(20, 3.2, '$K_1=10,\\ \\tau=5$', color=C['noche'])
    g(fig, 'f_primer_orden_escalon')


# -------------------------------------------------- primer orden: rampa
def primer_orden_rampa():
    fig, axs = plt.subplots(1, 2, figsize=(6.6, 2.7), sharey=True, gridspec_kw=dict(wspace=0.08))
    for ax, tau in zip(axs, [10, 1]):
        t = np.linspace(0, 40, 800)
        y = t - tau + tau*np.exp(-t/tau)
        ax.plot(t, t, color=C['azul'], ls='--', lw=1.4, label='$K_1u(t)=t$')
        ax.plot(t, y, color=C['coral'], lw=2, label='$y(t)$')
        tm = 32
        ax.annotate('', xy=(tm, tm), xytext=(tm, tm - tau*(1 - np.exp(-tm/tau))),
                    arrowprops=dict(arrowstyle='<->', color=C['noche']))
        ax.text(tm + 0.8, tm - tau/2 - 1, f'$K_1\\tau={tau}$', color=C['noche'])
        ax.set_title(f'$\\tau={tau}$'); ax.set_xlabel('t'); ax.grid(True); ax.set_xlim(0, 40); ax.set_ylim(0, 40)
    axs[0].legend(loc='upper left')
    g(fig, 'f_primer_orden_rampa')


# --------------------------------------- polos y modos (plano s -> tiempo)
def polos_modos():
    casos = [(-2, 0, 'polo real en $-2$', C['azul']), (-0.5, 0, 'polo real en $-0.5$', C['verde']),
             (0.3, 0, 'polo real en $+0.3$', C['coral']), (-0.4, 3, '$-0.4\\pm 3j$', C['violeta']),
             (0, 3, '$\\pm 3j$', C['ambar']), (0.25, 3, '$0.25\\pm 3j$', C['coral'])]
    fig = plt.figure(figsize=(6.6, 3.6))
    gs = fig.add_gridspec(2, 4, width_ratios=[1.3, 1, 1, 1], wspace=0.35, hspace=0.55)
    ap = fig.add_subplot(gs[:, 0])
    ap.axhline(0, color=C['gris'], lw=0.8); ap.axvline(0, color=C['gris'], lw=0.8)
    ap.axvspan(-3, 0, color=C['verde'], alpha=0.06); ap.text(-2.5, -3.9, 'estable', color=C['verde'], fontsize=8)
    t = np.linspace(0, 10, 500)
    for k, (sg, wd, nom, col) in enumerate(casos):
        ap.plot([sg], [wd], 'x', color=col, ms=8, mew=2)
        if wd:
            ap.plot([sg], [-wd], 'x', color=col, ms=8, mew=2)
        ap.text(sg - 0.08, wd + 0.3, str(k + 1), color=col, fontsize=8.5, fontweight='bold')
        ax = fig.add_subplot(gs[k//3, 1 + k % 3])
        y = np.exp(sg*t)*(np.cos(wd*t) if wd else 1)
        ax.plot(t, y, color=col, lw=1.6); ax.axhline(0, color=C['gris'], lw=0.6)
        ax.set_title(f'{k+1}: {nom}', fontsize=8); ax.set_xticks([]); ax.set_yticks([])
        lim = max(1.2, min(abs(y).max(), 5)*1.1); ax.set_ylim(-lim, lim)
    ap.set_xlim(-2.6, 1.0); ap.set_ylim(-4.2, 4.2); ap.set_xlabel('Re $s$'); ap.set_ylabel('Im $s$')
    ap.set_title('plano-$s$')
    g(fig, 'f_polos_modos')


if __name__ == '__main__':
    senal_temperatura(); chrysler(); polos_complejos(); termico()
    primer_orden_escalon(); primer_orden_rampa(); polos_modos()
