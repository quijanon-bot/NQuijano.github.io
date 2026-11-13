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
10. **Numeración.** En `NotasSisNL.tex`, `\setcounter{chapter}{N-1}` antes del `\input` del capítulo N mientras los anteriores no estén migrados.

## Pendientes del capítulo 10 (migrado el 13 de noviembre de 2026)

- Fuentes: `AdvancedStab_Notas2026.tex` (octubre de 2026, que ya corregía Handout7 y las diapositivas), las diapositivas `Present2026/AdvancedStab_2026_v4.pptx` (epígrafe de Daniel Kehlmann; la v4 pone CLF e ISS primero y UUB en un apéndice), `Ecuaciones_LaTeXiT_AdvancedStab.tex` y los scripts `MATLAB_AdvancedStab/AS01`--`AS15`, reescritos como `C10_Ej*`. Las notas siguen el orden de los temas (UUB, conversos, CLF, Barbalat, ISS, interconexiones), no el de la v4.
- **Los teoremas conversos quedaron en este capítulo**, no en el 9 como decía la planeación anterior. `cap07/s04_directo.tex` ya cita `\cref{sec:av-conversos}`. Cuando se migre el capítulo 9, no repetirlos: citar este capítulo.
- Funciones de comparación, estabilidad uniforme y LaSalle--Yoshizawa son del capítulo 9 (por migrar): aquí se recuerdan en §10.1 y §10.5. Al migrar el 9, cambiar "capítulo~9" por `\cref` y quitar las repeticiones que sobren. El 8 (LaSalle) se cita como "capítulo~8".
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

## Pendientes de los capítulos 1 y 2 (migrados el 10 de noviembre de 2026)

- Correr en MATLAB `crearModelo_EstructuraVariable` y `crearModelo_DiodoTunel` (Simulink no estaba disponible) y grabar, si se quiere la versión de MATLAB, los `C1_Video_*` y `C2_Video_*`; los MP4 publicados son los de `herramientas/cap01_02_videos.py`.
- Confirmar en Khalil (3.ª ed.) la sección del diodo túnel (§1.2.2) y la notación del capítulo 1.
- Verificar datos bibliográficos de Poi1881 (continuación en 1882, 1885 y 1886), And29, Duf18, San64 y Bro83 (páginas en el libro de Birkhäuser).
- Las fotos de Malthus, Verhulst, Poincaré, Lyapunov y Newton del Handout1 (y las de la colección personal) no se pasaron a las notas; si se quieren, van en `notas/figuras/cap01/` con su crédito.
- El capítulo 1 cita los capítulos 4, 6 y 8--10 por número (aún no migrados); al migrarlos, cambiar "capítulo~8" por `\cref{cap:invarianza}`, etc. (Las citas al capítulo 7 ya usan `\cref{cap:lyapunov}`.)

## Pendientes del capítulo 7 (migrado el 10 de noviembre de 2026)

- Fuentes: Handout7.tex (definiciones, métodos indirecto y directo, global, cuadráticas, lineales, región de atracción), diapositivas `Present2026/Lyapunov2026` y los scripts `Codigos/LyapLin/L01`--`L08` con su `GuionClase.md`, reescritos como `C7_Ej*`. LaSalle, gradiente variable, Krasovskii y Zubov quedan para el capítulo 8; variantes en el tiempo, funciones de comparación, recíprocos y Chetaev, para el 9; UUB, CLF, Barbalat e ISS, para el 10. El capítulo 7 los cita por número ("capítulo~8"); al migrarlos, cambiar por `\cref`.
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
