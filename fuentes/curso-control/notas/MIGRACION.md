# Guía para migrar un capítulo al formato nuevo

El capítulo 10 (respuesta frecuencial) fue el piloto; los capítulos 2, 3 (Modelado I y II) y 9 (retroalimentación de estado) ya están migrados con el mismo esquema. Para migrar cualquier otro:

1. **Copiar** el `HandoutN_Ctrl.tex` a `notas/capitulos/NN_nombre.tex` (o partirlo en `capitulos/capNN/sXX_*.tex` como el piloto).
2. **Abrir el capítulo** con `\capitulo[cap:etiqueta]{Título}{cita}{autor}` (se conserva la cita literaria de cada capítulo) y un bloque `objetivos` con la ruta de su página web.
3. **Cajas.** `mybox` → `definicion`, `ideaclave`, `receta` o `cuidado`, según lo que sea; `mybox_ej` → `ejemplo` (con `\solucion`) o `problema` (en los ejercicios de repaso). Las etiquetas van como opción: `\begin{ejemplo}[label=ej:xx]{Título}`.
4. **Colores sueltos.** `\textcolor{red}{...}` → `\alerta{...}`; `\textcolor{blue}{...}` → `\clave{...}` (término que se define) o, si es un párrafo de resumen, una caja `ideaclave`.
5. **Notación.** Reemplazar los símbolos escritos a mano por las macros de `notacion.sty` (tabla de abajo).
6. **Código.** Mover cada `lstlisting` a un `.m` en `codigo/capNN_*/`, con encabezado (QUÉ HACE / OBSERVE / ESPERADO / EXPLORE), marcas `% [ini:nombre]` … `% [fin:nombre]`, y en el `.tex` usar `\codigorepo{ruta}{nombre}{descripción}`. Simulink: un `crearModelo_*.m`.
7. **Figuras.** Si la figura sale de un cálculo, generarla con un script (Python en `herramientas/capNN_figuras.py` o MATLAB en `codigo/`) para que sea reproducible. Diagramas de bloques: TikZ en `notas/figuras/tikz/`, compilados con `herramientas/tikz.sh capNN nombre…` (deja el PDF para las notas y el SVG para la web).
8. **Verificar.** Recalcular todos los números con `herramientas/capNN_numeros.py` y escribir `verificarCapNN.m` con los clave; compilar; revisar.
9. **Página web.** Copiar `sitio/partes/10-respuesta-frecuencial.qmd` (o la 02/03) como plantilla y agregar el capítulo a `NOMBRES` en `herramientas/pdf_por_capitulo.py` para que tenga su propio PDF.
10. **Numeración.** En `NotasControl.tex`, `\setcounter{chapter}{N-1}` antes del `\input` del capítulo N mientras los anteriores no estén migrados.

## Inventario de inconsistencias encontradas (noviembre de 2026)

| Capítulo (archivo anterior) | Qué hay que cambiar |
|:--|:--|
| Introducción | 38 `\textcolor{red/blue}` |
| Modelado I (`Handout2_CtrlParte1`) | **migrado** (capítulo 2) |
| Modelado II (`Handout2_CtrlParte2`) | **migrado** (capítulo 3) |
| Espacio de estado (`Handout3`) | `\bar{x}` (14) → `\eq{x}`; "tiempo de asentamiento" (1) |
| Estabilidad (`Handout4`) | `C(s)/R(s)` (2) → `Y(s)/R(s)`; menciones de tiempo muerto (8): revisar contra el programa |
| Error (`Handout5`) | 15 `\textcolor`; ya usa $\kappa_p$, $\kappa_v$ ✓ |
| PID nociones (`Handout6a`) | "realimentación" (2); "overshoot"/`MP` (22) → `\OS`; "incremental" se queda (algoritmo digital) ✓ |
| PID sintonización (`Handout6b`) | $K_p$ = ganancia del proceso ✓ (coincide con la notación); unificar `P_{cr}` |
| Retroalimentación de estado (`Handout7`) | **migrado** (capítulo 9) |
| Bode (`Handout8`) | **migrado** (capítulo 10 piloto) |
| Presentación Clase 2 de Bode | tabla de Ziegler-Nichols usa $K_p$ para el controlador → $K_c$ |

Archivo `Handout6_Ctrl.tex`: es una versión anterior que fusiona 6a y 6b; no se incluye en el libro.

## Correcciones numéricas hechas en el capítulo 10

- Adelanto: $\omega_M = 8.85$ (el texto decía 14).
- Atraso: con la holgura de 5°, $\omega = 1.68$ y PM = 44.8° (con $\omega=2$ el PM queda en 40.3°).
- Rango de $K_c$: GM = +40 dB (no −40 dB).
- $\omega_{GM}$ asintótico del ejemplo $10\,000/[(s+1)(s+10)(s+100)]$: 31.6 (no 50).
- Ajuste de ganancia: $K_c = 33\,056$; la lectura a ojo de −24.2 dB da 32 400 (no 33 192).
- Ejemplo $100/(s(s+10))$, asintótico: $\zeta\approx0.42$, %OS ≈ 23 % (el texto daba $\zeta=0.4$, $t_p=0.29$).
- Pico de resonancia: $M_r$ (antes $M_P$, se confundía con el sobrepico).
- Se quitó el literal de tiempo muerto del problema de identificación (el curso no cubre retardos en esta parte).

## Correcciones hechas en el capítulo 2 (Modelado I)

- Equilibrio $T^*$ (antes $\bar T$); escalón $\mathbf{1}(t)$ con la macro `\escalon` (antes $u(t)$, que chocaba con la entrada $u$).
- Polos complejos del ejemplo $3\ddot x+2\dot x+x=0$: $-\tfrac13\pm j\tfrac{\sqrt2}{3}$ (faltaba la $j$). Solución en forma cerrada verificada.
- "Su magnitud sería $\angle p$" → su **fase**.
- Se eliminó la "inversión del tiempo" (no vale para la transformada unilateral); el escalamiento se enuncia solo con $a>0$.
- Ejemplo de `dsolve`: texto y código con $\dot y(0)=0$ (el texto decía $-3$).
- Error ante rampa: $e(t)=K_1\tau(1-e^{-t/\tau})$ (el signo estaba errado).
- Se quitó la mención a "la posición final de la masa" en el teorema del valor final (no correspondía a ningún ejemplo).
- La figura del escalón de primer orden decía $K_1=10$, $\tau=5$ en el pie y otros valores en el texto: se unificó.
- Problema de identificación: $\tau=29.9$ s (≈ 30), $e_\infty=0.72$ °C, $\tau_{máx}=20.8$ s.

## Correcciones hechas en el capítulo 3 (Modelado II)

- **Tanques.** El ejemplo $\tau_1=1$, $\tau_2=4$, $C_2=2$, $K_1=K_2=1$ no es físico: en esta planta $C_2=-C_1$ y $\zeta\geq1$ siempre (el propio ejercicio de repaso lo pedía demostrar). Se usan datos físicos ($A_1=2$, $A_2=3$, $C'_{v1}=0.1$, $C'_{v2}=0.05$, $h_2^*=4$: $\zeta=2.245$) y el subamortiguado se ilustra con masa-resorte-amortiguador ($m=1$, $b=1.2$, $k=4$). El ejercicio de tanques usa ahora otros datos para no repetir el ejemplo.
- La condición "$(\tau_1\tau_2)^2<4C_2K_1K_2\tau_1\tau_2$" para polos complejos estaba mal escrita; con $C_2=-C_1$ nunca se cumple.
- $\beta=\cos^{-1}\zeta$ (decía $\beta=\cos\zeta$).
- La aproximación $t_r\approx(2.3\zeta^2-0.078\zeta+1.12)/\omega_n$ (10–90 %) se verificó: error < 3.1 % para $0.1\le\zeta\le0.9$.
- Ejemplo $62.5(s+2.5)/[(s^2+6s+25)(s+6.25)]$: %OS 54.5 % (sin el polo) y 38.0 % (completo); $t_s$ 1.47 s y 1.59 s (antes 55 %, 38 %, 1.33 s —que era la fórmula $4/(\zeta\omega_n)$— y 1.6 s).
- Ejemplo $20/[(s+10)(s^2+2s+2)]$: %OS 4.27 % contra 4.32 % de la aproximación.
- Reducción despreciando el polo en $-30$: se fijó $K=60$ (con el $K$ implícito anterior las curvas no tenían sobrepico) y se discute $K=300$.
- El ejercicio "demostrar que $G_H$ de cuarto orden se reduce a $0.731(s+3.428)/[(s+1.043)(s+2.4)]$" tenía una respuesta que no satisface $M_{2q}=\Delta_{2q}$ (y el sistema de tres ecuaciones no tiene solución real); se reformuló sin cero: $d_1=1.211$, $d_2=0.2295$.
- Problema del sistema multilazo: el polo real es $-3.904$.
- MP → %OS; "determinante" → discriminante; "asentamiento" → establecimiento.

Todos los números de los capítulos 2 y 3 se recalcularon con `herramientas/cap02_numeros.py` y `cap03_numeros.py` (sympy y python-control) y con `verificarCap02.m` / `verificarCap03.m` (18/18 y 26/26 en Octave 8.4).

## Correcciones hechas en el capítulo 9 (retroalimentación de estado)

- **Notación nueva:** el estimado del observador es $\tilde x$ (macro `\est`) y el error de estimación $\varepsilon$ (macro `\errest`). En la versión anterior se usaba $\hat x$, que en el curso es la variable desviación (chocan cuando se diseña un observador sobre un modelo linealizado, como en la Actividad 2), y $e$, que es el error de seguimiento. Si se prefiere otro símbolo, se cambia solo en `notacion.sty` y `sitio/recursos/macros.html`.
- "Ackerman" → Ackermann; referencias exactas de Kalman (1960, 1963), Luenberger (1964) y Ackermann (1972).
- Servo $1/(s(s+1)(s+2))$: el polinomio es $\lambda^3+(3+K_3)\lambda^2+(2+K_2)\lambda+K_1$ (decía $-\lambda(2-K_2)$; las ganancias $[160\;54\;11]$ estaban bien).
- La definición de controlabilidad por ubicación de polos decía que $\mathbb{K}$ es único: solo lo es con una entrada.
- Ejemplo $\mathrm{diag}(-1,-3)$, $\mathbb{B}=[1\;1]^\top$: ahora resuelto, $\mathbb{K}=[0.5\;\;-0.5]$.
- Tercer orden $10/((s+10)(s^2+0.5s+1))$: la planta tiene %OS = 44.1 % y $t_p$ = 3.35 s; el diseño da 9.8 % y 1.05 s (el tercer polo desvía un poco) y valor final 0.029. Se explica que $\mathbb{K}$ depende de la representación (`tf2ss` frente a variables de fase).
- Acción integral: $K_e = 18\,314$ con $\omega_n^2$ sin redondear (18 310 con 183.1).
- El ejercicio de compensador completo usaba los mismos números que ahora son ejemplo del texto; se cambiaron (polos en $-3\pm 3j$ y observador en $-15$).
- Se agregaron la prueba PBH, la noción cuantitativa de controlabilidad (número de condición) y la advertencia sobre la robustez del principio de separación.

Verificado con `herramientas/cap09_numeros.py` y `verificarCap09.m` (30/30 en Octave 8.4).
