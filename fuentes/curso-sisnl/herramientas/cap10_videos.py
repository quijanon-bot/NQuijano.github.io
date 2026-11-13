"""Videos de la parte 10 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C10_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap10_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V10_1_banda_uub.mp4, V10_2_bola_no_invariante.mp4,
           V10_3_energia_futura.mp4, V10_4_rediseno_iss.mp4
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.linalg import solve_continuous_lyapunov, expm
from estilo import C
from cap04_videos import grabar

o = dict(rtol=1e-9, atol=1e-11)


def v10_1_banda():                  # C10_Video_BandaUUB
    d, a = 1.0, 4.0; bs = np.r_[np.linspace(3, 1.05, 70), np.full(20, 1.05)]
    t = np.linspace(0, 12, 1200)
    X = [solve_ivp(lambda tt, z: [-z[0] + d*np.sin(tt)], (0, 12), [x0], t_eval=t, **o).y[0] for x0 in (4, -4, 2)]
    env = np.exp(-t)*a + d*(1 - np.exp(-t))
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.28, width_ratios=[1.5, 1]))
    bb = np.linspace(1.01, 3.2, 300)
    def act(k):
        b = bs[k]; T = np.log((a - d)/(b - d))
        a1.cla()
        for x, c in zip(X, (C['azul'], C['verde'], C['violeta'])): a1.plot(t, x, color=c, lw=1.4)
        a1.plot(t, env, '--', color=C['coral'], lw=1); a1.plot(t, -env, '--', color=C['coral'], lw=1)
        a1.axhspan(-b, b, xmin=min(T/12, 1), color=C['verde'], alpha=0.15); a1.axvline(T, color=C['gris'], ls=':')
        a1.set_xlim(0, 12); a1.set_ylim(-4.3, 4.3); a1.grid(True); a1.set_xlabel('$t$'); a1.set_ylabel('$x$')
        a1.set_title(rf'$\dot x=-x+\sin t$: cota $b={b:.2f}$ desde $T={T:.2f}$')
        a2.cla(); a2.plot(bb, np.log((a - d)/(bb - d)), color=C['noche']); a2.plot(b, T, 'o', color=C['coral'], ms=9)
        a2.axvline(d, color=C['coral'], ls='--', lw=1); a2.set_xlim(0.9, 3.2); a2.set_ylim(0, 6)
        a2.grid(True); a2.set_xlabel('cota $b$'); a2.set_ylabel('$T(4,b)$'); a2.set_title('afinar la cota cuesta tiempo')
    grabar(fig, act, len(bs), 'V10_1_banda_uub')


def v10_2_bola():                   # C10_Video_BolaNoInvariante
    A = np.array([[0, 1], [-4, -0.2]]); B = np.array([0, 1]); P = solve_continuous_lyapunov(A.T, -np.eye(2))
    lm, lM = np.linalg.eigvalsh(P); mu = 2*np.linalg.norm(P @ B)*0.2/0.5; eta = lM*mu**2
    t = np.linspace(0, 20, 2001)
    s = solve_ivp(lambda tt, z: A @ z + B*0.2*np.sin(1.3*tt), (0, 20), [2.45, 0], t_eval=t, **o)
    n = np.linalg.norm(s.y, axis=0); V = np.einsum('ij,ik,kj->j', s.y, P, s.y)
    th = np.linspace(0, 2*np.pi, 300); U = np.vstack([np.cos(th), np.sin(th)])
    E = U*np.sqrt(eta/np.einsum('ij,ik,kj->j', U, P, U))
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.6), gridspec_kw=dict(wspace=0.3))
    nf = 150; idx = np.linspace(0, len(t) - 1, nf).astype(int)
    def act(k):
        j = idx[k]; dentro = n[j] <= mu
        a1.cla(); a1.fill(mu*np.cos(th), mu*np.sin(th), color=C['coral'], alpha=0.12); a1.plot(mu*np.cos(th), mu*np.sin(th), color=C['coral'])
        a1.plot(E[0], E[1], color=C['azul'], lw=2.2); a1.plot(s.y[0, :j+1], s.y[1, :j+1], color=C['noche'], lw=0.9)
        a1.plot(*s.y[:, j], 'o', color=C['verde'] if dentro else C['coral'], ms=9)
        a1.set_xlim(-5.6, 5.6); a1.set_ylim(-5.6, 5.6); a1.set_aspect('equal'); a1.grid(True)
        a1.set_title(r'$B_\mu$ (coral) y $\Omega_\eta$ (azul)'); a1.set_xlabel('$x_1$'); a1.set_ylabel('$x_2$')
        a2.cla(); a2.plot(t[:j+1], n[:j+1]/mu, color=C['coral'], label=r'$\|x\|/\mu$')
        a2.plot(t[:j+1], V[:j+1]/eta, color=C['azul'], label=r'$V/\eta$'); a2.axhline(1, color=C['noche'], ls='--', lw=1)
        a2.set_xlim(0, 20); a2.set_ylim(0, 2); a2.grid(True); a2.legend(loc='upper right'); a2.set_xlabel('$t$')
        a2.set_title('sale de la bola, no del conjunto de nivel')
    grabar(fig, act, nf, 'V10_2_bola_no_invariante')


def v10_3_energia():                # C10_Video_EnergiaFutura
    A = np.array([[0, 1], [-1, -1]]); P = solve_continuous_lyapunov(A.T, -np.eye(2)); x0 = np.array([1, 0.5])
    s = np.linspace(0, 14, 1400); X = np.array([expm(A*q) @ x0 for q in s]).T; n2 = (X**2).sum(0)
    Vt = np.einsum('ij,ik,kj->j', X, P, X)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.3))
    ts = np.linspace(0, 6, 120)
    def act(k):
        tc = ts[k]; j = np.searchsorted(s, tc)
        a1.cla(); a1.plot(s, n2, color=C['claro']); a1.fill_between(s[j:], n2[j:], color=C['azul'], alpha=0.3)
        a1.plot(s[j:], n2[j:], color=C['azul']); a1.axvline(tc, color=C['coral'])
        a1.set_xlim(0, 12); a1.set_ylim(0, 1.3); a1.grid(True); a1.set_xlabel('$s$'); a1.set_ylabel(r'$\|x(s)\|^2$')
        a1.set_title(rf'$V(x(t))=\int_t^\infty\|x\|^2={Vt[j]:.3f}$')
        a2.cla(); a2.plot(s, Vt, color=C['claro']); a2.plot(s[:j+1], Vt[:j+1], color=C['noche'], lw=2)
        a2.plot(tc, Vt[j], 'o', color=C['coral'], ms=8)
        a2.plot([tc - 1, tc + 1], [Vt[j] + n2[j], Vt[j] - n2[j]], '--', color=C['coral'], lw=1.2)
        a2.set_xlim(0, 7); a2.set_ylim(0, 2.4); a2.grid(True); a2.set_xlabel('$t$'); a2.set_ylabel('$x\'Px$')
        a2.set_title(rf'pendiente $-\|x(t)\|^2=-{n2[j]:.3f}$')
    grabar(fig, act, len(ts), 'V10_3_energia_futura')


def v10_4_rediseno():               # C10_Video_RedisenoISS
    k = lambda x: -2*x/(x**2 + 1); k1 = lambda x: k(x) - x*(x**2 + 1)
    ws = np.r_[np.linspace(0.05, 1, 60), np.full(15, 1.0)]; xx = np.linspace(-1, 12, 600)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.4), gridspec_kw=dict(wspace=0.3))
    ev = lambda t, z: z[0] - 30; ev.terminal = True
    def act(j):
        w = ws[j]
        a1.cla(); a1.plot(xx, -xx + (xx**2 + 1)*w, color=C['coral'], label='cancelación')
        a1.plot(xx, -xx - xx*(xx**2 + 1)**2 + (xx**2 + 1)*w, color=C['azul'], label=r'con $-L_gV$')
        a1.axhline(0, color=C['gris'], lw=0.8); a1.set_xlim(-1, 12); a1.set_ylim(-4, 8); a1.grid(True)
        a1.set_xlabel('$x$'); a1.set_ylabel(r'$\dot x$'); a1.legend(loc='upper left')
        a1.set_title(rf'error del actuador $w={w:.2f}$')
        a2.cla()
        for kk, c in [(k, C['coral']), (k1, C['azul'])]:
            s = solve_ivp(lambda t, z: [z[0] + (z[0]**2 + 1)*(kk(z[0]) + w)], (0, 8), [0], events=ev, max_step=0.02, **o)
            a2.plot(s.t, s.y[0], color=c)
        a2.set_xlim(0, 8); a2.set_ylim(-0.5, 12); a2.grid(True); a2.set_xlabel('$t$'); a2.set_ylabel('$x$')
        a2.set_title('desde $x(0)=0$')
    grabar(fig, act, len(ws), 'V10_4_rediseno_iss')


if __name__ == '__main__':
    import sys
    fns = [v10_1_banda, v10_2_bola, v10_3_energia, v10_4_rediseno]
    for f in fns:
        if len(sys.argv) == 1 or f.__name__ in sys.argv[1:]: f()
