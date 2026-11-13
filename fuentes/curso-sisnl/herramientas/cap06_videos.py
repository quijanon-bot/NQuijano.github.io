"""Videos de la parte 6 para la página web (MP4, H.264), hechos con matplotlib.
Son la versión en Python de los scripts C6_Video_* (mismos modelos y parámetros);
los de MATLAB siguen siendo la referencia para grabar en clase.
Ejecutar:  python3 herramientas/cap06_videos.py   [nombre ...]     (requiere ffmpeg)
Salida:    sitio/videos/V6_1_cuello_botella.mp4, V6_2_hopf.mp4,
           V6_3_histeresis_ciclos.mp4, V6_4_poincare.mp4
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from estilo import C
from cap04_videos import grabar

o = dict(rtol=1e-9, atol=1e-11)


def v6_1_cuello():                  # C6_Video_CuelloBotella
    mus = [-0.5, -0.1, -0.02]; nt = 110
    datos = []
    for mu in mus:
        e = lambda t, x: x[0] + 3; e.terminal = True
        s = solve_ivp(lambda t, x: [mu - x[0]**2], (0, 40), [3.0], events=e, dense_output=True, **o)
        tk = np.linspace(0, s.t[-1], nt); datos.append((mu, tk, s.sol(tk)[0]))
    xx = np.linspace(-3, 3, 300)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.6), gridspec_kw=dict(wspace=0.28))
    def act(k):
        i, j = divmod(k, nt); mu, tk, xk = datos[i]
        a1.cla(); a1.plot(xx, mu - xx**2, color=C['noche']); a1.axhline(0, color=C['gris'], ls=':')
        a1.plot(xk[j], 0, 'o', color=C['coral'], ms=11)
        a1.set_xlim(-3, 3); a1.set_ylim(-6, 1); a1.grid(True); a1.set_xlabel('$x$'); a1.set_ylabel(r'$\dot x=\mu-x^2$')
        a1.set_title(rf'$\mu={mu:g}$: no hay equilibrios')
        a2.cla()
        for ii in range(i):
            a2.plot(datos[ii][1], datos[ii][2], color=C['claro'], lw=1.2)
        a2.plot(tk[:j+1], xk[:j+1], color=C['azul'], lw=2)
        a2.set_xlim(0, 26); a2.set_ylim(-3, 3); a2.grid(True); a2.set_xlabel('$t$'); a2.set_ylabel('$x$')
        a2.set_title(rf'tránsito $\approx\pi/\sqrt{{|\mu|}}={np.pi/np.sqrt(-mu):.1f}$')
    grabar(fig, act, nt*len(mus), 'V6_1_cuello_botella')


def ciclo(mu):
    F = lambda t, z: [z[1] - (z[0]**3 - mu*z[0]), -z[0]]
    s = solve_ivp(F, (0, 300), [0.1, 0], **o)
    return solve_ivp(F, (0, 7), s.y[:, -1], max_step=0.02, **o).y


def v6_2_hopf():                    # C6_Video_Hopf
    mus = np.linspace(-0.4, 1, 120)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.8), gridspec_kw=dict(wspace=0.28, width_ratios=[1.2, 1]))
    def act(k):
        mu = mus[k]; F = lambda t, z: [z[1] - (z[0]**3 - mu*z[0]), -z[0]]
        s = solve_ivp(F, (0, 60), [0.6, 0], max_step=0.05, **o)
        a1.cla(); a1.plot(s.y[0], s.y[1], color=C['azul'], lw=1)
        if mu > 0.005:
            Y = ciclo(mu); a1.plot(Y[0], Y[1], color=C['verde'], lw=3)
        a1.plot(0, 0, 'o', color=C['noche'] if mu < 0 else 'w', mec=C['noche'], ms=8)
        a1.set_xlim(-1.8, 1.8); a1.set_ylim(-1.8, 1.8); a1.set_aspect('equal'); a1.grid(True)
        a1.set_xlabel('$x_1$'); a1.set_ylabel('$x_2$'); a1.set_title(rf'$\mu={mu:.2f}$')
        lam = np.linalg.eigvals([[mu, 1], [-1, 0]])
        a2.cla(); a2.axvline(0, color=C['noche']); a2.axhline(0, color=C['gris'], ls=':')
        a2.plot(lam.real, lam.imag, 'x', color=C['coral'], ms=14, mew=3)
        a2.set_xlim(-0.6, 0.6); a2.set_ylim(-1.5, 1.5); a2.grid(True)
        a2.set_xlabel(r'Re $\lambda$'); a2.set_ylabel(r'Im $\lambda$'); a2.set_title('valores propios del origen')
    grabar(fig, act, len(mus), 'V6_2_hopf')


def v6_3_histeresis():              # C6_Video_Histeresis
    T = 3000.
    g = lambda t, x, m0, m1: [x[0]*((m0 + (m1 - m0)*t/T) + x[0]**2 - x[0]**4) + 1e-6]
    tt = np.linspace(0, T, 160)
    s1 = solve_ivp(g, (0, T), [1e-3], args=(-0.4, 0.1), t_eval=tt, max_step=1, rtol=1e-10, atol=1e-12)
    s2 = solve_ivp(g, (0, T), [s1.y[0, -1]], args=(0.1, -0.4), t_eval=tt, max_step=1, rtol=1e-10, atol=1e-12)
    m = np.concatenate([-0.4 + 0.5*tt/T, 0.1 - 0.5*tt/T]); R = np.concatenate([s1.y[0], s2.y[0]])
    th = 0.35*np.arange(len(m))
    rr = np.linspace(0, 1.3, 400); mr = rr**4 - rr**2; est = (2*rr - 4*rr**3) < 0
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.6), gridspec_kw=dict(wspace=0.28))
    def act(k):
        a1.cla(); k0 = max(0, k - 12)
        cc = np.linspace(0, 2*np.pi, 200); a1.plot(R[k]*np.cos(cc), R[k]*np.sin(cc), color=C['claro'], lw=1)
        ts = np.linspace(th[k0], th[k], 20*(k - k0) + 2); rs = np.interp(ts, th[k0:k+1], R[k0:k+1])
        a1.plot(rs*np.cos(ts), rs*np.sin(ts), color=C['azul'], lw=1.5)
        a1.plot(R[k]*np.cos(th[k]), R[k]*np.sin(th[k]), 'o', color=C['coral'], ms=10)
        a1.set_xlim(-1.3, 1.3); a1.set_ylim(-1.3, 1.3); a1.set_aspect('equal'); a1.grid(True)
        a1.set_title(rf'$\mu={m[k]:.3f}$ ' + ('(subiendo)' if k < len(tt) else '(bajando)'))
        a2.cla(); a2.plot(mr[est], rr[est], color=C['verde'], lw=2.4); a2.plot(mr[~est], rr[~est], color=C['coral'], lw=2, ls='--')
        a2.plot([-0.45, 0], [0, 0], color=C['noche'], lw=2); a2.plot([0, 0.15], [0, 0], color=C['coral'], lw=2, ls='--')
        a2.plot(m[:k+1], R[:k+1], color=C['azul'], lw=1.5); a2.plot(m[k], R[k], 'o', color=C['coral'], ms=8)
        a2.set_xlim(-0.45, 0.15); a2.set_ylim(-0.05, 1.3); a2.grid(True); a2.set_xlabel(r'$\mu$'); a2.set_ylabel('$r$')
        a2.set_title(r'$\dot r=r(\mu+r^2-r^4)$')
    grabar(fig, act, len(m), 'V6_3_histeresis_ciclos')


def v6_4_poincare():                # C6_Video_Poincare
    F = lambda t, z: [z[1] - (z[0]**3 - z[0]), -z[0]]
    tt = np.linspace(0, 26, 400)
    s = solve_ivp(F, (0, 26), [0.2, 0], t_eval=tt, max_step=0.02, **o)
    from cap06_figuras import retorno
    Fz = lambda z: F(0, z)
    qq = np.linspace(0.05, 2.5, 40); PP = [retorno(Fz, q)[0] for q in qq]
    q = [0.2]
    for _ in range(4): q.append(retorno(Fz, q[-1])[0])
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 4.8), gridspec_kw=dict(wspace=0.28))
    def act(k):
        X = s.y[:, :k+1]
        a1.cla(); a1.plot(X[0], X[1], color=C['azul'], lw=1.3); a1.plot([0, 2.5], [0, 0], color=C['ambar'], lw=3)
        cr = [i for i in range(1, X.shape[1]) if X[1, i-1] > 0 >= X[1, i] and X[0, i] > 0]
        a1.plot(X[0, cr], 0*X[0, cr], 'o', color=C['coral'], ms=7, zorder=5)
        a1.set_xlim(-2.5, 2.5); a1.set_ylim(-2.5, 2.5); a1.set_aspect('equal'); a1.grid(True)
        a1.set_xlabel('$x_1$'); a1.set_ylabel('$x_2$'); a1.set_title(r'van der Pol: sección $\Sigma$ (ámbar)')
        a2.cla(); a2.plot(qq, PP, color=C['noche'], lw=2); a2.plot(qq, qq, color=C['gris'], ls=':')
        for i in range(min(len(cr), len(q) - 1)):
            a2.plot([q[i], q[i], q[i+1]], [q[i] if i else 0, q[i+1], q[i+1]], color=C['coral'], lw=1.4)
        a2.set_xlim(0, 2.5); a2.set_ylim(0, 2.5); a2.set_aspect('equal'); a2.grid(True)
        a2.set_xlabel('$q_k$'); a2.set_ylabel('$q_{k+1}=P(q_k)$'); a2.set_title('telaraña')
    grabar(fig, act, len(tt), 'V6_4_poincare')


if __name__ == '__main__':
    import sys
    fns = dict(v6_1_cuello=v6_1_cuello, v6_2_hopf=v6_2_hopf, v6_3_histeresis=v6_3_histeresis, v6_4_poincare=v6_4_poincare)
    for nombre in (sys.argv[1:] or fns):
        fns[nombre]()
