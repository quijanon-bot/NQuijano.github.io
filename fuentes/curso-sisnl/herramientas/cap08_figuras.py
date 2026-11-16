"""Figuras del capítulo 8 (principio de invarianza y construcción de funciones de Lyapunov).
PDF (notas) y SVG (web). Cada figura reproduce un script de codigo/cap08_invarianza/ (se indica cuál).
Ejecutar:  python3 herramientas/cap08_figuras.py   [nombre_de_función ...]
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.linalg import solve_continuous_lyapunov
from estilo import C, guardar
from cap04_figuras import campo, punto, ejes

CAP = 'cap08'
def g(fig, nombre): guardar(fig, nombre, CAP)
o = dict(rtol=1e-10, atol=1e-12)


def sim(f, x0, T, n=4000, **kw):
    return solve_ivp(lambda t, z: f(z), (0, T), x0, t_eval=np.linspace(0, T, n), **o, **kw)


def zona(ax, X, Y, mask, col, alfa=0.25):
    ax.contourf(X, Y, mask.astype(float), levels=[0.5, 1.5], colors=[col], alpha=alfa)


# ------------------------------------------------------------------ 8.2-8.3 péndulo
def pendulo():                      # C8_Ej2 [pendulo] y [permanencia]
    a, b, c = 1.0, 0.3, 1.8
    f = lambda z: [z[1], -a*np.sin(z[0]) - b*z[1]]
    V = lambda x1, x2: a*(1 - np.cos(x1)) + x2**2/2
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.1), gridspec_kw=dict(width_ratios=[1.35, 1], wspace=0.3))
    A = ax[0]; X, Y = np.meshgrid(np.linspace(-9.5, 9.5, 700), np.linspace(-2.6, 2.6, 400))
    VV = V(X, Y)
    zona(A, X, Y, (VV <= c) & (np.abs(X) >= np.pi), C['gris'], 0.22)
    zona(A, X, Y, (VV <= c) & (np.abs(X) < np.pi), C['azul'], 0.25)
    A.contour(X, Y, VV, levels=[2*a], colors=[C['noche']], linewidths=0.9)
    xE = np.arccos(1 - c/a)
    A.plot([-xE, xE], [0, 0], color=C['coral'], lw=3, solid_capstyle='butt')
    s = sim(f, [2.0, 0.8], 40, 8000)
    A.plot(s.y[0], s.y[1], color=C['noche'], lw=0.9)
    ev = lambda t, z: z[1]
    r = solve_ivp(lambda t, z: f(z), (0, 40), [2.0, 0.8], events=ev, **o)
    A.plot(r.y_events[0][:, 0], r.y_events[0][:, 1], 's', color=C['coral'], ms=3.5)
    for q in np.linspace(-xE, xE, 7):     # el campo sobre E es vertical
        if abs(q) > 0.05:
            A.annotate('', xy=(q, -0.55*np.sin(q)), xytext=(q, 0), arrowprops=dict(arrowstyle='-|>', color=C['violeta'], lw=1.1))
    for kx in (-2, 0, 2): punto(A, (kx*np.pi, 0), True)
    for kx in (-1, 1): punto(A, (kx*np.pi, 0), False)
    A.text(-9.2, 2.15, r'gris: $\{V\leq c\}$ fuera de $\Omega_c$', fontsize=7.5, color=C['gris'])
    A.text(-1.1, -1.85, r'$\Omega_c$', color=C['azul'], fontsize=9); A.text(1.0, 0.18, '$E$', color=C['coral'], fontsize=9)
    ejes(A, (-9.5, 9.5), (-2.6, 2.6), r'$\Omega_c$ ($c=1.8$), $E$ y una trayectoria')
    A.set_aspect('auto')
    A = ax[1]; t = s.t; Vt = V(*s.y); Vd = -b*s.y[1]**2
    A.plot(t, Vt, color=C['azul'], label='$V(x(t))$'); A.plot(t, Vd, color=C['coral'], lw=1.3, label=r'$\dot V(x(t))$')
    for te in r.t_events[0][:6]: A.axvline(te, color=C['gris'], lw=0.6, ls=':')
    A.set_xlim(0, 20); A.set_xlabel('$t$'); A.grid(True); A.legend(loc='upper right')
    A.set_title(r'$\dot V=0$ en los cruces; $V$ sigue bajando')
    g(fig, 'f_pendulo')


def limite():                       # C8_Ej1 [limite]
    fig, ax = plt.subplots(1, 3, figsize=(7.6, 2.6), gridspec_kw=dict(wspace=0.35))
    s = sim(lambda z: [z[1], -z[0] - 0.4*z[1]], [2, 0], 30)
    A = ax[0]; A.plot(s.y[0], s.y[1], color=C['azul'], lw=1.2); punto(A, (0, 0), True)
    ejes(A, (-2.3, 2.3), (-2.3, 2.3), r'(a) $\omega(x_0)=\{0\}$')
    fv = lambda z: [z[1], -z[0] + (1 - z[0]**2)*z[1]]
    A = ax[1]; s = sim(fv, [0.1, 0], 60, 12000); A.plot(s.y[0], s.y[1], color=C['claro'], lw=0.8)
    r = sim(fv, [2, 0], 100, 20000); m = r.t > 80; A.plot(r.y[0][m], r.y[1][m], color=C['coral'], lw=1.6)
    tn = np.arange(1, 61); q = solve_ivp(lambda t, z: fv(z), (0, 60), [0.1, 0], t_eval=tn, **o)
    A.scatter(q.y[0], q.y[1], c=tn, cmap='viridis', s=9, zorder=4)
    ejes(A, (-3, 3), (-3, 3), r'(b) $\omega(x_0)=\Gamma$')
    A = ax[2]; s = sim(lambda z: [0.5, -z[1]], [-2.5, 2], 12)
    A.plot(s.y[0], s.y[1], color=C['violeta'], lw=1.4); A.annotate('', xy=(3.4, 0.0), xytext=(2.6, 0.0), arrowprops=dict(arrowstyle='-|>', color=C['violeta']))
    ejes(A, (-3, 3.6), (-0.5, 2.3), r'(c) $\omega(x_0)=\emptyset$'); A.set_aspect('auto')
    g(fig, 'f_limite')


# ------------------------------------------------------------------ 8.4 ejemplos
def duffing():                      # C8_Ej3 [duffing]
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(wspace=0.28))
    X, Y = np.meshgrid(np.linspace(-2.5, 2.5, 500), np.linspace(-1.6, 1.6, 400))
    for A, k1, tit in [(ax[0], 1.0, 'resorte duro ($k_1=1$): GAS'), (ax[1], -1.0, r'resorte blando ($k_1=-1$): local')]:
        f = lambda z, k1=k1: [z[1], -(z[0] + k1*z[0]**3) - 0.4*z[1]*abs(z[1])]
        VV = X**2/2 + k1*X**4/4 + Y**2/2
        campo(A, lambda U, W: (W, -(U + k1*U**3) - 0.4*W*np.abs(W)), (-2.5, 2.5), (-1.6, 1.6), n=17)
        if k1 > 0:
            A.contour(X, Y, VV, levels=[0.1, 0.4, 1, 2], colors=[C['azul']], linewidths=0.8)
            for x0 in ([1.4, 0], [-1.0, 1.2], [0.4, -1.4]):
                s = sim(f, x0, 40); A.plot(s.y[0], s.y[1], color=C['noche'], lw=0.9)
            punto(A, (0, 0), True)
        else:
            cc = 0.24
            zona(A, X, Y, (VV <= cc) & (np.abs(X) >= 1), C['gris'], 0.25)
            zona(A, X, Y, (VV <= cc) & (np.abs(X) < 1), C['azul'], 0.25)
            A.contour(X, Y, VV, levels=[0.25], colors=[C['noche']], linewidths=1.0)
            s = sim(f, [0.9, 0], 60); A.plot(s.y[0], s.y[1], color=C['verde'], lw=1.0)
            esc = lambda t, z: abs(z[0]) - 3; esc.terminal = True
            s = solve_ivp(lambda t, z: f(z), (0, 20), [1.2, 0], events=esc, max_step=0.01, **o)
            A.plot(s.y[0], s.y[1], color=C['coral'], lw=1.4); A.plot(1.2, 0, 'o', color=C['coral'], ms=4)
            punto(A, (0, 0), True); punto(A, (1, 0), False); punto(A, (-1, 0), False)
            A.text(1.25, 0.12, '$V(x_0)=0.20<c$', fontsize=7.5, color=C['coral'])
        ejes(A, (-2.5, 2.5), (-1.6, 1.6), tit); A.set_aspect('auto')
    g(fig, 'f_duffing')


def ciclo():                        # C8_Ej4 [ciclo]
    f = lambda z: [z[0]*(1 - z[0]**2 - z[1]**2) - z[1], z[1]*(1 - z[0]**2 - z[1]**2) + z[0]]
    fig, ax = plt.subplots(1, 2, figsize=(7.2, 3.0), gridspec_kw=dict(width_ratios=[1, 1.2], wspace=0.3))
    A = ax[0]; c = 0.2; r1, r2 = np.sqrt(1 - 2*np.sqrt(c)), np.sqrt(1 + 2*np.sqrt(c))
    th = np.linspace(0, 2*np.pi, 300)
    A.fill(np.r_[r2*np.cos(th), r1*np.cos(th[::-1])], np.r_[r2*np.sin(th), r1*np.sin(th[::-1])], color=C['azul'], alpha=0.2)
    A.plot(np.cos(th), np.sin(th), color=C['coral'], lw=2.4)
    for x0 in ([1.3, 0.3], [0.0, -0.4]):
        s = sim(f, x0, 12); A.plot(s.y[0], s.y[1], color=C['noche'], lw=0.9)
    punto(A, (0, 0), False)
    A.text(-0.45, 0.05, '$E=M$', color=C['coral'], fontsize=9); A.text(0.6, 1.25, r'$\Omega_c$', color=C['azul'], fontsize=9)
    ejes(A, (-1.6, 1.6), (-1.6, 1.6), r'anillo $\Omega_{0.2}$ y el ciclo')
    A = ax[1]; rr = np.linspace(0, 1.6, 400)
    A.plot(rr, (rr**2 - 1)**2/4, color=C['noche']); A.axhline(c, color=C['azul'], ls='--', lw=1)
    A.axvspan(r1, r2, color=C['azul'], alpha=0.12)
    s = sim(f, [1.3, 0.3], 12, 40); R = np.hypot(*s.y)
    A.scatter(R, (R**2 - 1)**2/4, c=s.t, cmap='viridis', s=14, zorder=4)
    s = sim(f, [0.0, -0.4], 12, 40); R = np.hypot(*s.y)
    A.scatter(R, (R**2 - 1)**2/4, c=s.t, cmap='viridis', s=14, zorder=4, marker='s')
    A.text(0.02, 0.21, '$c=0.2$', color=C['azul'], fontsize=8); A.set_xlim(0, 1.6); A.set_ylim(0, 0.6)
    A.set_xlabel('$r$'); A.set_ylabel(r'$V=\frac{1}{4}(r^2-1)^2$'); A.grid(True)
    A.set_title('el "sombrero": $V(0)$ es un máximo')
    g(fig, 'f_ciclo')


def adaptativo():                   # C8_Ej5 [adaptativo]
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(width_ratios=[1, 1.2], wspace=0.3))
    f = lambda z: [-(z[1] - 1)*z[0], z[0]**2]
    A = ax[0]; Y, K = np.meshgrid(np.linspace(-3, 3, 300), np.linspace(-2.5, 5, 300))
    A.contour(Y, K, Y**2/2 + (K - 2)**2/2, levels=[0.5, 2, 4.5, 8], colors=[C['claro']], linestyles='--', linewidths=0.8)
    A.plot([0, 0], [-2.5, 1], color=C['coral'], lw=2.4); A.plot([0, 0], [1, 5], color=C['verde'], lw=2.4)
    for x0 in ([2, -1], [-1, 0], [0.5, 3], [-2.5, 2]):
        s = sim(f, x0, 30); A.plot(s.y[0], s.y[1], color=C['noche'], lw=1.0); A.plot(*x0, 'o', color=C['noche'], ms=3)
        kinf = 1 + np.sqrt((x0[1] - 1)**2 + x0[0]**2); A.plot(0, kinf, '*', color=C['ambar'], ms=10, zorder=5)
    A.text(0.15, -2.2, 'inestables', color=C['coral'], fontsize=7.5); A.text(0.15, 4.5, 'estables', color=C['verde'], fontsize=7.5)
    ejes(A, (-3, 3), (-2.5, 5), r'plano $(y,k)$, $a=\gamma=1$', '$y$', '$k$'); A.set_aspect('auto')
    A = ax[1]; s = sim(f, [2, -1], 8)
    A.plot(s.t, s.y[0], color=C['azul'], label='$y(t)$'); A.plot(s.t, s.y[1], color=C['violeta'], label='$k(t)$')
    A.axhline(1 + 2*np.sqrt(2), color=C['ambar'], ls='--', lw=1.1); A.axhline(2, color=C['gris'], ls=':', lw=1)
    A.text(4.6, 4.15, r'$k_\infty=3.83$', color=C['ambar'], fontsize=8); A.text(5.2, 1.6, '$b=2$ (ficción)', color=C['gris'], fontsize=8)
    A.set_xlim(0, 8); A.set_xlabel('$t$'); A.grid(True); A.legend(loc=(0.62, 0.38)); A.set_title('$(y_0,k_0)=(2,-1)$')
    g(fig, 'f_adaptativo')


def lotka():                        # C8_Ej7 [lotka]
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(wspace=0.28))
    for A, e, tit in [(ax[0], 0.0, '$e=0$: $V$ se conserva'), (ax[1], 0.2, '$e=0.2$: converge')]:
        vs = 0.5; ps = 1 - e*vs
        f = lambda z, e=e: [z[0]*(1 - e*z[0] - z[1]), z[1]*(-0.5 + z[0])]
        Vv, Pp = np.meshgrid(np.linspace(0.02, 4.2, 300), np.linspace(0.02, 3.2, 300))
        VV = (Vv - vs - vs*np.log(Vv/vs)) + (Pp - ps - ps*np.log(Pp/ps))
        A.contour(Vv, Pp, VV, levels=[0.1, 0.4, 0.9, 1.6], colors=[C['claro']], linewidths=0.8)
        s = sim(f, [2.0, 0.2], 60 if e == 0 else 120, 8000); A.plot(s.y[0], s.y[1], color=C['azul'], lw=1.0)
        if e > 0:
            A.axvline(vs, color=C['coral'], lw=1.6); A.text(vs + 0.05, 2.9, '$E=\\{v=v^*\\}$', color=C['coral'], fontsize=8)
        punto(A, (vs, ps), e > 0)
        ejes(A, (0, 4.2), (0, 3.2), tit, '$v$', '$p$'); A.set_aspect('auto')
    g(fig, 'f_lotka')


def inestable():                    # C8_Ej8 [inestable]
    def f(z):
        r = np.hypot(*z); th = np.arctan2(z[1], z[0]); rd = r*(1 - r); thd = 1 - np.cos(th)
        return [rd*np.cos(th) - r*thd*np.sin(th), rd*np.sin(th) + r*thd*np.cos(th)]
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(width_ratios=[1, 1.3], wspace=0.3))
    A = ax[0]; th = np.linspace(0, 2*np.pi, 300)
    A.fill(np.r_[1.5*np.cos(th), 0.5*np.cos(th[::-1])], np.r_[1.5*np.sin(th), 0.5*np.sin(th[::-1])], color=C['azul'], alpha=0.15)
    A.plot(np.cos(th), np.sin(th), color=C['coral'], lw=2)
    x0s = [(np.cos(0.15), np.sin(0.15)), (1.4*np.cos(2), 1.4*np.sin(2)), (0.6*np.cos(-1), 0.6*np.sin(-1))]
    cols = [C['noche'], C['violeta'], C['verde']]
    for x0, c in zip(x0s, cols):
        s = sim(f, list(x0), 60, 6000); A.plot(s.y[0], s.y[1], color=c, lw=1.0); A.plot(*x0, 'o', color=c, ms=3)
    punto(A, (1, 0), False)
    ejes(A, (-1.6, 1.6), (-1.6, 1.6), r'$\Omega=\{\frac{1}{2}\leq r\leq\frac{3}{2}\}$, $E=M$')
    A = ax[1]
    for x0, c in zip(x0s, cols):
        s = sim(f, list(x0), 60, 6000); A.plot(s.t, np.hypot(s.y[0] - 1, s.y[1]), color=c, lw=1.3)
    A.set_xlim(0, 60); A.set_ylim(0, 2.2); A.set_xlabel('$t$'); A.set_ylabel('distancia a $(1,0)$'); A.grid(True)
    A.set_title('converge, pero no es estable')
    g(fig, 'f_inestable')


def region():                       # C8_Ej9 [region]
    f = lambda z: [z[1], -z[0] + z[0]**3 - z[1]]
    fig, ax = plt.subplots(figsize=(4.6, 3.2))
    X, Y = np.meshgrid(np.linspace(-1.8, 1.8, 500), np.linspace(-1.2, 1.2, 400)); VV = X**2/2 - X**4/4 + Y**2/2
    zona(ax, X, Y, (VV < 0.25) & (np.abs(X) < 1), C['azul'], 0.25)
    zona(ax, X, Y, (VV < 0.25) & (np.abs(X) >= 1), C['gris'], 0.22)
    ax.contour(X, Y, VV, levels=[0.25], colors=[C['noche']], linewidths=1)
    for x0 in ([0, 0.7], [-0.9, 0.2], [0.6, -0.6]):
        s = sim(f, x0, 30); ax.plot(s.y[0], s.y[1], color=C['azul'], lw=1)
    esc = lambda t, z: abs(z[0]) - 1.8; esc.terminal = True
    for x0 in ([1.1, 0.1], [-0.2, 1.0]):
        s = solve_ivp(lambda t, z: f(z), (0, 30), x0, events=esc, max_step=0.01, **o); ax.plot(s.y[0], s.y[1], color=C['coral'], lw=1.1)
    punto(ax, (0, 0), True); punto(ax, (1, 0), False); punto(ax, (-1, 0), False)
    ejes(ax, (-1.8, 1.8), (-1.2, 1.2), r'$\{V<\frac{1}{4}\}\cap\{|x_1|<1\}\subset\mathcal{R}_A$'); ax.set_aspect('auto')
    g(fig, 'f_region')


# ------------------------------------------------------------------ 8.6 gradiente variable
def _cstarG(a, X, Y):
    Yy = X + Y; Vd = (a - 2)*X*Y - X**2 - Yy*np.sin(Yy); VV = a*X**2/2 + X*Y + Y**2/2
    m = (Vd >= 0) & (X**2 + Y**2 > 1e-4)
    return VV, Vd, VV[m].min()


def gradiente():                    # C8_Ej10 [g1] y [barrido]
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.1), gridspec_kw=dict(width_ratios=[1.1, 1], wspace=0.3))
    X, Y = np.meshgrid(np.linspace(-8, 8, 801), np.linspace(-8, 8, 801))
    VV, Vd, cs = _cstarG(2.0, X, Y); cs = np.pi**2/2
    A = ax[0]; zona(A, X, Y, Vd > 0, C['coral'], 0.25)
    A.contour(X, Y, VV, levels=[cs], colors=[C['azul']], linewidths=1.8)
    xx = np.linspace(-8, 8, 2); A.plot(xx, np.pi - xx, ':', color=C['noche'], lw=0.8); A.plot(xx, -np.pi - xx, ':', color=C['noche'], lw=0.8)
    f = lambda z: [z[1], -(z[0] + z[1]) - np.sin(z[0] + z[1])]
    for x0, c in [([2, 0.5], C['noche']), ([-1.5, 3], C['noche']), ([6, -2], C['gris']), ([-6, 7.5], C['gris'])]:
        s = sim(f, x0, 25); A.plot(s.y[0], s.y[1], color=c, lw=1.0)
    ejes(A, (-8, 8), (-8, 8), r'$a_{11}=2$: $x_1^2+(x_1+x_2)^2<\pi^2$')
    A = ax[1]; aa = np.linspace(1.15, 4, 60); Xs, Ys = np.meshgrid(np.linspace(-12, 12, 601), np.linspace(-12, 12, 601))
    ar = [np.pi*_cstarG(a, Xs, Ys)[2]/np.sqrt(a/4 - 1/4) for a in aa]
    A.plot(aa, ar, color=C['azul']); A.plot(2, np.pi**3, 'o', color=C['coral']); A.plot(1.48, 37.4, '*', color=C['ambar'], ms=11)
    A.text(2.1, np.pi**3 + 0.8, r'$a_{11}=2$: $\pi^3=31.0$', color=C['coral'], fontsize=8)
    A.text(1.6, 37.6, r'$a_{11}\approx1.48$: $37.4$', color=C['ambar'], fontsize=8)
    A.set_xlabel('$a_{11}$'); A.set_ylabel(r'área de $\Omega_{c^*}$'); A.grid(True); A.set_ylim(0, 42)
    A.set_title('la elección limpia no es la mejor')
    g(fig, 'f_gradiente')
    fig, ax = plt.subplots(1, 4, figsize=(7.6, 2.2), gridspec_kw=dict(wspace=0.12))
    Xs, Ys = np.meshgrid(np.linspace(-6, 6, 601), np.linspace(-6, 6, 601))
    for A, a in zip(ax, (1.1, 1.48, 2.0, 3.0)):
        VV, Vd, cs = _cstarG(a, Xs, Ys)
        zona(A, Xs, Ys, Vd > 0, C['coral'], 0.25)
        if cs > 1e-3: A.contour(Xs, Ys, VV, levels=[cs], colors=[C['azul']], linewidths=1.6)
        ejes(A, (-6, 6), (-6, 6), f'$a_{{11}}={a}$'); A.set_xticks([]); A.set_yticks([]); A.set_xlabel(''); A.set_ylabel('')
    g(fig, 'f_barrido')


def gradiente_pendulo():            # C8_Ej11 [pendulo]
    b = 0.5; k = b/2
    f = lambda z: [z[1], -np.sin(z[0]) - b*z[1]]
    E = lambda x1, x2: 1 - np.cos(x1) + x2**2/2
    V = lambda x1, x2: 1 - np.cos(x1) + (k*b*x1**2 + 2*k*x1*x2 + x2**2)/2
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(width_ratios=[1.1, 1], wspace=0.3))
    A = ax[0]; X, Y = np.meshgrid(np.linspace(-3.4, 3.4, 400), np.linspace(-2.6, 2.6, 400))
    A.contour(X, Y, E(X, Y), levels=[0.2, 0.6, 1.2, 2.0], colors=[C['gris']], linestyles='--', linewidths=0.8)
    A.contour(X, Y, V(X, Y), levels=[0.2, 0.6, 1.2, 2.0], colors=[C['azul']], linewidths=1.1)
    A.contour(X, Y, V(X, Y), levels=[2 + np.pi**2*k*(b - k)/2], colors=[C['verde']], linewidths=1.8)
    A.axvline(np.pi, color=C['noche'], lw=0.6, ls=':'); A.axvline(-np.pi, color=C['noche'], lw=0.6, ls=':')
    s = sim(f, [2.0, 0.8], 20); A.plot(s.y[0], s.y[1], color=C['noche'], lw=0.9)
    ejes(A, (-3.4, 3.4), (-2.6, 2.6), r'energía (gris) y $V$ inclinada (azul)'); A.set_aspect('auto')
    A = ax[1]; A.plot(s.t, E(*s.y), color=C['gris'], ls='--', label='energía'); A.plot(s.t, V(*s.y), color=C['azul'], label='$V$')
    A.set_xlim(0, 20); A.set_xlabel('$t$'); A.grid(True); A.legend(); A.set_title('escalones contra descenso estricto')
    g(fig, 'f_gradiente_pendulo')


# ------------------------------------------------------------------ 8.7 Krasovskii
def krasovskii():                   # C8_Ej12 [k1]
    f = lambda z: np.array([-3*z[0] + z[1], z[0] - z[1] - z[1]**3])
    fig, ax = plt.subplots(1, 2, figsize=(7.2, 3.1), gridspec_kw=dict(wspace=0.3))
    X, Y = np.meshgrid(np.linspace(-2.6, 2.6, 400), np.linspace(-2.6, 2.6, 400))
    F1, F2 = -3*X + Y, X - Y - Y**3
    ax[0].contour(X, Y, F1**2 + F2**2, levels=[0.5, 2, 6, 15, 30], colors=[C['azul']], linewidths=0.9)
    th = np.linspace(0, 2*np.pi, 12, endpoint=False)
    for t_ in th:
        s = sim(f, [2.2*np.cos(t_), 2.2*np.sin(t_)], 6, 1500)
        ax[0].plot(s.y[0], s.y[1], color=C['noche'], lw=0.8)
        Z = np.array([f(s.y[:, j]) for j in range(s.y.shape[1])]).T
        ax[1].plot(Z[0], Z[1], color=C['violeta'], lw=0.8)
    for rr in (4, 8, 12): ax[1].plot(rr*np.cos(np.linspace(0, 2*np.pi, 200)), rr*np.sin(np.linspace(0, 2*np.pi, 200)), color=C['claro'], lw=0.8)
    ejes(ax[0], (-2.6, 2.6), (-2.6, 2.6), r'plano $x$: niveles de $\|f(x)\|^2$')
    ejes(ax[1], (-14, 14), (-14, 14), r'plano $z=f(x)$', '$z_1$', '$z_2$')
    g(fig, 'f_krasovskii')


def krasovskii_trampa():            # C8_Ej13 [k2]
    f = lambda z: [-z[0] + z[0]**3, -z[1]]
    fig, ax = plt.subplots(figsize=(5.0, 3.0))
    X, Y = np.meshgrid(np.linspace(-1.6, 1.6, 600), np.linspace(-0.6, 0.6, 300)); VV = (X - X**3)**2 + Y**2
    c = 0.12
    zona(ax, X, Y, (VV <= c) & (np.abs(X) < 1/np.sqrt(3)), C['azul'], 0.25)
    zona(ax, X, Y, (VV <= c) & (np.abs(X) >= 1/np.sqrt(3)), C['gris'], 0.25)
    for xv in (1/np.sqrt(3), -1/np.sqrt(3)): ax.axvline(xv, color=C['noche'], ls=':', lw=0.9)
    for xv in (1, -1): ax.axvline(xv, color=C['coral'], lw=1.2)
    s = sim(f, [0.85, 0.5], 12); ax.plot(s.y[0], s.y[1], color=C['verde'], lw=1.2)
    esc = lambda t, z: abs(z[0]) - 1.6; esc.terminal = True
    s = solve_ivp(lambda t, z: f(z), (0, 10), [1.05, 0.1], events=esc, max_step=0.01, **o); ax.plot(s.y[0], s.y[1], color=C['coral'], lw=1.3)
    punto(ax, (0, 0), True); punto(ax, (1, 0), False); punto(ax, (-1, 0), False)
    ejes(ax, (-1.6, 1.6), (-0.6, 0.6), r'$V=\|f\|^2$ se anula en las tres raíces'); ax.set_aspect('auto')
    g(fig, 'f_krasovskii_trampa')


# ------------------------------------------------------------------ 8.8 Zubov
def zubov1d():                      # C8_Ej14 [z1]
    fig, ax = plt.subplots(1, 2, figsize=(7.0, 2.6), gridspec_kw=dict(wspace=0.3))
    x = np.linspace(-1.4, 1.4, 400)
    ax[0].plot(x, -x + x**3, color=C['azul']); ax[0].axhline(0, color=C['gris'], lw=0.6)
    for xe, est in ((0, True), (1, False), (-1, False)): punto(ax[0], (xe, 0), est)
    ax[0].set_xlabel('$x$'); ax[0].set_title(r'$f(x)=-x+x^3$'); ax[0].grid(True)
    xi = np.linspace(-0.995, 0.995, 400)
    ax[1].plot(xi, xi**2, color=C['azul'], label='$V=x^2$'); ax[1].plot(xi, -np.log(1 - xi**2), color=C['coral'], label=r'$W=-\ln(1-x^2)$')
    for xv in (-1, 1): ax[1].axvline(xv, color=C['noche'], ls=':')
    ax[1].axhline(1, color=C['gris'], ls='--', lw=0.8); ax[1].set_ylim(0, 4); ax[1].set_xlabel('$x$'); ax[1].grid(True); ax[1].legend()
    ax[1].set_title(r'$W\to\infty$ en $\partial\mathcal{R}_A$')
    g(fig, 'f_zubov1d')


def zubov_hiperbola():              # C8_Ej14 [z2]
    f = lambda z: [-z[0] + 2*z[0]**2*z[1], -z[1]]
    fig, ax = plt.subplots(figsize=(4.8, 3.5))
    X, Y = np.meshgrid(np.linspace(-3, 3, 600), np.linspace(-3, 3, 600)); w = X*Y
    W = np.where(w < 1, Y**2/2 + X**2/(2*(1 - np.minimum(w, 0.9999))), np.inf); VV = 1 - np.exp(-W)
    zona(ax, X, Y, w >= 1, C['gris'], 0.25)
    cs = ax.contour(X, Y, VV, levels=[0.25, 0.5, 0.75, 0.9, 0.99], colors=[C['azul']], linewidths=1)
    xx = np.linspace(0.34, 3, 200); ax.plot(xx, 1/xx, color=C['coral'], lw=1.8); ax.plot(-xx, -1/xx, color=C['coral'], lw=1.8)
    for x0 in ([1.9, 0.5], [-2.5, -0.35], [0.5, 2.5]):
        s = sim(f, x0, 15); ax.plot(s.y[0], s.y[1], color=C['noche'], lw=1)
    esc = lambda t, z: abs(z[0]) - 3; esc.terminal = True
    s = solve_ivp(lambda t, z: f(z), (0, 10), [2.1, 0.5], events=esc, max_step=0.01, **o); ax.plot(s.y[0], s.y[1], color=C['coral'], lw=1.2, ls='--')
    ejes(ax, (-3, 3), (-3, 3), r'niveles de $V$; $\mathcal{R}_A=\{x_1x_2<1\}$')
    g(fig, 'f_zubov_hiperbola')


def zubov_malla(n=91, L=3.0):
    """W(x0) = int_0^inf ||phi_t(x0)||^2 dt para van der Pol en tiempo invertido (C8_Ej15)."""
    fW = lambda t, z: [-z[1], z[0] + (z[0]**2 - 1)*z[1], z[0]**2 + z[1]**2]
    e = lambda t, z: z[0]**2 + z[1]**2 - 100; e.terminal = True
    g_ = np.linspace(-L, L, n); W = np.full((n, n), np.inf)
    for i, yy in enumerate(g_):
        for j, xx in enumerate(g_):
            s = solve_ivp(fW, (0, 40), [xx, yy, 0], events=e, rtol=1e-7, atol=1e-9)
            if s.status == 0 and np.hypot(*s.y[:2, -1]) < 1e-3: W[i, j] = s.y[2, -1]
    return g_, W


def zubov_vdp():                    # C8_Ej15 [zubov]
    g_, W = zubov_malla()
    X, Y = np.meshgrid(g_, g_); VV = 1 - np.exp(-W)
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.2), gridspec_kw=dict(wspace=0.3))
    A = ax[0]
    A.contour(X, Y, VV, levels=[0.5, 0.9, 0.99, 0.999], colors=[C['azul']], linewidths=1)
    s = sim(lambda z: [z[1], -z[0] + (1 - z[0]**2)*z[1]], [2, 0], 40, 8000); m = s.t > 30
    A.plot(s.y[0][m], s.y[1][m], color=C['coral'], lw=1.8)
    P = np.array([[1.5, -0.5], [-0.5, 1]]); th = np.linspace(0, 2*np.pi, 300); U = np.vstack([np.cos(th), np.sin(th)])
    R = np.sqrt(2.30/np.einsum('ij,ik,kj->j', U, P, U)); A.plot(U[0]*R, U[1]*R, color=C['verde'], lw=1.6)
    ejes(A, (-3, 3), (-3, 3), 'Zubov (azul), ciclo (coral), cuadrática (verde)')
    A = ax[1]; im = A.pcolormesh(X, Y, np.where(np.isinf(W), np.nan, VV), cmap='Blues', shading='gouraud', vmin=0, vmax=1)
    A.plot(s.y[0][m], s.y[1][m], color=C['coral'], lw=1.2); fig.colorbar(im, ax=A, fraction=0.046)
    ejes(A, (-3, 3), (-3, 3), '$V(x)$ en la malla (blanco: $W=\\infty$)')
    g(fig, 'f_zubov_vdp')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
        sys.exit()
    for fn in [pendulo, limite, duffing, ciclo, adaptativo, lotka, inestable, region, gradiente, gradiente_pendulo,
               krasovskii, krasovskii_trampa, zubov1d, zubov_hiperbola, zubov_vdp]:
        fn()
