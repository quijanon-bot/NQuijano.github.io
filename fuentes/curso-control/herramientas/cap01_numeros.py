"""Números del capítulo 1 (Introducción). Ejecutar:  python3 herramientas/cap01_numeros.py
Todo lo que el texto, la página y verificarCap01.m reportan sale de aquí.

Tanque de la sección 1.2 (tiempo en minutos):
    A dh/dt = u + d - h/R ,   A = 0.5 m^2,  R = 2 min/m^2   ->  K = R = 2,  tau = A R = 1 min
Lazo abierto (calibrado):     u = r / K_nom
Lazo cerrado (calibración + corrección proporcional):  u = r/K_nom + Kc (r - h),  Kc = 5
"""
import numpy as np
import control as ct

A, R, Kc = 0.5, 2.0, 5.0
Kn = R

def final_abierto(R_real=R, d=0.0, r=1.0):
    return R_real*(r/Kn + d)

def final_cerrado(R_real=R, d=0.0, r=1.0, kc=Kc):
    # h = R (r/Kn + kc (r - h) + d)  ->  h (1 + R kc) = R (r/Kn + kc r + d)
    return R_real*(r/Kn + kc*r + d)/(1 + R_real*kc)

print('== Tanque: lazo abierto vs lazo cerrado ==')
print(f'K = {R}, tau = {A*R} min, Kc = {Kc}, K*Kc = {R*Kc}')
print(f'nominal:        abierto {final_abierto():.4f}  cerrado {final_cerrado():.4f}')
print(f'lluvia d=0.2:   abierto {final_abierto(d=0.2):.4f}  cerrado {final_cerrado(d=0.2):.4f}')
print(f'R=2.4 (+20%):   abierto {final_abierto(R_real=2.4):.4f}  cerrado {final_cerrado(R_real=2.4):.4f}')
print(f'factor 1/(1+K Kc) = {1/(1+R*Kc):.4f};  con R=2.4: {1/(1+2.4*Kc):.4f}')
print(f'tau lazo cerrado = {A*R/(1+R*Kc)*60:.2f} s ;  u(1+) = {1/Kn + Kc:.2f} m^3/min (lazo abierto: {1/Kn})')
for kc in [1, 5, 10, 20, 50]:
    print(f'   Kc={kc:3d}: desviación por lluvia {final_cerrado(d=0.2,kc=kc)-1:.4f} m, pico de u {1/Kn+kc:.1f}')
# Kc para que la lluvia deje menos de 1 cm:  2*0.2/(1+2Kc) < 0.01
print('Kc mínimo para desviación < 1 cm:', (0.4/0.01 - 1)/2)

print('\n== Ascensor (respuesta de segundo orden, piso 4) ==')
z, wn, kg = 0.6, 0.8, 0.975
T = 4*kg*ct.tf([wn**2], [1, 2*z*wn, wn**2])
info = ct.step_info(T, T=np.linspace(0, 40, 400001), SettlingTimeThreshold=0.02)
print(f"OS = {100*np.exp(-z*np.pi/np.sqrt(1-z**2)):.2f} %   valor final = {4*kg:.2f} pisos  error = {4-4*kg:.2f} piso")
print(f"tp = {info['PeakTime']:.2f} s   ts(2%) = {info['SettlingTime']:.2f} s   pico = {info['Peak']:.3f}")

print('\n== Tanque de almacenamiento: prealimentación vs retroalimentación ==')
# A2 dh/dt = F1 - F2 ;  F1 sube 0.5 m^3/min en t = 2 min; sensor de flujo con error de -10 %
A2, dF1, eps, kc2 = 2.0, 0.5, 0.10, 1.0
print(f'solo prealimentación: deriva {dF1*eps/A2:.4f} m/min -> en 18 min {dF1*eps/A2*18:.3f} m')
print(f'solo retroalimentación P (Kc={kc2}): desviación final {dF1/kc2:.3f} m, tau = {A2/kc2} min')
print(f'combinadas: desviación final {dF1*eps/kc2:.3f} m')

print('\n== Ganancia de proceso ==')
print('0.5 kW -> 10 °C :', 10/0.5, '°C/kW')
