"""Figuras del capítulo 1 (introducción y motivación). PDF (notas) y SVG (web).
Cada figura reproduce un script de codigo/cap01_introduccion/ (se indica cuál).
Ejecutar:  python3 herramientas/cap01_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from estilo import C, guardar

CAP = 'cap01'


def g(fig, nombre):
    guardar(fig, nombre, CAP)


def ode(f, T, x0, n=2001, t0=0, **kw):
    t = np.linspace(t0, T, n)
    s = solve_ivp(f, (t0, T), x0, t_eval=t, rtol=1e-10, atol=1e-12, **kw)
    return s.t, s.y


def ejes0(a):
    a.axhline(0, color=C['gris'], lw=0.6); a.axvline(0, color=C['gris'], lw=0.6)


# ---------------------------------------------------------------- C1_Ej1
def superposicion():
    R, K = 1.6, 32
    F = lambda P: R*P*(1 - P/K)
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.32))
    a = ax[0]; P = np.linspace(0, K, 400)
    a.plot(P, 2*P, color=C['gris'], ls='--', label='lineal: $2P$')
    a.plot(P, F(P), color=C['azul'], label=r'logístico: $RP(1-P/K)$')
    a.plot([10, 20], [F(10), F(20)], 'o', color=C['coral'], ms=5)
    a.annotate('$F(20)=12$', (20, 12), xytext=(21.5, 4.5), fontsize=8, color=C['coral'],
               arrowprops=dict(arrowstyle='-', color=C['coral'], lw=0.7))
    a.annotate('$F(10)=11$', (10, 11), xytext=(1.5, 15.5), fontsize=8, color=C['coral'],
               arrowprops=dict(arrowstyle='-', color=C['coral'], lw=0.7))
    a.set_ylim(0, 20); a.set_xlim(0, K); a.set_xlabel('$P[k]$'); a.set_ylabel('$P[k+1]$'); a.grid(True)
    a.legend(fontsize=7.5, loc='upper right'); a.set_title('un año de conejos')
    a = ax[1]; s = np.linspace(0, 20, 401)
    a.plot(s, F(s) + F(20 - s), color=C['azul'], label='logístico')
    a.plot(s, 2*s + 2*(20 - s), color=C['gris'], ls='--', label='lineal (siempre 40)')
    a.plot([0, 10, 20], [12, 22, 12], 'o', color=C['coral'], ms=5)
    a.set_xlabel('conejos en la isla 1 (de 20)'); a.set_ylabel('total al año siguiente'); a.grid(True)
    a.set_ylim(0, 45); a.legend(fontsize=7.5, loc='center right')
    a.set_title('repartir no es neutral')
    g(fig, 'f_superposicion')


# ---------------------------------------------------------------- C1_Ej2
def logistica():
    K = 32
    fig, ax = plt.subplots(2, 2, figsize=(6.8, 4.6), gridspec_kw=dict(wspace=0.28, hspace=0.55))
    for a, R, col in [(ax[0, 0], 1.6, C['azul']), (ax[0, 1], 3.2, C['violeta']),
                      (ax[1, 0], 3.5, C['ambar']), (ax[1, 1], 3.9, C['coral'])]:
        P = [1.0]
        for k in range(50):
            P.append(R*P[-1]*(1 - P[-1]/K))
        a.plot(range(51), P, '-', color=col, lw=0.8, alpha=0.6)
        a.plot(range(51), P, 'o', color=col, ms=2.6)
        a.set_ylim(0, K); a.grid(True); a.set_xlabel('$k$')
        desc = {1.6: 'un punto fijo: 12', 3.2: 'período 2', 3.5: 'período 4', 3.9: 'aperiódico'}[R]
        a.set_title(fr'$R={R}$: {desc}')
    ax[0, 0].set_ylabel('$P[k]$'); ax[1, 0].set_ylabel('$P[k]$')
    g(fig, 'f_logistica')


def bifurcacion_logistica():
    K = 32
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.7), gridspec_kw=dict(wspace=0.3, width_ratios=[1.35, 1]))
    a = ax[0]
    Rs = np.linspace(1.0, 4.0, 1600)
    p = np.ones_like(Rs)
    for k in range(800):
        p = Rs*p*(1 - p/K)
    for k in range(120):
        p = Rs*p*(1 - p/K)
        a.plot(Rs, p, ',', color=C['noche'], alpha=0.35)
    for R, col in [(1.6, C['azul']), (3.2, C['violeta']), (3.5, C['ambar']), (3.9, C['coral'])]:
        a.axvline(R, color=col, lw=0.9, ls='--')
    a.set_xlim(1, 4); a.set_ylim(0, K); a.set_xlabel('$R$'); a.set_ylabel('valores visitados')
    a.set_title('mapa logístico (tiempo discreto)')
    a = ax[1]
    t = np.linspace(0, 10, 400)
    for R, col in [(1.6, C['azul']), (3.2, C['violeta']), (3.9, C['coral'])]:
        a.plot(t, K*np.exp(R*t)/(K + np.exp(R*t) - 1), color=col, label=fr'$R={R}$')
    a.set_ylim(0, 34); a.set_xlabel('$t$'); a.set_ylabel('$P(t)$'); a.grid(True); a.legend(fontsize=7.5)
    a.set_title('logística continua: siempre monótona')
    g(fig, 'f_bifurcacion')


# ---------------------------------------------------------------- C1_Ej3
def panorama():
    fig = plt.figure(figsize=(6.9, 4.7))
    gs = fig.add_gridspec(2, 3, wspace=0.42, hspace=0.55)
    a = fig.add_subplot(gs[0, 0])
    X1, X2 = np.meshgrid(np.linspace(-3*np.pi, 3*np.pi, 300), np.linspace(-4, 4, 200))
    a.streamplot(X1, X2, X2, -np.sin(X1) - 0.3*X2, color=C['claro'], density=0.8, linewidth=0.6, arrowsize=0.6)
    for x0 in [(-7, 2.2), (-1, 2.6), (2, 2.2), (5, 2.2)]:
        t, X = ode(lambda t, x: [x[1], -np.sin(x[0]) - 0.3*x[1]], 30, list(x0))
        a.plot(X[0], X[1], color=C['azul'], lw=1)
    k = np.arange(-3, 4)
    a.plot(k[k % 2 == 0]*np.pi, 0*k[k % 2 == 0], 'o', color=C['noche'], ms=4)
    a.plot(k[k % 2 != 0]*np.pi, 0*k[k % 2 != 0], 'o', mfc='white', mec=C['noche'], ms=4)
    a.set_xlim(-3*np.pi, 3*np.pi); a.set_ylim(-4, 4); a.set_xticks([-2*np.pi, 0, 2*np.pi])
    a.set_xticklabels([r'$-2\pi$', '0', r'$2\pi$']); a.set_xlabel(r'$\theta$'); a.set_ylabel(r'$\dot\theta$')
    a.set_title('(a) infinitos equilibrios', fontsize=9)
    a = fig.add_subplot(gs[0, 1])
    f = lambda t, x: [x[1], (1 - x[0]**2)*x[1] - x[0]]
    for x0, col in [([0.1, 0], C['azul']), ([3.5, 0], C['violeta'])]:
        t, X = ode(f, 30, x0, n=4001); a.plot(X[0], X[1], color=col, lw=1)
    t, X = ode(f, 60, [2, 0], n=6001); kk = t > 40
    a.plot(X[0][kk], X[1][kk], color=C['coral'], lw=2.2)
    a.set_xlabel('$x_1$'); a.set_ylabel('$x_2$'); a.set_xlim(-3, 4); a.set_ylim(-4, 4)
    a.set_title('(b) ciclo límite', fontsize=9); ejes0(a)
    a = fig.add_subplot(gs[0, 2])
    t = np.linspace(0, 0.985, 400); a.plot(t, 1/(t - 1), color=C['azul'])
    a.axvline(1, color=C['coral'], ls='--', lw=1); a.text(1.03, -40, '$t=1$', color=C['coral'], fontsize=8)
    a.set_xlim(0, 1.25); a.set_ylim(-60, 2); a.set_xlabel('$t$'); a.set_ylabel('$x(t)$'); a.grid(True)
    a.set_title(r'(c) escape: $\dot x=-x^2$', fontsize=9)
    a = fig.add_subplot(gs[1, 0])
    r = np.linspace(-4, 0, 200)
    a.plot(r, -np.sqrt(-r), color=C['noche'], label='estable'); a.plot(r, np.sqrt(-r), color=C['noche'], ls='--', label='inestable')
    a.plot(0, 0, 'o', color=C['coral'], ms=5); a.set_xlim(-4, 2); a.set_ylim(-2.3, 2.3); a.grid(True)
    a.set_xlabel('$r$'); a.set_ylabel('$x^*$'); a.legend(fontsize=7, loc='lower right')
    a.set_title(r'(d) silla-nodo: $\dot x=r+x^2$', fontsize=9)
    lor = lambda t, x: [10*(x[1] - x[0]), x[0]*(28 - x[2]) - x[1], x[0]*x[1] - 8/3*x[2]]
    t = np.linspace(0, 40, 40001)
    A = solve_ivp(lor, (0, 40), [1, 1, 1], t_eval=t, rtol=1e-12, atol=1e-12).y
    B = solve_ivp(lor, (0, 40), [1 + 1e-9, 1, 1], t_eval=t, rtol=1e-12, atol=1e-12).y
    a = fig.add_subplot(gs[1, 1])
    a.plot(A[0], A[2], color=C['azul'], lw=0.35); a.set_xlabel('$x$'); a.set_ylabel('$z$')
    a.set_title('(e) atractor de Lorenz', fontsize=9)
    a = fig.add_subplot(gs[1, 2])
    d = np.linalg.norm(A - B, axis=0)
    a.semilogy(t, d + 1e-16, color=C['coral'], lw=1); a.set_ylim(1e-10, 1e2); a.grid(True)
    a.set_xlabel('$t$'); a.set_ylabel(r'$\|\Delta x(t)\|$')
    a.set_title(r'(f) $\|\Delta x(0)\|=10^{-9}$', fontsize=9)
    g(fig, 'f_panorama')
    return t[np.argmax(d > 1)]


# ---------------------------------------------------------------- C1_Ej4
def energia():
    m, k, c = 1, 4, 0.5
    t, X = ode(lambda t, x: [x[1], (-k*x[0] - c*x[1])/m], 20, [1, 0], n=4001)
    E = 0.5*k*X[0]**2 + 0.5*m*X[1]**2
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.32))
    a = ax[0]; a.plot(t, X[0], color=C['azul'], label='$x_1=y$'); a.plot(t, X[1], color=C['coral'], label=r'$x_2=\dot y$')
    a.set_xlabel('$t$'); a.grid(True); a.legend(fontsize=7.5); a.set_xlim(0, 12)
    a.set_title('masa-resorte con fricción')
    a = ax[1]; a.plot(t, E, color=C['noche'])
    zeros = t[np.where(np.diff(np.sign(X[1])) != 0)[0]]
    for z in zeros[:5]:
        a.axvline(z, color=C['ambar'], lw=0.7, ls=':')
    a.set_xlim(0, 12); a.set_xlabel('$t$'); a.set_ylabel('$E(x(t))$'); a.grid(True)
    a.set_title(r'$\dot E=-cx_2^2\leq 0$ (punteado: $x_2=0$)', fontsize=9)
    g(fig, 'f_energia')


# ---------------------------------------------------------------- C1_Ej5
def reescalamiento():
    casos = [(1, 1, 0.5), (1, 4, 1), (2, 18, 3)]
    cols = [C['azul'], C['coral'], C['violeta']]
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.4), gridspec_kw=dict(wspace=0.25))
    for (m, k, c), col in zip(casos, cols):
        w = np.sqrt(k/m)
        t, X = ode(lambda t, x: [x[1], (-k*x[0] - c*x[1])/m], 20/w, [1, 0])
        ax[0].plot(t, X[0], color=col, label=f'$(m,k,c)=({m},{k},{c})$')
        ax[1].plot(w*t, X[0], color=col, lw=4 - 1.3*casos.index((m, k, c)))
    ax[0].set_xlim(0, 20); ax[0].set_xlabel('$t$'); ax[0].set_ylabel('$y$'); ax[0].legend(fontsize=7)
    ax[1].set_xlabel(r'$\tau=\omega t$'); ax[0].grid(True); ax[1].grid(True)
    ax[0].set_title('tres sistemas...'); ax[1].set_title(r'...una curva: $\alpha=0.5$')
    g(fig, 'f_reescalamiento')


# ---------------------------------------------------------------- C1_Ej6
def control_cubico():
    k = 5
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.6), gridspec_kw=dict(wspace=0.32))
    a = ax[0]
    t, X = ode(lambda t, x: [x[0]], 1.5, [1]); a.plot(t, X[0], color=C['gris'], label='$u=0$')
    t, X = ode(lambda t, x: [x[0] - k**3*x[0]**3], 5, [1]); a.plot(t, X[0], color=C['coral'], label='$u=-kx$')
    t, X = ode(lambda t, x: [(1 - k)*x[0]], 5, [1]); a.plot(t, X[0], color=C['azul'], label=r'$u=-(kx)^{1/3}$')
    a.axhline(k**-1.5, color=C['coral'], lw=0.7, ls=':'); a.text(3.2, 0.16, r'$k^{-3/2}=0.089$', color=C['coral'], fontsize=8)
    a.set_ylim(-0.05, 1.6); a.set_xlabel('$t$'); a.set_ylabel('$x$'); a.grid(True); a.legend(fontsize=7.5)
    a.set_title(r'$\dot x=x+u^3$, $x(0)=1$')
    a = ax[1]; s = np.linspace(-0.2, 0.2, 401)
    a.plot(s, s - k**3*s**3, color=C['coral'], label=r'$u=-kx$: $x-k^3x^3$')
    a.plot(s, (1 - k)*s, color=C['azul'], label=r'$u=-(kx)^{1/3}$: $(1-k)x$')
    a.plot([-k**-1.5, k**-1.5], [0, 0], 'o', color=C['noche'], ms=4)
    a.plot(0, 0, 'o', mfc='white', mec=C['coral'], ms=6)
    ejes0(a); a.set_ylim(-0.4, 0.4); a.set_xlabel('$x$'); a.set_ylabel(r'$\dot x$'); a.legend(fontsize=7, loc='lower left')
    a.set_title('campo en lazo cerrado')
    g(fig, 'f_control_cubico')


# ---------------------------------------------------------------- C1_Ej7
def doble_integrador():
    k3 = lambda x: 1.0 if x[0]*(x[0] + x[1]) < 0 else -1.0
    leyes = [(lambda x: -5*x[0], C['gris'], '$u=-5x_1$'), (lambda x: -x[0] - x[1], C['coral'], 'PD'),
             (lambda x: k3(x)*x[0], C['azul'], 'estructura variable')]
    fig, ax = plt.subplots(1, 2, figsize=(6.8, 2.7), gridspec_kw=dict(wspace=0.3))
    for u, col, lab in leyes:
        t, X = ode(lambda t, x: [x[1], u(x)], 10, [1, 1], n=10001, max_step=1e-3)
        ax[0].plot(X[0], X[1], color=col, lw=1.3, label=lab)
        if lab != '$u=-5x_1$':
            ax[1].plot(t, X[0], color=col, label=lab)
    ax[0].plot([-1.5, 1.6], [1.5, -1.6], color=C['noche'], ls='--', lw=0.8)
    ax[0].text(-1.45, 1.05, '$s=x_1+x_2=0$', fontsize=7.5, color=C['noche'])
    ax[0].set_aspect('equal'); ax[0].set_xlim(-1.5, 1.7); ax[0].set_ylim(-1.6, 1.6); ejes0(ax[0])
    ax[0].set_xlabel('$x_1$'); ax[0].set_ylabel('$x_2$'); ax[0].legend(fontsize=6.8, loc='lower left')
    ax[1].axvline(np.pi/2, color=C['ambar'], ls=':', lw=1); ax[1].text(1.7, 0.75, r'$t=\pi/2$', color=C['ambar'], fontsize=8)
    ax[1].set_xlabel('$t$'); ax[1].set_ylabel('$x_1$'); ax[1].grid(True); ax[1].legend(fontsize=7.5)
    ax[1].set_title('sin sobrepico, como $\\dot x_1=-x_1$', fontsize=9)
    g(fig, 'f_doble_integrador')


# ---------------------------------------------------------------- C1_Ej8
def brockett():
    rho = 0.5
    def f(t, z):
        v = rho*np.array([-np.sin(t), np.cos(t)])
        return [v[0], v[1], z[0]*v[1] - z[1]*v[0]]
    t, Z = ode(f, 2*np.pi, [0, 0, 0], n=801)
    fig = plt.figure(figsize=(6.6, 2.8))
    a = fig.add_subplot(1, 2, 1, projection='3d')
    a.plot(Z[0], Z[1], Z[2], color=C['azul'], lw=2); a.plot(Z[0], Z[1], 0*Z[2], color=C['claro'], lw=1)
    a.plot([0], [0], [0], 'o', color=C['noche']); a.plot([0], [0], [Z[2, -1]], 'o', color=C['coral'])
    a.set_xlabel('$z_1$', labelpad=-8); a.set_ylabel('$z_2$', labelpad=-8); a.set_zlabel('$z_3$', labelpad=-6)
    a.tick_params(labelsize=6, pad=-3); a.view_init(22, -50)
    a.set_title(r'una vuelta: $z_3=2\pi\rho^2$', fontsize=9)
    a = fig.add_subplot(1, 2, 2)
    a.plot(t, Z[0], color=C['azul'], label='$z_1$'); a.plot(t, Z[1], color=C['violeta'], label='$z_2$')
    a.plot(t, Z[2], color=C['coral'], label='$z_3$'); a.set_xlabel('$t$'); a.grid(True); a.legend(fontsize=7.5)
    a.set_xticks([0, np.pi, 2*np.pi]); a.set_xticklabels(['0', r'$\pi$', r'$2\pi$'])
    a.set_title(r'$(z_1,z_2)$ vuelve; $z_3$ no', fontsize=9)
    g(fig, 'f_brockett')


# ---------------------------------------------------------------- C1_Ej9
def pid():
    m, c, k, v, w, r, kP, kD, kI = 1, 1, 2, 0.5, 0.1, 1, 10, 3, 5
    def dyn(t, x, ki):
        e = x[0] + w - r
        return [x[1], (-kD*x[1] - kP*e - ki*x[2] + v - c*x[1] - k*x[0])/m, e]
    fig, a = plt.subplots(figsize=(5.4, 2.4))
    t, X = ode(lambda t, x: dyn(t, x, 0), 15, [0, 0, 0]); a.plot(t, X[0], color=C['coral'], label='PD')
    t, X = ode(lambda t, x: dyn(t, x, kI), 15, [0, 0, 0]); a.plot(t, X[0], color=C['azul'], label='PID')
    a.axhline(r, color=C['noche'], ls='--', lw=0.8, label='referencia $r$')
    a.axhline(r - w, color=C['azul'], ls=':', lw=0.8); a.text(12.3, 0.83, '$r-w$', color=C['azul'], fontsize=8)
    a.axhline((kP*(r - w) + v)/(k + kP), color=C['coral'], ls=':', lw=0.8)
    a.set_xlabel('$t$'); a.set_ylabel('$y$'); a.grid(True); a.legend(fontsize=7.5, loc='lower right')
    a.set_ylim(0, 1.2)
    g(fig, 'f_pid')


if __name__ == '__main__':
    superposicion(); logistica(); bifurcacion_logistica()
    tl = panorama(); print('  Lorenz se separa en t =', round(tl, 2))
    energia(); reescalamiento(); control_cubico(); doble_integrador(); brockett(); pid()
