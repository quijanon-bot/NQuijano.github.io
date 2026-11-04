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

## Pendientes del piloto

- Correr en MATLAB los `C11_Video_*` y los `crearModelo_*` (no se pudieron probar sin MATLAB/Simulink).
- Confirmar en la 3.ª edición de Khalil la numeración citada: Def. 6.1, 6.3, 6.4, 6.5; Lemas 6.1–6.4, 6.6, 6.7; Teoremas 6.1 y 6.3; §14.4.
- Verificar volumen y páginas de las entradas nuevas de `referencias.bib` (LuPo44, Pop61, Yak62 en particular).
- El capítulo 2 ya está revisado en el borrador Tufte `LibroSisNL2026/capitulos/cap02_unidimensionales.tex`: su migración es casi mecánica (cambiar cajas y rutas).
