"""Figuras del capítulo 6 (error en estado estacionario). python3 herramientas/cap06_figuras.py"""
import numpy as np
import matplotlib.pyplot as plt
import control as ct
from estilo import C, guardar
g = lambda fig, n: guardar(fig, n, 'cap06')
s = ct.tf('s')
arr = lambda x: np.asarray(x).ravel()


def senales():
    t = np.linspace(-1, 5, 601)
    fig, axs = plt.subplots(1, 3, figsize=(7.0, 2.2), gridspec_kw=dict(wspace=0.35))
    for a, (y, tit) in zip(axs, (((t >= 0)*1.0, 'escalón: $1/s$'), ((t >= 0)*t, 'rampa: $1/s^2$'), ((t >= 0)*t**2/2, 'parábola: $1/s^3$'))):
        a.plot(t, y, color=C['azul']); a.set_title(tit); a.grid(True); a.set_xlabel('t')
    g(fig, 'f_senales')


def tipos():
    t = np.linspace(0, 12, 2401)
    plantas = (('tipo 0', 4/((s+1)*(s+2))), ('tipo 1', 4/(s*(s+2))), ('tipo 2', 4*(s+0.5)/(s**2*(s+2))))
    fig, axs = plt.subplots(2, 3, figsize=(7.0, 3.8), sharex=True, gridspec_kw=dict(hspace=0.35, wspace=0.3))
    for j, (nom, G) in enumerate(plantas):
        T = ct.feedback(G, 1)
        for i, (r, tit) in enumerate(((np.ones_like(t), 'escalón'), (t, 'rampa'))):
            y = arr(ct.forced_response(T, t, r).outputs)
            a = axs[i, j]; a.plot(t, r, '--', color=C['gris'], lw=1.2); a.plot(t, y, color=C['coral'])
            a.set_title(f'{nom}, {tit}', fontsize=9); a.grid(True)
    for a in axs[1]:
        a.set_xlabel('t (s)')
    g(fig, 'f_tipos')


def no_unitaria():
    G = 100/(s+1); H = 1/(s+5); t = np.linspace(0, 3, 3001)
    T = ct.feedback(G, H); y = arr(ct.step_response(T, t).outputs)
    yH = arr(ct.step_response(T*H, t).outputs)
    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    ax.plot(t, np.ones_like(t), '--', color=C['gris'], label='$r$')
    ax.plot(t, y, color=C['noche'], label='$y$')
    ax.plot(t, 1-yH, color=C['verde'], label='$e_a=r-Hy$')
    ax.plot(t, 1-y, color=C['coral'], label='$e=r-y$')
    ax.axhline(1/21, color=C['verde'], lw=0.6, ls=':'); ax.axhline(1-100/21, color=C['coral'], lw=0.6, ls=':')
    ax.set_xlabel('t (s)'); ax.legend(ncol=4, fontsize=8, loc='lower center', bbox_to_anchor=(0.5, 1.0)); ax.grid(True); ax.set_ylim(-5, 7)
    g(fig, 'f_no_unitaria')


def perturbacion():
    Gp = 1/((s+1)*(s+2)); t = np.linspace(0, 15, 3001)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.6), gridspec_kw=dict(wspace=0.3))
    for K, c in ((1, C['azul']), (10, C['ambar']), (100, C['coral'])):
        e = arr(ct.step_response(-0.5*ct.feedback(Gp, K), t).outputs); a1.plot(t, e, color=c, label=f'P, $K={K}$')
    e = arr(ct.step_response(-0.5*ct.feedback(Gp, 10+18/s), t).outputs); a1.plot(t, e, color=C['verde'], lw=2, label='PI, $K=10$, $K_i=18$')
    a1.set_title('perturbación a la entrada'); a1.legend(fontsize=7); a1.set_xlabel('t (s)'); a1.grid(True)
    for K, c in ((1, C['azul']), (10, C['ambar']), (100, C['coral'])):
        e = arr(ct.step_response(-0.5*ct.feedback(1, K*Gp), t).outputs); a2.plot(t, e, color=c)
    a2.set_title('perturbación a la salida'); a2.set_xlabel('t (s)'); a2.grid(True)
    a1.set_ylabel('$e=-y$')
    g(fig, 'f_perturbacion')


def atraso():
    G = 1/(s*(s+4)*(s+8)); K = 67.83; a, b = 0.0519, 0.005
    T0 = ct.feedback(K*G, 1); T1 = ct.feedback(K*(s+a)/(s+b)*G, 1)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.6), gridspec_kw=dict(wspace=0.3))
    t = np.linspace(0, 15, 3001)
    a1.plot(t, arr(ct.step_response(T0, t).outputs), color=C['azul'], label='solo $K$')
    a1.plot(t, arr(ct.step_response(T1, t).outputs), color=C['coral'], label='con atraso')
    a1.set_title('escalón'); a1.legend(fontsize=8); a1.grid(True); a1.set_xlabel('t (s)')
    t = np.linspace(0, 400, 8001)
    a2.plot(t, t-arr(ct.forced_response(T0, t, t).outputs), color=C['azul'])
    a2.plot(t, t-arr(ct.forced_response(T1, t, t).outputs), color=C['coral'])
    a2.axhline(0.05, color=C['gris'], ls=':', lw=1); a2.set_ylim(0, 0.6)
    a2.set_title('error ante rampa'); a2.grid(True); a2.set_xlabel('t (s)')
    g(fig, 'f_atraso')


def sensibilidad():
    w = np.logspace(-2, 3, 800)
    fig, ax = plt.subplots(figsize=(6.0, 2.8))
    for K, ls in ((10, '--'), (200, '-')):
        L = K/((1j*w+1)*(1j*w+10)); S = abs(1/(1+L)); T = abs(L/(1+L))
        ax.loglog(w, S, ls, color=C['azul'], label=f'$|S|$, $K={K}$'); ax.loglog(w, T, ls, color=C['coral'], label=f'$|T|$, $K={K}$')
    ax.axvspan(0.1, 0.4, color=C['verde'], alpha=0.12); ax.axvspan(30, 80, color=C['ambar'], alpha=0.15)
    ax.text(0.12, 2e-3, 'perturbación', fontsize=8, color=C['verde']); ax.text(32, 2e-3, 'ruido', fontsize=8, color=C['ambar'])
    ax.set_xlabel('$\\omega$ (rad/s)'); ax.legend(fontsize=7.5, ncol=2, loc='lower left'); ax.grid(True, which='both', alpha=0.4); ax.set_ylim(1e-3, 3)
    g(fig, 'f_sensibilidad')


if __name__ == '__main__':
    senales(); tipos(); no_unitaria(); perturbacion(); atraso(); sensibilidad()
