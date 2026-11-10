"""Figuras del capítulo 12 (linealización por retroalimentación). PDF y SVG.
Cada figura reproduce un script de codigo/cap12_linealizacion/ (se indica cuál).
Ejecutar:  python3 herramientas/cap12_figuras.py
"""
import math
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.signal import place_poles
from scipy.linalg import expm
from estilo import C, guardar

CAP = 'cap12'
def g(fig, nombre): guardar(fig, nombre, CAP)
o = dict(rtol=1e-10, atol=1e-12)

# ------------------------------------------------------------------ levitador
m, k, gr, a, L0, L1, R = 0.1, 0.001, 9.81, 0.05, 0.01, 0.02, 1.0
Lx = lambda y: L1 + L0/(1 + y/a)
def f_lev(x, u, mm=m):
    y, v, i = x
    return np.array([v, gr - k/mm*v - L0*a*i**2/(2*mm*(a+y)**2), (u - R*i + L0*a*v*i/(a+y)**2)/Lx(y)])
def eq(yb):
    i = np.sqrt(2*gr*m/(L0*a))*(a + yb); return np.array([yb, 0, i]), R*i
def jac(yb):
    D = L1*(a+yb) + L0*a
    A = np.array([[0, 1, 0], [2*gr/(a+yb), -k/m, -np.sqrt(2*gr*a*L0/m)/(a+yb)], [0, np.sqrt(2*gr*m*a*L0)/D, -R*(a+yb)/D]])
    return A, np.array([[0], [0], [(a+yb)/D]])
def phi3(x): return gr - k/m*x[1] - L0*a*x[2]**2/(2*m*(a+x[0])**2)
def Lf3(x):
    y, v, i = x; c = L0*a/(2*m); f3 = (-R*i + L0*a*v*i/(a+y)**2)/Lx(y)
    return 2*c*i**2/(a+y)**3*v - k/m*phi3(x) - 2*c*i/(a+y)**2*f3
def bfun(x): return -L0*a*x[2]/(m*(a+x[0])**2*Lx(x[0]))
KFL = np.array([6000., 1100., 60.])
def ufl(x, yd, Kf=KFL):
    xi = np.array([x[0], x[1], phi3(x)]); v = yd[3] - Kf@(xi - np.array(yd[:3])); return (v - Lf3(x))/bfun(x)
A05, B05 = jac(0.05); K = place_poles(A05, B05, [-20, -25, -30]).gain_matrix.ravel()
xs, us = eq(0.05)


def levitador_inestable():          # C12_Ej1 [inestable], C12_Ej6 [levitador]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.32))
    ys = np.linspace(0.005, 0.3, 150)
    ev = np.array([np.sort(np.linalg.eigvals(jac(y)[0]).real) for y in ys])
    for j, col in zip(range(3), [C['azul'], C['violeta'], C['coral']]):
        ax[0].plot(ys, ev[:, j], color=col)
    ax[0].axhline(0, color=C['gris'], lw=0.7); ax[0].axvline(0.05, color=C['gris'], ls=':', lw=0.8)
    ax[0].set_xlabel(r'punto de operación $\bar y$ [m]'); ax[0].set_ylabel(r'Re $\lambda(A(\bar y))$')
    ax[0].set_title('Siempre un valor propio positivo'); ax[0].grid(True)
    ii = np.linspace(-8, 8, 300)
    for y, col in zip([0.03, 0.05, 0.1], [C['azul'], C['coral'], C['violeta']]):
        ax[1].plot(ii, -L0*a*ii/(m*(a+y)**2*Lx(y)), color=col, label=fr'$y={y}$')
    ax[1].axhline(0, color=C['gris'], lw=0.7); ax[1].axvline(0, color=C['gris'], lw=0.7)
    ax[1].plot([xs[2]], [bfun(xs)], 'o', color=C['noche'], ms=4)
    ax[1].set_xlabel('corriente $i=x_3$ [A]'); ax[1].set_ylabel(r'$b(x)=L_gL_f^2h$'); ax[1].legend(loc='upper right')
    ax[1].set_title(r'$b=0$ cuando $i=0$'); ax[1].grid(True)
    g(fig, 'f_levitador_inestable')


def jacobiana():                    # C12_Ej1 [comparacion]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.7), gridspec_kw=dict(wspace=0.32))
    Acl = A05 - B05@K[None, :]; te = np.linspace(0, 0.6, 1201)
    for y0, col in zip([0.045, 0.08, 0.01, 0.15], [C['verde'], C['azul'], C['violeta'], C['coral']]):
        x0 = np.array([y0, 0, xs[2]])
        s = solve_ivp(lambda t, x: f_lev(x, us - K@(x - xs)), (0, 0.6), x0, t_eval=te, max_step=1e-3, **o)
        yl = np.array([(expm(Acl*t)@(x0 - xs))[0] for t in te]) + 0.05
        ax[0].plot(te, 100*s.y[0], color=col, label=fr'$y_0={y0}$'); ax[0].plot(te, 100*yl, '--', color=col, lw=1.1)
        ax[1].semilogy(te[1:], abs(s.y[0] - yl)[1:] + 1e-12, color=col)
    ax[0].invert_yaxis(); ax[0].set_xlabel('$t$ [s]'); ax[0].set_ylabel('$y$ [cm]'); ax[0].legend(ncol=2, fontsize=7.5)
    ax[0].set_title('Planta (—) y predicción lineal (- -)'); ax[0].grid(True)
    ax[1].set_ylim(1e-8, 0.05); ax[1].set_xlabel('$t$ [s]'); ax[1].set_ylabel(r'$|y-y_{\mathrm{lin}}|$ [m]')
    ax[1].set_title('El error crece lejos de $x^*$'); ax[1].grid(True)
    g(fig, 'f_jacobiana')


def integral():                     # C12_Ej2 [carga]
    C1 = np.array([[1, 0, 0]])
    Aa = np.block([[A05, np.zeros((3, 1))], [C1, np.zeros((1, 1))]]); Ba = np.vstack([B05, [[0]]])
    Ka = place_poles(Aa, Ba, [-15, -20, -25, -30]).gain_matrix.ravel()
    mt = lambda t: 0.1 + 0.02*(t >= 0.5); te = np.linspace(0, 2, 2001)
    s1 = solve_ivp(lambda t, x: f_lev(x, us - K@(x - xs), mt(t)), (0, 2), xs, t_eval=te, max_step=1e-3, **o)
    s2 = solve_ivp(lambda t, z: np.r_[f_lev(z[:3], us - Ka[:3]@(z[:3]-xs) - Ka[3]*z[3], mt(t)), z[0] - 0.05], (0, 2), np.r_[xs, 0], t_eval=te, max_step=1e-3, **o)
    u1 = us - (s1.y.T - xs)@K; u2 = us - (s2.y[:3].T - xs)@Ka[:3] - Ka[3]*s2.y[3]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.32))
    ax[0].plot(te, 100*s1.y[0], color=C['coral'], label='estados'); ax[0].plot(te, 100*s2.y[0], color=C['azul'], label='con integrador')
    ax[0].axhline(5, color=C['gris'], ls=':'); ax[0].axvline(0.5, color=C['gris'], ls=':', lw=0.8)
    ax[0].invert_yaxis(); ax[0].set_xlabel('$t$ [s]'); ax[0].set_ylabel('$y$ [cm]'); ax[0].legend(loc='lower right')
    ax[0].set_title('Masa real 0.12 kg desde $t=0.5$'); ax[0].grid(True)
    ax[1].plot(te, u1, color=C['coral']); ax[1].plot(te, u2, color=C['azul'])
    ax[1].axhline(R*np.sqrt(2*gr*0.12/(L0*a))*0.1, color=C['gris'], ls=':')
    ax[1].set_xlabel('$t$ [s]'); ax[1].set_ylabel('$u$ [V]'); ax[1].set_title('El integrador encuentra el voltaje'); ax[1].grid(True)
    g(fig, 'f_integral')


def pendulo():                      # C12_Ej3
    aa, bb, cc, k1, k2 = 10, 1, 10, 4, 3
    pend = lambda uf: (lambda t, x: [x[1], -aa*np.sin(x[0]) - bb*x[1] + cc*uf(x)])
    te = np.linspace(0, 6, 1201); oo = dict(rtol=1e-11, atol=1e-12)
    pl = solve_ivp(pend(lambda x: (-(aa+k1)*(x[0]-np.pi) - k2*x[1])/cc), (0, 6), [0, 0], t_eval=te, **oo)
    pf = solve_ivp(pend(lambda x: (aa*np.sin(x[0]) - k1*(x[0]-np.pi) - k2*x[1])/cc), (0, 6), [0, 0], t_eval=te, **oo)
    pe = solve_ivp(lambda t, e: [e[1], -k1*e[0] - (bb+k2)*e[1]], (0, 6), [-np.pi, 0], t_eval=te, **oo)
    tm = np.linspace(0, 10, 1001)
    pm = solve_ivp(pend(lambda x: (8*np.sin(x[0]) - k1*(x[0]-np.pi/2) - k2*x[1])/cc), (0, 10), [0, 0], t_eval=tm, **oo)
    pb = solve_ivp(pend(lambda x: (10*np.sin(x[0]) - k1*(x[0]-np.pi/2) - k2*x[1])/cc), (0, 10), [0, 0], t_eval=tm, **oo)
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.4), gridspec_kw=dict(wspace=0.42))
    ax[0].plot(te, pl.y[0], color=C['coral'], label='jacobiana'); ax[0].plot(te, pf.y[0], color=C['azul'], label='exacta')
    ax[0].plot(te, pe.y[0] + np.pi, '--', color=C['noche'], lw=1.1, label='diseño')
    ax[0].axhline(np.pi, color=C['gris'], ls=':'); ax[0].set_xlabel('$t$'); ax[0].set_ylabel('$x_1$ [rad]'); ax[0].legend(fontsize=7)
    ax[0].set_title('Hacia $\\pi$'); ax[0].grid(True)
    ax[1].semilogy(te[1:], abs(pl.y[0] - pe.y[0] - np.pi)[1:] + 1e-16, color=C['coral'])
    ax[1].semilogy(te[1:], abs(pf.y[0] - pe.y[0] - np.pi)[1:] + 1e-16, color=C['azul'])
    ax[1].set_xlabel('$t$'); ax[1].set_title('|$x_1-$diseño|'); ax[1].grid(True); ax[1].set_ylim(1e-14, 10)
    ax[2].plot(tm, np.degrees(pb.y[0]), color=C['azul'], label=r'$\hat a=a$'); ax[2].plot(tm, np.degrees(pm.y[0]), color=C['violeta'], label=r'$\hat a=8$')
    ax[2].axhline(90, color=C['gris'], ls=':'); ax[2].set_xlabel('$t$'); ax[2].set_ylabel('$x_1$ [°]'); ax[2].legend(fontsize=7)
    ax[2].set_title('Hacia $\\pi/2$: modelo malo'); ax[2].grid(True)
    g(fig, 'f_pendulo')


def lie():                          # C12_Ej4
    mu = 1
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.9), gridspec_kw=dict(wspace=0.3, width_ratios=[1, 1.25]))
    a_ = ax[0]; a_.axvspan(-1, 1, color=C['verde'], alpha=0.12); a_.axvspan(-3, -1, color=C['coral'], alpha=0.08); a_.axvspan(1, 3, color=C['coral'], alpha=0.08)
    th = np.linspace(0, 2*np.pi, 200)
    for r_ in [0.5, 1, 1.5, 2, 2.5]: a_.plot(r_*np.cos(th), r_*np.sin(th), color=C['claro'], lw=0.8)
    s = solve_ivp(lambda t, x: [x[1], -x[0] + mu*(1 - x[0]**2)*x[1]], (0, 30), [0.2, 0], t_eval=np.linspace(0, 30, 3000), **o)
    a_.plot(s.y[0], s.y[1], color=C['azul'], lw=1.3)
    a_.text(0, 2.6, r'$L_f\lambda\geq0$', ha='center', color=C['verde'], fontsize=8.5)
    a_.text(2.0, -2.6, r'$L_f\lambda\leq0$', ha='center', color=C['coral'], fontsize=8.5)
    a_.set_xlim(-3, 3); a_.set_ylim(-3, 3); a_.set_aspect('equal'); a_.set_xlabel('$x_1$'); a_.set_ylabel('$x_2$')
    a_.set_title(r'$\lambda=\frac{1}{2}(x_1^2+x_2^2)$')
    t = np.linspace(0, 16, 1601); s = solve_ivp(lambda t, x: [x[1], -x[0] + mu*(1 - x[0]**2)*x[1]], (0, 16), [0.2, 0], t_eval=t, **o)
    L = mu*(1 - s.y[0]**2)*s.y[1]**2; lam = 0.5*(s.y[0]**2 + s.y[1]**2)
    ax[1].plot(t, L, color=C['azul'], label=r'$L_f\lambda$ (fórmula)'); ax[1].plot(t, np.gradient(lam, t), '--', color=C['coral'], lw=1.2, label=r'$d\lambda/dt$ (medida)')
    ax[1].plot(t, lam, color=C['gris'], lw=1, label=r'$\lambda(t)$'); ax[1].axhline(0, color=C['gris'], lw=0.6)
    ax[1].set_xlabel('$t$'); ax[1].legend(fontsize=7.5, loc='lower left'); ax[1].set_title('La derivada a lo largo de $f$'); ax[1].grid(True)
    g(fig, 'f_lie')


def difeo():                        # C12_Ej5
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 3.0), gridspec_kw=dict(wspace=0.3))
    s = np.linspace(-2, 2, 200)
    for c in np.linspace(-2, 2, 11):
        ax[0].plot(c*np.ones_like(s), s + c**3/2, color=C['azul'], lw=0.9)
        ax[0].plot(s, c + s**3/2, color=C['coral'], lw=0.9)
    ax[0].set_xlim(-2.2, 2.2); ax[0].set_ylim(-4.5, 4.5); ax[0].set_xlabel('$z_1$'); ax[0].set_ylabel('$z_2$')
    ax[0].set_title(r'$\Phi=(x_1,\ x_2+x_1^3/2)$: global')
    th1 = np.linspace(0, 2*np.pi, 300); th2 = np.linspace(2*np.pi, 4*np.pi, 300)
    for c in np.linspace(-0.8, 0.5, 6):
        ax[1].plot(np.exp(c)*np.cos(th1), np.exp(c)*np.sin(th1), color=C['azul'], lw=2.4, alpha=0.6)
        ax[1].plot(np.exp(c)*np.cos(th2), np.exp(c)*np.sin(th2), '--', color=C['coral'], lw=1.2)
    ax[1].plot([1], [0], 'o', color=C['noche'], ms=5)
    ax[1].annotate(r'$\Psi(0,0)=\Psi(0,2\pi)$', xy=(1, 0), xytext=(0.25, -1.45), fontsize=8, arrowprops=dict(arrowstyle='->', color=C['noche']))
    ax[1].set_aspect('equal'); ax[1].set_xlim(-1.9, 1.9); ax[1].set_ylim(-1.9, 1.9)
    ax[1].set_title(r'$\Psi=e^{x_1}(\cos x_2,\sin x_2)$: dos vueltas')
    g(fig, 'f_difeo')


def grado_lineal():                 # C12_Ej6 [markov]
    fig, ax = plt.subplots(figsize=(4.4, 2.8))
    casos = [([1], [1, 1], '$1/(s+1)$, $r=1$'), ([1], [1, 2, 1], '$1/(s+1)^2$, $r=2$'), ([1], [1, 3, 3, 1], '$1/(s+1)^3$, $r=3$'), ([1, 2], [1, 4, 3], '$(s+2)/((s+1)(s+3))$, $r=1$')]
    tt = np.logspace(-3, 0.4, 120)
    for (num, den, nom), col, ls in zip(casos, [C['azul'], C['violeta'], C['coral'], C['ambar']], ['-', '-', '-', '--']):
        n = len(den) - 1
        A_ = np.vstack([np.hstack([np.zeros((n-1, 1)), np.eye(n-1)]), -np.array(den[:0:-1], float)])
        B_ = np.r_[np.zeros(n-1), 1]; C_ = np.zeros(n); C_[:len(num)] = num[::-1]
        y = [sum(C_@np.linalg.matrix_power(A_, kk-1)@B_*t**kk/math.factorial(kk) for kk in range(1, 30)) for t in tt]
        ax.loglog(tt, np.abs(y), color=col, ls=ls, label=nom)
    for r_ in [1, 2, 3]:
        ax.loglog(tt[:40], tt[:40]**r_/np.prod(range(1, r_+1)), ':', color=C['gris'], lw=0.9)
    ax.set_xlabel('$t$'); ax.set_ylabel('$y(t)$ (escalón)'); ax.legend(fontsize=7, loc='lower right'); ax.grid(True, which='both', alpha=0.4)
    ax.set_title('Cerca de $t=0$: $y\\approx CA^{r-1}B\\,t^r/r!$')
    g(fig, 'f_grado_lineal')


def vdp_fl():                       # C12_Ej8
    mu = 1; ton = 10
    uf = lambda t, x: (t >= ton)*(x[0] - mu*(1 - x[0]**2)*x[1] - 4*x[0] - 4*x[1])
    t = np.linspace(0, 16, 3201)
    s = solve_ivp(lambda t, x: [x[1], -x[0] + mu*(1 - x[0]**2)*x[1] + uf(t, x)], (0, 16), [0.5, 0], t_eval=t, max_step=0.01, **o)
    k0 = np.searchsorted(t, ton)
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.3))
    ax[0].plot(s.y[0, :k0], s.y[1, :k0], color=C['claro']); ax[0].plot(s.y[0, k0:], s.y[1, k0:], color=C['azul'])
    ax[0].plot(*s.y[:, k0], 'o', color=C['coral'], ms=4); ax[0].set_xlabel('$x_1$'); ax[0].set_ylabel('$x_2$'); ax[0].set_title('Plano de fase'); ax[0].grid(True)
    e = solve_ivp(lambda t, e: [e[1], -4*e[0] - 4*e[1]], (t[k0], 16), s.y[:, k0], t_eval=t[k0:], **o)
    ax[1].plot(t[:k0+1], s.y[0, :k0+1], color=C['claro']); ax[1].plot(t[k0:], s.y[0, k0:], color=C['azul'], label='planta')
    ax[1].plot(t[k0:], e.y[0], '--', color=C['coral'], lw=1.2, label=r'$\ddot y+4\dot y+4y=0$')
    ax[1].axvline(ton, color=C['gris'], ls=':'); ax[1].set_xlabel('$t$'); ax[1].set_ylabel('$y=x_1$'); ax[1].legend(fontsize=7.5, loc='lower right')
    ax[1].set_title('Ley conectada en $t=10$'); ax[1].grid(True)
    g(fig, 'f_vdp_fl')


def seguimiento():                  # C12_Ej9 [seguimiento]
    Am = 0.03; w = 2*np.pi
    yd = lambda t: np.array([0.08 + Am*np.sin(w*t), Am*w*np.cos(w*t), -Am*w**2*np.sin(w*t), -Am*w**3*np.cos(w*t)])
    def ujac(t, x):
        xr, ur = eq(yd(t)[0]); return ur - K@(x - xr)
    x0, _ = eq(0.08); te = np.linspace(0, 3, 3001)
    s1 = solve_ivp(lambda t, x: f_lev(x, ujac(t, x)), (0, 3), x0, t_eval=te, max_step=1e-3, **o)
    s2 = solve_ivp(lambda t, x: f_lev(x, ufl(x, yd(t))), (0, 3), x0, t_eval=te, max_step=1e-3, **o)
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.32))
    ax[0].plot(te, 100*(0.08 + Am*np.sin(w*te)), '--', color=C['noche'], lw=1.1, label='$y_d$')
    ax[0].plot(te, 100*s1.y[0], color=C['coral'], label='jacobiana'); ax[0].plot(te, 100*s2.y[0], color=C['azul'], label='exacta')
    ax[0].invert_yaxis(); ax[0].set_xlabel('$t$ [s]'); ax[0].set_ylabel('$y$ [cm]'); ax[0].legend(fontsize=7.5, ncol=3, loc='lower center'); ax[0].grid(True)
    ax[0].set_ylim(15.5, 3)
    ax[0].set_title('$y_d=0.08+0.03\\sin 2\\pi t$')
    ax[1].semilogy(te[1:], abs(s1.y[0] - 0.08 - Am*np.sin(w*te))[1:] + 1e-12, color=C['coral'])
    ax[1].semilogy(te[1:], abs(s2.y[0] - 0.08 - Am*np.sin(w*te))[1:] + 1e-12, color=C['azul'])
    ax[1].set_xlabel('$t$ [s]'); ax[1].set_ylabel('$|y-y_d|$ [m]'); ax[1].set_title('Error de seguimiento'); ax[1].grid(True); ax[1].set_ylim(1e-9, 0.1)
    g(fig, 'f_seguimiento')


def singularidad():                 # C12_Ej9 [singularidad], [suave]
    x0, _ = eq(0.05)
    ev = lambda t, x: x[2] - 0.02; ev.terminal = True; ev.direction = -1
    s5 = solve_ivp(lambda t, x: f_lev(x, ufl(x, [0.2, 0, 0, 0])), (0, 1.2), x0, events=ev, max_step=2e-4, **o)
    p = 6; cf = np.poly(-p*np.ones(4)); Af = np.vstack([np.hstack([np.zeros((3, 1)), np.eye(3)]), -cf[:0:-1]]); Bf = np.array([0, 0, 0, p**4])
    s6 = solve_ivp(lambda t, z: np.r_[f_lev(z[:3], ufl(z[:3], z[3:7])), Af@z[3:7] + Bf*0.2], (0, 2), np.r_[x0, 0.05, 0, 0, 0], max_step=2e-4, **o)
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.6), gridspec_kw=dict(wspace=0.32))
    ax[0].plot(s5.t, 100*s5.y[0], color=C['coral'], label='escalón 5 → 20 cm'); ax[0].plot(s6.t, 100*s6.y[0], color=C['azul'], label='referencia suave')
    ax[0].plot(s6.t, 100*s6.y[3], '--', color=C['noche'], lw=1, label='$y_d(t)$')
    ax[0].invert_yaxis(); ax[0].set_xlabel('$t$ [s]'); ax[0].set_ylabel('$y$ [cm]'); ax[0].legend(fontsize=7.5, loc='upper right'); ax[0].grid(True)
    ax[0].set_title('Posición')
    ax[1].plot(s5.t, s5.y[2], color=C['coral']); ax[1].plot(s6.t, s6.y[2], color=C['azul'])
    ax[1].annotate(f'$i\\to0$ en {1000*s5.t[-1]:.0f} ms', xy=(s5.t[-1], 0.02), xytext=(0.35, 3), fontsize=8, arrowprops=dict(arrowstyle='->', color=C['coral']))
    ax[1].set_xlabel('$t$ [s]'); ax[1].set_ylabel('$i$ [A]'); ax[1].set_title(r'Corriente: $b(x)\propto i$'); ax[1].grid(True)
    g(fig, 'f_singularidad')


def robustez():                     # C12_Ej9 [robustez]
    mt = lambda t: 0.1 + 0.02*(t >= 0.5); te = np.linspace(0, 2, 2001)
    kI = np.poly([-10, -15, -20, -30])
    def fli(x, sg):
        v = -(kI[4]*sg + kI[3]*(x[0] - 0.05) + kI[2]*x[1] + kI[1]*phi3(x)); return (v - Lf3(x))/bfun(x)
    s3 = solve_ivp(lambda t, x: f_lev(x, ufl(x, [0.05, 0, 0, 0]), mt(t)), (0, 2), xs, t_eval=te, max_step=1e-3, **o)
    s4 = solve_ivp(lambda t, z: np.r_[f_lev(z[:3], fli(z[:3], z[3]), mt(t)), z[0] - 0.05], (0, 2), np.r_[xs, 0], t_eval=te, max_step=1e-3, **o)
    C1 = np.array([[1, 0, 0]]); Aa = np.block([[A05, np.zeros((3, 1))], [C1, np.zeros((1, 1))]]); Ba = np.vstack([B05, [[0]]])
    s1 = solve_ivp(lambda t, x: f_lev(x, us - K@(x - xs), mt(t)), (0, 2), xs, t_eval=te, max_step=1e-3, **o)
    fig, ax = plt.subplots(figsize=(4.6, 2.6))
    ax.plot(te, 100*s1.y[0], color=C['gris'], lw=1.2, label='jacobiana (estados)')
    ax.plot(te, 100*s3.y[0], color=C['coral'], label='exacta')
    ax.plot(te, 100*s4.y[0], color=C['azul'], label='exacta + integrador')
    ax.axhline(5, color=C['gris'], ls=':'); ax.axvline(0.5, color=C['gris'], ls=':', lw=0.8)
    ax.invert_yaxis(); ax.set_xlabel('$t$ [s]'); ax.set_ylabel('$y$ [cm]'); ax.legend(fontsize=7.5, loc='lower left'); ax.grid(True)
    ax.set_title('La ley cancela con $m=0.10$; la real es 0.12')
    g(fig, 'f_robustez')


def fase_no_minima():               # C12_Ej10
    kk = 2
    rhs = lambda t, x: [x[0] + x[1], 3*x[0]**2*x[1] + x[0] + (-x[0] + 3*x[0]**3 - kk*(-x[0]**3 + x[1]))]
    ev = lambda t, x: abs(x[0]) - 2.2; ev.terminal = True
    s = solve_ivp(rhs, (0, 10), [0.05, 0.6], events=ev, max_step=0.002, **o)
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.7), gridspec_kw=dict(wspace=0.3))
    xx = np.linspace(-0.3, 2.4, 300)
    ax[0].plot(xx, xx**3, color=C['verde'], lw=4, alpha=0.6, label=r'$Z^*=\{x_2=x_1^3\}$')
    ax[0].plot(s.y[0], s.y[1], color=C['azul']); ax[0].plot(0.05, 0.6, 'o', color=C['noche'], ms=4)
    ax[0].set_xlim(-0.3, 2.4); ax[0].set_ylim(-1, 11); ax[0].set_xlabel(r'$x_1=\eta$'); ax[0].set_ylabel('$x_2$'); ax[0].legend(fontsize=7.5, loc='upper left'); ax[0].grid(True)
    ax[0].set_title('Llega a $Z^*$ y se va por ella')
    ax[1].plot(s.t, -s.y[0]**3 + s.y[1], color=C['azul'], label=r'$y=\xi$'); ax[1].plot(s.t, s.y[0], color=C['coral'], label=r'$\eta=x_1$')
    ax[1].set_xlabel('$t$'); ax[1].legend(fontsize=7.5, loc='upper left'); ax[1].grid(True); ax[1].set_title('$y\\to0$ como se diseñó; $\\eta$ escapa')
    g(fig, 'f_fase_no_minima')


def ceros():                        # C12_Ej11 [lineal]
    t = np.linspace(0, 6, 601)
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.3), gridspec_kw=dict(wspace=0.45))
    for (al, be), col, ls, nom in [((1, -2), C['azul'], '-', 'cero en $-1$'), ((2, -1), C['coral'], '--', 'cero en $+1$')]:
        s = solve_ivp(lambda tt, x: [x[1], al*x[2] + (-al*x[2] - 4*x[0] - 4*x[1]), be*x[2] - (-al*x[2] - 4*x[0] - 4*x[1])], (0, 6), [1, 0, 0], t_eval=t, **o)
        u = -al*s.y[2] - 4*s.y[0] - 4*s.y[1]
        ax[0].plot(t, s.y[0], color=col, ls=ls, label=nom); ax[1].plot(t, s.y[2], color=col, ls=ls); ax[2].plot(t, u, color=col, ls=ls)
    ax[0].set_title('$y(t)$: idéntica'); ax[1].set_title('$x_3(t)$'); ax[2].set_title('$u(t)$'); ax[1].set_yscale('symlog', linthresh=1); ax[2].set_yscale('symlog', linthresh=1)
    ax[0].legend(fontsize=7)
    for a_ in ax: a_.set_xlabel('$t$'); a_.grid(True)
    g(fig, 'f_ceros')


def dinamica_cero3d():              # C12_Ej11 [tres], C12_Video_DinamicaCero
    c = lambda e1, e2: 0.3*(e1**2 - e2**2)
    fig = plt.figure(figsize=(6.9, 3.0))
    G1, G2 = np.meshgrid(np.linspace(-2.2, 2.2, 30), np.linspace(-2.2, 2.2, 30))
    for j, (sg, col, tit) in enumerate([(-0.25, C['verde'], 'fase mínima ($s=-0.25$)'), (0.12, C['coral'], 'fase no mínima ($s=+0.12$)')]):
        a_ = fig.add_subplot(1, 2, j+1, projection='3d')
        a_.plot_surface(G1, G2, c(G1, G2), alpha=0.18, color=C['azul'], linewidth=0)
        M = np.array([[sg, -2], [2, sg]])
        s = solve_ivp(lambda t, z: np.r_[-3*z[0], M@z[1:] + np.array([z[0], 0])], (0, 14), [1.2, 1.0, 0.3], t_eval=np.linspace(0, 14, 3000), **o)
        mk = (abs(s.y[1]) < 2.2) & (abs(s.y[2]) < 2.2)
        a_.plot(s.y[1][mk], s.y[2][mk], (s.y[0] + c(s.y[1], s.y[2]))[mk], color=col, lw=1.5)
        a_.scatter([1.0], [0.3], [0.3 + c(1.0, 0.3)], color=C['noche'], s=10)
        a_.view_init(25, -35); a_.set_xlabel('$x_1$', labelpad=-6); a_.set_ylabel('$x_2$', labelpad=-6); a_.set_zlabel('$x_3$', labelpad=-6)
        a_.tick_params(labelsize=6, pad=-2); a_.set_title(tit, fontsize=9)
    g(fig, 'f_dinamica_cero3d')


def escape():                       # C12_Ej12 [iss]
    fig, ax = plt.subplots(1, 2, figsize=(6.9, 2.7), gridspec_kw=dict(wspace=0.3))
    e = np.linspace(0.3, 4.5, 200)
    for k_, a_ in zip([1, 5], ax):
        a_.fill_between(e, (k_+1)/e, 3.5, color=C['coral'], alpha=0.12)
        a_.plot(e, (k_+1)/e, color=C['coral'], lw=1.2)
        for e0 in [0.6, 1.2, 2.0, 3.0, 4.0]:
            for x0 in [0.6, 1.6, 2.8]:
                ev = lambda t, z: z[1] - 6; ev.terminal = True
                s = solve_ivp(lambda t, z: [-k_*z[0], -z[1] + z[1]**2*z[0]], (0, 5), [x0, e0], events=ev, max_step=0.01, rtol=1e-9)
                col = C['coral'] if e0*x0 > k_+1 else C['azul']
                a_.plot(s.y[1], s.y[0], color=col, lw=0.9); a_.plot(e0, x0, 'o', color=col, ms=2.5)
        a_.set_xlim(0, 4.5); a_.set_ylim(0, 3.2); a_.set_xlabel(r'$\eta$'); a_.set_ylabel(r'$\xi$')
        a_.set_title(f'$k={k_}$: escapa si $\\eta_0\\xi_0>{k_+1}$')
    g(fig, 'f_escape')


def no_cancelar():                  # C12_Ej12 [nocancelar]
    t = np.linspace(0, 4, 4001)
    sF = solve_ivp(lambda tt, x: x - x**3 + (x**3 - 2*x), (0, 4), [3], t_eval=t, **o)
    sC = solve_ivp(lambda tt, x: x - x**3 - 2*x, (0, 4), [3], t_eval=t, **o)
    uF = sF.y[0]**3 - 2*sF.y[0]; uC = -2*sC.y[0]
    from scipy.integrate import cumulative_trapezoid
    fig, ax = plt.subplots(1, 3, figsize=(6.9, 2.3), gridspec_kw=dict(wspace=0.42))
    ax[0].plot(t, sF.y[0], color=C['coral'], label='cancela'); ax[0].plot(t, sC.y[0], color=C['azul'], label='conserva'); ax[0].legend(fontsize=7)
    ax[1].plot(t, uF, color=C['coral']); ax[1].plot(t, uC, color=C['azul'])
    ax[2].plot(t, cumulative_trapezoid(uF**2, t, initial=0), color=C['coral']); ax[2].plot(t, cumulative_trapezoid(uC**2, t, initial=0), color=C['azul'])
    ax[0].set_title('$x(t)$'); ax[1].set_title('$u(t)$'); ax[2].set_title(r'$\int_0^t u^2\,d\tau$')
    for a_ in ax: a_.set_xlabel('$t$'); a_.grid(True)
    g(fig, 'f_no_cancelar')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
        sys.exit()
    for fn in [levitador_inestable, jacobiana, integral, pendulo, lie, difeo, grado_lineal, vdp_fl, seguimiento,
               singularidad, robustez, fase_no_minima, ceros, dinamica_cero3d, escape, no_cancelar]:
        fn()
