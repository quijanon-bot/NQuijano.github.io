"""Verificación de los números del capítulo 7 (PID: nociones básicas).
Ejecutar:  python3 herramientas/cap07_numeros.py
"""
import numpy as np, sympy as sp, control as ct
from pidsim import simular, metricas
s = ct.tf('s')

def info(T, tf=None):
    i = ct.step_info(T, T=tf) if tf is not None else ct.step_info(T)
    return {k: round(float(i[k]), 4) for k in ('RiseTime', 'SettlingTime', 'Overshoot', 'SteadyStateValue', 'Peak')}

print('=== Masa-resorte-amortiguador 1/(s^2+10s+20) ===')
P = 1/(s**2 + 10*s + 20)
print(' lazo abierto:', info(P), ' polos', np.round(ct.poles(P), 4), 'zeta', 10/(2*np.sqrt(20)), 'wn', np.sqrt(20))
for Kc in (10, 100, 300):
    T = ct.feedback(Kc*P, 1); wn = np.sqrt(20 + Kc); z = 10/(2*wn)
    print(f' P Kc={Kc}: ess={20/(20+Kc):.4f} wn={wn:.3f} zeta={z:.4f}', info(T, np.linspace(0, 3, 30001)))
for Kd in (10, 20):
    T = ct.feedback((300 + Kd*s)*P, 1)
    wn = np.sqrt(320); z = (10 + Kd)/(2*wn)
    OSp = 100*np.exp(-np.pi*z/np.sqrt(1 - z**2)) if z < 1 else 0
    print(f' PD Kd={Kd}: cero en {-300/Kd}, zeta={z:.4f}, OS 2o orden sin cero={OSp:.2f}', info(T, np.linspace(0, 3, 30001)))
Ki = sp.symbols('K_i')
ss_ = sp.symbols('s')
pc = sp.Poly(sp.expand(ss_*(ss_**2 + 10*ss_ + 20) + 300*ss_ + Ki), ss_); print(' PI char', pc.all_coeffs(), ' Routh: 10*320 > Ki -> Ki < 3200')
for Ki in (70, 200):
    T = ct.feedback((300 + Ki/s)*P, 1); print(f' PI Ki={Ki}:', info(T, np.linspace(0, 10, 100001)))
T = ct.feedback((350 + 300/s + 50*s)*P, 1); print(' PID 350/300/50:', info(T, np.linspace(0, 10, 100001)), 'polos', np.round(ct.poles(T), 4))

print('\n=== Conversiones ===')
def serie_a_ideal(K, Ti, Td): return K*(1 + Td/Ti), Ti + Td, Ti*Td/(Ti + Td)
def ideal_a_serie(K, Ti, Td):
    r = np.sqrt(1 - 4*Td/Ti); return K/2*(1 + r), Ti/2*(1 + r), Ti/2*(1 - r)
print(' serie (2,8,2) -> ideal', serie_a_ideal(2, 8, 2), ' -> serie', ideal_a_serie(*serie_a_ideal(2, 8, 2)))
print(' ideal (5,4,2): 4Td=8 > Ti=4 -> no; ceros', np.roots([4*2, 4, 1]))
Kc, Ti, Td = 350, 350/300, 50/350
print(' paralelo (350,300,50) -> ideal', Kc, Ti, Td, ' Ti>=4Td?', Ti >= 4*Td, ' serie', ideal_a_serie(Kc, Ti, Td))
print(' ceros del PID 350/300/50', np.roots([50, 350, 300]))

print('\n=== Banda proporcional (ejercicio) ===')
Kc1 = 100/25; Kc2 = (1/0.25)*(100/200)   # PB% = (1/Kc)(uR/eR)*100 -> Kc = (uR/eR)/(PB/100)
print(' Kc (100/PB) =', Kc1, ' Kc con rangos =', Kc2, '%/°C')
Kp = 2.5; r = 120; u0 = 50
# lazo P: u = u0 + Kc e ; y = Kp u (estático) ; e = r - y
for Kpv in (2.5,):
    y = Kpv*(u0 + Kc2*r)/(1 + Kpv*Kc2); print(' y =', y, ' e =', r - y)
u0b = r/Kp; print(' u0 que anula =', u0b)
for Kpv in (2.2, 2.8):
    y = Kpv*(u0b + Kc2*r)/(1 + Kpv*Kc2); print(f' Kp={Kpv}: y={y:.3f} e={r-y:.3f}')
# PB para e<=2 con u0=50: e = (r - Kp u0)/(1+Kp Kc)
r2 = 150; Kcmin = ((r2 - Kp*u0)/2 - 1)/Kp; PB = (1/Kcmin)*(100/200)*100; print(' r=150: Kc min =', Kcmin, ' PB% =', PB, ' e con Kc=2:', (r2 - Kp*u0)/(1 + Kp*2))

print('\n=== Ruido y filtro derivativo (Kc=3, Ti=8, Td=2) ===')
for w in (0.1, 10, 100):
    print(f' w={w}: amplitud en u (D pura) = {0.01*3*2*w:.4f}')
for Nv in (5, 10, 20):
    w = 100; amp = 0.01*3*abs(1j*w*2/(1j*w*2/Nv + 1)); print(f' N={Nv}: cota alta frec Kc N={3*Nv}, |.| en w=100: {amp:.4f}, corte N/Td={Nv/2}')

print('\n=== Digital ===')
Kc, Ti, Td, Ts = 3, 8, 2, 0.1
print(' posicional: u = 3(e + 0.0125 sum e + 20 (e-e1))')
print(' incremental coef:', Kc*(1 + Ts/Ti + Td/Ts), Kc*(-1 - 2*Td/Ts), Kc*Td/Ts)

print('\n=== Windup: PID 3/8/2, e^{-4s}/(10s+1), u in [0,1.5] ===')
G = 1/(10*s + 1)
for nombre, kw in [('lineal', {}), ('saturado', dict(umin=0, umax=1.5)),
                   ('back Tt=sqrt(TiTd)=4', dict(umin=0, umax=1.5, aw='back', Tt=4.0)),
                   ('back Tt=Ti=8', dict(umin=0, umax=1.5, aw='back', Tt=8.0)),
                   ('clamp', dict(umin=0, umax=1.5, aw='clamp'))]:
    t, y, u, v, I = simular(G, 3, 8, 2, tf=120, dt=0.005, L=4, N=10, **kw)
    OS, ts, IAE = metricas(t, y); sat = np.sum((u >= 1.5 - 1e-9) | (u <= 1e-9))*0.005 if kw else 0
    print(f' {nombre:22s} OS={OS:6.2f}%  ts={ts:6.2f}  IAE={IAE:6.2f}  umax={u.max():.3f}  t_sat={sat:.2f}')

print('\n=== Kicks: P=1/(s^2+10s+20), PID 350/300/50, tf=0.01 ===')
for nombre, b, c in [('estandar', 1, 1), ('PI-D', 1, 0), ('I-PD', 0, 0)]:
    t, y, u, v, I = simular(1/(s**2 + 10*s + 20), 350, 350/300, 50/350, tf=6, dt=1e-4, b=b, c=c, N=(50/350)/0.01)
    OS, ts, IAE = metricas(t, y); print(f' {nombre:9s} |u|max={np.abs(u).max():9.1f} OS={OS:6.2f} ts={ts:.3f}')
print(' u(0+) con filtro: Kc + Kd/tf = 350 + 50/tf ->', [350 + 50/x for x in (0.01, 0.05, 0.1)])

print('\n=== Ponderación de la referencia: PI Kc=20 Ti=0.3 en 1/((s+1)(s+5)) ===')
print(' char: s^3+6s^2+(5+Kc)s+Kc/Ti ->', [1, 6, 25, 20/0.3], ' Routh 6*25=150 >', 20/0.3)
Gp = 1/((s + 1)*(s + 5))
for beta in (0, 0.3, 0.5, 1):
    t, y, *_ = simular(Gp, 20, 0.3, 0, tf=10, dt=1e-3, b=beta)
    OS, ts, IAE = metricas(t, y); print(f' beta={beta}: OS={OS:.2f} ts={ts:.2f}')
for nombre, (K, Tiv) in [('agresivo', (20, 0.3)), ('conservador', (2, 1))]:
    t, y, *_ = simular(Gp, K, Tiv, 0, tf=15, dt=1e-3, r=0.0, d=1.0, td=0.0)
    print(f' perturbación {nombre}: ymax={y.max():.4f} en t={t[y.argmax()]:.2f}')
