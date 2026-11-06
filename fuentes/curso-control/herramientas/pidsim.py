"""Simulador sencillo de lazos PID para las figuras y la verificación de los capítulos 7 y 8.

Planta lineal (función de transferencia) con tiempo muerto opcional en la entrada,
controlador PID ideal con:
  - ponderación de la referencia: b (proporcional) y c (derivativa)  [beta, gamma]
  - filtro derivativo con N (N=None: derivada ideal aproximada con N muy grande)
  - saturación del actuador [umin, umax]
  - anti-windup: 'ninguno', 'back' (back-calculation con Tt) o 'clamp' (integración condicional)
  - perturbación de carga a la entrada de la planta y ruido de medida.
Integración: planta exacta con ZOH a paso dt; controlador con Euler hacia atrás en la derivada.
"""
import numpy as np
import control as ct
from scipy.signal import cont2discrete


def planta_discreta(G, dt):
    sys = ct.tf2ss(G)
    A, B, C, D = (np.asarray(m, float) for m in (sys.A, sys.B, sys.C, sys.D))
    Ad, Bd, Cd, Dd, _ = cont2discrete((A, B, C, D), dt, method='zoh')
    return Ad, Bd, Cd, Dd


def simular(G, Kc, Ti=np.inf, Td=0.0, tf=50.0, dt=0.01, L=0.0, r=1.0, b=1.0, c=1.0, N=None,
            umin=-np.inf, umax=np.inf, aw='ninguno', Tt=None, d=0.0, td=None, ruido=None, tr=0.0):
    """Devuelve t, y, u (salida del actuador), v (salida del controlador antes del saturador), I (término integral)."""
    n = int(round(tf/dt)); t = np.arange(n + 1)*dt
    Ad, Bd, Cd, Dd = planta_discreta(G, dt)
    x = np.zeros((Ad.shape[0], 1))
    nL = int(round(L/dt)); buf = [0.0]*nL
    y = np.zeros(n + 1); u = np.zeros(n + 1); v = np.zeros(n + 1); I = np.zeros(n + 1)
    rr = np.where(t >= tr, r, 0.0) if np.isscalar(r) else np.asarray(r)
    dd = np.zeros(n + 1) if td is None else np.where(t >= td, d, 0.0)
    nn = np.zeros(n + 1) if ruido is None else np.asarray(ruido)
    Ii = 0.0; Dprev = 0.0; epd_prev = None
    Nf = 1e6 if N is None else N
    for k in range(n + 1):
        y[k] = (Cd @ x).item()
        ym = y[k] + nn[k]
        e = rr[k] - ym
        P = Kc*(b*rr[k] - ym)
        epd = c*rr[k] - ym
        if Td > 0:
            if epd_prev is None:
                epd_prev = 0.0          # antes de t=0 todo estaba en cero
            # D(s) = Kc Td s / (Td s/N + 1), Euler hacia atrás
            a = Td/Nf
            Dk = (a*Dprev + Kc*Td*(epd - epd_prev))/(a + dt)
        else:
            Dk = 0.0
        vk = P + Ii + Dk
        uk = min(max(vk, umin), umax)
        v[k] = vk; u[k] = uk; I[k] = Ii
        # actualizar el integrador
        if np.isfinite(Ti):
            dI = Kc/Ti*e
            if aw == 'back':
                dI += (uk - vk)/Tt
            elif aw == 'clamp':
                if uk != vk and (vk - uk)*e > 0:
                    dI = 0.0
            Ii += dt*dI
        Dprev = Dk; epd_prev = epd
        # planta (con retardo en la entrada y perturbación de carga)
        uin = uk + dd[k]
        if nL > 0:
            buf.append(uin); uin = buf.pop(0)
        x = Ad @ x + Bd*uin
    return t, y, u, v, I


def metricas(t, y, ref=1.0, banda=0.02, t0=0.0):
    """Sobrepico (%), tiempo de establecimiento (2 %), IAE."""
    m = t >= t0
    tt, yy = t[m] - t0, y[m]
    yf = ref
    OS = max(0.0, (yy.max() - yf)/abs(yf)*100)
    fuera = np.where(np.abs(yy - yf) > banda*abs(yf))[0]
    ts = tt[fuera[-1] + 1] if len(fuera) and fuera[-1] + 1 < len(tt) else (0.0 if not len(fuera) else np.inf)
    IAE = np.trapezoid(np.abs(ref - yy), tt)
    return OS, ts, IAE
