"""Figuras del capítulo 2 (sistemas unidimensionales). PDF (notas) y SVG (web).
Cada figura reproduce un script de codigo/cap02_unidimensionales/ (se indica cuál).
Ejecutar:  python3 herramientas/cap02_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.optimize import brentq
from estilo import C, guardar

CAP = 'cap02'


def g(fig, nombre):
    guardar(fig, nombre, CAP)


def ode(f, T, x0, n=2001, t0=0, **kw):
    t = np.linspace(t0, T, n)
    s = solve_ivp(f, (t0, T), np.atleast_1d(x0), t_eval=t, rtol=1e-10, atol=1e-12, **kw)
    return s.t, s.y


def h_diodo(v):
    return 17.76*v - 103.79*v**2 + 229.62*v**3 - 226.31*v**4 + 83.72*v**5


def dh_diodo(v):
    return 17.76 - 2*103.79*v + 3*229.62*v**2 - 4*226.31*v**3 + 5*83.72*v**4


def linea_fase(a, f, xr, eqs=None, col=None, n=1201, marcar=True):
    """Misma convención que comun/lineaFase.m: lleno = estable, vacío = inestable,
    gris = semiestable; triángulos = sentido del flujo. Tipo por el signo de f."""
    x = np.linspace(*xr, n); y = f(x)
    a.plot(x, y, color=col or C['azul'], lw=1.8)
    a.axhline(0, color=C['noche'], lw=0.7)
    if eqs is None:
        eqs = [brentq(f, x[i], x[i + 1]) for i in range(n - 1) if y[i]*y[i + 1] < 0]
    eqs = sorted(eqs)
    hh = 1e-4*(xr[1] - xr[0])
    bordes = [xr[0]] + list(eqs) + [xr[1]]
    for i in range(len(bordes) - 1):
        xm = 0.5*(bordes[i] + bordes[i + 1]); s = np.sign(f(np.array([xm]))[0])
        if s != 0 and bordes[i + 1] - bordes[i] > 0.04*(xr[1] - xr[0]):
            a.plot(xm, 0, '>' if s > 0 else '<', color=C['azul'], ms=6, zorder=4)
    tipos = []
    for e in eqs:
        fl, fr = f(np.array([e - hh]))[0], f(np.array([e + hh]))[0]
        tipo = 'estable' if fl > 0 > fr else ('inestable' if fl < 0 < fr else 'semiestable')
        tipos.append(tipo)
        if marcar:
            cara = {'estable': C['noche'], 'inestable': 'white', 'semiestable': '#AAAAAA'}[tipo]
            a.plot(e, 0, 'o', mfc=cara, mec=C['noche'], ms=7, mew=1.2, zorder=5)
    a.set_xlim(*xr); a.grid(True)
    return eqs, tipos


# ---------------------------------------------------------------- C2_Ej1
def seno():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.3))
    a = ax[0]
    linea_fase(a, np.sin, (-2*np.pi, 2*np.pi), eqs=list(np.arange(-2, 3)*np.pi))
    a.set_xticks(np.arange(-2, 3)*np.pi); a.set_xticklabels([r'$-2\pi$', r'$-\pi$', '0', r'$\pi$', r'$2\pi$'])
    a.set_xlabel('$x$'); a.set_ylabel(r'$\dot x=\sin x$'); a.set_title('línea de fase')
    a = ax[1]
    for x0 in np.linspace(-2*np.pi + 0.2, 2*np.pi - 0.2, 15):
        t, X = ode(lambda t, x: np.sin(x), 6, x0); a.plot(t, X[0], color=C['azul'], lw=1)
    for k in range(-2, 3):
        a.axhline(k*np.pi, color=C['noche'], lw=0.7, ls='--')
    t = np.linspace(0, 6, 13)
    a.plot(t, 2*np.arctan(np.tan(np.pi/8)*np.exp(t)), 'o', mfc='white', mec=C['coral'], ms=4.5, label=r'exacta, $x_0=\pi/4$')
    a.set_yticks(np.arange(-2, 3)*np.pi); a.set_yticklabels([r'$-2\pi$', r'$-\pi$', '0', r'$\pi$', r'$2\pi$'])
    a.set_xlabel('$t$'); a.set_ylabel('$x(t)$'); a.legend(fontsize=7, loc='lower right')
    a.set_title('ninguna cruza un equilibrio')
    g(fig, 'f_seno')


# ---------------------------------------------------------------- C2_Ej2
def no_hiperbolicos():
    fig, ax = plt.subplots(2, 3, figsize=(6.8, 3.9), gridspec_kw=dict(wspace=0.35, hspace=0.6))
    casos = [(lambda x: -x**3, r'$\dot x=-x^3$: estable'), (lambda x: x**3, r'$\dot x=x^3$: inestable'),
             (lambda x: x**2, r'$\dot x=x^2$: semiestable')]
    for j, (f, tit) in enumerate(casos):
        linea_fase(ax[0, j], f, (-1.5, 1.5), eqs=[0]); ax[0, j].set_title(tit, fontsize=9); ax[0, j].set_xlabel('$x$')
        a = ax[1, j]
        for x0 in [-1.5, -1, -0.5, 0.5, 1, 1.5]:
            ev = lambda t, x: abs(x[0]) - 3; ev.terminal = True
            s = solve_ivp(lambda t, x: f(x), (0, 6), [x0], events=ev, rtol=1e-10, atol=1e-12, max_step=0.01)
            a.plot(s.t, s.y[0], color=C['azul'] if x0 < 0 else C['coral'], lw=1)
        a.set_ylim(-3.1, 3.1); a.set_xlim(0, 6); a.grid(True); a.set_xlabel('$t$')
    ax[1, 0].set_ylabel('$x(t)$')
    t = np.linspace(0, 6, 200)
    ax[1, 0].plot(t, 1.5/np.sqrt(1 + 2*1.5**2*t), ':', color=C['noche'], lw=1)
    ax[1, 0].text(2.3, 0.85, r'$\sim t^{-1/2}$', fontsize=8, color=C['noche'])
    g(fig, 'f_no_hiperbolicos')


# ---------------------------------------------------------------- C2_Ej3
def potencial():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.4), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; s = np.linspace(-2*np.pi, 2*np.pi, 801)
    a.plot(s, np.cos(s) - 1, color=C['violeta'])
    a.plot([-np.pi, np.pi], [-2, -2], 'o', color=C['noche'], ms=6)
    a.plot([-2*np.pi, 0, 2*np.pi], [0, 0, 0], 'o', mfc='white', mec=C['noche'], ms=6)
    a.annotate('', xy=(2.6, np.cos(2.6) - 1), xytext=(1.0, np.cos(1.0) - 1),
               arrowprops=dict(arrowstyle='-|>', color=C['coral'], lw=1.5))
    a.set_xticks(np.arange(-2, 3)*np.pi); a.set_xticklabels([r'$-2\pi$', r'$-\pi$', '0', r'$\pi$', r'$2\pi$'])
    a.set_xlabel('$x$'); a.set_ylabel(r'$V(x)=\cos x-1$'); a.grid(True); a.set_title('la bolita baja por $V$')
    a = ax[1]
    for x0 in [-3, -2, -1, -0.2, 0.2, 1, 2, 3]:
        t, X = ode(lambda t, x: np.sin(x), 8, x0); a.plot(t, np.cos(X[0]) - 1, color=C['violeta'], lw=1)
    a.set_xlabel('$t$'); a.set_ylabel('$V(x(t))$'); a.grid(True); a.set_title('$V$ nunca crece')
    g(fig, 'f_potencial')


# ---------------------------------------------------------------- C2_Ej4
def cosecha():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.3))
    a = ax[0]
    for h, col in [(0, C['gris']), (0.2, C['azul']), (0.25, C['ambar']), (0.3, C['coral'])]:
        f = lambda x, h=h: x*(1 - x) - h
        if h in (0.2,):
            linea_fase(a, f, (0, 1), col=col)
        else:
            s = np.linspace(0, 1, 300); a.plot(s, f(s), color=col, lw=1.4 if h else 1)
        a.text(0.5, 0.25 - h + 0.012, f'$h={h}$', color=col, fontsize=7.5, ha='center')
    a.plot(0.5, 0, 'o', mfc='#AAAAAA', mec=C['noche'], ms=6)
    a.set_ylim(-0.35, 0.3); a.set_xlabel('$x$'); a.set_ylabel(r'$\dot x=x(1-x)-h$')
    a.set_title('dos equilibrios chocan en $h=1/4$', fontsize=9)
    a = ax[1]
    ev = lambda t, x: x[0]; ev.terminal = True; ev.direction = -1
    for x0 in [0.2, 0.3, 0.5, 0.9]:
        s = solve_ivp(lambda t, x: x*(1 - x) - 0.2, (0, 20), [x0], events=ev, rtol=1e-10, atol=1e-12, max_step=0.02)
        a.plot(s.t, s.y[0], color=C['azul'], lw=1.2)
    s = solve_ivp(lambda t, x: x*(1 - x) - 0.3, (0, 20), [0.5], events=ev, rtol=1e-10, atol=1e-12, max_step=0.02)
    a.plot(s.t, s.y[0], color=C['coral'], lw=1.6, ls='--')
    a.text(s.t[-1] + 0.3, 0.03, f'$t={s.t[-1]:.2f}$', color=C['coral'], fontsize=8)
    for xs in [(1 - np.sqrt(0.2))/2, (1 + np.sqrt(0.2))/2]:
        a.axhline(xs, color=C['noche'], ls=':', lw=0.8)
    a.set_xlim(0, 20); a.set_ylim(-0.02, 1); a.set_xlabel('$t$'); a.set_ylabel('$x(t)$'); a.grid(True)
    a.set_title('$h=0.2$ (azul) y $h=0.3$ (coral)', fontsize=9)
    g(fig, 'f_cosecha')


# ---------------------------------------------------------------- C2_Ej5
E0, R, Cp = 1.2, 1.5, 2.0


def diodo():
    f = lambda v: ((E0 - v)/R - h_diodo(v))/Cp
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.32))
    a = ax[0]; vv = np.linspace(-0.05, 1.15, 600)
    a.plot(vv, h_diodo(vv), color=C['coral'], label='$i=h(v)$')
    a.plot(vv, (E0 - vv)/R, color=C['noche'], ls='--', lw=1.2, label='recta de carga $(E-v)/R$')
    eqs, tipos = linea_fase(ax[1], f, (-0.05, 1.15))
    for e, tp in zip(eqs, tipos):
        a.plot(e, h_diodo(e), 'o', mfc=C['noche'] if tp == 'estable' else 'white', mec=C['noche'], ms=6)
    a.set_ylim(-0.1, 1.35); a.set_xlabel('$v$ [V]'); a.set_ylabel('$i$ [mA]'); a.grid(True); a.legend(fontsize=7)
    a.set_title('equilibrios = intersecciones')
    ax[1].set_xlabel('$v$ [V]'); ax[1].set_ylabel(r'$\dot v$ [V/ns]'); ax[1].set_title('línea de fase')
    g(fig, 'f_diodo')
    fig, a = plt.subplots(figsize=(4.6, 2.5))
    for v0 in np.arange(0, 1.01, 0.1):
        t, X = ode(lambda t, v: f(v), 6, v0)
        a.plot(t, X[0], color=C['azul'] if v0 < 0.2854 else C['violeta'], lw=1.1)
    for e in eqs:
        a.axhline(e, color=C['noche'], ls='--', lw=0.7)
    a.set_xlabel('$t$ [ns]'); a.set_ylabel('$v(t)$ [V]'); a.grid(True); a.set_xlim(0, 6)
    g(fig, 'f_diodo_tiempo')
    return eqs


# ---------------------------------------------------------------- C2_Ej6
def histeresis():
    Tm, Emax = 4000.0, 1.8
    E = lambda t: Emax*min(t, 2*Tm - t)/Tm
    s = solve_ivp(lambda t, v: ((E(t) - v)/R - h_diodo(v))/Cp, (0, 2*Tm), [0.0], max_step=0.5,
                  rtol=1e-9, atol=1e-11, dense_output=True)
    t = np.linspace(0, 2*Tm, 40001); v = s.sol(t)[0]; Et = np.array([E(x) for x in t])
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.7), gridspec_kw=dict(wspace=0.32, width_ratios=[1.2, 1]))
    a = ax[0]; vv = np.linspace(-0.05, 1.2, 800); Eq = vv + R*h_diodo(vv)
    dg = 1 + R*dh_diodo(vv)
    a.plot(np.where(dg > 0, Eq, np.nan), vv, color=C['claro'], lw=5, label='equilibrios estables')
    a.plot(np.where(dg < 0, Eq, np.nan), vv, color=C['claro'], lw=1.5, ls='--', label='inestables')
    mid = len(t)//2
    a.plot(Et[:mid], v[:mid], color=C['azul'], lw=1.6, label='subiendo $E$')
    a.plot(Et[mid:], v[mid:], color=C['coral'], lw=1.6, label='bajando $E$')
    a.annotate('', xy=(1.66, 1.0), xytext=(1.66, 0.25), arrowprops=dict(arrowstyle='-|>', color=C['azul']))
    a.annotate('', xy=(0.64, 0.12), xytext=(0.64, 0.45), arrowprops=dict(arrowstyle='-|>', color=C['coral']))
    a.set_xlim(0, 1.8); a.set_ylim(-0.05, 1.2); a.set_xlabel('$E$ [V]'); a.set_ylabel('$v$ [V]'); a.grid(True)
    a.legend(fontsize=6.6, loc='upper left'); a.set_title('histéresis')
    a = ax[1]
    for Ev, col in [(0.5, C['gris']), (1.2, C['azul']), (1.75, C['coral'])]:
        f = lambda x, Ev=Ev: ((Ev - x)/R - h_diodo(x))/Cp
        x = np.linspace(-0.05, 1.2, 500); a.plot(x, f(x), color=col, lw=1.4, label=f'$E={Ev}$ V')
    a.axhline(0, color=C['noche'], lw=0.7); a.set_ylim(-0.6, 0.8); a.grid(True)
    a.set_xlabel('$v$ [V]'); a.set_ylabel(r'$\dot v$'); a.legend(fontsize=7); a.set_title('uno, tres, uno')
    g(fig, 'f_histeresis')
    up = Et[np.where((v[:-1] < 0.5) & (v[1:] >= 0.5))[0][0]]
    dn = Et[np.where((v[:-1] > 0.5) & (v[1:] <= 0.5))[0][0]]
    return up, dn


# ---------------------------------------------------------------- C2_Ej7
def halcon():
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.4), gridspec_kw=dict(wspace=0.38))
    for a, (v, c) in zip(ax[:2], [(1, 3), (3, 1)]):
        f = lambda p, v=v, c=c: 0.5*p*(1 - p)*(v - c*p)
        linea_fase(a, f, (0, 1), eqs=[0, v/c, 1] if v < c else [0, 1])
        a.set_xlabel('$p_1$'); a.set_title(f'$v={v}$, $c={c}$')
    ax[0].set_ylabel(r'$\dot p_1$')
    a = ax[2]
    for p0 in [0.01, 0.1, 0.2, 0.5, 0.7, 0.9, 0.99]:
        t, X = ode(lambda t, p: 0.5*p*(1 - p)*(1 - 3*p), 40, p0); a.plot(t, X[0], color=C['azul'], lw=1)
    a.axhline(1/3, color=C['noche'], ls='--', lw=0.8); a.set_ylim(0, 1); a.set_xlabel('$t$'); a.set_ylabel('$p_1(t)$')
    a.grid(True); a.set_title('$v=1$, $c=3$: todos a $1/3$', fontsize=9)
    g(fig, 'f_halcon')


# ---------------------------------------------------------------- C2_Ej8
def no_unicidad():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; t = np.linspace(0, 3, 601)
    xc = lambda t, c: (t > c)*((2/3)*np.maximum(t - c, 0))**1.5
    for c, col in zip([0, 0.5, 1, 1.5], [C['azul'], C['violeta'], C['ambar'], C['verde']]):
        a.plot(t, xc(t, c), color=col, label=f'$c={c}$'); a.plot(t, -xc(t, c), color=col, lw=0.9, alpha=0.6)
    a.plot(t, 0*t, color=C['noche'], lw=3, label=r'$x\equiv0$ (ode45)')
    a.set_xlabel('$t$'); a.set_ylabel('$x$'); a.grid(True); a.legend(fontsize=6.8, loc='upper left', ncol=2)
    a.set_title(r'$\dot x=x^{1/3}$, $x(0)=0$', fontsize=9)
    a = ax[1]
    for x0 in [0.25, 0.5, 1]:
        T = 1.5*x0**(2/3); tt = np.linspace(0, 3, 601)
        a.plot(tt, np.where(tt < T, np.maximum(x0**(2/3) - 2*tt/3, 0)**1.5, 0), color=C['coral'])
        a.plot(T, 0, 'o', color=C['coral'], ms=4)
    a.set_xlabel('$t$'); a.set_ylabel('$x$'); a.grid(True)
    a.set_title(r'$\dot x=-x^{1/3}$: llega a 0 en $T=\frac{3}{2}x_0^{2/3}$', fontsize=9)
    g(fig, 'f_no_unicidad')


# ---------------------------------------------------------------- C2_Ej9
def escape():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.28))
    ev = lambda t, x: abs(x[0]) - 1e3; ev.terminal = True
    a = ax[0]
    for x0, col in zip([0.25, 0.5, 1, 2], [C['azul'], C['violeta'], C['ambar'], C['coral']]):
        s = solve_ivp(lambda t, x: x**2, (0, 6), [x0], events=ev, rtol=1e-10, atol=1e-12, max_step=0.002)
        a.plot(s.t, s.y[0], color=col, label=f'$x_0={x0}$'); a.axvline(1/x0, color=col, ls='--', lw=0.7)
    a.set_ylim(0, 20); a.set_xlim(0, 4.5); a.set_xlabel('$t$'); a.set_ylabel('$x(t)$'); a.grid(True)
    a.legend(fontsize=7); a.set_title(r'$\dot x=x^2$: escape en $1/x_0$', fontsize=9)
    a = ax[1]
    for x0 in [-3, -2, -0.5, 0.5, 0.95, 1.05, 1.5, 3]:
        s = solve_ivp(lambda t, x: x**2 - 1, (0, 4), [x0], events=ev, rtol=1e-10, atol=1e-12, max_step=0.002)
        a.plot(s.t, s.y[0], color=C['azul'] if x0 < 1 else C['coral'], lw=1.1)
    a.axhline(-1, color=C['noche'], lw=0.8); a.axhline(1, color=C['noche'], lw=0.8, ls='--')
    a.set_ylim(-3.2, 4); a.set_xlim(0, 4); a.set_xlabel('$t$'); a.grid(True)
    a.set_title(r'$\dot x=x^2-1$: atracción de $-1$ es $(-\infty,1)$', fontsize=9)
    g(fig, 'f_escape')


if __name__ == '__main__':
    seno(); no_hiperbolicos(); potencial(); cosecha()
    print('  diodo: equilibrios', [round(e, 4) for e in diodo()])
    print('  histéresis: saltos en E =', [round(e, 3) for e in histeresis()])
    halcon(); no_unicidad(); escape()
