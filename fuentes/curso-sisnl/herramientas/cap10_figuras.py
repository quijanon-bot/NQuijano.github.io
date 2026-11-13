"""Figuras del capítulo 10 (UUB, conversos, CLF, Barbalat, ISS). PDF (notas) y SVG (web).
Cada figura reproduce un script de codigo/cap10_avanzada/ (se indica cuál).
Ejecutar:  python3 herramientas/cap10_figuras.py   [nombre_de_función ...]
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.linalg import solve_continuous_lyapunov, expm
from estilo import C, guardar
from cap04_figuras import campo, tray, punto, ejes

CAP = 'cap10'
def g(fig, nombre): guardar(fig, nombre, CAP)
o = dict(rtol=1e-10, atol=1e-12)


def elipse(P, c, n=400):
    """Frontera de {x : x' P x = c}."""
    th = np.linspace(0, 2*np.pi, n); U = np.vstack([np.cos(th), np.sin(th)])
    r = np.sqrt(c/np.einsum('ij,ik,kj->j', U, P, U)); return U*r


# ------------------------------------------------------------------ 10.2
def uub_escalar():                  # C10_Ej1 [escalar]
    fig, ax = plt.subplots(1, 2, figsize=(7.0, 2.9), gridspec_kw=dict(width_ratios=[1.6, 1], wspace=0.32))
    d = 1.0; t = np.linspace(0, 12, 1200)
    a = ax[0]
    for x0, c in [(4, C['azul']), (2, C['violeta']), (-4, C['verde'])]:
        s = solve_ivp(lambda tt, z: [-z[0] + d*np.sin(tt)], (0, 12), [x0], t_eval=t, **o)
        a.plot(t, s.y[0], color=c, lw=1.5, label=f'$x(0)={x0}$')
    env = np.exp(-t)*4 + d*(1 - np.exp(-t))
    a.plot(t, env, color=C['coral'], lw=1.2, ls='--'); a.plot(t, -env, color=C['coral'], lw=1.2, ls='--')
    b = 1.5; T = np.log((4 - d)/(b - d))
    a.axhspan(-b, b, xmin=T/12, color=C['verde'], alpha=0.12)
    a.axvline(T, color=C['gris'], lw=0.8, ls=':'); a.text(T + 0.15, 3.3, f'$T(4,1.5)=\\ln 6={T:.2f}$', fontsize=8)
    for y in (d/np.sqrt(2), -d/np.sqrt(2)): a.axhline(y, color=C['noche'], lw=0.8, ls=':')
    a.set_xlim(0, 12); a.set_ylim(-4.3, 4.3); a.set_xlabel('$t$'); a.set_ylabel('$x$'); a.grid(True)
    a.legend(loc='lower right', fontsize=7, ncol=3); a.set_title(r'$\dot x=-x+\sin t$')
    a = ax[1]; bb = np.linspace(1.01, 3.5, 300)
    for aa, c in [(4, C['azul']), (14, C['violeta'])]:
        a.plot(bb, np.log((aa - d)/(bb - d)), color=c, label=f'$a={aa}$')
    a.axvline(d, color=C['coral'], ls='--', lw=1); a.text(1.05, 5.5, r'$b\to\delta$', color=C['coral'], fontsize=8)
    a.set_xlabel('cota última $b$'); a.set_ylabel('$T(a,b)$'); a.set_ylim(0, 6.5); a.grid(True); a.legend()
    a.set_title('el precio de afinar la cota')
    g(fig, 'f_uub_escalar')


def conjuntos():                    # C10_Ej2 [conjuntos] y [resorte]
    fig, ax = plt.subplots(1, 2, figsize=(7.2, 3.3), gridspec_kw=dict(width_ratios=[1, 1.25], wspace=0.3))
    A = np.array([[0, 1], [-4, -0.2]]); B = np.array([0, 1])
    P = solve_continuous_lyapunov(A.T, -np.eye(2)); lm, lM = np.linalg.eigvalsh(P)
    mu = 2*np.linalg.norm(P @ B)*0.2/0.5; eta = lM*mu**2; b = mu*np.sqrt(lM/lm)
    a = ax[0]; th = np.linspace(0, 2*np.pi, 300)
    a.fill(mu*np.cos(th), mu*np.sin(th), color=C['coral'], alpha=0.12); a.plot(mu*np.cos(th), mu*np.sin(th), color=C['coral'], lw=1.4)
    E = elipse(P, eta); a.plot(E[0], E[1], color=C['azul'], lw=2)
    a.plot(b*np.cos(th), b*np.sin(th), color=C['verde'], lw=1.4, ls='--')
    s = solve_ivp(lambda tt, z: A @ z + B*0.2*np.sin(1.3*tt), (0, 40), [2.45, 0], max_step=0.02, **o)
    a.plot(s.y[0], s.y[1], color=C['noche'], lw=0.8); a.plot(2.45, 0, 'o', color=C['noche'], ms=4)
    nm = np.linalg.norm(s.y, axis=0).max()
    a.text(-1.6, 0.3, r'$B_\mu$', color=C['coral'], fontsize=9); a.text(-1.2, 4.0, r'$\Omega_\eta$', color=C['azul'], fontsize=9)
    a.text(3.2, 4.2, r'$B_b$', color=C['verde'], fontsize=9)
    ejes(a, (-5.4, 5.4), (-5.4, 5.4), f'$\\mu={mu:.2f}$, $b={b:.2f}$, máx $\\|x\\|={nm:.2f}$')
    a = ax[1]; M = 0.3; th_ = 0.9; mu2 = np.sqrt(5)*M/th_
    lm2, lM2 = (5 - np.sqrt(5))/4, (5 + np.sqrt(5))/4; b2 = np.sqrt((lM2*mu2**2 + mu2**4/2)/lm2)
    for wf, c, lab in [(lambda tt: M*np.cos(tt), C['azul'], r'$w=0.3\cos t$'), (lambda tt: M*np.cos(2*tt), C['violeta'], r'$w=0.3\cos 2t$'),
                       (lambda tt: M + 0*tt, C['ambar'], r'$w\equiv0.3$')]:
        s = solve_ivp(lambda tt, z: [z[1], -(1 + z[0]**2)*z[0] - z[1] + wf(tt)], (0, 30), [2, 0], t_eval=np.linspace(0, 30, 3000), **o)
        a.plot(s.t, np.linalg.norm(s.y, axis=0), color=c, lw=1.3, label=lab)
    a.axhline(mu2, color=C['coral'], ls='--', lw=1.2); a.text(25, mu2 + 0.05, f'$\\mu={mu2:.3f}$', color=C['coral'], fontsize=8)
    a.axhline(b2, color=C['verde'], ls='--', lw=1.2); a.text(25, b2 + 0.05, f'$b={b2:.2f}$', color=C['verde'], fontsize=8)
    a.set_xlim(0, 30); a.set_ylim(0, 2.2); a.set_xlabel('$t$'); a.set_ylabel(r'$\|x(t)\|$'); a.grid(True)
    a.legend(loc='upper center', fontsize=7, ncol=3); a.set_title('resorte endurecido forzado')
    g(fig, 'f_conjuntos')


# ------------------------------------------------------------------ 10.3
def energia_futura():               # C10_Ej3 [energia]
    A = np.array([[0, 1], [-1, -1]]); P = solve_continuous_lyapunov(A.T, -np.eye(2)); x0 = np.array([1, 0.5])
    t = np.linspace(0, 12, 1200); X = np.array([expm(A*tt) @ x0 for tt in t]).T; n2 = (X**2).sum(0)
    fig, ax = plt.subplots(1, 2, figsize=(7.0, 2.8), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; a.fill_between(t, n2, color=C['azul'], alpha=0.2); a.plot(t, n2, color=C['azul'])
    a.text(2.0, 0.8, f'área $={x0 @ P @ x0:.2f}=V(x_0)$', fontsize=9, color=C['noche'])
    a.set_xlabel(r'$\tau$'); a.set_ylabel(r'$\|\phi(\tau;x_0)\|^2$'); a.set_xlim(0, 12); a.grid(True); a.set_title('energía futura')
    a = ax[1]; V = np.einsum('ij,ik,kj->j', X, P, X); a.plot(t, V, color=C['noche'], lw=2, label=r'$V(x(t))=x\'Px$')
    tc = 2.0; k = np.argmin(abs(t - tc)); m = -n2[k]
    a.plot(t[k-150:k+150], V[k] + m*(t[k-150:k+150] - tc), color=C['coral'], lw=1.3, ls='--', label=r'pendiente $-\|x(t)\|^2$')
    a.plot(tc, V[k], 'o', color=C['coral'], ms=4)
    a.set_xlabel('$t$'); a.set_xlim(0, 12); a.set_ylim(0, 2.4); a.grid(True); a.legend(); a.set_title('se gasta en el presente')
    g(fig, 'f_energia_futura')


def sinV():                         # C10_Ej4 [sinV]
    def F(x):
        r2 = x[0]**2 + x[1]**2
        return [x[1], (np.sin(np.pi/r2)**2 if r2 > 1e-12 else 0)*x[1] - x[0]]
    fig, ax = plt.subplots(figsize=(4.2, 4.0)); th = np.linspace(0, 2*np.pi, 400)
    for n in (1, 2, 3, 4):
        r = 1/np.sqrt(n); ax.plot(r*np.cos(th), r*np.sin(th), color=C['azul'], lw=1.8 if n < 4 else 1)
        ax.text(r*0.72, r*0.72, f'$\\Gamma_{n}$', color=C['azul'], fontsize=8)
    s = solve_ivp(lambda t, z: F(z), (0, 80), [0.6, 0], max_step=0.02, **o)
    ax.plot(s.y[0], s.y[1], color=C['coral'], lw=0.7); ax.plot(0.6, 0, 'o', color=C['coral'], ms=4)
    punto(ax, (0, 0), True); ejes(ax, (-1.15, 1.15), (-1.15, 1.15), r'órbitas en $\|x\|^2=1/n$')
    g(fig, 'f_sinV')


# ------------------------------------------------------------------ 10.4
def sontag():                       # C10_Ej7 [sontag] y C10_Ej8 [pequeno]
    uS = lambda x: -np.cos(x) + x**3 - x*np.sqrt(x**4 + 1); uF = lambda x: -np.cos(x) + x**3 - x
    fig, ax = plt.subplots(1, 3, figsize=(7.4, 2.7), gridspec_kw=dict(wspace=0.45))
    t = np.linspace(0, 6, 600)
    for u, c, lab in [(uS, C['azul'], 'Sontag'), (uF, C['coral'], 'linealización')]:
        s = solve_ivp(lambda tt, z: [np.cos(z[0]) - z[0]**3 + u(z[0])], (0, 6), [2.0], t_eval=t, **o)
        ax[0].plot(t, s.y[0], color=c, label=lab); ax[1].plot(t, u(s.y[0]), color=c)
    ax[1].axhline(-1, color=C['gris'], ls=':', lw=1); ax[1].text(4, -0.8, '$u^*=-1$', fontsize=8)
    ax[0].set_xlabel('$t$'); ax[0].set_ylabel('$x$'); ax[0].legend(); ax[0].grid(True); ax[0].set_title(r'$\dot x=\cos x-x^3+u$')
    ax[1].set_xlabel('$t$'); ax[1].set_ylabel('$u$'); ax[1].grid(True); ax[1].set_title('esfuerzo')
    k8 = lambda x: -(1 + np.sqrt(1 + x**8))/x
    s = solve_ivp(lambda tt, z: [z[0] + z[0]**2*k8(z[0])], (0, 8), [1.0], t_eval=np.linspace(0, 8, 400), **o)
    a = ax[2]; a.semilogy(s.t, s.y[0], color=C['azul'], label='$x(t)$'); a.semilogy(s.t, abs(k8(s.y[0])), color=C['coral'], label=r'$|u(t)|$')
    a.set_xlabel('$t$'); a.legend(); a.grid(True); a.set_title(r'$\dot x=x+x^2u$')
    g(fig, 'f_sontag')


# ------------------------------------------------------------------ 10.5
def pulsos():                       # C10_Ej9 [pulsos]
    fig, ax = plt.subplots(1, 3, figsize=(7.4, 2.4), gridspec_kw=dict(wspace=0.35))
    a = ax[0]; xs, ys = [0], [0]
    for k in range(1, 7):
        w = 1/k**3; xs += [k - w/2, k, k + w/2]; ys += [0, k, 0]
    xs.append(6.6); ys.append(0); a.plot(xs, ys, color=C['azul'], lw=1.4)
    a.set_xlabel('$t$'); a.set_ylabel(r'$\psi$'); a.set_title(r'área $\pi^2/12$, $\psi(k)=k$'); a.grid(True)
    t = np.linspace(1, 3000, 20000); a = ax[1]; a.semilogx(t, np.sin(np.log(t)), color=C['violeta'])
    a.set_xlabel('$t$'); a.set_title(r'$h=\sin(\ln t)$'); a.grid(True)
    t = np.linspace(0, 2.2, 40000); a = ax[2]; a.plot(t, np.exp(-t)*np.sin(np.exp(2*t)), color=C['verde'], lw=0.8)
    a.plot(t, np.exp(-t), color=C['gris'], ls=':', lw=1); a.plot(t, -np.exp(-t), color=C['gris'], ls=':', lw=1)
    a.set_xlabel('$t$'); a.set_title(r'$h=e^{-t}\sin(e^{2t})$'); a.grid(True)
    g(fig, 'f_pulsos')


def adaptativo():                   # C10_Ej10 [adaptativo]
    fig, ax = plt.subplots(1, 2, figsize=(7.0, 2.7), gridspec_kw=dict(wspace=0.3), sharey=True)
    t = np.linspace(0, 40, 2000)
    for a, wf, tit in [(ax[0], np.sin, r'$\omega=\sin t$'), (ax[1], lambda tt: np.exp(-0.3*tt), r'$\omega=e^{-0.3t}$')]:
        s = solve_ivp(lambda tt, z: [-z[0] + z[1]*wf(tt), -z[0]*wf(tt)], (0, 40), [1, 1], t_eval=t, **o)
        a.plot(t, s.y[0], color=C['azul'], label='$e$'); a.plot(t, s.y[1], color=C['coral'], label=r'$\theta$')
        a.set_xlabel('$t$'); a.grid(True); a.set_title(tit + f',  $\\theta(40)={s.y[1, -1]:.2f}$'); a.legend()
    g(fig, 'f_adaptativo')


# ------------------------------------------------------------------ 10.6
def rediseno():                     # C10_Ej13 [rediseno]
    fig, ax = plt.subplots(1, 2, figsize=(7.0, 2.8), gridspec_kw=dict(wspace=0.3))
    k = lambda x: -2*x/(x**2 + 1); k1 = lambda x: k(x) - x*(x**2 + 1)
    ev = lambda t, z: z[0] - 30; ev.terminal = True
    a = ax[0]
    s = solve_ivp(lambda t, z: [z[0] + (z[0]**2 + 1)*(k(z[0]) + 1)], (0, 6), [0], events=ev, max_step=0.01, **o)
    a.plot(s.t, s.y[0], color=C['coral'], label='cancelación'); a.axvline(4*np.pi/(3*np.sqrt(3)), color=C['coral'], ls=':', lw=1)
    s = solve_ivp(lambda t, z: [z[0] + (z[0]**2 + 1)*(k1(z[0]) + 1)], (0, 6), [0], max_step=0.01, **o)
    a.plot(s.t, s.y[0], color=C['azul'], label=r'con $-L_gV$')
    a.text(2.5, 8, '$t_e=2.42$', color=C['coral'], fontsize=8); a.text(3.3, 1.2, f'$x\\to{s.y[0, -1]:.4f}$', color=C['azul'], fontsize=8)
    a.set_ylim(-0.5, 10); a.set_xlim(0, 6); a.set_xlabel('$t$'); a.set_ylabel('$x$'); a.legend(loc='upper left'); a.grid(True)
    a.set_title(r'$w\equiv1$, $x(0)=0$')
    a = ax[1]; e = 0.1; xm = (1 - np.sqrt(1 - 4*e**2))/(2*e); xp = (1 + np.sqrt(1 - 4*e**2))/(2*e)
    for x0 in [0, 5, 9.5, 10.3, 12]:
        s = solve_ivp(lambda t, z: [-z[0] + (z[0]**2 + 1)*e], (0, 8), [x0], events=ev, max_step=0.01, **o)
        a.plot(s.t, s.y[0], color=C['azul'] if x0 < xp else C['coral'], lw=1.2)
    a.axhline(xm, color=C['verde'], ls='--', lw=1); a.axhline(xp, color=C['noche'], ls='--', lw=1)
    a.text(5.5, xm + 0.5, f'$x_-={xm:.3f}$', fontsize=8, color=C['verde']); a.text(5.5, xp + 0.5, f'$x_+={xp:.2f}$', fontsize=8)
    a.set_ylim(-0.5, 16); a.set_xlim(0, 8); a.set_xlabel('$t$'); a.grid(True); a.set_title(r'cancelación, $w\equiv0.1$')
    g(fig, 'f_rediseno')


# ------------------------------------------------------------------ 10.7
def cascada():                      # C10_Ej14 [cascadas]
    fig, ax = plt.subplots(1, 3, figsize=(7.4, 2.6), gridspec_kw=dict(wspace=0.4))
    ev = lambda t, z: abs(z[0]) - 40; ev.terminal = True
    s = solve_ivp(lambda t, z: [-z[0] + z[0]**2*z[1], -z[1]], (0, 1), [2, 2], events=ev, max_step=0.002, **o)
    a = ax[0]; a.plot(s.t, s.y[0], color=C['coral'], label='$x_1$'); a.plot(s.t, s.y[1], color=C['azul'], label='$x_2$')
    a.axvline(0.5*np.log(2), color=C['gris'], ls=':'); a.set_ylim(0, 40); a.set_xlim(0, 0.6)
    a.set_title(r'$-x_1+x_1^2x_2$: escape en 0.347', fontsize=8.5); a.set_xlabel('$t$'); a.legend(); a.grid(True)
    s = solve_ivp(lambda t, z: [-z[0] + z[0]*z[1]**2, -z[1]], (0, 8), [1, 3], max_step=0.01, **o)
    a = ax[1]; a.plot(s.t, s.y[0], color=C['coral'], label='$x_1$'); a.plot(s.t, s.y[1], color=C['azul'], label='$x_2$')
    a.set_title(f'$-x_1+x_1x_2^2$: pico {s.y[0].max():.1f}', fontsize=8.5); a.set_xlabel('$t$'); a.legend(); a.grid(True)
    s = solve_ivp(lambda t, z: [-z[0] + z[1]**2, -z[1] + 0.3*np.sin(t)], (0, 20), [2, -2], max_step=0.01, **o)
    a = ax[2]; a.plot(s.t, s.y[0], color=C['coral'], label='$x_1$'); a.plot(s.t, s.y[1], color=C['azul'], label='$x_2$')
    a.set_title(r'cascada ISS, $w=0.3\sin t$', fontsize=8.5); a.set_xlabel('$t$'); a.legend(); a.grid(True)
    g(fig, 'f_cascada')


def pequena_ganancia():             # C10_Ej15 [ganancia]
    fig, ax = plt.subplots(1, 3, figsize=(7.6, 2.8), gridspec_kw=dict(wspace=0.3))
    casos = [(1, 0.8, 'ab=0.8'), (1, 1.2, 'ab=1.2'), (1, -3, 'ab=-3')]
    for a, (aa, bb, tit) in zip(ax, casos):
        F = lambda x, aa=aa, bb=bb: [-x[0] + aa*x[1], -x[1] + bb*np.sin(x[0])]
        campo(a, lambda X, Y, aa=aa, bb=bb: (-X + aa*Y, -Y + bb*np.sin(X)), (-3, 3), (-3, 3), 15)
        for x0 in [(-2.8, 2.5), (2.8, -2.5), (2.8, 2.5), (-2.8, -2.5), (0.3, 0.05), (-0.3, -0.05), (-0.3, 2.8), (0.3, -2.8)]:
            tray(a, F, list(x0), T=15, atras=False, caja=(-3, 3, -3, 3), lw=0.9)
        punto(a, (0, 0), bb != 1.2)
        if bb == 1.2:
            for sg in (1, -1): punto(a, (sg*1.027, sg*1.027), True)
        ejes(a, (-3, 3), (-3, 3), f'${tit}$')
    g(fig, 'f_pequena_ganancia')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
        sys.exit()
    for fn in [uub_escalar, conjuntos, energia_futura, sinV, sontag, pulsos, adaptativo, rediseno, cascada, pequena_ganancia]:
        fn()
