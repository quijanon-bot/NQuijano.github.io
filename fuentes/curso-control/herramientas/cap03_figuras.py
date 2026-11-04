"""Figuras del capítulo 3 (Modelado II). Genera PDF (notas) y SVG (web).
Ejecutar:  python3 herramientas/cap03_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
import control as ct
from scipy.integrate import solve_ivp
from estilo import C, guardar

CAP = 'cap03'
s = ct.tf('s')


def g(fig, nombre):
    guardar(fig, nombre, CAP)


def paso(G, t):
    return ct.step_response(G, t)[1]


# ------------------------------------------------------------ linealización
def linealizacion():
    x = np.linspace(0, 10, 400)
    f = x*np.sqrt(x**2 + 5*x)
    x0, f0, d = 5, 5*np.sqrt(50), np.sqrt(50) + 5*15/(2*np.sqrt(50))
    fig, ax = plt.subplots(figsize=(5.6, 2.9))
    ax.plot(x, f, color=C['azul'], lw=2.2, label='$f(x)=x\\sqrt{x^2+5x}$')
    ax.plot(x, f0 + d*(x - x0), color=C['coral'], ls='--', lw=1.6, label='$f(x_0)+f\'(x_0)(x-x_0)$')
    err = np.abs(f0 + d*(x - x0) - f)/np.maximum(f, 1e-9)
    ok = x[(err < 0.05)]
    ax.axvspan(ok.min(), ok.max(), color=C['verde'], alpha=0.10)
    ax.text(ok.min() + 0.1, 100, f'error < 5 %\n${ok.min():.1f}\\leq x\\leq {ok.max():.1f}$', color=C['verde'], fontsize=8.5)
    ax.plot([x0], [f0], 'o', color=C['noche'], ms=5)
    ax.annotate('$x_0=5$', (x0, f0), xytext=(5.6, 15), color=C['noche'], arrowprops=dict(arrowstyle='->', color=C['gris']))
    ax.set_xlabel('$x$'); ax.set_ylabel('$\\dot x$'); ax.grid(True); ax.legend(loc='upper left')
    ax.set_xlim(0, 10); ax.set_ylim(-20, 130)
    g(fig, 'f_linealizacion')
    print('     rango 5 %:', ok.min(), ok.max())


# -------------------------------------------------- tanques: NL vs lineal
A1, A2, Cv1, Cv2 = 2.0, 3.0, 0.1, 0.05
h2e = 4.0; fe = Cv2*np.sqrt(h2e); h1e = h2e + (fe/Cv1)**2
C1 = Cv1/(2*np.sqrt(h1e - h2e)); C3 = Cv2/(2*np.sqrt(h2e))


def tanques():
    G = (1/C1)*(C1/(C3 + C1))/((A1/C1*s + 1)*(A2/(C3 + C1)*s + 1) - (1/C1)*(C1/(C3 + C1))*C1)
    t = np.linspace(0, 4000, 2001)
    fig, axs = plt.subplots(1, 2, figsize=(6.6, 2.7), gridspec_kw=dict(wspace=0.3))
    for ax, df in zip(axs, [0.01, 0.05]):
        def rhs(_, h):
            h1, h2 = h
            f1 = Cv1*np.sqrt(max(h1 - h2, 0)); f2 = Cv2*np.sqrt(max(h2, 0))
            return [(fe + df - f1)/A1, (f1 - f2)/A2]
        sol = solve_ivp(rhs, (0, t[-1]), [h1e, h2e], t_eval=t, rtol=1e-8, atol=1e-10)
        ax.plot(t, sol.y[1], color=C['azul'], lw=2.2, label='no lineal')
        ax.plot(t, h2e + df*paso(G, t), color=C['coral'], ls='--', lw=1.6, label='linealizado')
        ax.axhline(h2e, color=C['gris'], lw=0.8, ls=':')
        ax.set_title(f'escalón de {df} m³/s en $f_i$'); ax.set_xlabel('t (s)'); ax.grid(True)
        ax.text(2200, h2e + 0.3*(sol.y[1][-1] - h2e), f'final: {sol.y[1][-1]:.2f} vs {h2e + df/C3:.2f}', color=C['noche'], fontsize=8.5)
    axs[0].set_ylabel('$h_2$ (m)'); axs[0].legend(loc='lower right')
    g(fig, 'f_tanques')


# ----------------------------------------------- segundo orden: varios zeta
def zetas():
    t = np.linspace(0, 12, 1200)
    zs = [0, 0.2, 0.5, 0.7, 1, 2]
    cols = [C['coral'], C['ambar'], C['violeta'], C['azul'], C['verde'], C['noche']]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.9), gridspec_kw=dict(width_ratios=[1, 1.7], wspace=0.28))
    th = np.linspace(0, 2*np.pi, 200)
    a1.plot(np.cos(th), np.sin(th), color=C['claro'], lw=0.8)
    a1.axhline(0, color=C['gris'], lw=0.8); a1.axvline(0, color=C['gris'], lw=0.8)
    for z, c in zip(zs, cols):
        p = np.roots([1, 2*z, 1])
        a1.plot(p.real, p.imag, 'x', color=c, ms=7, mew=2)
        a2.plot(t, paso(1/(s**2 + 2*z*s + 1), t), color=c, lw=1.8, label=f'$\\zeta={z}$')
    a1.set_xlim(-4.0, 0.5); a1.set_ylim(-1.3, 1.3)
    a1.set_xlabel('Re $s$'); a1.set_ylabel('Im $s$'); a1.set_title('polos ($\\omega_n=1$)')
    a1.text(-3.9, 0.15, '$\\zeta=2$', color=C['noche'], fontsize=8)
    a2.axhline(1, color=C['gris'], lw=0.8); a2.set_xlim(0, 12); a2.set_ylim(0, 2.05)
    a2.set_xlabel('$\\omega_n t$'); a2.set_title('respuesta al escalón unitario'); a2.grid(True)
    a2.legend(ncol=2, loc='upper right')
    g(fig, 'f_zetas')


# ------------------------------------------------- características (z=0.4)
def caracteristicas():
    z, wn = 0.4, 1.0
    wd = wn*np.sqrt(1 - z**2); sg = z*wn
    t = np.linspace(0, 14, 4000)
    y = paso(wn**2/(s**2 + 2*z*wn*s + wn**2), t)
    tp = np.pi/wd; OS = np.exp(-z*np.pi/np.sqrt(1 - z**2)); tr0 = (np.pi - np.arccos(z))/wd
    t10 = t[np.argmax(y >= 0.1)]; t90 = t[np.argmax(y >= 0.9)]
    fuera = np.where(abs(y - 1) > 0.02)[0]; ts = t[fuera[-1] + 1]
    fig, ax = plt.subplots(figsize=(6.4, 3.3))
    env = np.exp(-sg*t)/np.sqrt(1 - z**2)
    ax.plot(t, 1 + env, color=C['gris'], ls=':', lw=1); ax.plot(t, 1 - env, color=C['gris'], ls=':', lw=1)
    ax.fill_between(t, 0.98, 1.02, color=C['verde'], alpha=0.15)
    ax.plot(t, y, color=C['azul'], lw=2.2)
    ax.axhline(1, color=C['gris'], lw=0.8)
    ax.annotate('', xy=(tp, 1 + OS), xytext=(tp, 1), arrowprops=dict(arrowstyle='<->', color=C['coral']))
    ax.text(tp + 0.25, 1.30, f'%OS = {100*OS:.1f} %', color=C['coral'])
    ax.plot([tp, tp], [0, 1 + OS], ls='--', color=C['coral'], lw=0.9)
    ax.text(tp + 0.1, 0.05, f'$t_p={tp:.2f}$', color=C['coral'])
    ax.plot([t10, t90], [0.1, 0.9], 'o', color=C['violeta'], ms=4)
    ax.annotate('', xy=(t90, 0.9), xytext=(t10, 0.9), arrowprops=dict(arrowstyle='<->', color=C['violeta']))
    ax.text(2.5, 0.6, f'$t_r$ (10–90 %) $={t90 - t10:.2f}$', color=C['violeta'], ha='left', fontsize=9)
    ax.plot([tr0], [1], 'o', color=C['ambar'], ms=4)
    ax.annotate(f'$t_r$ (0–100 %) $={tr0:.2f}$', (tr0, 1), xytext=(3.9, 1.62), color=C['ambar'], fontsize=9, arrowprops=dict(arrowstyle='->', color=C['ambar']))
    ax.plot([ts, ts], [0, 1.02], ls='--', color=C['verde'], lw=0.9)
    ax.text(ts + 0.15, 0.25, f'$t_s$ (2 %) $={ts:.2f}$\n$4/(\\zeta\\omega_n)={4/sg:.0f}$', color=C['verde'], fontsize=9)
    ax.text(7.5, 1.5, 'envolventes $1\\pm e^{-\\zeta\\omega_n t}/\\sqrt{1-\\zeta^2}$', color=C['gris'], fontsize=9)
    ax.set_xlim(0, 14); ax.set_ylim(0, 1.75); ax.set_xlabel('t (s)'); ax.set_ylabel('$y(t)$'); ax.grid(True)
    ax.set_title('$\\zeta=0.4$, $\\omega_n=1$ rad/s')
    g(fig, 'f_caracteristicas')


# --------------------------------------------------------------- %OS vs zeta
def os_zeta():
    z = np.linspace(0.001, 0.999, 400)
    os_ = 100*np.exp(-z*np.pi/np.sqrt(1 - z**2))
    fig, ax = plt.subplots(figsize=(5.4, 2.7))
    ax.plot(z, os_, color=C['azul'], lw=2.2)
    for zz in [0.2, 0.4559, 0.5912, 0.707]:
        o = 100*np.exp(-zz*np.pi/np.sqrt(1 - zz**2))
        ax.plot([zz], [o], 'o', color=C['coral'], ms=4)
        ax.annotate(f'({zz:.3g}, {o:.1f} %)', (zz, o), xytext=(zz + 0.03, o + 5), color=C['coral'], fontsize=8.5)
    ax.set_xlabel('$\\zeta$'); ax.set_ylabel('%OS'); ax.grid(True); ax.set_xlim(0, 1); ax.set_ylim(0, 100)
    g(fig, 'f_os_zeta')


# ----------------------------------------- moverse por líneas del plano s
def lineas_plano():
    t = np.linspace(0, 7, 1500)
    fig, axs = plt.subplots(2, 3, figsize=(6.6, 4.0), gridspec_kw=dict(height_ratios=[1, 1.1], hspace=0.45, wspace=0.3))
    casos = [('$t_s$ constante (vertical)', [(-1, 1.5), (-1, 3), (-1, 6)]),
             ('$t_p$ constante (horizontal)', [(-0.6, 3), (-1.5, 3), (-3, 3)]),
             ('$\\zeta$ constante (radial)', [(-0.75, 1.5), (-1.5, 3), (-3, 6)])]
    cols = [C['azul'], C['coral'], C['verde']]
    for k, (tit, polos) in enumerate(casos):
        ap, ay = axs[0, k], axs[1, k]
        ap.axhline(0, color=C['gris'], lw=0.6); ap.axvline(0, color=C['gris'], lw=0.6)
        for (sg, wd), c in zip(polos, cols):
            ap.plot([sg, sg], [wd, -wd], 'x', color=c, ms=6, mew=1.8)
            wn2 = sg**2 + wd**2
            ay.plot(t, paso(wn2/(s**2 - 2*sg*s + wn2), t), color=c, lw=1.6)
        ap.set_xlim(-3.5, 0.5); ap.set_ylim(-6.8, 6.8); ap.set_title(tit, fontsize=9)
        ap.set_xticks([-3, -2, -1, 0]); ap.tick_params(labelsize=7.5)
        if k == 0:
            ap.axvline(-1, color=C['gris'], ls=':', lw=0.9)
        elif k == 1:
            ap.axhline(3, color=C['gris'], ls=':', lw=0.9)
        else:
            ap.plot([0, -3.4], [0, 6.8], color=C['gris'], ls=':', lw=0.9)
        ay.axhline(1, color=C['gris'], lw=0.6); ay.set_ylim(0, 1.75); ay.grid(True); ay.tick_params(labelsize=7.5)
        ay.set_xlabel('t (s)')
    axs[0, 0].set_ylabel('Im $s$'); axs[1, 0].set_ylabel('$y(t)$')
    g(fig, 'f_lineas_plano')


# --------------------------------------------------------- diseño K y Kh
def diseno():
    OS = 0.2
    z = -np.log(OS)/np.sqrt(np.pi**2 + np.log(OS)**2); wn = np.pi/np.sqrt(1 - z**2)
    K = wn**2; Kh = (2*z*wn - 1)/K
    t = np.linspace(0, 4, 2000)
    T = ct.feedback(K/s/(s + 1), 1 + Kh*s)
    T0 = ct.feedback(K/s/(s + 1), 1)
    fig, ax = plt.subplots(figsize=(5.6, 2.7))
    ax.plot(t, paso(T0, t), color=C['gris'], lw=1.3, ls='--', label='sin tacómetro ($K_h=0$)')
    ax.plot(t, paso(T, t), color=C['azul'], lw=2.2, label=f'$K={K:.2f}$, $K_h={Kh:.3f}$')
    ax.axhline(1.2, color=C['coral'], lw=0.8, ls=':'); ax.axvline(1, color=C['coral'], lw=0.8, ls=':')
    ax.plot([1], [1.2], 'o', color=C['coral'], ms=5)
    ax.text(1.05, 1.24, '$t_p=1$ s, %OS = 20 %', color=C['coral'])
    ax.axhline(1, color=C['gris'], lw=0.6)
    ax.set_xlabel('t (s)'); ax.set_ylabel('$y(t)$'); ax.grid(True); ax.legend(loc='lower right'); ax.set_ylim(0, 1.9)
    g(fig, 'f_diseno_kkh')


# --------------------------------------------------------- polos dominantes
def dominantes():
    t = np.linspace(0, 7, 2000)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.7), gridspec_kw=dict(wspace=0.28))
    a1.plot(t, paso(20/((s + 10)*(s**2 + 2*s + 2)), t), color=C['azul'], lw=2.2, label='$\\frac{20}{(s+10)(s^2+2s+2)}$')
    a1.plot(t, paso(2/(s**2 + 2*s + 2), t), color=C['coral'], ls='--', lw=1.6, label='$\\frac{2}{s^2+2s+2}$')
    a1.set_title('polo lejano: se puede despreciar'); a1.legend(loc='lower right', fontsize=9.5)
    tt = np.linspace(0, 3, 2000)
    a2.plot(tt, paso(62.5*(s + 2.5)/((s**2 + 6*s + 25)*(s + 6.25)), tt), color=C['azul'], lw=2.2, label='completo (38 %)')
    a2.plot(tt, paso(10*(s + 2.5)/(s**2 + 6*s + 25), tt), color=C['coral'], ls='--', lw=1.6, label='sin el polo (54.5 %)')
    a2.plot(tt, paso(25/(s**2 + 6*s + 25), tt), color=C['gris'], ls=':', lw=1.6, label='solo dominantes (9.5 %)')
    a2.set_title('polo y cero cercanos: no'); a2.legend(loc='lower right', fontsize=8.5)
    for a in (a1, a2):
        a.axhline(1, color=C['gris'], lw=0.6); a.grid(True); a.set_xlabel('t (s)')
    a1.set_ylabel('$y(t)$'); a2.set_ylim(0, 1.65)
    g(fig, 'f_dominantes')


# ------------------------------------------------------------- reducción
def reduccion():
    t = np.linspace(0, 8, 2000)
    d1, d2 = 1.61503, 0.62361
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.7), gridspec_kw=dict(wspace=0.28))
    a1.plot(t, paso(ct.feedback(60/(s*(s + 2)*(s + 30)), 1), t), color=C['azul'], lw=2.2, label='$\\frac{K}{s(s+2)(s+30)}$')
    a1.plot(t, paso(ct.feedback(2/(s*(s + 2)), 1), t), color=C['coral'], ls='--', lw=1.6, label='$\\frac{K/30}{s(s+2)}$')
    a1.set_title('despreciar el polo en $-30$ ($K=60$)'); a1.legend(loc='lower right', fontsize=9.5)
    a2.plot(t, paso(6/(s**3 + 6*s**2 + 11*s + 6), t), color=C['azul'], lw=2.2, label='$G_H$: polos $-1,-2,-3$')
    a2.plot(t, paso(1/(d2*s**2 + d1*s + 1), t), color=C['coral'], ls='--', lw=1.6, label='$G_L$: polos $-1.02,-1.57$')
    a2.set_title('igualación de momentos'); a2.legend(loc='lower right', fontsize=8.5)
    for a in (a1, a2):
        a.axhline(1, color=C['gris'], lw=0.6); a.grid(True); a.set_xlabel('t (s)')
    a1.set_ylabel('$y(t)$')
    g(fig, 'f_reduccion')


# ---------------------------------------------------- masa-resorte (ej. 3.x)
def masa_resorte():
    t = np.linspace(0, 12, 1500)
    G = 1/(s**2 + 1.2*s + 4)
    fig, ax = plt.subplots(figsize=(5.4, 2.5))
    ax.plot(t, paso(G, t), color=C['azul'], lw=2.2)
    ax.axhline(0.25, color=C['gris'], lw=0.8)
    ax.set_xlabel('t (s)'); ax.set_ylabel('$x(t)$ (m)'); ax.grid(True)
    ax.text(4.5, 0.1, '$m=1$, $b=1.2$, $k=4$:  $\\omega_n=2$, $\\zeta=0.3$', color=C['noche'])
    g(fig, 'f_masa_resorte')


if __name__ == '__main__':
    linealizacion(); tanques(); zetas(); caracteristicas(); os_zeta(); lineas_plano()
    diseno(); dominantes(); reduccion(); masa_resorte()
