"""Figuras del capítulo 9 (retroalimentación de estado). PDF (notas) y SVG (web).
Ejecutar:  python3 herramientas/cap09_figuras.py
"""
import numpy as np
import matplotlib.pyplot as plt
import control as ct
from scipy.signal import tf2ss
from estilo import C, guardar

CAP = 'cap09'


def g(fig, nombre):
    guardar(fig, nombre, CAP)


def ackermann(A, B, polos):
    n = A.shape[0]
    q = np.real(np.poly(polos))
    qA = sum(c*np.linalg.matrix_power(A, n - i) for i, c in enumerate(q))
    Cc = np.hstack([np.linalg.matrix_power(A, i) @ B for i in range(n)])
    e = np.zeros((1, n)); e[0, -1] = 1
    return e @ np.linalg.solve(Cc, qA)


def polos(OS, tp=None, ts=None):
    z = -np.log(OS)/np.sqrt(np.pi**2 + np.log(OS)**2)
    wn = np.pi/(tp*np.sqrt(1 - z**2)) if tp else 4/(z*ts)
    return np.roots([1, 2*z*wn, wn**2])


def inicial(A, x0, t):
    n = A.shape[0]
    return ct.initial_response(ct.ss(A, np.zeros((n, 1)), np.eye(n), 0), t, X0=x0).outputs


def motivador():
    A = np.array([[-1, 2], [3, -2.]]); B = np.array([[0], [1.]]); K = np.array([[4, 2.]])
    t = np.linspace(0, 4, 801)
    xa = inicial(A, [1, 1], t); xc = inicial(A - B @ K, [1, 1], t); u = -(K @ xc).ravel()
    fig, axs = plt.subplots(1, 3, figsize=(6.8, 2.5), gridspec_kw=dict(wspace=0.38))
    axs[0].plot(t, xa[0], color=C['azul'], label='$x_1$'); axs[0].plot(t, xa[1], color=C['coral'], label='$x_2$')
    axs[0].set_title('sin control (polo en $+1$)'); axs[0].legend(loc='upper left')
    axs[1].plot(t, xc[0], color=C['azul']); axs[1].plot(t, xc[1], color=C['coral'])
    axs[1].set_title('$u=-\\mathbb{K}x$: polos $-2,\\,-3$')
    axs[2].plot(t, u, color=C['violeta']); axs[2].set_title('esfuerzo $u(t)$')
    for a in axs:
        a.grid(True); a.set_xlabel('t (s)'); a.axhline(0, color=C['gris'], lw=0.6)
    g(fig, 'f_motivador')


def condicion():
    B = np.array([[0], [1.]]); t = np.linspace(0, 5, 2001)
    av = np.logspace(-2, 0.5, 40); nk, um, cd = [], [], []
    for a in av:
        A = np.array([[-1, a], [3, -2.]]); K = np.array([[3 + 2/a, 2]])
        x = inicial(A - B @ K, [1, 1], t)
        nk.append(np.linalg.norm(K)); um.append(np.abs(K @ x).max())
        cd.append(np.linalg.cond(np.hstack([B, A @ B])))
    fig, ax = plt.subplots(figsize=(5.6, 2.7))
    ax.loglog(av, um, color=C['coral'], lw=2.2, label='$\\max|u(t)|$ desde $x(0)=[1\\;1]^\\top$')
    ax.loglog(av, cd, color=C['azul'], ls='--', lw=1.6, label='número de condición de $\\mathfrak{C}$')
    ax.set_xlabel('$a$'); ax.grid(True, which='both', alpha=0.5); ax.legend(loc='upper right')
    ax.set_title('casi no controlable = muy caro de controlar')
    g(fig, 'f_condicion')


def tres_polos():
    num, den = [10], np.polymul([1, 10], [1, 0.5, 1])
    p2 = polos(0.1, tp=1); p = [p2[0], p2[1], 10*p2[0].real]
    A, B, Cm, D = tf2ss(num, den); K = ackermann(A, B, p)
    t = np.linspace(0, 12, 2401)
    _, y0 = ct.step_response(ct.tf(num, den), t)
    _, y1 = ct.step_response(ct.ss(A - B @ K, B, Cm, D), t)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.6), gridspec_kw=dict(wspace=0.32))
    a1.plot(t, y0, color=C['gris'], lw=1.8); a1.set_title('planta: %OS = 44 %, $t_p=3.35$ s')
    a2.plot(t[t <= 4], y1[t <= 4]/y1[-1], color=C['azul'], lw=2.2)
    a2.axhline(1.1, color=C['coral'], ls=':', lw=0.9); a2.axvline(1, color=C['coral'], ls=':', lw=0.9)
    a2.set_title('$u=r-\\mathbb{K}x$ (normalizada): 9.8 %, 1.05 s')
    a2.text(1.6, 0.35, f'valor final real: {y1[-1]:.3f}', color=C['coral'])
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)')
    a1.set_ylabel('$y(t)$')
    g(fig, 'f_tres_polos')


def observador():
    A = np.array([[0, 1], [-10, -2.]]); Cm = np.array([[1, 0.]]); L = np.array([[14], [62.]])
    Ao = np.block([[A, np.zeros((2, 2))], [L @ Cm, A - L @ Cm]])
    t = np.linspace(0, 3, 1501); X = inicial(Ao, [1, 0, 0, 0], t)
    fig, axs = plt.subplots(1, 2, figsize=(6.6, 2.5), gridspec_kw=dict(wspace=0.28))
    for k, a in enumerate(axs):
        a.plot(t, X[k], color=C['azul'], lw=2.2, label=f'$x_{k+1}$ (planta)')
        a.plot(t, X[k + 2], color=C['coral'], ls='--', lw=1.8, label=f'$\\tilde x_{k+1}$ (observador)')
        a.grid(True); a.set_xlabel('t (s)'); a.legend(loc='upper right' if k == 0 else 'lower right')
    g(fig, 'f_observador')


def separacion():
    A = np.array([[0, 1], [-2, -3.]]); B = np.array([[0], [1.]]); Cm = np.array([[1, 0.]])
    K = ackermann(A, B, [-2 + 2j, -2 - 2j])
    N = 1/(Cm @ np.linalg.solve(-(A - B @ K), B))[0, 0]
    t = np.linspace(0, 4, 2001)
    fig, ax = plt.subplots(figsize=(5.8, 2.7))
    yr = ct.step_response(ct.ss(A - B @ K, B*N, Cm, 0), t).outputs
    ax.plot(t, yr, color=C['noche'], lw=2.4, label='estado medido ($u=-\\mathbb{K}x+Nr$)')
    for po, col in [(-10, C['azul']), (-4, C['coral'])]:
        L = ackermann(A.T, Cm.T, [po, po]).T
        # estados [x; e], e = x - x~ ; u = -K x~ + N r = -K x + K e + N r
        Aa = np.block([[A - B @ K, B @ K], [np.zeros((2, 2)), A - L @ Cm]])
        Ba = np.vstack([B*N, np.zeros((2, 1))])
        sys = ct.ss(Aa, Ba, np.hstack([Cm, np.zeros((1, 2))]), 0)
        y = ct.forced_response(sys, t, np.ones_like(t), X0=[0, 0, 1, -1]).outputs
        ax.plot(t, y, color=col, ls='--', lw=1.8, label=f'con observador (polos en ${po}$), $e(0)=[1\\;-1]^\\top$')
    ax.axhline(1, color=C['gris'], lw=0.6); ax.grid(True); ax.set_xlabel('t (s)'); ax.set_ylabel('$y(t)$')
    ax.legend(loc='lower right', fontsize=8)
    g(fig, 'f_separacion')


def integral():
    A = np.array([[0, 1], [-3, -5.]]); B = np.array([[0], [1.]]); Cm = np.array([[1, 0.]])
    p2 = polos(0.1, ts=0.5); K = ackermann(A, B, p2)
    Aa = np.block([[A, np.zeros((2, 1))], [-Cm, np.zeros((1, 1))]]); Ba = np.vstack([B, [[0]]])
    Ka = ackermann(Aa, Ba, [p2[0], p2[1], -100])
    t = np.linspace(0, 1, 2001)
    X0 = ct.step_response(ct.ss(A - B @ K, B, np.eye(2), 0), t).outputs[:, 0, :]
    X1 = ct.step_response(ct.ss(Aa - Ba @ Ka, np.array([[0], [0], [1.]]), np.eye(3), 0), t).outputs[:, 0, :]
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(6.6, 2.6), gridspec_kw=dict(wspace=0.3))
    a1.plot(t, X0[0], color=C['gris'], lw=1.8, label='$u=r-\\mathbb{K}x$')
    a1.plot(t, X1[0], color=C['azul'], lw=2.2, label='con integrador')
    a1.axhline(1, color=C['gris'], lw=0.6); a1.set_title('salida $y(t)$'); a1.legend(loc='center right')
    a1.text(0.45, 0.12, f'valor final sin integrador: {X0[0, -1]:.4f}', color=C['gris'], fontsize=8.5)
    u0 = 1 - (K @ X0).ravel(); u1 = -(Ka @ X1).ravel()
    a2.plot(t, u0, color=C['gris'], lw=1.8); a2.plot(t, u1, color=C['azul'], lw=2.2)
    a2.set_title('esfuerzo $u(t)$')
    for a in (a1, a2):
        a.grid(True); a.set_xlabel('t (s)')
    g(fig, 'f_integral')


if __name__ == '__main__':
    motivador(); condicion(); tres_polos(); observador(); separacion(); integral()
