# Transparencia: escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
"""Videos de la parte 11 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C11_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap11_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V11_1_balance.mp4, V11_2_lasalle.mp4, V11_3_nyquist.mp4,
           V11_4_interconexion.mp4, V11_5_agua.mp4
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from scipy.integrate import solve_ivp
from estilo import C
from cap04_videos import grabar

o = dict(rtol=1e-10, atol=1e-12)


def cumtrapz(y, t):
    return np.concatenate([[0], np.cumsum(0.5*(y[1:] + y[:-1])*np.diff(t))])


def v11_1_balance():                # C11_Video_Balance
    d = 0.3; uf = lambda t: 0.8*np.sin(1.2*t)*(t < 12)
    t = np.linspace(0, 30, 901)
    s1 = solve_ivp(lambda tt, x: [x[1], -(x[0] + x[0]**3) - d*x[1] + uf(tt)], (0, 12), [0, 0], t_eval=t[t <= 12], max_step=0.01, **o)
    s2 = solve_ivp(lambda tt, x: [x[1], -(x[0] + x[0]**3) - d*x[1]], (12, 30), s1.y[:, -1], t_eval=t[t > 12], max_step=0.01, **o)
    X = np.hstack([s1.y, s2.y]); y = X[1]
    V = X[0]**2/2 + X[0]**4/4 + y**2/2; S = cumtrapz(uf(t)*y, t); D = cumtrapz(d*y**2, t)
    fig = plt.figure(figsize=(9.6, 5.4)); gs = fig.add_gridspec(2, 2, hspace=0.45, wspace=0.25)
    a1 = fig.add_subplot(gs[0, 0]); a2 = fig.add_subplot(gs[0, 1]); a3 = fig.add_subplot(gs[1, :])
    a1.set_xlim(-2, 2); a1.set_ylim(-0.6, 0.6); a1.axis('off'); a1.set_title(r'masa con resorte duro, $F(x_1)=x_1+x_1^3$')
    a1.plot([-1.95, -1.95], [-0.4, 0.4], color=C['noche'], lw=4)
    res, = a1.plot([], [], color=C['gris'], lw=1.2)
    masa = Rectangle((-0.2, -0.25), 0.4, 0.5, color=C['azul']); a1.add_patch(masa)
    fl = a1.annotate('', xy=(0, 0.4), xytext=(0, 0.4), arrowprops=dict(arrowstyle='->', color=C['coral'], lw=2))
    barras = a2.bar(['suministrada', 'disipada', 'almacenada'], [0, 0, 0], color=[C['verde'], C['violeta'], C['noche']])
    a2.set_ylim(0, 5.5); a2.grid(True, axis='y')
    a3.axvspan(0, 12, color=C['ambar'], alpha=0.08); a3.set_xlim(0, 30); a3.set_ylim(0, 5.5); a3.grid(True)
    lS, = a3.plot([], [], color=C['verde'], label=r'$\int u\,y$'); lD, = a3.plot([], [], color=C['violeta'], label=r'$\int\delta y^2$')
    lV, = a3.plot([], [], color=C['noche'], lw=2.4, label='$V$'); a3.legend(loc='upper left'); a3.set_xlabel('$t$ (s)')
    def act(j):
        k = 2*j; xm = 0.8*X[0, k]; xs = np.linspace(-1.9, xm - 0.2, 200)
        res.set_data(xs, 0.12*np.sin(np.linspace(0, 16*np.pi, 200))); masa.set_x(xm - 0.2)
        fl.xy = (xm + 0.5*uf(t[k]), 0.4); fl.set_position((xm, 0.4))
        for b, v in zip(barras, (S[k], D[k], V[k])): b.set_height(v)
        a2.set_title(f'$t={t[k]:.1f}$ s:  $V={V[k]:.3f}={S[k]:.3f}-{D[k]:.3f}$')
        lS.set_data(t[:k+1], S[:k+1]); lD.set_data(t[:k+1], D[:k+1]); lV.set_data(t[:k+1], V[:k+1])
    grabar(fig, act, 451, 'V11_1_balance')


def v11_2_lasalle():                # C11_Video_LaSalle
    t = np.linspace(0, 14, 701)
    X = solve_ivp(lambda tt, x: [x[1], -x[0] - x[1]], (0, 14), [1.5, 0], t_eval=t, **o).y
    V = (X[0]**2 + X[1]**2)/2
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.6), gridspec_kw=dict(wspace=0.28))
    th = np.linspace(0, 2*np.pi, 200)
    for c in np.arange(0.25, 1.3, 0.25): a1.plot(np.sqrt(2*c)*np.cos(th), np.sqrt(2*c)*np.sin(th), color=C['claro'], lw=0.9)
    a1.axhline(0, color=C['coral'], lw=2.2); a1.set_aspect('equal'); a1.set_xlim(-1.7, 1.7); a1.set_ylim(-1.7, 1.7); a1.grid(True)
    a1.set_xlabel('$x_1$ (carga)'); a1.set_ylabel('$x_2=y$ (corriente)'); a1.set_title(r'$E=\{\dot V=0\}=\{x_2=0\}$ en rojo')
    tr, = a1.plot([], [], color=C['azul']); pt, = a1.plot([], [], 'o', ms=8, color=C['ambar'])
    a2.set_xlim(0, 14); a2.set_ylim(0, 1.2); a2.grid(True); a2.set_xlabel('$t$'); a2.set_title(r'$V(x(t))$, $\dot V=-x_2^2$')
    lV, = a2.plot([], [], color=C['noche'], lw=2.4)
    cruces = [k for k in range(1, len(t)) if np.sign(X[1, k]) != np.sign(X[1, k-1])]
    def act(j):
        k = 2*j
        tr.set_data(X[0, :k+1], X[1, :k+1]); pt.set_data([X[0, k]], [X[1, k]]); lV.set_data(t[:k+1], V[:k+1])
        for c in cruces:
            if k - 2 < c <= k:
                a2.axvline(t[c], color=C['coral'], ls='--', lw=1); a1.plot(X[0, c], 0, 'x', color=C['coral'], ms=10, mew=2)
    grabar(fig, act, 351, 'V11_2_lasalle')


def v11_3_nyquist():                # C11_Video_Nyquist
    w = np.logspace(-3, 3.5, 3000)
    zs = np.r_[np.linspace(1.2, 3, 120), np.full(45, 3.0), np.linspace(3, 5, 120), np.full(30, 5.0)]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.2), gridspec_kw=dict(wspace=0.28))
    a1.axvspan(-0.12, 0, color=C['coral'], alpha=0.06); a1.axhline(0, color=C['gris'], lw=0.8); a1.axvline(0, color=C['gris'], lw=0.8)
    a1.set_xlim(-0.12, 0.4); a1.set_ylim(-0.3, 0.08); a1.grid(True); a1.set_xlabel('Re'); a1.set_ylabel('Im')
    cN, = a1.plot([], [], lw=2.4)
    a2.set_xscale('log'); a2.set_xlim(1e-3, 3e3); a2.set_ylim(-2.5, 2.5); a2.grid(True); a2.set_xlabel(r'$\omega$')
    a2.set_title(r'$\omega^2\,\mathrm{Re}\,G_z(j\omega)\to 3-z$')
    cW, = a2.plot([], [], lw=2.4); lim, = a2.plot([1e-3, 3e3], [0, 0], ':', lw=1.5)
    def act(j):
        z = zs[j]; G = (1j*w + z)/((1j*w)**2 + 3*1j*w + 2)
        v, c = ('SPR', C['verde']) if z < 3 - 1e-9 else (('PR', C['ambar']) if abs(z - 3) < 1e-9 else ('no PR', C['coral']))
        cN.set_data(G.real, G.imag); cN.set_color(c); cW.set_data(w, w**2*G.real); cW.set_color(c)
        lim.set_ydata([3 - z]*2); lim.set_color(c); a1.set_title(f'$z={z:.2f}$: {v}')
    grabar(fig, act, len(zs), 'V11_3_nyquist')


def v11_4_interconexion():          # C11_Video_Interconexion
    a, k, b = 1, 0.5, 2; t = np.linspace(0, 25, 751)
    X = solve_ivp(lambda tt, x: [x[1], -a*x[0]**3 - k*x[1] - x[3], x[3], -b*x[2] - x[3]**3 + x[1]], (0, 25), [1.5, 0, 0, 0], t_eval=t, **o).y
    V1 = a*X[0]**4/4 + X[1]**2/2; V2 = b*X[2]**2/2 + X[3]**2/2
    fig = plt.figure(figsize=(9.6, 5.2)); gs = fig.add_gridspec(2, 2, hspace=0.45, wspace=0.25)
    a1 = fig.add_subplot(gs[0, 0]); a2 = fig.add_subplot(gs[0, 1]); a3 = fig.add_subplot(gs[1, :])
    a1.set_xlim(-2, 2); a1.set_ylim(-1, 1); a1.axis('off')
    m1 = Rectangle((-0.2, 0.25), 0.4, 0.4, color=C['azul']); m2 = Rectangle((-0.2, -0.65), 0.4, 0.4, color=C['coral'])
    a1.add_patch(m1); a1.add_patch(m2); a1.text(-1.9, 0.45, '$H_1$'); a1.text(-1.9, -0.45, '$H_2$')
    barras = a2.bar(['$V_1$', '$V_2$', '$V_1+V_2$'], [0, 0, 0], color=[C['azul'], C['coral'], C['noche']])
    a2.set_ylim(0, 1.35); a2.grid(True, axis='y')
    a3.set_xlim(0, 25); a3.set_ylim(0, 1.35); a3.grid(True); a3.set_xlabel('$t$')
    l1, = a3.plot([], [], color=C['azul'], label='$V_1$'); l2, = a3.plot([], [], color=C['coral'], label='$V_2$')
    l3, = a3.plot([], [], color=C['noche'], lw=2.4, label='$V$'); a3.legend(loc='upper right')
    def act(j):
        k = 2*j
        m1.set_x(X[0, k] - 0.2); m2.set_x(X[2, k] - 0.2)
        for bb, v in zip(barras, (V1[k], V2[k], V1[k] + V2[k])): bb.set_height(v)
        a2.set_title(f'$t={t[k]:.1f}$')
        l1.set_data(t[:k+1], V1[:k+1]); l2.set_data(t[:k+1], V2[:k+1]); l3.set_data(t[:k+1], V1[:k+1] + V2[:k+1])
    grabar(fig, act, 376, 'V11_4_interconexion')


def v11_5_agua():                   # C11_Video_Agua
    Q, r, vm = 2.0, 2.0, 2.0; c1 = np.array([0.6, 1.0, 1.4]); c2 = np.array([0.6, 1.0, 2.0])
    def agua(tt, x, c):
        v, q = np.maximum(x[:3], 0), x[3:]; F = r*(1 - v/vm); Fb = q @ F/Q
        return np.r_[q - c*np.sqrt(v), q*(F - Fb)]
    def Vt(X, c):
        vs = Q**2/c.sum()**2; qs = c*Q/c.sum()
        return r/(2*Q*vm)*np.sum((X[:3] - vs)**2, axis=0) + np.sum(qs[:, None]*np.log(qs[:, None]/X[3:]), axis=0)/Q
    t1 = np.linspace(0, 40, 481); t2 = np.linspace(40, 80, 481)
    X1 = solve_ivp(agua, (0, 40), [0.1, 0.8, 0.3, 0.9, 0.6, 0.5], t_eval=t1, args=(c1,), **o).y
    X2 = solve_ivp(agua, (40, 80), X1[:, -1], t_eval=t2, args=(c2,), **o).y
    t = np.r_[t1, t2[1:]]; X = np.hstack([X1, X2[:, 1:]]); V = np.r_[Vt(X1, c1), Vt(X2[:, 1:], c2)]
    fig = plt.figure(figsize=(9.6, 5.2)); gs = fig.add_gridspec(2, 2, hspace=0.45, wspace=0.25)
    a1 = fig.add_subplot(gs[0, 0]); a2 = fig.add_subplot(gs[0, 1]); a3 = fig.add_subplot(gs[1, :])
    nv = a1.bar([1, 2, 3], [0, 0, 0], 0.6, color='#8CB5E6'); ref, = a1.plot([0.5, 3.5], [4/9]*2, '--', color=C['noche'], lw=1)
    a1.set_xlim(0.3, 3.7); a1.set_ylim(0, 1); a1.set_xticks([1, 2, 3]); a1.grid(True, axis='y')
    cq = a2.bar([1, 2, 3], [0, 0, 0], 0.6, color=[C['azul'], C['coral'], C['violeta']])
    a2.set_ylim(0, 1.3); a2.set_xticks([1, 2, 3]); a2.grid(True, axis='y'); a2.set_title(r'caudales $q_i$ ($\sum q_i=Q=2$)')
    a3.set_yscale('log'); a3.set_xlim(0, 80); a3.set_ylim(1e-8, 10); a3.grid(True); a3.axvline(40, color=C['ambar'], lw=2)
    lV, = a3.plot([], [], color=C['noche'], lw=2.4); a3.set_xlabel('$t$ (s)'); a3.set_title('$V=V_1+V_2$ respecto al equilibrio vigente')
    def act(k):
        for bb, v in zip(nv, X[:3, k]): bb.set_height(v)
        for bb, v in zip(cq, X[3:, k]): bb.set_height(v)
        if t[k] >= 40: ref.set_ydata([4/12.96]*2)
        lV.set_data(t[:k+1], V[:k+1])
        a1.set_title(f'volúmenes, $t={t[k]:.1f}$ s, $c_3={1.4 + 0.6*(t[k] >= 40):.1f}$')
    grabar(fig, act, len(t), 'V11_5_agua')


if __name__ == '__main__':
    import sys
    fns = [v11_1_balance, v11_2_lasalle, v11_3_nyquist, v11_4_interconexion, v11_5_agua]
    for f in fns:
        if len(sys.argv) == 1 or f.__name__ in sys.argv[1:]: f()
