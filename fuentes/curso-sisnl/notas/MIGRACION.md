# Guía para migrar un capítulo al formato nuevo

El capítulo 11 (pasividad) es el piloto. El esquema es el mismo del curso de Control (`curso-control/notas/MIGRACION.md`), con tres agregados propios de un curso de matemáticas: teoremas numerados, demostraciones y trampas.

1. **Copiar** el `HandoutN.tex` (carpeta `LibroSisNL2024/Chapters`) a `notas/capitulos/NN_nombre.tex` y partirlo en `capitulos/capNN/sXX_*.tex`, una sección por archivo.
2. **Abrir el capítulo** con `\capitulo[cap:etiqueta]{Título}{cita}{autor}` (se conserva la cita literaria del handout) y un bloque `objetivos` con la ruta de su página web.
3. **Cajas.** `mybox` con `thm`/`lem`/`definition` → `teorema`, `lema`, `proposicion`, `corolario`, `definicion` (todas comparten numeración); `mybox_ej` → `ejemplo` con `\solucion`; las conclusiones plausibles pero falsas → `trampa` con `\plausible{...}` y `\correcto{...}`; las preguntas cortas → `pausa` con `\respuesta{...}`; historia → `historia`; resumen → `parallevar`.
4. **Colores sueltos.** `\textcolor{red}{...}` → `\alerta{...}`; `\textcolor{blue}{...}` → `\clave{...}`.
5. **Notación.** Sin negrillas en vectores; tiempo como primer argumento, `f(t,x,u)`; equilibrio `\eq`; invariante/variante en el tiempo (nunca autónomo); macros de `notacion.sty`.
6. **Código.** Cada `lstlisting` a un `.m` en `codigo/capNN_*/` con encabezado QUÉ HACE / OBSERVE / ESPERADO / EXPLORE y marcas `% [ini:nombre]`/`% [fin:nombre]`; en el `.tex`, `\codigorepo{ruta}{marca}{descripción}`. Simulink: un `crearModelo_*.m`. Las funciones del modelo van en archivos propios (MATLAB y Octave tratan distinto las funciones locales en scripts).
7. **Figuras.** Si sale de un cálculo, se genera con `herramientas/capNN_figuras.py` (PDF para las notas, SVG para la web). Diagramas: TikZ en `notas/figuras/tikz/` con `herramientas/tikz.sh capNN nombre`.
8. **Verificar.** Recalcular todos los números con `herramientas/capNN_numeros.py` y escribir `verificarCapNN.m`; compilar; revisar las referencias a Khalil (3.ª edición).
9. **Página web.** Copiar `sitio/partes/11-pasividad.qmd` como plantilla y agregar el capítulo a `NOMBRES` en `herramientas/pdf_por_capitulo.py`.
10. **Numeración.** Con los doce capítulos migrados ya no hace falta `\setcounter{chapter}` (queda uno antes del 12, inofensivo).

## Pendientes del capítulo 9 (migrado el 16 de noviembre de 2026)

- Fuentes: diapositivas `Present2026/Clase101926_VariantesTiempo` y su versión `StmasVariantes_Inestab2026` (exportada como `VariantesTp_Inestabilidad.pdf`), `Ecuaciones_LaTeXiT.tex` (S4.1--S50.3), el *Solucionario y guion* del 19 de octubre de 2026 (E1--E9 y el quiz de la clase $\mathcal{KL}$), `VanDerPol_Inestabilidad.pptx` y los scripts `Codigos/MATLAB_VariantesTiempo/TV01`--`TV09`, reescritos como `C9_Ej*`. `Handout6a.tex` era de preliminares matemáticos (ya cubiertos en el capítulo 3).
- Prefijo de etiquetas: `vt-`. Las funciones de comparación (`def:vt-clases`) y la caracterización $\mathcal{KL}$ (`lem:vt-kl`) viven aquí; LaSalle--Yoshizawa, Barbălat, los conversos y el ejemplo adaptativo se citan del capítulo 10 sin repetirse.
- Correcciones a las diapositivas: la cota de la estabilidad exponencial ($V\le k_2\|x\|^a$, no $\ge$), el enunciado del segundo teorema de inestabilidad ($\dot V-\lambda V\ge0$), la $\dot V$ del ejemplo del primer teorema, la cota de Cetaev ($\tfrac12$ en lugar de $\tfrac38$) y el límite $e^{-1/11}=0.913$ (el guion decía 0.914).
- Se agregaron: Floquet para la Mathieu amortiguada ($|\mu|=e^{-\pi}$), la ganancia rápida (el certificado falla y el sistema es GES, $|\mu|=e^{-\pi/5}$), la linealización no uniforme $\dot x_1=-x_1+tx_2^2$, el teorema de Matrosov (profundiza), la ecuación de Lyapunov diferencial escalar y el ejemplo $\dot x=(6t\sin t-2t)x$ (AS no US).
- Correr en MATLAB `crearModelo_MathieuAmortiguada` (Simulink no estaba disponible) y, si se quiere la versión de MATLAB, grabar los `C9_Video_*`; los MP4 publicados son los de `herramientas/cap09_videos.py`.
- Confirmar en Khalil (3.ª ed.): Def. 4.2--4.4, Lemas 4.2--4.5, Teo. 4.3 (Cetaev), 4.8--4.13, §4.5 (los ejemplos $6t\sin t$ y la ganancia variable), §4.6 (Markus--Yamabe) y §9.6 (variación lenta). En Kellett--Braun: Ej. 2.7. Los dos teoremas de inestabilidad variantes se citan de Slotine--Li sin sección: dar el número exacto.
- Verificar los datos bibliográficos nuevos: Mas49, Yos66, MaYa60, Che61 (traducción de 1961 del libro de Cetaev) y Mat62. Las referencias a "Serón, Ej. 4.2 y 4.3" se citan como `Ser00` sin número.
- El epígrafe es un fragmento de la cita de Vila-Matas de las diapositivas (recortado).

## Pendientes del capítulo 8 (migrado el 16 de noviembre de 2026)

- Fuentes: `LaSalle/LaSalle_Invarianza.tex` y `Construccion/Construccion_Lyapunov.tex` (paquetes de octubre de 2026 para Handout7, que acompañaban las láminas 97--108 de `Present2026/Lyapunov2026`), los scripts `Codigos/LaSalle/lasalle_01`--`08` y `Codigos/GradienteZubov/construccion_01`--`06`, reescritos como `C8_Ej*`. Lo que ya estaba en el capítulo 7 (Barbashin--Krasovskii, la trampa de la $V$ no radialmente no acotada, el término cruzado del péndulo, la ecuación de Lyapunov con $Q=C^\top C$ y las dos masas, la estimación cuadrática de van der Pol) se cita y no se repite: el ejemplo de observabilidad es ahora la prueba del Teorema `thm:ly-observable`, el gradiente variable *deduce* la $V$ inclinada del péndulo y Zubov numérico se compara con $c^*=2.30$.
- Prefijo de etiquetas: `iv-` (el capítulo 1 ya usa `in-`).
- Se agregaron: la proposición del estimado con $\dot V\le0$ (caso b), el problema `prob:ly-duffing` resuelto con LaSalle, el punto de vista del cilindro (con la contractibilidad de la región de atracción, Bhatia--Szegő) y la función `comun/nivelCritico.m` (y `cap08_invarianza/zubovMalla.m`).
- Las referencias "capítulo~8" de los capítulos 1, 2, 4, 5, 7 y 10 ya se cambiaron por `\cref` (a `cap:invarianza`, `thm:iv-lasalle`, `ej:iv-pendulo`, `ej:iv-lotka`, `ej:iv-observable`, `ej:iv-region`, `cor:iv-gas` o `sec:iv-gradiente`/`sec:iv-zubov`). El diagrama `t_mapa_lyapunov.tex` (TikZ independiente) sigue diciendo "capítulo 8", que es correcto.
- LaSalle--Yoshizawa se enuncia y prueba en el capítulo 10 y se usa en el 9; el capítulo 8 ya cita el 9 con `\cref{cap:variantes}`.
- Correr en MATLAB `crearModelo_AdaptativoLaSalle` (Simulink no estaba disponible) y, si se quiere la versión de MATLAB, grabar los `C8_Video_*`; los MP4 publicados son los de `herramientas/cap08_videos.py`. `C8_Video_ZubovVanDerPol` calcula una malla de $61\times61$ simulaciones: en Octave tarda más de diez minutos; en MATLAB, del orden de un minuto.
- Confirmar en Khalil (3.ª ed.): §4.2, Lema 4.1, Teorema 4.4, Corolarios 4.1 y 4.2, el número del ejemplo adaptativo (aquí "Ej. 4.9"), el ejercicio del método de Krasovskii (cap. 4) y §8.2 (Zubov). En Kellett--Braun: Ej. 2.35 (amortiguamiento cuadrático). En Slotine--Li: la ubicación del sistema del problema 8.7 (gradiente variable).
- Verificar los datos bibliográficos nuevos: ScGi62 (Trans. AIEE, Part II, vol. 81, 203--210), Par00 (tesis de Caltech) y BhSz70 (la contractibilidad de la región de atracción: dar el teorema exacto si se quiere citar).
- El epígrafe es de Borges (*Nueva refutación del tiempo*). Los paquetes de octubre no tenían epígrafe.

## Pendientes del capítulo 10 (migrado el 13 de noviembre de 2026)

- Fuentes: `AdvancedStab_Notas2026.tex` (octubre de 2026, que ya corregía Handout7 y las diapositivas), las diapositivas `Present2026/AdvancedStab_2026_v4.pptx` (epígrafe de Daniel Kehlmann; la v4 pone CLF e ISS primero y UUB en un apéndice), `Ecuaciones_LaTeXiT_AdvancedStab.tex` y los scripts `MATLAB_AdvancedStab/AS01`--`AS15`, reescritos como `C10_Ej*`. Las notas siguen el orden de los temas (UUB, conversos, CLF, Barbalat, ISS, interconexiones), no el de la v4.
- **Los teoremas conversos quedaron en este capítulo**, no en el 9 como decía la planeación anterior. `cap07/s04_directo.tex` ya cita `\cref{sec:av-conversos}`. Cuando se migre el capítulo 9, no repetirlos: citar este capítulo.
- Las funciones de comparación y la estabilidad uniforme se definen en el capítulo 9 (`def:vt-clases`, `lem:vt-kl`); §10.1 las recuerda (`def:av-comparacion` remite a `def:vt-clases`). LaSalle--Yoshizawa y Barbălat se prueban en §10.5 y el 9 los usa. Las referencias "capítulo~9" ya son `\cref`. El 8 (LaSalle) ya está migrado y se cita con `\cref` (`thm:iv-lasalle`).
- Correcciones nuevas respecto a las notas de octubre: el pico de la cascada $\dot x_1=-x_1+x_1x_2^2$ desde $(1,3)$ es $18.2=e^{4-\ln3}$ (no 18.1); con $k-L_gV$ y $w\equiv1$, $x$ se asienta en el equilibrio $0.4887$.
- Correr en MATLAB `crearModelo_RedisenoISS` (Simulink no estaba disponible; el bloque MATLAB Function de Sontag se programa por código y puede requerir ajuste) y, si se quiere la versión de MATLAB, grabar los `C10_Video_*`; los MP4 publicados son los de `herramientas/cap10_videos.py`.
- Confirmar en Khalil (3.ª ed.): Def. 4.6, Teo. 4.14, 4.16, 4.18, 4.19, Def. 4.7, Lemas 4.6, 4.7, 8.2, 9.1 y Teo. 8.4. En Kellett--Braun: ec. (2.51), Teo. 2.31, 2.32, §2.5.1, Teo. 7.4, 7.9, Ej. 9.2, ec. (9.10), §9.2 y §9.6. En Slotine--Li: Lema 4.3 y Ej. 4.13.
- Verificar los datos bibliográficos nuevos: Mas56, Bar59 (volumen y páginas) y JTP94.

## Pendientes del capítulo 6 (migrado el 13 de noviembre de 2026)

- Fuentes: Handout5.tex (2023), diapositivas `Present2026/Bifurcaciones2026.pptx` y sus complementos `Bifurcaciones2D_Complementos.pptx` (hiperbolicidad y las dos rutas, receta de cinco pasos, fantasma, interruptor genético, genericidad, Hopf completo, histéresis de ciclos), y los scripts `bif_*.m`, `BifEj*.m`, `CodigosVariosHand5.m` y `Bifurcaciones80min_LiveScript.m`, reescritos como `C6_Ej*`. Se agregaron: la proposición de la función implícita, las condiciones de la silla-nodo, la horquilla escondida (variedad central con parámetro), el coeficiente de Lyapunov con `primerLyapunov`, el retardo con rampa lenta, las bifurcaciones de período infinito y homoclínica, el teorema de la divergencia para el multiplicador y el mapa de Poincaré numérico de van der Pol (`mapaPoincare`).
- Correr en MATLAB `crearModelo_InterruptorGenetico` (Simulink no estaba disponible) y, si se quiere la versión de MATLAB, grabar los `C6_Video_*`; los MP4 publicados son los de `herramientas/cap06_videos.py`.
- Confirmar en Khalil (3.ª ed.): §2.7 (bifurcaciones, terminología segura/peligrosa). En Strogatz (2.ª ed.): §3.0--3.4, §8.4, Ejemplo 8.1.2 (interruptor genético) y Ejemplo 8.7.1 (mapa de Poincaré). En Perko (3.ª ed.): §3.4, Teorema 2 (multiplicador por la divergencia) y §4.3 (Andronov--Pontryagin y Peixoto). En Guckenheimer y Holmes: ec. (3.4.11) para $\ell_1$. En Jordan y Smith (4.ª ed.): §13.2 y la Fig. 13.2. En Sastry: cap. 7 (el ejemplo de la silla-nodo de ciclos).
- Verificar los datos bibliográficos nuevos: Poi1885, Hop42, AnPo37, Pei62, Gri68 (Strogatz cita Griffith 1971; confirmar cuál es la fuente del modelo), Kuz04, GuHo83, SBBB09, TuSh95 y JoSm07.
- La foto y el video de la viga que se pandea (Strogatz) y el video de YouTube de la lámina 3 no se pasaron a las notas.
- Los capítulos 1, 2, 4, 5 y 7 ya citan este capítulo con `\cref{cap:bifurcaciones}`.

## Pendientes del capítulo 4 (migrado el 11 de noviembre de 2026)

- Fuentes: Handout3.tex (2023), diapositivas `Present2026/SisBidim.pptx`, el cuaderno `Planos_de_fase_Python.ipynb` (clase del 19 de agosto) y los scripts `EjemploIntroSisBidim.m` y `CodigosVariosHandout3.m`, reescritos como `C4_Ej*`. Se agregaron nulclinas, la clasificación traza--determinante completa, el diodo túnel de segundo orden, las variedades estable e inestable (clase del 31 de agosto) y la no unicidad de la variedad central. Las bifurcaciones en 2-D quedan para el capítulo 6.
- Correr en MATLAB `crearModelo_DiodoTunel2D` (Simulink no estaba disponible) y, si se quiere la versión de MATLAB, grabar los `C4_Video_*`; los MP4 publicados son los de `herramientas/cap04_videos.py`. `C4_Video_TrazaDeterminante` es lento en Octave (324 cuadros); en MATLAB no debería haber problema.
- Confirmar en Khalil (3.ª ed.): §1.2.2 (diodo túnel con $L=5\,\mu$H), Teoremas 8.1, 8.2 y 8.3 (variedad central). En Perko (3.ª ed.): §1.2, §1.5, §1.9, §2.7 y §2.8.
- Verificar los datos bibliográficos nuevos: Per01, Gro59 (Doklady 128, 880--881), Har60 (Proc. AMS 11, 610--620), Har60b (Bol. Soc. Mat. Mexicana 5, 220--241), Car81, Pli64 (Izv. 28, 1297--1324) y Kel67 (JDE 3, 546--570).
- Datos biográficos de Duffing: tomados de Kovacic y Brennan (KoBr11, cap. 1). Se quitaron "Max Plank" y "la Shell"; si se quiere conservar la relación de Ossag con la Shell (Rhenania-Ossag), confirmarla en esa fuente.
- La foto de Duffing de las diapositivas no se pasó a las notas; si se quiere, va en `notas/figuras/cap04/` con su crédito.
- Los capítulos 2, 3, 5 y 7 ya citan este capítulo con `\cref{cap:bidimensionales}`.

## Correcciones del capítulo 2 respecto a Handout2, el borrador de LibroSisNL2026 y SisUniDim2026

Trasladado desde el cierre del capítulo (caja `profundiza`) el 17 de noviembre de 2026, por decisión del autor durante la auditoría. Se conserva el texto original (LaTeX):

(i) En $\dot x=\sin x$ con $x_0=\pi/4$ se afirmaba que $x(t)\to\infty$; la solución tiende a $\pi$ (\cref{tr:un-infinito}). (ii) En $\dot x=x^2-1$ se decía que una perturbación grande de $-1$ ``podría tender a $1$''; si $x_0>1$ la solución escapa en tiempo finito (\cref{ej:un-x2menos1}). (iii) La ecuación integral se escribía con $f(\tau)$ en lugar de $f(x(\tau))$. (iv) En el juego halcón--paloma se cambió la notación de los pagos ($F$ en lugar de $\omega(\bar\pi_i,p)$ y $J_1$) y se probó la invarianza por columnas, que antes se usaba sin justificar (\cref{lem:un-columnas}). (v) El tiempo de escape de $\dot x=x^2$ se llamaba \emph{finite escape time} sin decir que la solución no existe después; se aclaró que la rama de la fórmula para $t>1/x_0$ no es parte de la solución. (vi) Se agregaron la logística con cosecha y la histéresis del diodo túnel, que conectan con la silla-nodo del \cref{cap:bifurcaciones}; las bifurcaciones de las diapositivas de 2026 (silla-nodo, transcrítica, horquilla, láser) quedan para ese capítulo. (vii) El teorema de existencia y unicidad se enuncia y se demuestra en el \cref{cap:preliminares}; aquí solo se usa. (viii) Notación de \texttt{notacion.sty}: invariante en el tiempo (no autónomo), $\eq$, $\Cont1$. Todos los números se verificaron con \texttt{herramientas/cap02\_numeros.py} (42 de 42) y \cmd{verificarCap02.m} (37 de 37).

Además se quitaron del texto tres menciones a "las notas de 2024": en la trampa `tr:un-infinito` ("Así lo afirmaban las notas de 2024"), en la nota al margen de los pagos del replicador (antes $\omega(\bar\pi_i,p)$ y $J_1$) y en el `ej:un-x2menos1` ("una perturbación grande de $-1$ puede llevar al equilibrio $1$").

## Correcciones del capítulo 1 respecto a Handout1, Handout1_2026 e Intro2026

Trasladado desde el cierre del capítulo (caja `profundiza`) el 17 de noviembre de 2026, por decisión del autor durante la auditoría. Se conserva el texto original (LaTeX):

(i) En el ejemplo $\dot x=x+u^3$ con $u=-kx$ se decía que el origen quedaba ``estable pero no asintóticamente estable''. Es falso: el origen sigue siendo inestable y la solución converge a otro equilibrio, $k^{-3/2}$ (\cref{ej:in-cubico}). (ii) La tesis de Poincaré (1879) trató de ecuaciones en derivadas parciales; la clasificación de puntos singulares, el índice y los ciclos límite son de la \emph{Memoria} de 1881--1886. Nació el 29 de abril, no el 28. (iii) Duffing (1918) estudió oscilaciones forzadas con resorte cúbico; el caos en su ecuación se encontró mucho después. (iv) El criterio del círculo es de Sandberg y Zames; Popov dio en 1961 su propio criterio. (v) La dinámica cero es de Byrnes e Isidori; la ISS la introdujo Sontag en 1989, y con Wang (1995) dio sus caracterizaciones. (vi) La obra de Lyapunov se tradujo al francés 15 años después de 1892, no 25. (vii) La ecuación logística la redescubrieron Pearl y Reed en 1920; se eliminó la mención a un redescubrimiento por ``Alfred Volta''. Rousseau era amigo del padre de Malthus, no su mentor. Feigenbaum trabajó con el mapa logístico a finales de los setenta. (viii) Se corrigió la grafía de Artstein. (ix) La ley de estructura variable produce un lazo discontinuo: se agregó la advertencia sobre la noción de solución y se matizó la comparación con el PD. (x) Se quitaron los restos de la plantilla Tufte y la notación se unificó con \texttt{notacion.sty} (invariante/variante en el tiempo, $\eq$, $f(t,x,u)$). Todos los números se verificaron con \texttt{herramientas/cap01\_numeros.py} (36 de 36) y \cmd{verificarCap01.m} (34 de 34).

Además, la trampa `tr:in-cubico` decía "Así lo decían las versiones anteriores de estas notas"; se quitó la frase.

## Pendientes de los capítulos 1 y 2 (migrados el 10 de noviembre de 2026)

- Correr en MATLAB `crearModelo_EstructuraVariable` y `crearModelo_DiodoTunel` (Simulink no estaba disponible) y grabar, si se quiere la versión de MATLAB, los `C1_Video_*` y `C2_Video_*`; los MP4 publicados son los de `herramientas/cap01_02_videos.py`.
- Confirmar en Khalil (3.ª ed.) la sección del diodo túnel (§1.2.2) y la notación del capítulo 1.
- Verificar datos bibliográficos de Poi1881 (continuación en 1882, 1885 y 1886), And29, Duf18, San64 y Bro83 (páginas en el libro de Birkhäuser).
- Las fotos de Malthus, Verhulst, Poincaré, Lyapunov y Newton del Handout1 (y las de la colección personal) no se pasaron a las notas; si se quieren, van en `notas/figuras/cap01/` con su crédito.
- El capítulo 1 cita los capítulos 4, 6 y 8--10 por número (aún no migrados); al migrarlos, cambiar "capítulo~8" por `\cref{cap:invarianza}`, etc. (Las citas al capítulo 7 ya usan `\cref{cap:lyapunov}`.)

## Pendientes del capítulo 7 (migrado el 10 de noviembre de 2026)

- Fuentes: Handout7.tex (definiciones, métodos indirecto y directo, global, cuadráticas, lineales, región de atracción), diapositivas `Present2026/Lyapunov2026` y los scripts `Codigos/LyapLin/L01`--`L08` con su `GuionClase.md`, reescritos como `C7_Ej*`. LaSalle, gradiente variable, Krasovskii y Zubov quedaron en el capítulo 8 (migrado el 16 de noviembre); variantes en el tiempo, funciones de comparación, recíprocos y Chetaev, para el 9; UUB, CLF, Barbalat e ISS, para el 10. El capítulo 7 cita el 8 con `\cref` y el 9 por número ("capítulo~9"); al migrar el 9, cambiar por `\cref`.
- Correr en MATLAB `crearModelo_PenduloLyapunov` (Simulink no estaba disponible) y, si se quiere la versión de MATLAB, grabar los `C7_Video_*`; los MP4 publicados son los de `herramientas/cap07_videos.py`.
- Confirmar en Khalil (3.ª ed.): Def. 4.1, Teoremas 4.1, 4.2, 4.5, 4.6, 4.7 y 4.10, Corolario 4.3, el ejemplo de la $V$ no radialmente no acotada y el del péndulo con término cruzado (§4.1), y la estimación con bolas de van der Pol (§8.2).
- Verificar datos de Vin57 (agregada) y de Lya92 (las páginas de la traducción de 1992 son 531--773, no 531--534).
- El epígrafe del Handout7 (Le Tellier) se cambió por el de Juan Esteban Constaín que abre las diapositivas de 2026.

## Pendientes del capítulo 12 (migrado el 9 de noviembre de 2026)

- Correr en MATLAB `C12_Video_*` y `crearModelo_LevitadorFL` (los videos se probaron en Octave sin grabar; el modelo de Simulink no se pudo probar). Los scripts originales de las clases (`FL1_V*`, `FL2_V*`, carpeta `Present2026/FeedbackLinearization2026/matlab`) quedan como están.
- Confirmar en Khalil (3.ª ed.): el levitador como ejercicio del cap. 1 y sus valores numéricos, §12.2–12.3, §13.2, Lema 4.7; y en Isidori (1995): Lema 4.1.1 y Prop. 4.1.3.
- Verificar datos de Bro78 (páginas en las memorias de IFAC 1978), JaRe80 y HSM83.

## Pendientes de los capítulos 3 y 5 (migrados el 9 de noviembre de 2026)

- Correr en MATLAB `C3_Video_*`, `C5_Video_*` y `crearModelo_VanDerPol` (probados solo en Octave o sin probar), copiar los `.mp4` a `sitio/videos/` y convertir en enlaces las filas de `videos.qmd` y de las páginas 03 y 05.
- Confirmar en la 3.ª edición de Khalil: Lemas 3.1–3.4, Teoremas 3.1–3.4, Lema A.1, Teorema B.1 (cap. 3); Lema 2.1, Lema 4.1 y §2.6 (cap. 5).
- Verificar datos bibliográficos de Ray1883, Lie28 (páginas), Kur75, Lau17, CGR26 y CCGQ26.
- Los epígrafes con letras de canciones y las fotos de las diapositivas de Manuela no se pasaron a las notas (derechos de autor); se usaron epígrafes de Javier Marías y Enrique Vila-Matas.

## Pendientes del piloto

- Correr en MATLAB los `C11_Video_*` y los `crearModelo_*` (no se pudieron probar sin MATLAB/Simulink).
- Confirmar en la 3.ª edición de Khalil la numeración citada: Def. 6.1, 6.3, 6.4, 6.5; Lemas 6.1–6.4, 6.6, 6.7; Teoremas 6.1 y 6.3; §14.4.
- Verificar volumen y páginas de las entradas nuevas de `referencias.bib` (LuPo44, Pop61, Yak62 en particular).
