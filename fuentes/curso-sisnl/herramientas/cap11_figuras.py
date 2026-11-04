"""Figuras del capítulo 11 (pasividad). PDF (notas) y SVG (web).
Cada figura reproduce un script de codigo/cap11_pasividad/ (se indica cuál).
Ejecutar:  python3 herramientas/cap11_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from scipy.integrate import solve_ivp
from estilo import C, guardar

CAP = 'cap11'


def g(fig, nombre):
    guardar(fig, nombre, CAP)


def ode(f, T, x0, n=4001, **kw):
    t = np.linspace(0, T, n)
    s = solve_ivp(f, (0, T), x0, t_eval=t, rtol=1e-10, atol=1e-12, **kw)
    return s.t, s.y


def cumtrapz(y, t):
    return np.concatenate([[0], np.cumsum(0.5*(y[1:] + y[:-1])*np.diff(t))])


def ejes0(a):
    a.axhline(0, color=C['gris'], lw=0.6); a.axvline(0, color=C['gris'], lw=0.6)


# ---------------------------------------------------------------- C11_Ej1
def masa_resorte():
    uf = lambda t: 0.8*np.sin(1.2*t)*(t < 12)
    t, X = ode(lambda t, x: [x[1], -(x[0] + x[0]**3) - 0.3*x[1] + uf(t)], 30, [0, 0], n=15001)
    V = 0.5*X[0]**2 + 0.25*X[0]**4 + 0.5*X[1]**2
    S = cumtrapz(uf(t)*X[1], t); Dd = cumtrapz(0.3*X[1]**2, t)
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.32))
    ax[0].plot(t, X[0], color=C['azul'], label='$x_1$ (posición)')
    ax[0].plot(t, X[1], color=C['coral'], label='$x_2=y$ (velocidad)')
    ax[0].plot(t, uf(t), color=C['gris'], lw=1, ls='--', label='$u$')
    ax[0].axvspan(0, 12, color=C['ambar'], alpha=0.08)
    ax[0].set_title('estado y entrada'); ax[0].legend(loc='upper center', fontsize=7, bbox_to_anchor=(0.5, -0.2), ncol=3)
    ax[1].plot(t, S, color=C['verde'], label=r'suministrada $\int u\,y$')
    ax[1].plot(t, Dd, color=C['violeta'], label=r'disipada $\int\delta y^2$')
    ax[1].plot(t, V, color=C['noche'], lw=2.4, label='almacenada $V$')
    ax[1].plot(t[::300], (S - Dd)[::300], 'o', ms=3, color=C['ambar'], label='$S-D$ (puntos)')
    ax[1].axvspan(0, 12, color=C['ambar'], alpha=0.08)
    ax[1].set_title('balance de energía'); ax[1].legend(loc='upper center', fontsize=7, bbox_to_anchor=(0.5, -0.2), ncol=2)
    for a in ax:
        a.set_xlabel('t (s)'); a.grid(True)
    g(fig, 'f_masa_resorte')


# ---------------------------------------------------------------- C11_Ej2
def senales():
    t = np.linspace(0, 40, 2001)
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.32))
    ax[0].plot(t, 1/np.sqrt(1 + t), color=C['azul'], label=r'$(1+t)^{-1/2}$')
    ax[0].plot(t, np.exp(-t/4), color=C['verde'], label=r'$e^{-t/4}$')
    ax2 = ax[0].twinx()
    ax2.plot(t, np.log1p(t), color=C['coral'], ls='--', label=r'energía en $[0,t]$: $\ln(1+t)$')
    ax2.plot(t, 2*(1 - np.exp(-t/2)), color=C['verde'], ls=':', lw=1.4)
    ax2.set_ylabel('energía acumulada', color=C['coral']); ax2.spines['right'].set_visible(True)
    ax[0].set_title('se apaga, pero no tiene energía finita')
    h1, l1 = ax[0].get_legend_handles_labels(); h2, l2 = ax2.get_legend_handles_labels()
    ax[0].legend(h1 + h2, l1 + l2, loc='upper center', fontsize=6.8, bbox_to_anchor=(0.5, -0.22), ncol=2)
    # pulsos triangulares de altura k y base 1/k^4 centrados en t = k
    tt = np.linspace(0, 6.5, 40001); yy = np.zeros_like(tt)
    for k in range(1, 7):
        bse = 1/k**4
        yy = np.maximum(yy, k*np.clip(1 - abs(tt - k)/(bse/2), 0, None))
    ax[1].plot(tt, yy, color=C['violeta'], lw=1.2)
    ax[1].set_title(r'no acotada, energía $\pi^2/18$')
    for a in ax:
        a.set_xlabel('t'); a.grid(True)
    g(fig, 'f_senales')


# ---------------------------------------------------------------- C11_Ej3
def sin_memoria():
    h = lambda v: 17.76*v - 103.79*v**2 + 229.62*v**3 - 226.31*v**4 + 83.72*v**5
    fig, ax = plt.subplots(1, 3, figsize=(7.0, 2.4), gridspec_kw=dict(wspace=0.35))
    for a in ax:
        X, Y = 10, 10
        a.add_patch(Polygon([[0, 0], [X, 0], [X, Y], [0, Y]], color=C['azul'], alpha=0.07, lw=0))
        a.add_patch(Polygon([[0, 0], [-X, 0], [-X, -Y], [0, -Y]], color=C['azul'], alpha=0.07, lw=0))
        ejes0(a); a.set_xlabel('$u$'); a.grid(True)
    v = np.linspace(-0.12, 1.0, 600)
    ax[0].plot(v, h(v), color=C['coral'])
    ax[0].set_xlim(-0.12, 1.0); ax[0].set_ylim(-1.2, 1.0)
    ax[0].set_title('diodo túnel: pasivo'); ax[0].set_ylabel('$y=h(u)$')
    ax[0].annotate('pendiente\nnegativa', xy=(0.42, h(0.42)), xytext=(0.45, 0.62), fontsize=7.5,
                   color=C['noche'], arrowprops=dict(arrowstyle='->', color=C['gris']))
    u = np.linspace(-2, 2, 400)
    al, be = 0.25, 1.5
    ax[1].fill_between(u, al*u, be*u, color=C['verde'], alpha=0.18, lw=0)
    ax[1].plot(u, al*u, color=C['verde'], lw=1); ax[1].plot(u, be*u, color=C['verde'], lw=1)
    ax[1].plot(u, 0.9*u + 0.25*np.sin(2*u), color=C['violeta'])
    ax[1].set_xlim(-2, 2); ax[1].set_ylim(-2, 2); ax[1].set_title(r'sector $[\alpha,\beta]$')
    u = np.linspace(-3, 3, 400)
    ax[2].fill_between(u, 0*u, u, color=C['verde'], alpha=0.18, lw=0)
    ax[2].plot(u, np.clip(u, -1, 1), color=C['azul'])
    ax[2].plot(u, u, color=C['verde'], lw=1)
    ax[2].set_xlim(-3, 3); ax[2].set_ylim(-1.4, 1.4); ax[2].set_title(r'saturación: sector $[0,1]$')
    g(fig, 'f_sin_memoria')


# ---------------------------------------------------------------- C11_Ej4
def integrador_filtro():
    w = np.logspace(-3, 3, 4000)
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.32))
    G1 = 1/(1j*w); G2 = 1/(1j*w + 1)
    ax[0].plot(G2.real, G2.imag, color=C['coral'], label='$1/(s+1)$')
    ax[0].plot(G2.real, -G2.imag, color=C['coral'], ls=':', lw=1)
    ax[0].plot([0, 0], [-1.6, 1.6], color=C['azul'], label='$1/s$ (eje imaginario)')
    ax[0].fill_betweenx([-1.6, 1.6], 0, 1.6, color=C['azul'], alpha=0.06)
    ejes0(ax[0]); ax[0].set_xlim(-0.6, 1.4); ax[0].set_ylim(-1.0, 1.0); ax[0].set_aspect('equal')
    ax[0].set_title('Nyquist'); ax[0].legend(loc='lower right', fontsize=7.5)
    ax[0].set_xlabel('Re'); ax[0].set_ylabel('Im')
    ax[1].semilogx(w, np.degrees(np.angle(G1)), color=C['azul'], label='$1/s$')
    ax[1].semilogx(w, np.degrees(np.angle(G2)), color=C['coral'], label='$1/(s+1)$')
    ax[1].axhline(-90, color=C['gris'], lw=0.8, ls='--')
    ax[1].set_ylim(-100, 5); ax[1].set_title('fase: el "exceso" del filtro')
    ax[1].set_xlabel(r'$\omega$ (rad/s)'); ax[1].set_ylabel('fase (°)'); ax[1].legend(fontsize=7.5)
    for a in ax:
        a.grid(True)
    g(fig, 'f_integrador_filtro')


# ---------------------------------------------------------------- C11_Ej6
def pasividad_local():
    k = 1.0
    x = np.linspace(-1.8, 1.8, 600)
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.32))
    d = x**2*(x**2 - k)
    ax[0].plot(x, d, color=C['noche'])
    ax[0].fill_between(x, d, 0, where=d > 0, color=C['coral'], alpha=0.25, lw=0, label='crea energía')
    ax[0].fill_between(x, d, 0, where=d <= 0, color=C['verde'], alpha=0.25, lw=0, label='disipa')
    ejes0(ax[0]); ax[0].set_ylim(-0.5, 2.0); ax[0].legend(loc='upper center', fontsize=7.5)
    ax[0].set_title(r'$\dot V-u\,y=x^2(x^2-k)$, $k=1$'); ax[0].set_xlabel('$x$')
    T = np.linspace(0, 4, 200); xb = 1.5
    ax[1].plot(T, -xb**2*(xb**2 - k)*T, color=C['coral'], label=r'$\int_0^T u\,y\,dt$')
    ax[1].plot(T, 0*T, color=C['azul'], label=r'$V(x(T))-V(x(0))=0$')
    ax[1].set_title(r'$x(t)\equiv 1.5$ con $u$ constante'); ax[1].set_xlabel('T (s)')
    ax[1].legend(fontsize=7.5)
    for a in ax:
        a.grid(True)
    g(fig, 'f_pasividad_local')


# ---------------------------------------------------------------- C11_Ej7
def lasalle_rlc():
    t, X = ode(lambda t, x: [x[1], -x[0] - x[1]], 14, [1.5, 0], n=5001)
    V = 0.5*(X[0]**2 + X[1]**2)
    fig, ax = plt.subplots(1, 3, figsize=(7.0, 2.4), gridspec_kw=dict(wspace=0.4))
    th = np.linspace(0, 2*np.pi, 300)
    for c in [0.25, 0.5, 0.75, 1.0, 1.25]:
        ax[0].plot(np.sqrt(2*c)*np.cos(th), np.sqrt(2*c)*np.sin(th), color=C['claro'], lw=0.8)
    ax[0].plot(X[0], X[1], color=C['azul'])
    ax[0].axhline(0, color=C['coral'], lw=1.6)
    ax[0].set_aspect('equal'); ax[0].set_xlim(-1.7, 1.7); ax[0].set_ylim(-1.7, 1.7)
    ax[0].set_title(r'$E=\{x_2=0\}$ en rojo'); ax[0].set_xlabel('$x_1$'); ax[0].set_ylabel('$x_2$')
    cruces = np.where(np.diff(np.sign(X[1])) != 0)[0]
    ax[1].plot(t, V, color=C['noche'])
    for i in cruces:
        ax[1].axvline(t[i], color=C['coral'], lw=0.8, ls='--')
    ax[1].set_title('$V(x(t))$: se aplana al cruzar'); ax[1].set_xlabel('t')
    # contraejemplo sin ZSO
    for x10 in [-1, -0.5, 0.5, 1]:
        t2, X2 = ode(lambda t, x: [0, -x[1]], 6, [x10, 1.2], n=600)
        ax[2].plot(X2[0], X2[1], color=C['violeta'])
        ax[2].plot(X2[0, -1], X2[1, -1], 'o', ms=3.5, color=C['violeta'])
    ax[2].axhline(0, color=C['coral'], lw=1.6)
    ax[2].set_xlim(-1.4, 1.4); ax[2].set_ylim(-0.2, 1.4)
    ax[2].set_title('sin ZSO: estable, no AS'); ax[2].set_xlabel('$x_1$'); ax[2].set_ylabel('$x_2$')
    for a in ax:
        a.grid(True)
    g(fig, 'f_lasalle_rlc')


# ---------------------------------------------------------------- C11_Ej8
def nyquist_familia():
    w = np.logspace(-3, 3.5, 6000)
    a, b = 3, 2
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.7), gridspec_kw=dict(wspace=0.3))
    cols = [C['verde'], C['ambar'], C['coral']]
    for z, col, et in zip([1.5, 3, 5], cols, ['SPR', 'PR, no SPR', 'no PR']):
        G = (1j*w + z)/((1j*w)**2 + a*1j*w + b)
        ax[0].plot(G.real, G.imag, color=col, label=f'$z={z:g}$: {et}')
        ax[1].semilogx(w, w**2*G.real, color=col)
        ax[1].axhline(a - z, color=col, lw=0.8, ls=':')
    ejes0(ax[0]); ax[0].set_xlim(-0.12, 0.35); ax[0].set_ylim(-0.25, 0.08)
    ax[0].fill_betweenx([-1, 1], -1, 0, color=C['coral'], alpha=0.05)
    ax[0].set_title('cerca del origen ($\\omega\\to\\infty$)'); ax[0].legend(fontsize=7, loc='lower right')
    ax[0].set_xlabel('Re'); ax[0].set_ylabel('Im')
    ax[1].set_ylim(-2.5, 2.5); ax[1].set_title(r'$\omega^2\,\mathrm{Re}\,G_z(j\omega)\to a-z$')
    ax[1].set_xlabel(r'$\omega$ (rad/s)')
    for x in ax:
        x.grid(True)
    g(fig, 'f_nyquist_familia')


# ---------------------------------------------------------------- C11_Ej10
def interconexion():
    def f(t, x, a=1, k=0.5, b=2):
        return [x[1], -a*x[0]**3 - k*x[1] - x[3], x[3], -b*x[2] - x[3]**3 + x[1]]
    t, X = ode(f, 25, [1.5, 0, 0, 0], n=5001)
    V1 = 0.25*X[0]**4 + 0.5*X[1]**2; V2 = X[2]**2 + 0.5*X[3]**2
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.3))
    ax[0].plot(t, X[0], color=C['azul'], label='$x_1$ ($H_1$)')
    ax[0].plot(t, X[2], color=C['coral'], label='$x_3$ ($H_2$)')
    ax[0].set_title('posiciones'); ax[0].legend(fontsize=7.5)
    ax[1].plot(t, V1, color=C['azul'], label='$V_1$')
    ax[1].plot(t, V2, color=C['coral'], label='$V_2$')
    ax[1].plot(t, V1 + V2, color=C['noche'], lw=2.4, label='$V=V_1+V_2$')
    ax[1].set_title('cada una sube y baja; la suma no'); ax[1].legend(fontsize=7.5)
    for a in ax:
        a.set_xlabel('t (s)'); a.grid(True)
    g(fig, 'f_interconexion')


# ---------------------------------------------------------------- C11_Ej11
def control_pasividad():
    fig, ax = plt.subplots(1, 3, figsize=(7.0, 2.4), gridspec_kw=dict(wspace=0.4))
    for tipo, col, et in [('lin', C['azul'], '$u=-k\\,y$'), ('atan', C['coral'], r'$u=-\frac{2k}{\pi}\arctan y$')]:
        uu = (lambda y: -y) if tipo == 'lin' else (lambda y: -(2/np.pi)*np.arctan(y))
        t, X = ode(lambda t, x: [x[1], -x[0]**3 + uu(x[1])], 30, [2, 0], n=6001)
        ax[0].plot(t, X[0], color=col, label=et)
        ax[1].plot(t, uu(X[1]), color=col)
    ax[0].set_title('$x_1(t)$, $k=1$'); ax[0].legend(fontsize=7)
    ax[1].set_title('$u(t)$')
    ax[1].axhline(2/np.pi, color=C['gris'], lw=0.8, ls=':'); ax[1].axhline(-2/np.pi, color=C['gris'], lw=0.8, ls=':')
    m, l, gg, bb, Kp, Kd, qr = 1, 1, 9.81, 0.5, 20, 5, np.pi/3
    for comp, col, et in [(True, C['verde'], 'PD + gravedad'), (False, C['violeta'], 'PD solo')]:
        def f(t, x):
            q, dq = x
            uu = (m*gg*l*np.sin(q) if comp else 0) - Kp*(q - qr) - Kd*dq
            return [dq, (uu - bb*dq - m*gg*l*np.sin(q))/(m*l**2)]
        t, X = ode(f, 6, [0, 0], n=1201)
        ax[2].plot(t, np.degrees(X[0]), color=col, label=et)
    ax[2].axhline(60, color=C['gris'], ls='--', lw=0.8)
    ax[2].set_title(r'péndulo, $q_r=60°$'); ax[2].legend(fontsize=7, loc='lower right'); ax[2].set_ylabel('q (°)')
    for a in ax:
        a.set_xlabel('t (s)'); a.grid(True)
    g(fig, 'f_control_pasividad')


# ---------------------------------------------------------------- C11_Ej12
def cascada():
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.32))
    ev = lambda t, x: abs(x[0]) - 50; ev.terminal = True
    for z0, col in [(1.0, C['azul']), (1.9, C['verde']), (2.1, C['ambar']), (3.0, C['coral'])]:
        s = solve_ivp(lambda t, x: [-x[0] + x[0]**2*x[1], -x[1]], (0, 6), [1, z0], events=ev,
                      max_step=0.002, rtol=1e-10, atol=1e-12)
        ax[0].plot(s.t, s.y[0], color=col, label=f'$z_0={z0:g}$')
    ax[0].set_ylim(-0.2, 8); ax[0].set_title('$u=-kz$: escape si $x_0z_0>1+k$')
    ax[0].legend(fontsize=7)
    for z0, col in [(1.0, C['azul']), (3.0, C['coral']), (10.0, C['violeta'])]:
        t, X = ode(lambda t, x: [-x[0] + x[0]**2*x[1], -x[0]**3 - x[1]], 6, [1, z0], n=3001)
        ax[1].plot(t, X[0], color=col, label=f'$z_0={z0:g}$')
    ax[1].set_title('pasivación: $u=-x^3-kz$'); ax[1].legend(fontsize=7)
    for a in ax:
        a.set_xlabel('t'); a.set_ylabel('$x(t)$'); a.grid(True)
    g(fig, 'f_cascada')


# ---------------------------------------------------------------- C11_Ej13 / Ej14
Q, R_, VM = 2.0, 2.0, 2.0


def agua(t, x, c):
    v, q = np.maximum(x[:3], 0), x[3:]
    Fi = R_*(1 - v/VM); Fb = q @ Fi/Q
    return np.concatenate([q - c*np.sqrt(v), q*(Fi - Fb)])


def Vtot(X, c):
    vs = Q**2/c.sum()**2; qs = c*Q/c.sum()
    return R_/(2*Q*VM)*np.sum((X[:3] - vs)**2, axis=0) + np.sum(qs[:, None]*np.log(qs[:, None]/X[3:]), axis=0)/Q


def agua_fig():
    c1 = np.array([0.6, 1.0, 1.4]); c2 = np.array([0.6, 1.0, 2.0])
    x0 = np.array([0.1, 0.8, 0.3, 0.9, 0.6, 0.5])
    t1, X1 = ode(lambda t, x: agua(t, x, c1), 40, x0, n=4001)
    t2, X2 = ode(lambda t, x: agua(t, x, c2), 40, X1[:, -1], n=4001)
    t = np.concatenate([t1, 40 + t2[1:]]); X = np.hstack([X1, X2[:, 1:]])
    V = np.concatenate([Vtot(X1, c1), Vtot(X2[:, 1:], c2)])
    fig, ax = plt.subplots(1, 3, figsize=(7.0, 2.4), gridspec_kw=dict(wspace=0.42))
    cols = [C['azul'], C['coral'], C['violeta']]
    for i in range(3):
        ax[0].plot(t, X[i], color=cols[i], label=f'$v_{i+1}$')
        ax[1].plot(t, X[3 + i], color=cols[i], label=f'$q_{i+1}$')
    ax[0].plot([0, 40], [4/9]*2, color=C['gris'], ls='--', lw=0.8)
    ax[0].plot([40, 80], [4/12.96]*2, color=C['gris'], ls='--', lw=0.8)
    ax[0].set_title('volúmenes'); ax[0].legend(fontsize=7)
    ax[1].set_title('caudales ($\\sum q_i=Q$)'); ax[1].legend(fontsize=7)
    ax[2].semilogy(t, V, color=C['noche']); ax[2].set_title('$V=V_1+V_2$ (eq. vigente)')
    for a in ax:
        a.axvline(40, color=C['ambar'], lw=1.2); a.set_xlabel('t (s)'); a.grid(True)
    g(fig, 'f_agua')
    # psi_i
    vs = 4/9; vt = np.linspace(-vs, 1.2, 400)
    fig, a = plt.subplots(figsize=(3.2, 2.3))
    for ci, col in zip(c1, cols):
        a.plot(vt, ci*vt*(np.sqrt(vs) - np.sqrt(vt + vs)), color=col, label=f'$c_i={ci:g}$')
    ejes0(a); a.set_xlabel(r'$\tilde v_i$'); a.set_title(r'$\psi_i(\tilde v_i)\leq 0$'); a.legend(fontsize=7); a.grid(True)
    g(fig, 'f_psi')


def agua_caras():
    c = np.array([0.6, 1.0, 1.4])
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.32))
    x0 = np.array([0.4, 0.4, 0.4, 1.0, 1.0, 0.0])
    t, X = ode(lambda t, x: agua(t, x, c), 25, x0, n=5001)
    for i, col in enumerate([C['azul'], C['coral'], C['violeta']]):
        ax[0].plot(t, np.maximum(X[i], 0), color=col, label=f'$v_{i+1}$')
    ax[0].set_title('$q_3(0)=0$: el tanque 3 se vacía'); ax[0].legend(fontsize=7)
    for k, col in zip([2, 4, 6, 8], [C['verde'], C['azul'], C['violeta'], C['coral']]):
        e = 10.0**-k
        x0 = np.array([0.4, 0.4, 0.4, 1 - e/2, 1 - e/2, e])
        t, X = ode(lambda t, x: agua(t, x, c), 30, x0, n=6001)
        ax[1].plot(t, X[5], color=col, label=f'$q_3(0)=10^{{-{k}}}$')
    ax[1].axhline(14/15, color=C['gris'], ls='--', lw=0.8)
    ax[1].set_title('converge, con retardo $\\sim\\ln(1/q_3(0))$'); ax[1].legend(fontsize=7)
    for a in ax:
        a.set_xlabel('t (s)'); a.grid(True)
    g(fig, 'f_agua_caras')


# ---------------------------------------------------------------- historia
def linea_tiempo():
    ev = [(1931, 'Brune', 'funciones reales\npositivas'), (1944, "Lur'e y\nPostnikov", 'estabilidad\nabsoluta'),
          (1961, 'Popov', 'criterio\nfrecuencial'), (1963, 'Yakubovich,\nKalman', 'lema KYP'),
          (1966, 'Zames', 'pasividad\nentrada-salida'), (1972, 'Willems', 'sistemas\ndisipativos'),
          (1976, 'Hill y\nMoylan', 'disipativo \u2192\nLyapunov'), (1991, 'Byrnes, Isidori\ny Willems', 'pasivación por\nrealimentación')]
    fig, a = plt.subplots(figsize=(7.0, 1.9))
    xs = np.arange(len(ev))
    a.plot([-0.6, len(ev) - 0.4], [0, 0], color=C['gris'], lw=1.2)
    for i, (y, n_, q) in enumerate(ev):
        up = 1 if i % 2 == 0 else -1
        col = C['ambar'] if y in (1972, 1966) else C['azul']
        a.plot([i, i], [0, 0.5*up], color=col, lw=1)
        a.plot(i, 0, 'o', color=col, ms=6)
        a.text(i, 0.55*up, f'{y}\n{n_}', ha='center', va='bottom' if up > 0 else 'top', fontsize=7.2,
               color=C['noche'], fontweight='bold')
        a.text(i, -0.15*up, q, ha='center', va='top' if up > 0 else 'bottom', fontsize=6.6, color=C['gris'])
    a.set_ylim(-2.0, 2.0); a.set_xlim(-0.7, len(ev) - 0.3); a.axis('off')
    g(fig, 'f_linea_tiempo')


if __name__ == '__main__':
    masa_resorte(); senales(); sin_memoria(); integrador_filtro(); pasividad_local()
    lasalle_rlc(); nyquist_familia(); interconexion(); control_pasividad(); cascada()
    agua_fig(); agua_caras(); linea_tiempo()
