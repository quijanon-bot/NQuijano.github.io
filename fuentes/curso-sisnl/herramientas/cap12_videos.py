# Transparencia: escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
"""Videos de la parte 12 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C12_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap12_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V12_1_levitador.mp4, V12_2_fase_no_minima.mp4,
           V12_3_dinamica_cero.mp4, V12_4_difeomorfismo.mp4
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from scipy.integrate import solve_ivp
from estilo import C
from cap04_videos import grabar
from cap12_figuras import f_lev, eq, ufl, K

o = dict(rtol=1e-10, atol=1e-12)


def v12_1_levitador():              # C12_Video_Levitador
    Am, w, T = 0.03, 2*np.pi, 3.0
    yd = lambda t: np.array([0.08 + Am*np.sin(w*t), Am*w*np.cos(w*t), -Am*w**2*np.sin(w*t), -Am*w**3*np.cos(w*t)])
    def ujac(t, x):
        xr, ur = eq(yd(t)[0]); return ur - K@(x - xr)
    t = np.linspace(0, T, int(4*24*T)); x0, _ = eq(0.08)
    X1 = solve_ivp(lambda tt, x: f_lev(x, ujac(tt, x)), (0, T), x0, t_eval=t, max_step=1e-3, rtol=1e-9, atol=1e-11).y
    X2 = solve_ivp(lambda tt, x: f_lev(x, ufl(x, yd(tt))), (0, T), x0, t_eval=t, max_step=1e-3, rtol=1e-9, atol=1e-11).y
    Yd = 0.08 + Am*np.sin(w*t)
    U1 = np.array([ujac(t[i], X1[:, i]) for i in range(len(t))]); U2 = np.array([ufl(X2[:, i], yd(t[i])) for i in range(len(t))])
    fig = plt.figure(figsize=(9.6, 5.4)); gs = fig.add_gridspec(2, 3, hspace=0.45, wspace=0.35)
    a1 = fig.add_subplot(gs[:, 0]); a2 = fig.add_subplot(gs[0, 1:]); a3 = fig.add_subplot(gs[1, 1:])
    a1.set_xlim(-0.03, 0.17); a1.set_ylim(0.2, -0.045); a1.set_aspect('equal'); a1.axis('off')
    cs = [C['coral'], C['azul']]; xc = [0.02, 0.11]; bolas = []; refs = []
    for j in range(2):
        a1.add_patch(Rectangle((xc[j] - 0.025, -0.03), 0.05, 0.025, color='#99A8C9'))
        refs.append(a1.plot([xc[j] - 0.02, xc[j] + 0.02], [0.08, 0.08], color=C['noche'], lw=2)[0])
        bolas.append(a1.plot([xc[j]], [0.08], 'o', ms=20, color=cs[j], mec=C['noche'])[0])
    a1.text(0.02, 0.17, 'jacobiana', ha='center', color=cs[0]); a1.text(0.11, 0.17, 'exacta', ha='center', color=cs[1])
    a2.plot(t, Yd, '--', color=C['noche'], lw=1); l1, = a2.plot([], [], color=cs[0]); l2, = a2.plot([], [], color=cs[1])
    a2.set_xlim(0, T); a2.set_ylim(0.13, 0.03); a2.grid(True); a2.set_ylabel('$y$ [m]')
    m1, = a3.plot([], [], color=cs[0]); m2, = a3.plot([], [], color=cs[1])
    a3.set_xlim(0, T); a3.set_ylim(min(U1.min(), U2.min()) - 1, max(U1.max(), U2.max()) + 1); a3.grid(True)
    a3.set_xlabel('$t$ [s]'); a3.set_ylabel('$u$ [V]')
    def act(i):
        bolas[0].set_ydata([X1[0, i]]); bolas[1].set_ydata([X2[0, i]])
        for r in refs: r.set_ydata([Yd[i]]*2)
        l1.set_data(t[:i+1], X1[0, :i+1]); l2.set_data(t[:i+1], X2[0, :i+1])
        m1.set_data(t[:i+1], U1[:i+1]); m2.set_data(t[:i+1], U2[:i+1])
        a2.set_title(f'$t = {t[i]:.2f}$ s (cuatro veces más lento)')
    grabar(fig, act, len(t), 'V12_1_levitador')


def v12_2_fase_no_minima():         # C12_Video_FaseNoMinima
    k = 2
    lazo = lambda tt, x: [x[0] + x[1], 3*x[0]**2*x[1] + x[0] + (-x[0] + 3*x[0]**3 - k*(-x[0]**3 + x[1]))]
    ev = lambda tt, x: abs(x[0]) - 2.2; ev.terminal = True
    s = solve_ivp(lazo, (0, 10), [0.05, 0.6], events=ev, max_step=0.005, dense_output=True, **o)
    t = np.linspace(0, s.t[-1], 288); X = s.sol(t)
    y = -X[0]**3 + X[1]; u = -X[0] + 3*X[0]**3 - k*y
    fig = plt.figure(figsize=(9.6, 5.4)); gs = fig.add_gridspec(2, 2, hspace=0.45, wspace=0.28)
    a1 = fig.add_subplot(gs[:, 0]); a2 = fig.add_subplot(gs[0, 1]); a3 = fig.add_subplot(gs[1, 1])
    xx = np.linspace(-0.3, 2.4, 300); a1.plot(xx, xx**3, color=C['verde'], lw=4, alpha=0.6)
    tr, = a1.plot([], [], color=C['azul']); pt, = a1.plot([], [], 'o', ms=9, color=C['coral'], mec=C['noche'])
    a1.set_xlim(-0.3, 2.4); a1.set_ylim(-1, 12); a1.grid(True); a1.set_xlabel(r'$x_1=\eta$'); a1.set_ylabel('$x_2$')
    a1.set_title(r'Llega a $Z^*=\{x_2=x_1^3\}$... y se va por ella')
    l1, = a2.plot([], [], color=C['azul'], label=r'$y=\xi$'); l2, = a2.plot([], [], color=C['coral'], label=r'$\eta=x_1$')
    a2.set_xlim(0, t[-1]); a2.set_ylim(-0.2, 2.4); a2.grid(True); a2.legend(loc='upper left'); a2.set_title('La salida converge como se diseñó...')
    l3, = a3.plot([], [], color=C['violeta']); a3.set_xlim(0, t[-1]); a3.set_ylim(min(-1, u.min()), 1.05*u.max()); a3.grid(True)
    a3.set_xlabel('$t$'); a3.set_ylabel('$u$'); a3.set_title('...pero el estado interno y el control explotan')
    def act(i):
        tr.set_data(X[0, :i+1], X[1, :i+1]); pt.set_data([X[0, i]], [X[1, i]])
        l1.set_data(t[:i+1], y[:i+1]); l2.set_data(t[:i+1], X[0, :i+1]); l3.set_data(t[:i+1], u[:i+1])
    grabar(fig, act, len(t), 'V12_2_fase_no_minima')


def v12_3_dinamica_cero():          # C12_Video_DinamicaCero
    c = lambda e1, e2: 0.3*(e1**2 - e2**2); t = np.linspace(0, 14, 14*24)
    Z = [solve_ivp(lambda tt, z: np.r_[-3*z[0], np.array([[sg, -2], [2, sg]])@z[1:] + np.array([z[0], 0])], (0, 14), [1.2, 1.0, 0.3], t_eval=t, **o).y
         for sg in (-0.25, 0.12)]
    fig = plt.figure(figsize=(9.6, 4.8)); G1, G2 = np.meshgrid(np.linspace(-2.2, 2.2, 25), np.linspace(-2.2, 2.2, 25))
    tit = ['Fase mínima ($s=-0.25$)', 'Fase no mínima ($s=+0.12$)']; cs = [C['verde'], C['coral']]; ax = []; tr = []; pt = []
    for j in range(2):
        a_ = fig.add_subplot(1, 2, j + 1, projection='3d'); ax.append(a_)
        a_.plot_surface(G1, G2, c(G1, G2), alpha=0.25, color='#99B3D9', linewidth=0)
        tr.append(a_.plot([], [], [], color=cs[j], lw=2)[0]); pt.append(a_.plot([], [], [], 'o', color=cs[j], mec=C['noche'])[0])
        a_.view_init(25, -35); a_.set_xlim(-2.2, 2.2); a_.set_ylim(-2.2, 2.2); a_.set_zlim(-1.6, 1.8)
        a_.set_xlabel('$x_1$'); a_.set_ylabel('$x_2$'); a_.set_zlabel('$x_3$'); a_.set_title(tit[j])
    def act(i):
        for j in range(2):
            z = Z[j][:, :i+1].copy(); fuera = (abs(z[1]) >= 2.2) | (abs(z[2]) >= 2.2); z[:, fuera] = np.nan
            x3 = z[0] + c(z[1], z[2]); tr[j].set_data_3d(z[1], z[2], x3)
            if not fuera[-1]: pt[j].set_data_3d([z[1, -1]], [z[2, -1]], [x3[-1]])
    grabar(fig, act, len(t), 'V12_3_dinamica_cero')


def v12_4_difeomorfismo():          # C12_Video_Difeomorfismo
    N = 12*24; rej = np.linspace(-2, 2, 11); s = np.linspace(-2, 2, 200); c1 = np.linspace(-0.8, 0.5, 8); th = np.linspace(0, 4*np.pi, 800)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.8), gridspec_kw=dict(wspace=0.25))
    hv = [a1.plot([], [], color=C['azul'], lw=1.2)[0] for _ in rej]; hh = [a1.plot([], [], color=C['coral'], lw=1.2)[0] for _ in rej]
    a1.set_xlim(-2.2, 2.2); a1.set_ylim(-4.5, 4.5); a1.grid(True); a1.set_title(r'$\Phi(x)=(x_1,\ x_2+x_1^3/2)$: global')
    ha = [a2.plot([], [], lw=1.4)[0] for _ in c1]
    a2.set_aspect('equal'); a2.set_xlim(-1.8, 1.8); a2.set_ylim(-1.8, 1.8); a2.grid(True)
    a2.set_title(r'$e^{x_1}(\cos x_2,\ \sin x_2)$: $\det\neq0$, pero dos vueltas')
    def act(i):
        al = min(1, i/(0.6*N)); al = 0.5 - 0.5*np.cos(np.pi*al)
        for k, r in enumerate(rej):
            hv[k].set_data(r*np.ones_like(s), s + al*r**3/2); hh[k].set_data(s, r + al*s**3/2)
        msk = th <= 4*np.pi*min(1, i/(0.85*N)); col = C['coral'] if np.any(th[msk] > 2*np.pi) else C['azul']
        for k, cc in enumerate(c1):
            ha[k].set_data(np.exp(cc)*np.cos(th[msk]), np.exp(cc)*np.sin(th[msk])); ha[k].set_color(col)
    grabar(fig, act, N, 'V12_4_difeomorfismo')


if __name__ == '__main__':
    import sys
    fns = [v12_1_levitador, v12_2_fase_no_minima, v12_3_dinamica_cero, v12_4_difeomorfismo]
    for f in fns:
        if len(sys.argv) == 1 or f.__name__ in sys.argv[1:]: f()
