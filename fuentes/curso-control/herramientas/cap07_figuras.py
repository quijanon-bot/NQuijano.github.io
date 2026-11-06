"""Figuras del capítulo 7 (PID: nociones básicas). PDF (notas) y SVG (web).
Ejecutar:  python3 herramientas/cap07_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
import control as ct
from estilo import C, guardar
from pidsim import simular

CAP = 'cap07'
s = ct.tf('s')
g = lambda fig, n: guardar(fig, n, CAP)


def paso(G, t):
    return ct.step_response(G, t).outputs


def tiempos():
    """Pasado (integral: área), presente (proporcional: valor), futuro (derivada: tendencia)."""
    t = np.linspace(0, 6, 600); e = 0.9*np.exp(-0.35*t) + 0.12*np.sin(1.2*t) + 0.15
    t1 = 2.5; i1 = np.searchsorted(t, t1); e1 = e[i1]; de = np.gradient(e, t)[i1]
    fig, ax = plt.subplots(figsize=(6.2, 2.6))
    ax.fill_between(t[:i1 + 1], 0, e[:i1 + 1], color=C['azul'], alpha=0.15)
    ax.plot(t, e, color=C['noche'])
    ax.plot([t1, t1], [0, e1], color=C['coral'], lw=2)
    tf_ = np.linspace(t1, t1 + 1.5, 20); ax.plot(tf_, e1 + de*(tf_ - t1), '--', color=C['verde'], lw=1.8)
    ax.plot(t1 + 1.5, e1 + de*1.5, 'o', color=C['verde'], ms=4)
    ax.text(1.0, 0.25, 'pasado: I\n(área)', color=C['azul'], ha='center')
    ax.text(t1 - 0.9, e1/2 + 0.05, 'presente: P\n(valor)', color=C['coral'])
    ax.text(t1 + 1.55, e1 + de*1.5 + 0.05, 'futuro: D\n(tendencia)', color=C['verde'], fontsize=8.5)
    ax.axhline(0, color=C['gris'], lw=0.7); ax.set_xlabel('t'); ax.set_ylabel('$e(t)$'); ax.set_yticks([]); ax.set_xticks([t1]); ax.set_xticklabels(['ahora'])
    g(fig, 'f_tiempos')


def onoff():
    """Relé (on/off) sobre e^{-2s}/(10s+1), r = 50 %, u en {10 %, 90 %}."""
    dt = 0.01; t = np.arange(0, 80, dt); L = 2.0; nL = int(L/dt)
    y = np.zeros_like(t); u = np.zeros_like(t); buf = [0.0]*nL; yk = 0.0; r = 50.0
    for k in range(len(t)):
        y[k] = yk; u[k] = 90.0 if r - yk > 0 else 10.0
        buf.append(u[k]); uin = buf.pop(0); yk += dt*(-yk + uin)/10.0
    fig, (a1, a2) = plt.subplots(2, 1, figsize=(6.2, 3.3), sharex=True, gridspec_kw=dict(hspace=0.15))
    a1.plot(t, 50*np.ones_like(t), '--', color=C['azul'], label='referencia $r$')
    a1.plot(t, y, color=C['coral'], label='PV $y$'); a1.set_ylabel('%'); a1.set_ylim(0, 85); a1.legend(loc='upper left', ncol=2, fontsize=8); a1.grid(True)
    a2.plot(t, u, color=C['noche'], label='OC $u$'); a2.plot(t, 50 - y, '--', color=C['azul'], label='error $e$')
    a2.set_ylabel('%'); a2.set_ylim(-15, 130); a2.set_xlabel('t (s)'); a2.legend(loc='upper left', ncol=2, fontsize=8); a2.grid(True)
    g(fig, 'f_onoff')


def banda():
    e = np.linspace(-1, 1, 400)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.2, 2.3), gridspec_kw=dict(wspace=0.3))
    a1.plot(e, np.where(e > 0, 90, 10), color=C['noche']); a1.set_title('on/off')
    e0 = 0.4; u = np.clip(50 + 40/e0*e, 10, 90)
    a2.plot(e, u, color=C['azul']); a2.axvspan(-e0, e0, color=C['azul'], alpha=0.1); a2.set_title('proporcional con banda')
    a2.text(0, 20, 'banda\nproporcional', ha='center', color=C['azul'], fontsize=8)
    for a in (a1, a2):
        a.set_xlabel('$e$'); a.set_ylabel('$u$ (%)'); a.set_yticks([10, 50, 90]); a.grid(True)
    g(fig, 'f_banda')


def integral():
    t = np.linspace(0, 20, 2001); G = 1/(s + 1)
    fig, axs = plt.subplots(1, 2, figsize=(7.0, 2.6), gridspec_kw=dict(wspace=0.3))
    T = ct.feedback(G/s, 1); y = paso(T, t); e = 1 - y
    u = ct.step_response(ct.feedback(1/s, G), t).outputs
    axs[0].plot(t, y, color=C['coral'], label='$y$'); axs[0].plot(t, e, '--', color=C['azul'], label='$e$')
    axs[0].plot(t, u, color=C['noche'], label='$u$'); axs[0].axhline(0, color=C['gris'], lw=0.6)
    axs[0].set_title('$G_c=1/s$, $G_p=1/(s+1)$'); axs[0].legend(ncol=3, fontsize=8); axs[0].grid(True); axs[0].set_xlabel('t (s)')
    for Ti, c in ((1, C['azul']), (2, C['coral']), (5, C['ambar'])):
        axs[1].plot(t, paso(ct.feedback(G/(Ti*s), 1), t), color=c, label=f'$T_i={Ti}$')
    axs[1].set_title('$G_c=1/(T_i s)$'); axs[1].legend(fontsize=8); axs[1].grid(True); axs[1].set_xlabel('t (s)')
    g(fig, 'f_integral')


def derivada():
    t = np.linspace(0, 4, 400); t1 = 2.0
    ea = np.where(t <= t1, 1 - 0.35*t, 1 - 0.35*t)            # cae
    eb = 1 - 0.35*t1 + 0.0*t
    eb = np.where(t <= t1, 1.0 - 0.35*t, 0.3 + 0.6*(t - t1))
    ea = np.where(t <= t1, 1.0 - 0.35*t, 0.3 - 0.6*(t - t1))
    fig, axs = plt.subplots(1, 2, figsize=(6.2, 2.2), sharey=True)
    for a, e, tit in ((axs[0], ea, '(a) el error cae rápido'), (axs[1], eb, '(b) el error vuelve a subir')):
        m = t <= t1; a.fill_between(t[m], 0, e[m], color=C['azul'], alpha=0.12)
        a.plot(t[m], e[m], color=C['noche']); a.plot(t[~m], e[~m], ':', color=C['coral'])
        a.axvline(t1, color=C['gris'], lw=0.7); a.axhline(0, color=C['gris'], lw=0.7); a.set_title(tit, fontsize=9)
        a.set_xticks([t1]); a.set_xticklabels(['$t_1$']); a.set_yticks([])
    axs[0].set_ylabel('$e(t)$')
    g(fig, 'f_derivada')


def mra():
    P = 1/(s**2 + 10*s + 20); t = np.linspace(0, 2, 2001); t2 = np.linspace(0, 4, 4001)
    fig, axs = plt.subplots(2, 2, figsize=(7.0, 4.6), gridspec_kw=dict(hspace=0.45, wspace=0.25))
    cols = [C['azul'], C['coral'], C['ambar'], C['violeta'], C['verde'], C['noche']]
    for Kc, c in zip((1, 10, 50, 100, 200, 500), cols):
        axs[0, 0].plot(t, paso(ct.feedback(Kc*P, 1), t), color=c, label=f'{Kc}')
    axs[0, 0].set_title('P: $K_c$ = 1 … 500'); axs[0, 0].legend(fontsize=7, ncol=3, title='$K_c$', title_fontsize=7)
    for Kd, c in zip((1, 5, 10, 15, 20, 25), cols):
        axs[0, 1].plot(t, paso(ct.feedback((300 + Kd*s)*P, 1), t), color=c, label=f'{Kd}')
    axs[0, 1].set_title('PD: $K_c=300$, $K_d$ = 1 … 25'); axs[0, 1].legend(fontsize=7, ncol=3, title='$K_d$', title_fontsize=7)
    for Ki, c in zip((1, 40, 80, 120, 160, 200), cols):
        axs[1, 0].plot(t2, paso(ct.feedback((300 + Ki/s)*P, 1), t2), color=c, label=f'{Ki}')
    axs[1, 0].set_title('PI: $K_c=300$, $K_i$ = 1 … 200'); axs[1, 0].legend(fontsize=7, ncol=3, title='$K_i$', title_fontsize=7)
    axs[1, 1].plot(t, paso(P, t)*20, ':', color=C['gris'], label='lazo abierto ×20')
    axs[1, 1].plot(t, paso(ct.feedback((350 + 300/s + 50*s)*P, 1), t), color=C['noche'], label='PID 350/300/50')
    axs[1, 1].set_title('PID: $K_c=350$, $K_i=300$, $K_d=50$'); axs[1, 1].legend(fontsize=7)
    for a in axs.flat:
        a.axhline(1, color=C['gris'], lw=0.6, ls='--'); a.grid(True); a.set_xlabel('t (s)')
    g(fig, 'f_mra')


def ruido():
    w = np.logspace(-2, 3, 500); Kc, Ti, Td = 3, 8, 2
    fig, ax = plt.subplots(figsize=(6.2, 2.7))
    ax.loglog(w, np.abs(Kc*(1 + 1/(Ti*1j*w) + Td*1j*w)), color=C['noche'], label='sin filtro')
    for Nv, c in ((5, C['azul']), (10, C['coral']), (20, C['ambar'])):
        ax.loglog(w, np.abs(Kc*(1 + 1/(Ti*1j*w) + Td*1j*w/(Td*1j*w/Nv + 1))), color=c, label=f'$N={Nv}$')
        ax.axhline(Kc*(1 + Nv), color=c, lw=0.6, ls=':')
    ax.set_xlabel('$\\omega$ (rad/s)'); ax.set_ylabel('$|G_c(j\\omega)|$'); ax.grid(True, which='both', alpha=0.4); ax.legend(fontsize=8)
    g(fig, 'f_ruido')


def kicks():
    P = 1/(s**2 + 10*s + 20)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.6), gridspec_kw=dict(wspace=0.3))
    for (nom, b, c_), col in zip((('estándar', 1, 1), ('PI-D', 1, 0), ('I-PD', 0, 0)), (C['coral'], C['azul'], C['verde'])):
        t, y, u, *_ = simular(P, 350, 350/300, 50/350, tf=3, dt=1e-4, b=b, c=c_, N=(50/350)/0.01)
        a1.plot(t, y, color=col, label=nom); a2.plot(t, u, color=col, label=nom)
    a1.set_title('salida $y$'); a2.set_title('señal de control $u$ (recortada)'); a2.set_ylim(-100, 600); a2.set_xlim(-0.05, 1)
    a2.annotate('pico ≈ 5300\n(derivative kick)', xy=(0.0, 590), xytext=(0.15, 450), fontsize=8, color=C['coral'], arrowprops=dict(arrowstyle='->', color=C['coral']))
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)'); a.legend(fontsize=8)
    g(fig, 'f_kicks')


def windup():
    G = 1/(10*s + 1)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.7), gridspec_kw=dict(wspace=0.3))
    for (nom, kw), col in zip((('sin anti-windup', dict()), ('back-calculation, $T_t=4$', dict(aw='back', Tt=4.0)),
                               ('integración condicional', dict(aw='clamp'))), (C['coral'], C['azul'], C['verde'])):
        t, y, u, v, I = simular(G, 3, 8, 2, tf=100, dt=0.005, L=4, N=10, umin=0, umax=1.5, **kw)
        a1.plot(t, y, color=col, label=nom); a2.plot(t, u, color=col); a2.plot(t, I, ':', color=col)
    a1.axhline(1, color=C['gris'], ls='--', lw=0.6); a1.set_title('salida $y$'); a1.legend(fontsize=7.5, loc='lower right')
    a2.set_title('$u$ (—) y término integral (···)'); a2.set_ylim(-0.2, 3.5)
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)')
    g(fig, 'f_windup')


def beta():
    Gp = 1/((s + 1)*(s + 5))
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.6), gridspec_kw=dict(wspace=0.3))
    for b, col in zip((1, 0.5, 0.3, 0), (C['coral'], C['ambar'], C['azul'], C['verde'])):
        t, y, *_ = simular(Gp, 20, 0.3, 0, tf=6, dt=1e-3, b=b); a1.plot(t, y, color=col, label=f'$\\beta={b}$')
    t, y, *_ = simular(Gp, 20, 0.3, 0, tf=6, dt=1e-3, r=0.0, d=1.0, td=0.0); a2.plot(t, y, color=C['noche'], label='cualquier $\\beta$')
    a1.set_title('cambio de referencia'); a2.set_title('perturbación a la entrada'); a1.legend(fontsize=8)
    a2.legend(fontsize=8)
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)')
    g(fig, 'f_beta')


if __name__ == '__main__':
    tiempos(); onoff(); banda(); integral(); derivada(); mra(); ruido(); kicks(); windup(); beta()
