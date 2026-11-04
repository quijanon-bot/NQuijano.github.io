"""Estilo gráfico común del curso Sistemas No Lineales (figuras de las notas y de la web).
Misma paleta que apuntessisnl.cls y que sitio/estilos.scss (y que el curso de Control).
"""
import os
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import LogLocator, NullFormatter, FuncFormatter
from matplotlib import font_manager
import glob
# Registrar Lato si está instalada en el sistema (TeX Live o fuentes del sistema)
for _f in glob.glob('/usr/share/fonts/truetype/lato/*.ttf') + \
          glob.glob('/usr/share/texlive/texmf-dist/fonts/truetype/public/lato/*.ttf'):
    try:
        font_manager.fontManager.addfont(_f)
    except Exception:
        pass

C = dict(azul='#1E5AA8', noche='#14213D', violeta='#6C4AB6', coral='#D1495B',
         ambar='#E09F3E', verde='#2A9D8F', teal='#0F7173', gris='#5C677D',
         claro='#C9D1DE', fondo='#F4F6FA')
# Convención de las figuras de Bode:
#   componentes: azul, coral, violeta, ámbar (en ese orden)
#   suma asintótica: noche, gruesa
#   curva real: verde, discontinua
COMP = [C['azul'], C['coral'], C['violeta'], C['ambar']]

plt.rcParams.update({
    'font.family': 'Lato', 'font.size': 10,
    'mathtext.fontset': 'custom', 'mathtext.rm': 'Lato', 'mathtext.it': 'Lato:italic',
    'mathtext.bf': 'Lato:bold', 'mathtext.sf': 'Lato',
    'axes.edgecolor': C['gris'], 'axes.labelcolor': C['noche'], 'axes.linewidth': 0.8,
    'axes.titlesize': 10.5, 'axes.titleweight': 'bold', 'axes.titlecolor': C['noche'],
    'axes.spines.top': False, 'axes.spines.right': False,
    'xtick.color': C['gris'], 'ytick.color': C['gris'],
    'grid.color': '#DDE2EA', 'grid.linewidth': 0.6,
    'legend.frameon': False, 'legend.fontsize': 8.5,
    'lines.linewidth': 1.8, 'figure.dpi': 150, 'savefig.bbox': 'tight',
    'savefig.pad_inches': 0.04, 'pdf.fonttype': 42, 'svg.fonttype': 'path',
})

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIR_PDF = os.path.join(RAIZ, 'notas', 'figuras', 'cap11')
DIR_WEB = os.path.join(RAIZ, 'sitio', 'figuras', 'cap11')
os.makedirs(DIR_PDF, exist_ok=True)
os.makedirs(DIR_WEB, exist_ok=True)


def guardar(fig, nombre, cap='cap11'):
    dpdf = os.path.join(RAIZ, 'notas', 'figuras', cap)
    dweb = os.path.join(RAIZ, 'sitio', 'figuras', cap)
    os.makedirs(dpdf, exist_ok=True); os.makedirs(dweb, exist_ok=True)
    fig.savefig(os.path.join(dpdf, nombre + '.pdf'))
    fig.savefig(os.path.join(dweb, nombre + '.svg'))
    plt.close(fig)
    print('  figura:', nombre)


def ejes_bode(ax, wlim, fase=False, paso=None):
    ax.set_xscale('log')
    ax.set_xlim(*wlim)
    ax.grid(True, which='major')
    ax.grid(True, which='minor', alpha=0.45)
    ax.xaxis.set_minor_formatter(NullFormatter())
    ax.xaxis.set_major_formatter(FuncFormatter(lambda v, _: f'{v:g}'))
    if fase:
        ax.set_ylabel('fase (°)')
        if paso:
            lo, hi = ax.get_ylim()
            ax.set_yticks(np.arange(np.ceil(lo/paso)*paso, hi + 1e-9, paso))
    else:
        ax.set_ylabel('magnitud (dB)')
        if paso:
            lo, hi = ax.get_ylim()
            ax.set_yticks(np.arange(np.ceil(lo/paso)*paso, hi + 1e-9, paso))


def figura_bode(ancho=6.2, alto=4.4):
    fig, (a1, a2) = plt.subplots(2, 1, figsize=(ancho, alto), sharex=True,
                                 gridspec_kw=dict(hspace=0.12))
    a2.set_xlabel('ω (rad/s)')
    return fig, a1, a2


def bode_asintotico(w, Kb, N, quiebres=()):
    """Misma regla que comun/bodeAsintotico.m.
    G'(s) = Kb*prod(s/wz+1)^o / (s^N ...), quiebres = [(w_i, orden_i)],
    orden > 0 cero, < 0 polo."""
    w = np.asarray(w, float)
    m = 20*np.log10(abs(Kb)) - 20*N*np.log10(w)
    f = -90*N*np.ones_like(w) + (180 if Kb < 0 else 0)
    for wb, o in quiebres:
        m = m + 20*o*np.maximum(0, np.log10(w/wb))
        f = f + 45*o*np.minimum(2, np.maximum(0, np.log10(w/wb) + 1))
    return m, f


def bode_real(G, w):
    import control as ct
    r = np.array([ct.evalfr(G, 1j*x) for x in w])
    return 20*np.log10(np.abs(r)), np.degrees(np.unwrap(np.angle(r)))
