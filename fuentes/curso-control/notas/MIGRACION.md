# Guía para migrar un capítulo al formato nuevo

El capítulo 10 (respuesta frecuencial) fue el piloto; los capítulos 1 (introducción), 2, 3 (Modelado I y II), 5 (estabilidad) y 9 (retroalimentación de estado) ya están migrados con el mismo esquema. Para migrar cualquier otro:

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
| Introducción | **migrado** (capítulo 1) |
| Modelado I (`Handout2_CtrlParte1`) | **migrado** (capítulo 2) |
| Modelado II (`Handout2_CtrlParte2`) | **migrado** (capítulo 3) |
| Espacio de estado (`Handout3`) | `\bar{x}` (14) → `\eq{x}`; "tiempo de asentamiento" (1) |
| Estabilidad (`Handout4`) | **migrado** (capítulo 5) |
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

## Correcciones hechas en el capítulo 1 (Introducción e historia)

- **Estructura nueva:** análisis, sistema y control (§1.1); lazo abierto y lazo cerrado con el tanque (§1.2); desempeño y diseño (§1.3); cómo plantear un problema de control, con la ducha y el tanque de almacenamiento (§1.4); historia por épocas (§1.5); mapa del curso, uso de las notas y lecciones de Bernstein (§1.6).
- **Tanque.** El ejercicio de Simulink en lazo abierto ahora compara con el lazo cerrado: $A=0.5$, $R=2$, $K_c=5$. Lluvia: 1.40 m (abierto) contra 1.036 m (cerrado); válvula obstruida: 1.20 contra 1.015; factor $1+KK_c=11$. Modelo `crearModelo_TanqueLazos.m`.
- **Terminología:** se separan *control en lazo abierto* (estrategia), *malla abierta* $G'=GH$ y *lazo abierto* $G_{OL}$; la versión anterior llamaba a $GH$ "función de transferencia en lazo abierto".
- **Historia, verificada contra fuentes** (Mayr, Bennett, Bissell 2009, IFAC, Berkeley) y con la referencia original de cada idea (Maxwell 1868, Vyshnegradskii 1876, Routh 1877, Lyapunov 1892, Hurwitz 1895, Airy 1840, Minorsky 1922, Hazen 1934, Ziegler y Nichols 1942, Ragazzini y Zadeh 1952, Kalman 1960–61, Pontryagin 1962, Bellman 1957):
  - Watt no patentó el regulador centrífugo; Thomas Mead lo patentó para molinos en 1787. Edmund Lee (1745) patentó la cola de abanico, no el regulador.
  - Se retiró "los hermanos Périer introducen en 1790 la acción integral" (no se encontró en las fuentes); la acción integral se atribuye al regulador cronométrico de los Siemens.
  - Lawrence Sperry voló en París el 18 de junio de 1914 (decía 1912).
  - Minorsky analizó la estabilidad con un modelo lineal; no usó ubicación de polos.
  - Bode: 1940–45 (decía 1934 para los márgenes). Hazen (decía "Hanzen") publicó en 1934 la teoría de servomecanismos. Se retiró que Hazen dictó el "primer curso de control en 1938" y que Brown inventó los diagramas de bloques (no verificado).
  - Foxboro *Stabilog* (decía "Stabilorg"), 1931; Taylor *pre-act*, 1935; 75 000 controladores vendidos en EE. UU. entre 1925 y 1935 y unas 600 empresas a mediados de los treinta (Bennett 1993).
  - Dantzig (decía "Danzig"), símplex en 1947. RIAS: fundado en 1955 (decía "finales de los cuarenta"). IFAC: 12 de septiembre de 1957, 18 países (decía 19). Se retiraron las cifras sin fuente sobre los pilotos automáticos alemanes.
  - Nota de Laserna: se reemplazó la "junta consultiva" (no verificada) por la reunión de Princeton (foto del archivo del IAS con Einstein, von Neumann, Morgenstern y Lefschetz) y la visita de von Neumann y Lefschetz a Bogotá en 1950.
  - Pie de la figura del analizador diferencial: es la máquina de Mánchester (1935) construida con el diseño de Bush. "Vaneevar" → Vannevar.
  - PATH: demostración del 7 de agosto de 1997, ocho autos a unos 6 m.
- Se omitió la lección de Bernstein sobre tiempo muerto (fuera del alcance del curso) y se reescribió la lista en trece puntos.
- Ascensor: $\zeta=0.6$, $\omega_n=0.8$: %OS 9.48 %, $t_p$ = 4.91 s, $t_s$ = 7.43 s.

Verificado con `herramientas/cap01_numeros.py` y `verificarCap01.m` (17/17 en Octave 8.4).

## Correcciones hechas en el capítulo 5 (Estabilidad)

- **Tiempo muerto retirado.** La sección de Padé (con el ejemplo $s+1+Ke^{-Ts}$) y los dos ejercicios de retardo salieron: el curso no cubre retardos. Se reemplazaron por un problema de ganancias negativas y Bode (Actividad 1, sección B) y uno de estabilidad local de un sistema no lineal.
- "Un sistema es estable si todos los polos **y ceros** están en el semiplano izquierdo" → solo los polos.
- Se agregó la distinción asintótica / marginal (Lyapunov) / BIBO, con el contraejemplo del polo doble en el eje y de $1/(s^2+1)$ ante $\sin t$.
- $s^3+2s^2+s+2$ estaba como ejemplo del caso 1 ($\epsilon$): la fila $s^1$ es una **fila completa** de ceros (caso 2); auxiliar $2(s^2+1)$, raíces $\pm j$.
- $s^5+7s^4+6s^3+42s^2+8s+56$ no tenía solución: auxiliar $7(s^2+2)(s^2+4)$, marginalmente estable (raíz $-7$).
- Rango de $K_c$ del lazo de tres primer orden: $-1.25<K_c<23.83$ (correcto); se agregaron $\omega_{cr}=0.2186$ rad/s, $P_{cr}=28.7$ s y la comparación con `margin` y con Ziegler-Nichols, más un ejemplo de estabilidad relativa ($s=z-0.05$: $0.266<K_c<3.33$).
- Planta inestable con compensador: $3<K<3.4891$ (correcto; el texto mostraba "$3<K<14$" como resultado intermedio sin explicar).
- PI sobre $2/(s^3+4s^2+5s+2)$: la región era correcta; se simplificó a $K_i<(1+K_c)(9-K_c)/8$ y se agregó la frecuencia sobre la frontera.
- Primer ejemplo de Kharitonov: faltaba $a_4\in[35,61]$; se terminó: tres de los cuatro polinomios son inestables y existe un caso real inestable ($r_0=1$, $r_1=4$, $r_2=6$, $r_3=20$, $q_0=5$). Se explica que los coeficientes no son independientes.
- Ejemplo de diseño robusto (figura con sensor $1/(r_3s+1)$, sin solución): Kharitonov da $-100<K<251$; con la dependencia de los coeficientes, $K<642$; con el modelo nominal, $K<1119$.
- El ejercicio de planta incierta usa otra planta ($1/(s^3+r_1s^2+r_2s+r_3)$) que la figura del ejemplo; se mantuvieron los dos y se contrastan (en el ejercicio los coeficientes sí son independientes: $-1<K<598$).
- Se agregó el resultado de Anderson, Jury y Mansour (1987): con $n=3$, 4 y 5 bastan 1, 2 y 3 polinomios.
- "Kharitanov" → Kharitonov; $C(s)/R(s)$ → $Y(s)/R(s)$; "tabla de Hurwitz" → tabla de Routh.
- **Historia**, verificada: Hurwitz publicó en 1895 en *Mathematische Annalen* (no en una revista de ingeniería en 1894; Stodola publicó en la *Schweizerische Bauzeitung* en 1893–94); el tema del premio Adams 1875–77 lo propusieron Challis, Maxwell y Stokes, y Routh lo ganó en 1877; se retiró que Stodola introdujo $\zeta$, $\omega_n$ y que citó a Routh en lugar de Hurwitz en 1899 (no se encontró en las fuentes); la anécdota del sirviente ("¡usted, señor!") se cuenta de lord Kelvin en 1845, no de Maxwell (corregida también en el capítulo 1).
- Funciones nuevas en `codigo/comun/`: `tablaRouth.m` (tabla numérica con los dos casos especiales) y `kharitonov.m`.

Verificado con `herramientas/cap05_numeros.py` y `verificarCap05.m` (39/39 en Octave 8.4).
