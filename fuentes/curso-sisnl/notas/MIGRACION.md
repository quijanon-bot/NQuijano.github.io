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

## Pendientes de los capítulos 1 y 2 (migrados el 10 de noviembre de 2026)

- Correr en MATLAB `crearModelo_EstructuraVariable` y `crearModelo_DiodoTunel` (Simulink no estaba disponible) y grabar, si se quiere la versión de MATLAB, los `C1_Video_*` y `C2_Video_*`; los MP4 publicados son los de `herramientas/cap01_02_videos.py`.
- Confirmar en Khalil (3.ª ed.) la sección del diodo túnel (§1.2.2) y la notación del capítulo 1.
- Verificar datos bibliográficos de Poi1881 (continuación en 1882, 1885 y 1886), And29, Duf18, San64 y Bro83 (páginas en el libro de Birkhäuser).
- Las fotos de Malthus, Verhulst, Poincaré, Lyapunov y Newton del Handout1 (y las de la colección personal) no se pasaron a las notas; si se quieren, van en `notas/figuras/cap01/` con su crédito.
- El capítulo 1 cita los capítulos 4 y 6--10 por número (aún no migrados); al migrarlos, cambiar "capítulo~7" por `\cref{cap:lyapunov}`, etc.

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
