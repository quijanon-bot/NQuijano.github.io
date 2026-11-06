"""Figuras del capítulo 8 (PID: sintonización). PDF (notas) y SVG (web).
Ejecutar:  python3 herramientas/cap08_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
import control as ct
from estilo import C, guardar
from pidsim import simular

CAP = 'cap08'
s = ct.tf('s')
g = lambda fig, n: guardar(fig, n, CAP)
paso = lambda G, t: ct.step_response(G, t).outputs


def retrasar(t, y, L):
    return np.where(t >= L, np.interp(t - L, t, y), 0.0)


def tipos():
    t = np.linspace(0, 30, 3001)
    casos = [('(a) primer orden', paso(1/(4*s + 1), t)),
             ('(b) orden superior', paso(1/(2*s + 1)**4, t)),
             ('(c) integrador', paso(1/(s*(s + 1)), t)/10),
             ('(d) oscilatorio', paso(1/(s**2 + 0.4*s + 1), t)),
             ('(e) tiempo muerto', retrasar(t, paso(1/(4*s + 1), t), 6)),
             ('(f) respuesta inversa', paso((1 - 3*s)/((2*s + 1)*(4*s + 1)), t))]
    fig, axs = plt.subplots(2, 3, figsize=(7.0, 3.6), sharex=True, gridspec_kw=dict(hspace=0.45, wspace=0.3))
    for a, (tit, y) in zip(axs.flat, casos):
        a.plot(t, y, color=C['azul']); a.axhline(0, color=C['gris'], lw=0.6); a.set_title(tit, fontsize=9)
        a.set_yticks([]); a.grid(True)
    for a in axs[1]:
        a.set_xlabel('t')
    g(fig, 'f_tipos')


def identificacion():
    G = 1/((8*s + 1)*(2*s + 1)); t = np.linspace(0, 60, 60001); L0 = 2
    y = retrasar(t, paso(G, t), L0); dy = np.gradient(y, t); i = np.argmax(dy)
    tm, ym, m = t[i], y[i], dy[i]; L = tm - ym/m; t63 = np.interp(0.632, y[t > tm], t[t > tm]); T100 = 1/m
    fig, ax = plt.subplots(figsize=(6.4, 2.9))
    ax.plot(t, y, color=C['noche'], lw=2, label='PV')
    tt = np.linspace(L, L + T100, 10); ax.plot(tt, m*(tt - L), '--', color=C['coral'], label='tangente de máxima pendiente')
    ax.axhline(1, color=C['gris'], lw=0.6); ax.axhline(0.632, color=C['gris'], lw=0.6, ls=':')
    ax.plot(tm, ym, 'o', color=C['coral'], ms=4)
    for x0, x1, yv, txt, c in ((0, L, -0.08, f'$L={L:.1f}$', C['violeta']), (L, t63, 0.55, f'$\\tau_{{63}}={t63-L:.1f}$', C['azul']),
                                (L, L + T100, 1.08, f'$\\tau_{{ZN}}={T100:.1f}$', C['ambar'])):
        ax.annotate('', xy=(x1, yv), xytext=(x0, yv), arrowprops=dict(arrowstyle='<->', color=c))
        ax.text((x0 + x1)/2, yv + 0.04, txt, color=c, ha='center', fontsize=8.5)
    ax.text(42, 0.66, '63 %', color=C['gris'], fontsize=8)
    ax.set_xlim(0, 45); ax.set_ylim(-0.15, 1.2); ax.set_xlabel('t (s)'); ax.set_ylabel('$\\Delta y/\\Delta y_\\infty$')
    ax.legend(loc='lower right', fontsize=8); ax.grid(True)
    g(fig, 'f_identificacion')


def integrador():
    t = np.linspace(0, 20, 2001); L = 3; Kv = 0.05
    y = np.where(t > L, Kv*10*(t - L), 0)
    fig, ax = plt.subplots(figsize=(5.0, 2.4))
    ax.plot(t, y, color=C['noche']); ax.plot([L, L + 10], [0, Kv*10*10], ':', color=C['coral'])
    ax.annotate('', xy=(L, -0.3), xytext=(0, -0.3), arrowprops=dict(arrowstyle='<->', color=C['violeta']))
    ax.text(L/2, -0.2, '$L$', color=C['violeta'], ha='center')
    ax.text(12, 2.5, 'pendiente $v$\n$K_v=v/\\Delta u_c$', color=C['coral'], fontsize=8.5)
    ax.set_xlabel('t'); ax.set_ylabel('$\\Delta y$'); ax.grid(True); ax.set_ylim(-0.6, 9)
    g(fig, 'f_integrador')


def malla_abierta():
    K, L, T = 2, 2, 10.0; r = L/T
    reglas = [('Ziegler-Nichols', (1.2*T/(L*K), 2*L, 0.5*L), C['coral']),
              ('Cohen-Coon', ((T/(K*L))*(4/3 + r/4), L*(32 + 6*r)/(13 + 8*r), 4*L/(11 + 2*r)), C['ambar']),
              ('coef. de ajustabilidad', (0.5*(1 + 0.5*r)/(K*r), T*(1 + 0.5*r), T*0.5*r/(0.5*r + 1)), C['azul'])]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.7), gridspec_kw=dict(wspace=0.3))
    for nom, p, c in reglas:
        t, y, *_ = simular(K/(T*s + 1), *p, tf=60, dt=0.005, L=L, N=10, c=0); a1.plot(t, y, color=c, label=nom)
        t, y, *_ = simular(K/(T*s + 1), *p, tf=60, dt=0.005, L=L, N=10, c=0, r=0.0, d=1.0, td=0.0); a2.plot(t, y, color=c)
    a1.set_title('cambio de referencia'); a2.set_title('perturbación a la entrada'); a1.legend(fontsize=7.5)
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)')
    g(fig, 'f_malla_abierta')


def malla_cerrada():
    den = [6, 11, 6, 1]; Kcr, Pcr = 10.0, 2*np.pi; Gp = 1/ct.tf(den, [1])
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.7), gridspec_kw=dict(wspace=0.3))
    t = np.linspace(0, 40, 4001)
    for f, c in ((0.8, C['azul']), (1.0, C['ambar']), (1.1, C['coral'])):
        a1.plot(t, paso(ct.feedback(f*Kcr*Gp, 1), t), color=c, label=f'$K_c={f:g}K_{{cr}}$')
    a1.set_title('$K_{cr}=10$, $P_{cr}=2\\pi$ s'); a1.legend(fontsize=7.5); a1.set_ylim(-0.3, 2.2)
    for nom, p, c in (('Ziegler-Nichols', (0.6*Kcr, Pcr/2, Pcr/8), C['coral']), ('Tyreus-Luyben', (Kcr/2.2, 2.2*Pcr, Pcr/6.3), C['azul'])):
        tt, y, *_ = simular(Gp, *p, tf=60, dt=0.002, N=10); a2.plot(tt, y, color=c, label=nom)
    a2.set_title('PID ideal'); a2.legend(fontsize=7.5)
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)')
    g(fig, 'f_malla_cerrada')


def sintesis_nomin():
    Gp = (1 - 9*s)/((15*s + 1)*(3*s + 1)); t = np.linspace(0, 120, 6001)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.6), gridspec_kw=dict(wspace=0.3))
    for lv, c in ((5, C['coral']), (10, C['ambar']), (20, C['azul'])):
        Gc = (45*s**2 + 18*s + 1)/(s*(lv**2*s + 2*lv + 9))
        a1.plot(t, paso(ct.feedback(Gc*Gp, 1), t), color=c, label=f'$\\lambda={lv}$')
        a2.plot(t, paso(ct.feedback(Gc, Gp), t), color=c)
    a1.set_title('salida $y$'); a2.set_title('señal de control $u$'); a1.legend(fontsize=8)
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)')
    g(fig, 'f_sintesis_nomin')


def imc_interna():
    Gp = (1 - 9*s)/((15*s + 1)*(3*s + 1)); t = np.linspace(0, 60, 6001); lv = 5
    Q1 = (15*s + 1)*(3*s + 1)/((1 - 9*s)*(lv*s + 1)); Q2 = (15*s + 1)*(3*s + 1)/((lv*s + 1)**2)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(7.0, 2.6), gridspec_kw=dict(wspace=0.3))
    a1.plot(t, paso(ct.minreal(Gp*Q1, verbose=False), t), color=C['coral'], label='$Q$ invierte el cero')
    a1.plot(t, paso(Gp*Q2, t), '--', color=C['azul'], label='$Q$ sin el cero')
    a2.plot(t, paso(Q1, t), color=C['coral']); a2.plot(t, paso(Q2, t), '--', color=C['azul']); a2.set_ylim(-60, 20)
    a1.set_title('salida $y$'); a2.set_title('señal de control $u$'); a1.legend(fontsize=8)
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)')
    g(fig, 'f_imc_interna')


def imc_robusto():
    Gp = 1.5*(1 - s)/((s + 1)*(4*s + 1)); Gm = 2/(5*s + 1); t = np.linspace(0, 40, 4001)
    fig, ax = plt.subplots(figsize=(6.2, 2.6))
    for lv, c in ((0.85, C['coral']), (1.5, C['ambar']), (3, C['azul'])):
        Q = (5*s + 1)/(2*(lv*s + 1)); Gc = ct.minreal(Q/(1 - Gm*Q), verbose=False)
        ax.plot(t, paso(ct.feedback(Gc*Gp, 1), t), color=c, label=f'$\\lambda={lv}$' + (' (inestable)' if lv < 0.887 else ''))
    ax.set_ylim(-1, 2.5); ax.grid(True); ax.set_xlabel('t (s)'); ax.legend(fontsize=8)
    g(fig, 'f_imc_robusto')


def imc_fopdt():
    K, tp, th = 1.2, 20.0, 4.0
    fig, ax = plt.subplots(figsize=(6.2, 2.6))
    for lv, c in ((3.2, C['coral']), (6.7, C['ambar']), (10, C['azul'])):
        p = ((tp + th/2)/(K*(lv + th/2)), tp + th/2, tp*th/(2*tp + th))
        t, y, *_ = simular(K/(tp*s + 1), *p, tf=100, dt=0.005, L=th, N=10); ax.plot(t, y, color=c, label=f'$\\lambda={lv}$')
    ax.grid(True); ax.set_xlabel('t (s)'); ax.legend(fontsize=8)
    g(fig, 'f_imc_fopdt')


if __name__ == '__main__':
    tipos(); identificacion(); integrador(); malla_abierta(); malla_cerrada(); sintesis_nomin(); imc_interna(); imc_robusto(); imc_fopdt()
