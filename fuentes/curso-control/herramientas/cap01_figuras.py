"""Figuras del capítulo 1 (Introducción).
Genera notas/figuras/cap01/*.pdf (LaTeX) y sitio/figuras/cap01/*.svg (web).
Ejecutar desde la raíz del repositorio:  python3 herramientas/cap01_figuras.py
Los números coinciden con herramientas/cap01_numeros.py y codigo/cap01_introduccion.
"""
import os
import numpy as np
import control as ct
import matplotlib.pyplot as plt
from estilo import C, guardar, RAIZ

CAP = 'cap01'
A, R, KC = 0.5, 2.0, 5.0     # tanque: A dh/dt = u + d - h/R  (min, m, m^3/min)


def escalon(t, t0, amp):
    return amp*(t >= t0)


def sim_tanque(Rreal, d_amp, cerrado, t, kc=KC):
    """Integra el tanque con Euler fino (lineal, sin saturación)."""
    h = np.zeros_like(t); u = np.zeros_like(t)
    dt = t[1]-t[0]
    for k in range(len(t)-1):
        r = escalon(t[k], 1.0, 1.0); d = escalon(t[k], 5.0, d_amp)
        u[k] = r/R + (kc*(r - h[k]) if cerrado else 0.0)
        h[k+1] = h[k] + dt*(u[k] + d - h[k]/Rreal)/A
    u[-1] = u[-2]
    return h, u


# ------------------------------------------------------------ 1.2 lazos
def f_tanque_lazos():
    t = np.linspace(0, 10, 20001)
    fig, axs = plt.subplots(1, 2, figsize=(7.2, 2.9), sharey=True,
                            gridspec_kw=dict(wspace=0.08))
    casos = [('(a) Llueve: $d=0.2$ m$^3$/min desde $t=5$ min', R, 0.2),
             ('(b) Válvula obstruida: $R$ sube 20 %', 2.4, 0.0)]
    for ax, (tit, Rr, dd) in zip(axs, casos):
        r = escalon(t, 1.0, 1.0)
        ha, _ = sim_tanque(Rr, dd, False, t)
        hc, _ = sim_tanque(Rr, dd, True, t)
        ax.plot(t, r, color=C['gris'], lw=1.1, ls=':', label='deseado $h_r$')
        ax.plot(t, ha, color=C['coral'], lw=2.0, label='lazo abierto')
        ax.plot(t, hc, color=C['azul'], lw=2.0, label='lazo cerrado')
        ax.set_title(tit, loc='left', fontsize=9)
        ax.set_xlabel('$t$ (min)'); ax.grid(True); ax.set_xlim(0, 10); ax.set_ylim(-0.05, 1.5)
        ax.annotate(f'{ha[-1]:.2f}', xy=(10, ha[-1]), xytext=(8.6, ha[-1]+0.07), color=C['coral'], fontsize=8.5)
        ax.annotate(f'{hc[-1]:.3f}', xy=(10, hc[-1]), xytext=(8.4, hc[-1]-0.15), color=C['azul'], fontsize=8.5)
    axs[0].set_ylabel('nivel $h$ (m)')
    axs[0].legend(loc='lower right', fontsize=8)
    guardar(fig, 'f_tanque_lazos', CAP)


def f_tanque_esfuerzo():
    t = np.linspace(0, 10, 20001)
    fig, ax = plt.subplots(figsize=(4.6, 2.4))
    _, ua = sim_tanque(R, 0.2, False, t)
    _, uc = sim_tanque(R, 0.2, True, t)
    ax.plot(t, ua, color=C['coral'], lw=2, label='lazo abierto')
    ax.plot(t, uc, color=C['azul'], lw=2, label='lazo cerrado ($K_c=5$)')
    ax.set_xlabel('$t$ (min)'); ax.set_ylabel('$u$ (m$^3$/min)'); ax.grid(True)
    ax.annotate('pico 5.5: el precio\nde corregir rápido', xy=(1.0, 5.5), xytext=(2.3, 4.0), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    ax.legend(loc='upper right', fontsize=8)
    guardar(fig, 'f_tanque_esfuerzo', CAP)


# ------------------------------------------------------------ 1.3 ascensor
def f_ascensor():
    z, wn, kg = 0.6, 0.8, 0.975
    T = 4*kg*ct.tf([wn**2], [1, 2*z*wn, wn**2])
    t = np.linspace(0, 14, 2000)
    _, y = ct.step_response(T, t)
    fig, ax = plt.subplots(figsize=(6.4, 2.8))
    ax.plot(t, 4*np.ones_like(t), color=C['gris'], ls=':', lw=1.3, label='entrada: botón del piso 4')
    ax.plot(t, y, color=C['azul'], lw=2.2, label='salida: posición del ascensor')
    ax.axvspan(0, 7.43, color=C['ambar'], alpha=0.10)
    ax.text(3.8, 0.5, 'respuesta transitoria', ha='center', color=C['noche'], fontsize=9)
    ax.text(10.8, 2.0, 'estado estacionario', ha='center', color=C['noche'], fontsize=9)
    ax.annotate('', xy=(12.6, 3.9), xytext=(12.6, 4.0),
                arrowprops=dict(arrowstyle='<->', color=C['coral'], lw=1.4, shrinkA=0, shrinkB=0))
    ax.annotate('error en estado\nestacionario', xy=(12.6, 3.95), xytext=(10.0, 2.9), fontsize=8.5,
                color=C['coral'], arrowprops=dict(arrowstyle='->', color=C['coral']))
    ax.annotate('sobrepaso:\nincomodidad', xy=(4.91, 4.27), xytext=(6.4, 4.75), fontsize=8.5,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    ax.set_xlabel('$t$ (s)'); ax.set_ylabel('piso'); ax.set_ylim(0, 5.2); ax.set_xlim(0, 14)
    ax.grid(True); ax.legend(loc='lower right', fontsize=8)
    guardar(fig, 'f_ascensor', CAP)


# ------------------------------------------------------------ 1.4 prealimentación
def f_prealimentacion():
    A2, dF1, eps, kc = 2.0, 0.5, 0.10, 1.0
    t = np.linspace(0, 20, 4001); dt = t[1]-t[0]
    F1 = 1 + dF1*(t >= 2)
    res = {}
    for nombre, ff, fb in [('ff', 1, 0), ('fb', 0, 1), ('ambas', 1, 1)]:
        h = np.zeros_like(t)
        for k in range(len(t)-1):
            F2 = 1 + ff*(1-eps)*(F1[k]-1) + fb*kc*h[k]
            h[k+1] = h[k] + dt*(F1[k]-F2)/A2
        res[nombre] = h
    fig, ax = plt.subplots(figsize=(6.4, 2.8))
    ax.plot(t, res['ff'], color=C['coral'], lw=2, label='solo prealimentación (sensor con 10 % de error)')
    ax.plot(t, res['fb'], color=C['violeta'], lw=2, label='solo retroalimentación ($K_c=1$)')
    ax.plot(t, res['ambas'], color=C['azul'], lw=2.2, label='las dos combinadas')
    ax.axhline(0, color=C['gris'], ls=':', lw=1.1)
    ax.set_xlabel('$t$ (min)'); ax.set_ylabel(r'$\hat h$ (m)  desviación del nivel')
    ax.set_xlim(0, 20); ax.set_ylim(-0.13, 0.6); ax.grid(True)
    ax.legend(loc='upper left', fontsize=8)
    ax.annotate('$F_1$ sube 0.5 m$^3$/min', xy=(2, 0), xytext=(3.0, -0.09), fontsize=8,
                arrowprops=dict(arrowstyle='->', color=C['gris']))
    guardar(fig, 'f_prealimentacion', CAP)


# ------------------------------------------------------------ 1.5 historia
def f_linea_tiempo():
    filas = [
        ('De la Antigüedad a la teoría de reguladores', [
            ('s. III a.C.', 'Ktesibios', 'clepsidra con\nregulador\nde flotador'),
            ('s. I', 'Herón', '$\\it{Pneumatica}$'),
            ('c. 1620', 'Drebbel', 'termostato\n(incubadora)'),
            ('1745', 'E. Lee', 'cola de abanico\nen molinos'),
            ('1788', 'Watt', 'regulador\ncentrífugo en la\nmáquina de vapor'),
            ('1868', 'Maxwell', '$\\it{On\\ governors}$'),
            ('1877', 'Routh', 'criterio de\nestabilidad'),
            ('1892', 'Lyapunov', 'estabilidad del\nmovimiento'),
            ('1895', 'Hurwitz', 'criterio con\ndeterminantes'),
            ('1914', 'L. Sperry', 'piloto\nautomático\nen París'),
            ('1922', 'Minorsky', 'gobierno de\nbarcos: PID')]),
        ('Del amplificador de Black a la era digital', [
            ('1927', 'Black', 'amplificador\nretroalimentado'),
            ('1932', 'Nyquist', 'criterio de\nestabilidad'),
            ('1934', 'Hazen', 'teoría de los\nservomecanismos'),
            ('1940–45', 'Bode', 'diseño en\nfrecuencia'),
            ('1942', 'Ziegler y Nichols', 'sintonización\ndel PID'),
            ('1948', 'Wiener · Evans', 'cibernética ·\nlugar de\nlas raíces'),
            ('1957', 'IFAC', 'fundada en\nParís; 1.er\ncongreso 1960'),
            ('1960', 'Kalman', 'espacio de\nestado, filtro\nde Kalman'),
            ('1962', 'Pontryagin · Bellman', 'control óptimo'),
            ('1969–75', 'PLC · DCS', 'el control\nindustrial se\nvuelve digital'),
            ('1997', 'PATH', 'pelotón de\nautos\nautomáticos'),
        ])]
    fig, axs = plt.subplots(2, 1, figsize=(7.6, 5.4), gridspec_kw=dict(hspace=0.25))
    colores = [C['ambar'], C['azul']]
    for ax, (tit, ev), col in zip(axs, filas, colores):
        n = len(ev)
        ax.axhline(0, color=C['gris'], lw=1.6, zorder=1)
        for i, (a, q, txt) in enumerate(ev):
            nivel = 1 if i % 2 == 0 else -1
            y = 0.55*nivel
            ax.plot([i, i], [0, y], color=col, lw=0.9, zorder=1)
            ax.plot(i, 0, 'o', ms=6.5, color=col, zorder=3)
            ax.text(i, y, f'{a}\n{q}\n{txt}', ha='center', va='bottom' if nivel > 0 else 'top',
                    fontsize=6.5, color=C['noche'], linespacing=1.08,
                    bbox=dict(boxstyle='round,pad=0.25', fc='white', ec=col, lw=0.8))
        ax.set_xlim(-0.7, n-0.3); ax.set_ylim(-1.9, 1.9); ax.axis('off')
        ax.set_title(tit, loc='left', fontsize=9.5, color=C['noche'])
    guardar(fig, 'f_linea_tiempo', CAP)


# ------------------------------------------------------------ fotos
def fotos():
    """Recorta y copia las fotos del autor (Science Museum, Londres) y la lámina de personajes."""
    from PIL import Image
    origen = '/tmp/claude-0/fig1'
    for f, n in [('MaquinaVaporWatt3', 'foto_watt'), ('AnalizadorDifBush', 'foto_bush'),
                 ('PersonajesHistoricos', 'personajes')]:
        p = os.path.join(origen, f + '_crop.jpg')
        if not os.path.exists(p):
            continue
        im = Image.open(p).convert('RGB')
        im1 = im.copy(); im1.thumbnail((2000, 2000))
        im1.save(os.path.join(RAIZ, 'notas', 'figuras', CAP, n + '.jpg'), quality=85)
        im2 = im.copy(); im2.thumbnail((1200, 1200))
        os.makedirs(os.path.join(RAIZ, 'sitio', 'figuras', CAP), exist_ok=True)
        im2.save(os.path.join(RAIZ, 'sitio', 'figuras', CAP, n + '.jpg'), quality=80)
        print('  foto:', n)


if __name__ == '__main__':
    f_tanque_lazos(); f_tanque_esfuerzo(); f_ascensor(); f_prealimentacion(); f_linea_tiempo(); fotos()
