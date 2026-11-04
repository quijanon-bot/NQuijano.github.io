"""Verificación independiente (python-control) de TODOS los números del
capítulo 10 (Respuesta frecuencial). Cada número que aparece en las notas
debe salir de aquí. Ejecutar:  python3 herramientas/cap10_numeros.py

Imprime los valores y falla (assert) si alguno se aleja de lo que dicen las
notas. Los mismos valores están en los comentarios de los .m del curso y en
codigo/cap10_respuesta_frecuencial/verificarCap10.m.
"""
import numpy as np
import control as ct
from scipy.optimize import brentq

s = ct.tf('s')
R = {}

def ok(nombre, valor, esperado, tol):
    R[nombre] = valor
    estado = 'OK ' if abs(valor - esperado) <= tol else 'XXX'
    print(f'{estado} {nombre:38s} = {valor:12.4f}   (notas: {esperado})')
    assert abs(valor - esperado) <= tol, nombre

def mag_db(G, w):
    return 20*np.log10(abs(ct.evalfr(G, 1j*w)))

def fase(G, w):
    """Fase continua en grados (sin saltos), por desenrollado desde w muy bajo."""
    ww = np.logspace(-4, np.log10(w), 4000)
    r = np.array([ct.evalfr(G, 1j*x) for x in ww])
    ph = np.unwrap(np.angle(r))
    return np.degrees(ph[-1])

def margenes(G):
    gm, pm, wcg, wcp = ct.margin(G)
    return 20*np.log10(gm), pm, wcg, wcp

def pm_de_zeta(z):
    return np.degrees(np.arctan(2*z/np.sqrt(-2*z**2 + np.sqrt(1 + 4*z**4))))

def zeta_de_os(os):
    return -np.log(os)/np.sqrt(np.pi**2 + np.log(os)**2)

def os_de_zeta(z):
    return 100*np.exp(-z*np.pi/np.sqrt(1 - z**2))

def step_info(T, tf=None):
    info = ct.step_info(T, SettlingTimeThreshold=0.02)
    return info

print('== 10.2 Respuesta senoidal')
G = 1/(s+10)
ok('|1/(j1+10)|', abs(ct.evalfr(G, 1j)), 0.0995, 5e-4)
ok('fase 1/(j1+10) (grados)', fase(G, 1), -5.71, 0.01)

print('== 10.5 Ejemplo s/(s+10)')
G = s/(s+10)
for w, m, f in [(1, -20.04, 84.29), (20, -0.97, 26.57), (0.1, -40.0, 89.43), (10, -3.01, 45.0)]:
    ok(f's/(s+10) dB en w={w}', mag_db(G, w), m, 0.01)
    ok(f's/(s+10) fase en w={w}', fase(G, w), f, 0.01)
ok('|s/(s+10)| en w=1 (lineal)', abs(ct.evalfr(G, 1j)), 0.0995, 5e-4)
ok('|s/(s+10)| en w=20 (lineal)', abs(ct.evalfr(G, 20j)), 0.894, 5e-4)
ok('|s/(s+10)| en w=0.1 (lineal)', abs(ct.evalfr(G, 0.1j)), 0.0100, 5e-5)

print('== 10.4 Segundo orden')
for z, mr_db, wr, os in [(0.05, 20.01, 0.997, 85.4), (0.1, 14.02, 0.990, 72.9), (0.2, 8.14, 0.959, 52.7),
                         (0.3, 4.85, 0.906, 37.2), (0.5, 1.25, 0.707, 16.3)]:
    ok(f'Mr(dB) zeta={z}', 20*np.log10(1/(2*z*np.sqrt(1 - z**2))), mr_db, 0.01)
    ok(f'wr/wn zeta={z}', np.sqrt(1 - 2*z**2), wr, 0.001)
    ok(f'%OS zeta={z}', os_de_zeta(z), os, 0.05)
ok('20log(1/(2*0.2))', 20*np.log10(1/0.4), 7.96, 0.01)
G2 = 1000/((s+1)*(s**2 + 4*s + 100))
ok('sorpresa |G(j10)| dB', mag_db(G2, 10), 7.92, 0.01)
ok('sorpresa fase asint. en 10', -45*np.log10(10/0.1) - 90, -180.0, 0.01)  # solo informativo
gm, pm, wcg, wcp = margenes(G2)
ok('sorpresa w cruce 0 dB', wcp, 12.7, 0.05)
ok('sorpresa PM', pm, -45.5, 0.1)
ok('sorpresa GM (dB)', gm, -7.5, 0.1)
ok('sorpresa: 5*104 - 1100 (Routh)', 5*104 - 1100, -580, 0)
ok('fase real de 1/(s+1) en 10', fase(1/(s+1), 10), -84.29, 0.01)

print('== 10.6 Identificación')
K = 10**(36/20)
ok('K = 10^(36/20)', K, 63.0957, 1e-3)
Gi = K*(s+1)/(s*(s/10 + 1)**2)
gm, pm, wcg, wcp = margenes(Gi)
ok('ident: w cruce', wcp, 78.80, 0.01)
ok('ident: PM', pm, 13.74, 0.01)

print('== 10.7 Márgenes 10000/((s+1)(s+10)(s+100))')
G = 1e4/((s+1)*(s+10)*(s+100))
gm, pm, wcg, wcp = margenes(G)
ok('GM (dB)', gm, 21.74, 0.01)
ok('w_GM', wcg, 33.32, 0.01)
ok('PM', pm, 54.90, 0.01)
ok('w_PM', wcp, 7.80, 0.01)
ok('GM veces', 10**(gm/20), 12.22, 0.01)
print('   asintótico: w_PM=10, fase asint. en 10 =', -90 - 45 - 0, '-> PM 45 (asint. fase pole100 en 10 = 0)')
ok('w_GM asintótico 10^1.5', 10**1.5, 31.62, 0.01)

print('== 10.7 Rango de Kc')
ok('Kcr Routh = 111*1110-1000', 111*1110 - 1000, 122210, 0)
ok('w_cr = sqrt(1110)', np.sqrt(1110), 33.32, 0.01)
ok('P_cr = 2pi/w_cr', 2*np.pi/np.sqrt(1110), 0.1886, 1e-4)
G1000 = 1000/((s+1)*(s+10)*(s+100))
gm, pm, wcg, wcp = margenes(G1000)
ok('GM con Kc=1000 (dB)', gm, 41.74, 0.01)
ok('Kcr = 1000*GM', 1000*10**(gm/20), 122210, 2)
ok('ZN Kc = 0.6 Kcr', 0.6*122210, 73326, 0)
ok('ZN Ti = Pcr/2', np.pi/np.sqrt(1110), 0.0943, 1e-4)
ok('ZN Td = Pcr/8', 2*np.pi/np.sqrt(1110)/8, 0.0236, 1e-4)

print('== 10.7 Sensor lento a/(s+a) sobre 10000/(...)')
for a, pm_est, pm_real, os in [(50, 46.0, 46.5, 28), (20, 33.6, 36.4, 44), (10, 17.0, 26.3, 68), (5, -2.4, 18.7, 104)]:
    H = a/(s+a)
    gm_, pm_, _, _ = margenes(G*H)
    T = ct.feedback(G, H)
    t = np.linspace(0, 6, 30001)
    _, y = ct.step_response(T, t)
    yss = ct.dcgain(T)
    ok(f'sensor a={a}: PM estimado', 54.90 - np.degrees(np.arctan(7.80/a)), pm_est, 0.15)
    ok(f'sensor a={a}: PM margin', pm_, pm_real, 0.1)
    ok(f'sensor a={a}: %OS', 100*(y.max() - yss)/yss, os, 1.0)

T0 = ct.feedback(G, 1); t = np.linspace(0, 5, 50001); _, y = ct.step_response(T0, t)
ok('sin sensor %OS', 100*(y.max() - ct.dcgain(T0))/ct.dcgain(T0), 18.3, 0.1)
for a, g in [(50, 12.7), (20, 8.6), (10, 6.1), (5, 4.7)]:
    ok(f'sensor a={a}: GM (dB)', margenes(G*a/(s+a))[0], g, 0.05)
ok('Ms=2: GM min (dB)', 20*np.log10(2/(2-1)), 6.02, 0.01)
ok('Ms=2: PM min', np.degrees(2*np.arcsin(1/4)), 29.0, 0.05)
ok('A=1e5, beta=0.01: Af', 1e5/(1 + 1e3), 99.90, 0.005)
ok('A=5e4: Af', 5e4/(1 + 500), 99.80, 0.005)

print('== 10.8 PM <-> zeta')
for z, pm, os in [(0.25, 28.0, 44.4), (0.40, 43.1, 25.4), (0.50, 51.8, 16.3), (0.60, 59.2, 9.5), (0.707, 65.5, 4.3)]:
    ok(f'PM(zeta={z})', pm_de_zeta(z), pm, 0.06)
    ok(f'%OS(zeta={z})', os_de_zeta(z), os, 0.06)
G = 100/(s*(s+10))
gm, pm, wcg, wcp = margenes(G)
ok('100/(s(s+10)) PM', pm, 51.83, 0.01)
ok('100/(s(s+10)) w_PM', wcp, 7.86, 0.01)
z = brentq(lambda x: pm_de_zeta(x) - pm, 0.01, 1)
ok('zeta desde PM', z, 0.500, 1e-3)
wn = wcp/np.sqrt(-2*z**2 + np.sqrt(1 + 4*z**4))
ok('wn desde w_PM', wn, 10.0, 1e-2)
ok('%OS', os_de_zeta(z), 16.3, 0.05)
ok('tp', np.pi/(wn*np.sqrt(1 - z**2)), 0.363, 1e-3)
ok('ts (4/zeta wn)', 4/(z*wn), 0.80, 1e-3)
ok('Mr (dB)', 20*np.log10(1/(2*z*np.sqrt(1 - z**2))), 1.25, 0.01)
ok('w_r', wn*np.sqrt(1 - 2*z**2), 7.07, 0.01)
wbw = wn*np.sqrt((1 - 2*z**2) + np.sqrt(4*z**4 - 4*z**2 + 2))
ok('w_BW', wbw, 12.72, 0.01)
ok('bandwidth(T)', ct.bandwidth(ct.feedback(G, 1)), 12.72, 0.01)
# asintótico: cruce en 10, fase -135 -> PM 45
za = brentq(lambda x: pm_de_zeta(x) - 45, 0.01, 1)
ok('zeta asintótico (PM=45)', za, 0.42, 0.005)
ok('%OS asintótico', os_de_zeta(za), 23.3, 0.1)
ok('aprox. zeta ~ PM/100 con PM=51.8', 0.518, 0.518, 0)
print('   variante 100/(s(s+5)): wn=10, zeta=0.25')
ok('100/(s(s+5)) %OS', os_de_zeta(0.25), 44.4, 0.05)
ok('100/(s(s+5)) ts', 4/(0.25*10), 1.6, 1e-6)
ok('100/(s(s+5)) tp', np.pi/(10*np.sqrt(1 - 0.25**2)), 0.324, 1e-3)

print('== 10.9 Tipo y constantes')
ok('kp tipo 0 (-40 dB)', 10**(-40/20), 0.01, 1e-9)
ok('ess escalón = 1/(1+kp)', 1/(1 + 0.01), 0.990, 1e-3)
ok('ka (cruce en 10)', 10**2, 100, 0)

print('== 10.10 Ajuste de ganancia: 1/(s(s+20)(s+100)), %OS = 20 %')
z = zeta_de_os(0.20)
ok('zeta(20 %)', z, 0.456, 1e-3)
pmd = pm_de_zeta(z)
ok('PM deseado', pmd, 48.15, 0.01)
G0 = 1/(s*(s+20)*(s+100))
wd = brentq(lambda w: fase(G0, w) - (-180 + pmd), 1, 30)
ok('w donde fase = -131.85', wd, 13.56, 0.01)
ok('|2000 G0| (dB) en wd', mag_db(2000*G0, wd), -24.36, 0.01)
Kc = 1/abs(ct.evalfr(G0, 1j*wd))
ok('Kc', Kc, 33056, 2)
T = ct.feedback(Kc*G0, 1)
info = step_info(T)
ok('%OS con Kc', info['Overshoot'], 19.9, 0.2)
ok('tp con Kc', info['PeakTime'], 0.21, 0.01)
ok('kv = Kc/2000', Kc/2000, 16.5, 0.05)
gm, pm, wcg, wcp = margenes(80000*G0)
ok('Kc=80000: PM', pm, 25.4, 0.05)
info = step_info(ct.feedback(80000*G0, 1))
ok('Kc=80000: %OS', info['Overshoot'], 49, 1.5)

print('== 10.11 Adelanto: Gp = 40/(s(s+2)), PM = 45, phi_seg = 10')
Gp = 40/(s*(s+2))
gm, pm0, wcg, wcp0 = margenes(Gp)
ok('PM sin compensar', pm0, 17.96, 0.01)
ok('w_PM sin compensar', wcp0, 6.17, 0.01)
phiM = 45 - pm0 + 10
ok('phi_M', phiM, 37.04, 0.01)
alpha = (1 + np.sin(np.radians(phiM)))/(1 - np.sin(np.radians(phiM)))
ok('alpha', alpha, 4.03, 0.01)
ok('-10 log alpha', -10*np.log10(alpha), -6.05, 0.01)
wM = brentq(lambda w: mag_db(Gp, w) + 10*np.log10(alpha), wcp0, 100*wcp0)
ok('w_M', wM, 8.85, 0.01)
wL = wM/np.sqrt(alpha); wH = alpha*wL
ok('w_L', wL, 4.41, 0.01)
ok('w_H', wH, 17.76, 0.01)
Gc_ld = alpha*(s + wL)/(s + wH)
gm, pm, wcg, wcp = margenes(Gc_ld*Gp)
ok('PM con adelanto', pm, 49.8, 0.1)
ok('w cruce con adelanto', wcp, 8.85, 0.01)
ok('pérdida de fase planta 6.17->8.85', fase(Gp, wcp0) - fase(Gp, wM), 5.23, 0.01)
T_ld = ct.feedback(Gc_ld*Gp, 1)
info = step_info(T_ld)
ok('adelanto %OS', info['Overshoot'], 22, 1)
ok('adelanto ts', info['SettlingTime'], 0.6, 0.15)
ok('adelanto BW', ct.bandwidth(T_ld), 14.5, 0.1)
T0 = ct.feedback(Gp, 1)
info = step_info(T0)
ok('sin compensar %OS', info['Overshoot'], 60, 1)
ok('sin compensar ts', info['SettlingTime'], 3.7, 0.2)
ok('sin compensar BW', ct.bandwidth(T0), 9.8, 0.2)
ok('phi max con alpha=10', np.degrees(np.arcsin(9/11)), 54.9, 0.05)
ok('phi max con alpha=20', np.degrees(np.arcsin(19/21)), 64.8, 0.05)

print('== 10.11 Atraso, misma planta')
fobj = -180 + 45 + 5
wdes = brentq(lambda w: fase(Gp, w) - fobj, 0.1, 6)
ok('w_des (fase = -130)', wdes, 1.68, 0.01)
wH_lg = wdes/10
alpha_lg = abs(ct.evalfr(Gp, 1j*wdes))
ok('alpha atraso', alpha_lg, 9.13, 0.01)
ok('20 log alpha atraso', 20*np.log10(alpha_lg), 19.2, 0.05)
wL_lg = wH_lg/alpha_lg
ok('w_H atraso', wH_lg, 0.168, 0.001)
ok('w_L atraso', wL_lg, 0.0184, 0.0002)
Gc_lg = (1/alpha_lg)*(s + wH_lg)/(s + wL_lg)
gm, pm, wcg, wcp = margenes(Gc_lg*Gp)
ok('PM con atraso', pm, 44.8, 0.1)
T_lg = ct.feedback(Gc_lg*Gp, 1)
t = np.linspace(0, 60, 60001)
info = ct.step_info(T_lg, T=t)
ok('atraso %OS', info['Overshoot'], 27, 1)
ok('atraso ts', info['SettlingTime'], 7.1, 0.5)
ok('atraso BW', ct.bandwidth(T_lg), 2.8, 0.1)
ok('atraso u(0+) = 1/alpha', 1/alpha_lg, 0.11, 0.01)
ok('adelanto u(0+) = alpha', alpha, 4.03, 0.01)
# Handout anterior: w_des = 2 sin holgura
Gc_h = 0.14125*(s + 0.2)/(s + 0.02825)
gm, pm, wcg, wcp = margenes(Gc_h*Gp)
ok('handout (w=2, sin holgura): PM', pm, 40.3, 0.3)

print('== 10.11 Atraso-adelanto: 20/(s(s+1)(s+2))')
Gp3 = 20/(s*(s+1)*(s+2))
gm, pm, wcg, wcp = margenes(Gp3)
ok('PM sin compensar', pm, -28.1, 0.1)
ok('GM sin compensar', gm, -10.5, 0.1)
wc = 1.2
ok('fase Gp en 1.2', fase(Gp3, wc), -171.2, 0.1)
a = 10
wLl = wc/np.sqrt(a); wHl = wc*np.sqrt(a)
Clead = a*(s + wLl)/(s + wHl)
MdB = mag_db(Clead*Gp3, wc)
ok('dB a quitar en 1.2', MdB, 23.2, 0.05)
beta = 10**(MdB/20); zl = wc/10; pl = zl/beta
ok('beta', beta, 14.5, 0.1)
Clag = (1/beta)*(s + zl)/(s + pl)
gm, pm, wcg, wcp = margenes(Clead*Clag*Gp3)
ok('atraso-adelanto PM', pm, 58.2, 0.05)
ok('atraso-adelanto GM', gm, 13.2, 0.1)

print('== 10.12 PID desde la frecuencia (planta 1/((s+1)(s+10)(s+100)))')
Gp4 = 1/((s+1)*(s+10)*(s+100))
Kcr = 122210; Pcr = 2*np.pi/np.sqrt(1110)
Kc_zn, Ti_zn, Td_zn = 0.6*Kcr, Pcr/2, Pcr/8
Czn = Kc_zn*(1 + 1/(Ti_zn*s) + Td_zn*s)
p = ct.evalfr(Czn*Gp4, 1j*np.sqrt(1110))
ok('punto ZN real', p.real, -0.6, 0.01)
ok('punto ZN imag', p.imag, -0.28, 0.01)
gm, pm, wcg, wcp = margenes(Czn*Gp4)
ok('PM con ZN', pm, 19.6, 1.0)
wc = 20; N = 10
Ti2 = 10/wc
PI = 1 + 1/(Ti2*s)
falta = -180 + 50 - (fase(Gp4, wc) + fase(PI, wc))
ok('fase que debe dar el PD', falta, 37.6, 0.1)
Td2 = brentq(lambda Td: np.degrees(np.arctan(wc*Td) - np.arctan(wc*Td/N)) - falta, 1e-4, 0.25)
ok('Td', Td2, 0.0465, 5e-4)
C0 = PI*(1 + Td2*s)/(1 + Td2*s/N)
Kc2 = 1/abs(ct.evalfr(C0*Gp4, 1j*wc))
ok('Kc moldeo', Kc2, 33427, 30)
gm, pm, wcg, wcp = margenes(Kc2*C0*Gp4)
ok('moldeo PM', pm, 50.0, 0.1)
ok('moldeo GM', gm, 24.4, 0.1)

print('== Ejercicios (soluciones)')
G = 100*(s+1)/(s*(s+10))
ok('E1 |G(j1)| dB', mag_db(G, 1), 22.97, 0.01)
ok('E1 |G(j10)| dB', mag_db(G, 10), 17.03, 0.01)
ok('E1 fase en 1', fase(G, 1), -50.7, 0.05)
G = 50/((s+2)*(s+5))
ok('E2 |G(j2)| dB', mag_db(G, 2), 10.33, 0.01)
ok('E2 fase en 2', fase(G, 2), -66.8, 0.05)
G = 10/(s+10)
ok('E3 |G(j10)|', abs(ct.evalfr(G, 10j)), 0.7071, 1e-4)
G = 100/(s**2 + 4*s + 100)
ok('E4 |G(j1)|', abs(ct.evalfr(G, 1j)), 1.01, 0.005)
ok('E4 fase en 1', fase(G, 1), -2.3, 0.05)
ok('E4 |G(j50)| dB', mag_db(G, 50), -27.6, 0.05)
ok('E4 fase en 50', fase(G, 50), -175.2, 0.05)
G = 20*(s+2)/(s*(s+20))
ok('R1 |G(j2)| dB', mag_db(G, 2), 2.97, 0.01)
ok('R1 |G(j20)| dB', mag_db(G, 20), -2.97, 0.01)
ok('R1 fase en 2', fase(G, 2), -50.7, 0.05)
G = 50/((s+5)*(s+10))
g = ct.evalfr(G, 5j)
ok('R2 amplitud 3|G(j5)|', 3*abs(g), 1.897, 1e-3)
ok('R2 fase', np.degrees(np.angle(g)), -71.57, 0.01)
ok('R2 w para |G| = 0.1', brentq(lambda w: abs(ct.evalfr(G, 1j*w)) - 0.1, 5, 50), 20.95, 0.01)
ok('R2 asint. w(-20 dB)', 10*10**((20 - 6.02)/40), 22.4, 0.05)
print('\nTodo verificado.')
