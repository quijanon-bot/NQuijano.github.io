"""Verificación de los números del capítulo 8 (PID: sintonización).
Ejecutar:  python3 herramientas/cap08_numeros.py
"""
import numpy as np, sympy as sp, control as ct
from pidsim import simular, metricas
s = ct.tf('s'); S = sp.symbols('s'); lam = sp.symbols('lambda', positive=True)

print('=== Ganancia normalizada (ejemplo) ===')
print(' Kp =', (30/60)/(20/100))

print('\n=== Datos FOPDT del ejercicio ===')
t = np.array([0, 2, 4, 6, 8, 10, 15, 20, 24, 30, 40, 50, 60, 100.])
y = np.array([80, 80, 80.1, 81.7, 83.3, 84.6, 87.7, 89.9, 91.4, 93.1, 95.0, 96.2, 96.9, 97.9])
modelo = lambda tt, K=18, L=4, T=20: 80 + K*(1 - np.exp(-np.clip(tt - L, 0, None)/T))
print(' modelo exacto L=4,T=20,dy=18 en los tiempos:', np.round(modelo(t), 2))
print(' Kp normalizado =', (18/100)/(15/100), ' físico =', 18/15, '°C/%')
y63 = 80 + 0.632*18; print(' 63%:', y63, '-> t63 ~ 24 s; T = 24 - L')
# tangente en el punto de máxima pendiente del modelo (en t=L, pendiente 18/20)
print(' pendiente máx (modelo) = 0.9 °C/s en t=4 -> la tangente corta 80 en t=4 y 98 en t=24: T_ZN = 20 con el modelo exacto')
# con los datos: pendiente máxima entre 4 y 6
sl = np.diff(y)/np.diff(t); i = np.argmax(sl); print(' pendiente máxima de los datos', sl[i], 'entre', t[i], t[i+1])
L_d = t[i] - (y[i] - 80)/sl[i]; T_zn = 18/sl[i]; print(' tangente con datos: L =', round(L_d, 3), ' T(100%) =', round(T_zn, 3), ' T(63%) =', round(24 - L_d, 3))
print(' MSE del modelo (L=4,T=20) =', np.mean((modelo(t) - y)**2))

print('\n=== Reglas de malla abierta para Kp=1.2, L=4, tau=20 ===')
K, L, T = 1.2, 4.0, 20.0; r = L/T
zn = dict(P=(T/(L*K), None, None), PI=(0.9*T/(L*K), L/0.3, None), PID=(1.2*T/(L*K), 2*L, 0.5*L))
cc = dict(P=((T/(K*L))*(1 + r/3), None, None), PI=((T/(K*L))*(0.9 + r/12), L*(30 + 3*r)/(9 + 20*r), None),
          PD=((T/(K*L))*(1.25 + r/6), None, L*(6 - 2*r)/(22 + 3*r)), PID=((T/(K*L))*(4/3 + r/4), L*(32 + 6*r)/(13 + 8*r), 4*L/(11 + 2*r)))
aj = (0.5*(1 + 0.5*r)/(K*r), T*(1 + 0.5*r), T*0.5*r/(0.5*r + 1))
for n, d in (('ZN', zn), ('CC', cc)):
    for k, v in d.items(): print(f'  {n} {k}: Kc={v[0]:.4f} Ti={v[1]} Td={v[2]}')
print('  r_c =', r, ' Ajustabilidad (0.2-0.5): Kc=%.4f Ti=%.3f Td=%.4f' % aj)
G = 1/(T*s + 1)
for n, (Kc, Ti, Td) in (('ZN', zn['PID']), ('CC', cc['PID']), ('Aj', aj)):
    tt, yy, uu, *_ = simular(K*G, Kc, Ti, Td, tf=150, dt=0.005, L=L, N=10)
    OS, ts, IAE = metricas(tt, yy)
    tt2, yd, *_ = simular(K*G, Kc, Ti, Td, tf=150, dt=0.005, L=L, N=10, r=0.0, d=1.0, td=0.0)
    # márgenes con el retardo exacto
    w = np.logspace(-3, 1, 40000); Gc = Kc*(1 + 1/(Ti*1j*w) + Td*1j*w/(Td*1j*w/10 + 1))
    Lw = Gc*K/(T*1j*w + 1)*np.exp(-1j*w*L); mag = np.abs(Lw); ph = np.unwrap(np.angle(Lw))
    ic = np.where(np.diff(np.sign(mag - 1)))[0][0]; PM = 180 + np.degrees(ph[ic]); wc = w[ic]
    ip = np.where(np.diff(np.sign(ph + np.pi)))[0][0]; GM = 1/mag[ip]
    print(f'  {n} PID sim: OS={OS:.1f}% ts={ts:.1f} IAE={IAE:.2f} |u|max={np.abs(uu).max():.2f} | pert: ymax={yd.max():.3f} IAE={np.trapezoid(np.abs(yd), tt2):.2f} | GM={GM:.2f} PM={PM:.1f} wc={wc:.3f} dL={np.radians(PM)/wc:.2f}')

print('\n=== Ziegler-Nichols de malla cerrada ===')
for den in ([0.1, 0.8, 1.7, 1], [6, 11, 6, 1], [8, 14, 7, 1]):
    a3, a2, a1, a0 = den; w2 = a1/a3; Kcr = a2*w2 - a0; print(f'  {den}: wcr={np.sqrt(w2):.4f} Kcr={Kcr:.4f} Pcr={2*np.pi/np.sqrt(w2):.4f}')
for den in ([6, 11, 6, 1], [8, 14, 7, 1]):
    a3, a2, a1, a0 = den; w2 = a1/a3; Kcr = a2*w2 - a0; Pcr = 2*np.pi/np.sqrt(w2)
    Gp = 1/ct.tf(den, [1])
    for nombre, (Kc, Ti, Td) in (('ZN', (0.6*Kcr, Pcr/2, Pcr/8)), ('TL', (Kcr/2.2, 2.2*Pcr, Pcr/6.3))):
        for fac in (1, 1.5):
            tt, yy, uu, *_ = simular(fac*Gp, Kc, Ti, Td, tf=120, dt=0.002, N=10)
            OS, ts, IAE = metricas(tt, yy)
            # relación de decaimiento: picos sucesivos de y-1
            e = yy - 1; pk = [j for j in range(1, len(e) - 1) if e[j] > e[j-1] and e[j] >= e[j+1] and e[j] > 1e-4]
            dec = e[pk[1]]/e[pk[0]] if len(pk) > 1 else np.nan
            w = np.logspace(-3, 2, 40000); Lw = Kc*(1 + 1/(Ti*1j*w) + Td*1j*w/(Td*1j*w/10 + 1))*fac/np.polyval(den, 1j*w)
            ph = np.unwrap(np.angle(Lw)); ip = np.where(np.diff(np.sign(ph + np.pi)))[0]; GM = 1/np.abs(Lw[ip[0]]) if len(ip) else np.inf
            print(f'   {den} {nombre} x{fac}: Kc={Kc:.3f} Ti={Ti:.3f} Td={Td:.3f} OS={OS:.1f} ts={ts:.1f} decaimiento={dec:.3f} GM={GM:.2f}')

print('\n=== Síntesis directa ===')
Gp = 2/(5*S + 1); T1 = 1/(lam*S + 1); print(' PI:', sp.simplify(T1/(Gp*(1 - T1))))
Gp = 3/((2*S + 1)*(10*S + 1)); print(' PID:', sp.factor(sp.simplify(T1/(Gp*(1 - T1)))), ' Kc=12/(3 lam), Ti=12, Td=20/12')
for lv in (1, 3, 5):
    Gc = (2*s + 1)*(10*s + 1)/(3*lv*s); Tcl = ct.feedback(Gc*3/((2*s + 1)*(10*s + 1)), 1)
    Kc, Ti, Td = 12/(3*lv), 12, 20/12
    tt, yy, uu, *_ = simular(3/((2*s + 1)*(10*s + 1)), Kc, Ti, Td, tf=40, dt=1e-3, N=10)
    print(f'  lambda={lv}: Kc={Kc:.3f} ts={metricas(tt, yy)[1]:.2f} (ideal 4lam={4*lv})  |u|max(N=10)={np.abs(uu).max():.2f}')
Gp = (1 - 9*S)/((15*S + 1)*(3*S + 1))
print(' fase no mínima T=1/(lam s+1):', sp.factor(sp.simplify((1/(lam*S + 1))/(Gp*(1 - 1/(lam*S + 1))))))
Tn = (1 - 9*S)/(lam*S + 1)**2; Gc = sp.factor(sp.simplify(Tn/(Gp*(1 - Tn)))); print(' T=(1-9s)/(lam s+1)^2:', Gc)
for lv in (5,):
    print('  lambda=5: Kc=', 18/(2*lv + 9), ' tau_f=', lv**2/(2*lv + 9), ' Ti=18 Td=2.5')

print('\n=== IMC ===')
Gp = 1.5*(1 - S)/((S + 1)*(4*S + 1)); Gm = 2/(5*S + 1); Q = (5*S + 1)/(2*(lam*S + 1))
car = sp.Poly(sp.expand(sp.numer(sp.together(1 + Q*(Gp - Gm)))), S); print(' Bequette:', car.all_coeffs())
lmin = sp.nsolve(20*lam**2 + 33*lam - 45, lam, 1); print(' lambda min =', lmin, '(raíz de 20l^2+33l-45)')
# PID por IMC
Kp, tp, th, t1, t2 = sp.symbols('K_p tau_p theta tau_1 tau_2', positive=True)
Q = (tp*S + 1)/(Kp*(lam*S + 1)); Gc = sp.simplify(Q/(1 - Kp/(tp*S + 1)*Q)); print(' 1er orden: Gc =', Gc)
Q = (t1*S + 1)*(t2*S + 1)/(Kp*(lam*S + 1)); Gc = sp.factor(sp.simplify(Q/(1 - Kp/((t1*S + 1)*(t2*S + 1))*Q))); print(' 2o orden: Gc =', Gc)
# FOPDT con Padé 1 y factorización all-pass: G- = Kp/((tp s+1)(th/2 s+1)), G+ = (1-th/2 s)
Gm = Kp*(1 - th/2*S)/((tp*S + 1)*(th/2*S + 1)); Q = (tp*S + 1)*(th/2*S + 1)/(Kp*(lam*S + 1))
Gc = sp.factor(sp.simplify(Q/(1 - Gm*Q))); print(' FOPDT Padé: Gc =', Gc)
num, den = sp.fraction(Gc); print('   -> Kc Kp = (tp+th/2)/(lam+th/2), Ti = tp+th/2, Td = tp th/(2tp+th)')
# verificación numérica del PID FOPDT y simulación con retardo exacto
K, tp_, th_ = 1.2, 20.0, 4.0
for lv in (3.2, 6.7, 10):
    Kc = (tp_ + th_/2)/(K*(lv + th_/2)); Ti = tp_ + th_/2; Td = tp_*th_/(2*tp_ + th_)
    tt, yy, uu, *_ = simular(K/(tp_*s + 1), Kc, Ti, Td, tf=150, dt=0.005, L=th_, N=10)
    OS, ts, IAE = metricas(tt, yy); print(f'  lambda={lv}: Kc={Kc:.3f} Ti={Ti} Td={Td:.3f} OS={OS:.1f} ts={ts:.1f} IAE={IAE:.2f} |u|max={np.abs(uu).max():.2f}')
# lambda mínimo estable con retardo exacto (PID ideal sin filtro, malla abierta Kc(1+1/Ti s+Td s) K e^{-th s}/(tp s+1))
def estable(lv):
    Kc = (tp_ + th_/2)/(K*(lv + th_/2)); Ti = tp_ + th_/2; Td = tp_*th_/(2*tp_ + th_)
    w = np.logspace(-3, 2, 200000); Lw = Kc*(1 + 1/(Ti*1j*w) + Td*1j*w/(Td*1j*w/10 + 1))*K/(tp_*1j*w + 1)*np.exp(-1j*w*th_)
    ph = np.unwrap(np.angle(Lw)); ip = np.where(np.diff(np.sign(ph + np.pi)))[0]
    return all(np.abs(Lw[ip]) < 1)
lo, hi = 0.01, 3.2
for _ in range(40):
    m = (lo + hi)/2
    lo, hi = (lo, m) if estable(m) else (m, hi)
print('  lambda mínimo estable (N=10, retardo exacto) ~', round(hi, 3), ' regla 0.8 theta =', 0.8*th_)
# inestable Kp/(1 - tau_u s)
tu = sp.symbols('tau_u', positive=True); g = sp.symbols('gamma')
gam = sp.solve(sp.Eq((g/tu + 1), (lam/tu + 1)**2), g)[0]; print(' inestable: gamma =', sp.simplify(gam))
Q = (1 - tu*S)*(gam*S + 1)/(Kp*(lam*S + 1)**2); Gc = sp.factor(sp.simplify(Q/(1 - Kp/(1 - tu*S)*Q))); print('   Gc =', Gc)
# error de ganancia K/(5s+1) vs 2/(5s+1)
Kk = sp.symbols('K'); car = sp.factor(sp.together(1 + (5*S + 1)/(2*(lam*S + 1))*(Kk - 2)/(5*S + 1))); print(' error de ganancia: ', car, '-> polo en s = -(K/2)/lam... estable si K>0')
# fase no mínima: polo del controlador inestable
print(' Q1 tiene un polo en s=+1/9, constante de tiempo 9 s')
Q1 = (15*s + 1)*(3*s + 1)/((1 - 9*s)*(5*s + 1)); tt = np.linspace(0, 200, 20001); uu = ct.step_response(Q1, tt).outputs
i = np.argmax(np.abs(uu) > 50); print('  |u| > 50 en t =', tt[i])
