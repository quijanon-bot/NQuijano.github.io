# Transparencia: escrito y corregido con la asistencia de Claude (Anthropic); revisado y validado por el autor.
"""Figuras del capítulo 9 (sistemas variantes en el tiempo).
PDF (notas) y SVG (web). Cada figura reproduce un script de codigo/cap09_variantes/ (se indica cuál).
Ejecutar:  python3 herramientas/cap09_figuras.py   [nombre_de_función ...]
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from estilo import C, guardar
from cap04_figuras import campo, punto, ejes

CAP = 'cap09'
def g(fig, nombre): guardar(fig, nombre, CAP)
o = dict(rtol=1e-10, atol=1e-12)
T0S = [0, 2, 5, 10, 50]
COLS = [C['azul'], C['verde'], C['ambar'], C['violeta'], C['coral']]


def tiempo_inicial():               # C9_Ej1 [tiempo]
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(wspace=0.3))
    A = ax[0]
    for t0, c in zip([0, 5, 10, 20, 40], COLS):
        t = np.linspace(t0, 80, 400); A.plot(t, (1 + t0)/(1 + t), color=c, lw=1.4, label=f'$t_0={t0}$')
        A.plot(t0 + 9*(1 + t0), 0.1, 'o', color=c, ms=4) if t0 + 9*(1 + t0) <= 80 else None
    A.axhline(0.1, color=C['gris'], ls='--', lw=0.9); A.set_xlim(0, 80); A.set_ylim(0, 1.05)
    A.set_xlabel('$t$'); A.set_ylabel('$x(t)$, $x_0=1$'); A.grid(True); A.legend(fontsize=7, loc='upper right')
    A.set_title('cada curva empieza en su $t_0$')
    A = ax[1]; s = np.linspace(0, 60, 400)
    for t0, c in zip(T0S, COLS): A.plot(s, (1 + t0)/(1 + t0 + s), color=c, lw=1.4, label=f'$\\beta_{{{t0}}}(1,s)$')
    A.axhline(1, color=C['noche'], ls=':', lw=1.2); A.text(32, 1.02, r'$\sup_{t_0}\beta_{t_0}(1,s)=1$', fontsize=8)
    A.set_xlim(0, 60); A.set_ylim(0, 1.12); A.set_xlabel('$s=t-t_0$'); A.grid(True); A.legend(fontsize=7, loc='lower left')
    A.set_title('una cota $\\mathcal{KL}$ por cada $t_0$, ninguna común')
    g(fig, 'f_tiempo_inicial')


def comparacion():                  # C9_Ej2 [kl]
    fig, ax = plt.subplots(1, 3, figsize=(7.8, 2.6), gridspec_kw=dict(wspace=0.35))
    r = np.linspace(0, 5, 400)
    A = ax[0]; A.plot(r, np.arctan(r), color=C['azul'], label=r'$\tan^{-1}r\in\mathcal{K}$')
    A.plot(r, r**2/10, color=C['verde'], label=r'$r^2/10\in\mathcal{K}_\infty$')
    A.plot(r, np.minimum(r, 1)*0.9, color=C['coral'], ls='--', label=r'$0.9\min\{r,1\}\notin\mathcal{K}$')
    A.axhline(np.pi/2, color=C['gris'], ls=':', lw=0.8); A.set_xlim(0, 5); A.set_ylim(0, 2.6); A.grid(True); A.legend(fontsize=6.5, loc='upper left')
    A.set_xlabel('$r$'); A.set_title(r'clase $\mathcal{K}$ y $\mathcal{K}_\infty$')
    r = np.linspace(0, 6, 400)
    for A, f, tit in [(ax[1], lambda r, s: r/(s*r + 1), r'$r/(sr+1)\in\mathcal{KL}$'), (ax[2], lambda r, s: r*np.exp(-s*r), r'$re^{-sr}\notin\mathcal{KL}$')]:
        for s, c in zip([0, 0.5, 1, 2, 4], COLS): A.plot(r, f(r, s), color=c, lw=1.3, label=f'$s={s}$')
        A.set_xlim(0, 6); A.set_ylim(0, 2.2 if 'sr+1' in tit else 1.2); A.set_xlabel('$r$'); A.grid(True); A.set_title(tit)
    ax[1].legend(fontsize=6.5, loc='upper left')
    for s in (1, 2, 4): ax[2].plot(1/s, np.exp(-1)/s, 'o', color=C['noche'], ms=3)
    ax[2].set_ylim(0, 0.5); ax[2].text(2.2, 0.38, 'máximo en $r=1/s$:\nno es creciente en $r$', fontsize=7.5)
    g(fig, 'f_comparacion')


def derivada_parcial():             # C9_Ej3 [parcial]
    t = np.linspace(0, 30, 3000); x = np.exp(-0.1*t)
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 2.8), gridspec_kw=dict(wspace=0.3))
    ax[0].plot(t, (2 + np.sin(t))*x**2, color=C['azul']); ax[0].set_title(r'$V(t,x(t))=(2+\sin t)\,x(t)^2$: sube a ratos')
    ax[0].set_xlabel('$t$'); ax[0].grid(True)
    ax[1].plot(t, (np.cos(t) - 0.2*(2 + np.sin(t))), color=C['coral'], label=r'correcta: $\cos t-0.2(2+\sin t)$')
    ax[1].plot(t, -0.2*(2 + np.sin(t)), color=C['gris'], ls='--', label=r'sin $\partial V/\partial t$: $-0.2(2+\sin t)$')
    ax[1].axhline(0, color=C['noche'], lw=0.6); ax[1].set_xlabel('$t$'); ax[1].set_ylabel(r'$\dot V/x^2$'); ax[1].set_ylim(-2.6, 2.4); ax[1].grid(True); ax[1].legend(fontsize=6.5, loc='upper right', ncol=1)
    ax[1].set_title(r'el término $\partial V/\partial t$ cambia el signo')
    g(fig, 'f_derivada_parcial')


def trampa_e1():                    # C9_Ej4 [e1]
    fig, ax = plt.subplots(figsize=(5.2, 2.9))
    for t0, c in zip([0, 1, 3, 10, 30], COLS):
        t = np.linspace(t0, 120, 600); ax.plot(t, np.exp(1/(1 + t) - 1/(1 + t0)), color=c, lw=1.4, label=f'$t_0={t0}$')
        ax.axhline(np.exp(-1/(1 + t0)), color=c, ls=':', lw=0.8)
    ax.set_xlim(0, 120); ax.set_ylim(0, 1.05); ax.set_xlabel('$t$'); ax.set_ylabel('$x(t)$, $x_0=1$'); ax.grid(True); ax.legend(fontsize=7, loc='lower right')
    ax.set_title(r'$\dot x=-x/(1+t)^2$: $\dot V<0$ y aun así $x(t)\not\to0$')
    g(fig, 'f_trampa_e1')


def mathieu():                      # C9_Ej5 [mathieu]
    A = lambda t: np.array([[0, 1], [-(2 + np.sin(t)), -1]])
    s = solve_ivp(lambda t, z: A(t) @ z, (0, 14), [1.5, 0], t_eval=np.linspace(0, 14, 3000), **o)
    V = s.y[0]**2 + s.y[1]**2/(2 + np.sin(s.t))
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; th = np.linspace(0, 2*np.pi, 300)
    for tt, c in zip([0, np.pi/2, 3*np.pi/2], [C['azul'], C['verde'], C['coral']]):
        Vc = 2.25*np.exp(-tt*0.0)  # nivel V = 2.25 en distintos t
        a.plot(np.sqrt(Vc)*np.cos(th), np.sqrt(Vc*(2 + np.sin(tt)))*np.sin(th), color=c, lw=1, ls='--', label=f'$V(t,x)=2.25$, $t={tt:.2f}$')
    a.plot(s.y[0], s.y[1], color=C['noche'], lw=1.1)
    ejes(a, (-1.8, 1.8), (-2.8, 2.8), 'los niveles "respiran" con $t$'); a.set_aspect('auto'); a.legend(fontsize=6, loc='lower left')
    a = ax[1]; a.semilogy(s.t, V, color=C['azul'], label='$V(t,x(t))$'); a.semilogy(s.t, 2.25*np.exp(-s.t), color=C['gris'], ls='--', label='$2.25\\,e^{-t}$')
    a.set_xlabel('$t$'); a.grid(True, which='both'); a.legend(fontsize=7); a.set_title('$\\dot V\\leq 0$ y, de hecho, decae como $e^{-t}$')
    g(fig, 'f_mathieu')


def ganancia():                     # C9_Ej6 [ges]
    gf = lambda t: 1 + 0.5*np.sin(t)
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 2.9), gridspec_kw=dict(wspace=0.3))
    a = ax[0]
    for th, c in zip(np.linspace(0, np.pi, 5, endpoint=False), COLS):
        t = np.linspace(0, 20, 2000)
        s = solve_ivp(lambda tt, z: [-z[0] - gf(tt)*z[1], z[0] - z[1]], (0, 20), [np.cos(th), np.sin(th)], t_eval=t, **o)
        a.semilogy(t, np.linalg.norm(s.y, axis=0), color=c, lw=1.2)
    a.semilogy(t, np.sqrt(2.5)*np.exp(-t/5), color=C['noche'], ls='--', lw=1.4, label=r'cota $\sqrt{1+k}\,e^{-t/(2(1+k))}$')
    a.set_xlabel('$t$'); a.set_ylabel(r'$\|x(t)\|$'); a.grid(True, which='both'); a.legend(fontsize=7); a.set_title('$g=1+0.5\\sin t$, $k=1.5$')
    a = ax[1]; t = np.linspace(0, 2*np.pi, 1000)
    a.plot(t, 2 + 2*gf(t) - 0.5*np.cos(t), color=C['azul'], label=r'$g=1+0.5\sin t$')
    a.plot(t, 2 + (1 + np.sin(10*t)) - 5*np.cos(10*t), color=C['coral'], lw=1, label=r'$g=(1+\sin 10t)/2$')
    a.axhline(2, color=C['gris'], ls='--', lw=0.8); a.axhline(0, color=C['noche'], lw=0.6)
    a.set_xlabel('$t$'); a.set_ylabel(r'$2+2g-\dot g$'); a.grid(True); a.legend(fontsize=7, loc='lower right'); a.set_title(r'si $g$ oscila rápido, el certificado se cae')
    g(fig, 'f_ganancia')


def markus():                       # C9_Ej7 [markus]
    MY = lambda t: np.array([[-1 + 1.5*np.cos(t)**2, 1 - 1.5*np.sin(t)*np.cos(t)], [-1 - 1.5*np.sin(t)*np.cos(t), -1 + 1.5*np.sin(t)**2]])
    t = np.linspace(0, 8, 3000); s = solve_ivp(lambda tt, z: MY(tt) @ z, (0, 8), [1, 0], t_eval=t, **o)
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; n = np.linalg.norm(s.y, axis=0); m = t <= 6.5
    a.plot(s.y[0][m], s.y[1][m], color=C['coral'], lw=1.4, label='solución de $\\dot x=A(t)x$')
    for tf, c in ((0, C['azul']), (1.2, C['verde'])):          # campos congelados A(tf)
        q = solve_ivp(lambda tt, z: MY(tf) @ z, (0, 12), [1, 0], t_eval=np.linspace(0, 12, 1500), **o)
        a.plot(q.y[0], q.y[1], color=c, lw=1.0, ls='--', label=f'campo congelado $A({tf})$')
    ejes(a, (-22, 22), (-22, 22), 'desde $(1,0)$: la real se va, las congeladas no'); a.legend(fontsize=6.5, loc='lower left')
    a = ax[1]; a.semilogy(t, n, color=C['coral'], label=r'$\|x(t)\|$'); a.semilogy(t, np.exp(t/2), color=C['noche'], ls='--', label='$e^{t/2}$')
    a.semilogy(t, np.exp(-t/4), color=C['azul'], ls=':', label=r'$e^{-t/4}$ ("lo que dicen" los valores propios)')
    a.set_xlabel('$t$'); a.grid(True, which='both'); a.legend(fontsize=7, loc='center left'); a.set_title(r'$\lambda(A(t))=-0.25\pm0.66j$ para todo $t$')
    g(fig, 'f_markus')


def linealizacion():                # C9_Ej8 [lineal]
    fig, ax = plt.subplots(figsize=(5.4, 2.9))
    for t0, c in zip([0, 10, 100], [C['azul'], C['ambar'], C['coral']]):
        ev = lambda tt, z: np.hypot(*z) - 1e3; ev.terminal = True
        s = solve_ivp(lambda tt, z: [-z[0] + tt*z[1]**2, z[0] - z[1]], (t0, t0 + 40), [0.1, 0.1], events=ev, max_step=0.01, **o)
        ax.semilogy(s.t - t0, np.hypot(*s.y), color=c, lw=1.4, label=f'$t_0={t0}$' + (' (escapa)' if s.status == 1 else ''))
        l = solve_ivp(lambda tt, z: [-z[0], z[0] - z[1]], (t0, t0 + 40), [0.1, 0.1], t_eval=np.linspace(t0, t0 + 40, 500), **o)
    ax.semilogy(l.t - t0, np.hypot(*l.y), color=C['gris'], ls='--', label='linealización (para todo $t_0$)')
    ax.set_xlabel('$t-t_0$'); ax.set_ylabel(r'$\|x\|$'); ax.set_ylim(1e-12, 2e3); ax.grid(True, which='both'); ax.legend(fontsize=7)
    ax.set_title(r'$\dot x_1=-x_1+t\,x_2^2$: desde $(0.1,0.1)$')
    g(fig, 'f_linealizacion')


def pulsos():                       # C9_Ej12 [pulsos]
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


def yoshizawa():                    # C9_Ej9 [yoshizawa]
    A = lambda t: np.array([[0, 1], [-(2 + np.sin(t)), -1]])
    t = np.linspace(0, 20, 4000); s = solve_ivp(lambda tt, z: A(tt) @ z, (0, 20), [1, 0], t_eval=t, **o)
    x2d = -s.y[1] - (2 + np.sin(t))*s.y[0]
    fig, ax = plt.subplots(figsize=(5.6, 2.9))
    ax.plot(t, s.y[1]**2, color=C['coral'], label=r'$W=x_2^2$ (LaSalle--Yoshizawa: $\to0$)')
    ax.plot(t, x2d, color=C['violeta'], lw=1, label=r'$\dot x_2$ (Barbalat: $\to0$)')
    ax.plot(t, s.y[0], color=C['azul'], label=r'$x_1=-(\dot x_2+x_2)/(2+\sin t)\to0$')
    ax.axhline(0, color=C['noche'], lw=0.6); ax.set_xlim(0, 20); ax.set_xlabel('$t$'); ax.grid(True); ax.legend(fontsize=7)
    ax.set_title('Mathieu amortiguada: de $x_2\\to0$ a $x_1\\to0$')
    g(fig, 'f_yoshizawa')


def inestabilidad():                # C9_Ej10 y C9_Ej11
    fig, ax = plt.subplots(1, 3, figsize=(7.8, 2.8), gridspec_kw=dict(wspace=0.3))
    fA = lambda z: [2*z[1] + z[0]*(z[0]**2 + 2*z[1]**4), -2*z[0] + z[1]*(z[0]**2 + z[1]**4)]
    a = ax[0]; esc = lambda t, z: np.hypot(*z) - 1.3; esc.terminal = True
    s = solve_ivp(lambda t, z: fA(z), (0, 200), [0.25, 0], events=esc, max_step=0.02, **o); a.plot(s.y[0], s.y[1], color=C['coral'], lw=0.9)
    punto(a, (0, 0), False); ejes(a, (-1.3, 1.3), (-1.3, 1.3), 'primer teorema: $\\dot V>0$')
    fB = lambda z: [z[0] + 3*z[1]*np.sin(z[1])**2 + 5*z[0]*z[1]**2*np.sin(z[0])**2, 3*z[0]*np.sin(z[1])**2 + z[1] - 5*z[0]**2*z[1]*np.cos(z[0])**2]
    a = ax[1]; X, Y = np.meshgrid(np.linspace(-1, 1, 300), np.linspace(-1, 1, 300))
    a.contourf(X, Y, (X**2 > Y**2).astype(float), levels=[0.5, 1.5], colors=[C['coral']], alpha=0.15)
    for x0 in ([0.05, 0.02], [-0.05, -0.03], [0.02, 0.6], [-0.03, -0.7]):
        esc = lambda t, z: np.hypot(*z) - 1.0; esc.terminal = True
        s = solve_ivp(lambda t, z: fB(z), (0, 10), x0, events=esc, max_step=0.01, **o); a.plot(s.y[0], s.y[1], color=C['noche'], lw=0.9)
    punto(a, (0, 0), False); ejes(a, (-1, 1), (-1, 1), r'segundo: $\dot V\geq 2V$; $V>0$ en coral')
    fC = lambda z: [z[0]**2 + z[1]**3, -z[1] + z[0]**3]
    a = ax[2]; X, Y = np.meshgrid(np.linspace(-0.5, 0.5, 300), np.linspace(-0.5, 0.5, 300))
    a.contourf(X, Y, ((X > Y**2/2) & (X**2 + Y**2 < 0.25)).astype(float), levels=[0.5, 1.5], colors=[C['verde']], alpha=0.25)
    a.add_patch(plt.Circle((0, 0), 0.5, fill=False, color=C['gris'], ls=':'))
    for x0 in ([0.02, 0.15], [0.03, -0.18], [0.01, 0.0]):
        esc = lambda t, z: np.hypot(*z) - 0.6; esc.terminal = True
        s = solve_ivp(lambda t, z: fC(z), (0, 200), x0, events=esc, max_step=0.01, **o); a.plot(s.y[0], s.y[1], color=C['noche'], lw=0.9)
    s = solve_ivp(lambda t, z: fC(z), (0, 10), [-0.2, 0.2], max_step=0.01, **o); a.plot(s.y[0], s.y[1], color=C['azul'], lw=0.9)
    punto(a, (0, 0), False); ejes(a, (-0.55, 0.55), (-0.55, 0.55), r'Chetaev: $\Omega_1=\{x_1>x_2^2/2\}$')
    g(fig, 'f_inestabilidad')


def vdp():                          # C9_Ej11 [vdp]
    fv = lambda t, z: [z[1], -z[0] + (1 - z[0]**2)*z[1]]
    fig, ax = plt.subplots(1, 2, figsize=(7.4, 3.0), gridspec_kw=dict(wspace=0.3))
    a = ax[0]; th = np.linspace(0, 2*np.pi, 200); a.plot(np.cos(th), np.sin(th), color=C['gris'], ls=':')
    s = solve_ivp(fv, (0, 45), [-2.5, 2.5], t_eval=np.linspace(0, 45, 9000), **o)   # desde fuera del ciclo
    a.plot(s.y[0], s.y[1], color=C['gris'], lw=0.8)
    for d, c in zip([1e-2, 1e-4, 1e-6], [C['azul'], C['verde'], C['coral']]):
        t = np.linspace(0, 45, 9000); s = solve_ivp(fv, (0, 45), [d, 0], t_eval=t, **o)
        a.plot(s.y[0], s.y[1], color=c, lw=0.8)
        ax[1].semilogy(t, np.hypot(*s.y), color=c, lw=1.2, label=f'$x_0=({d:g},0)$')
    punto(a, (0, 0), False); ejes(a, (-3, 3), (-3, 3), 'inestable, y todo queda acotado')
    ax[1].axhline(1, color=C['gris'], ls=':'); ax[1].set_xlabel('$t$'); ax[1].set_ylabel(r'$\|x(t)\|$'); ax[1].grid(True, which='both'); ax[1].legend(fontsize=7, loc='lower right')
    ax[1].set_title(r'salida de $B_1$ en $t\approx2\ln(1/\delta)$')
    g(fig, 'f_vdp')


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        for nombre in sys.argv[1:]: globals()[nombre]()
        sys.exit()
    for fn in [tiempo_inicial, comparacion, derivada_parcial, trampa_e1, mathieu, ganancia, markus, linealizacion, pulsos, yoshizawa, inestabilidad, vdp]:
        fn()
