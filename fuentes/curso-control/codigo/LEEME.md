# Códigos del curso

Ejecute una vez por sesión `iniciarCurso` (esta carpeta). Requiere Control System Toolbox; los `crearModelo_*.m` requieren Simulink.

- `comun/`: funciones de todos los capítulos (`bodeAsintotico`, `margenesTabla`, `faseEn`, `pmDeZeta`, `zetaDePM`, `zetaDeOS`, `segundoOrden`, `polosDeseados`, `variablesFase`, `tablaRouth`, `kharitonov`, `estiloFigura`, `abrirVideo`).
- `cap01_introduccion/`: scripts `C1_Ej1`–`C1_Ej3` (tanque en lazo abierto y cerrado, ascensor, prealimentación), modelo `crearModelo_TanqueLazos` y pruebas `verificarCap01`.
- `cap02_modelado_primer_orden/` y `cap03_modelado_segundo_orden/`: scripts `C2_Ej*`, `C3_Ej*`, modelos `crearModelo_*` y pruebas `verificarCap02`, `verificarCap03`.
- `cap05_estabilidad/`: scripts `C5_Ej1`–`C5_Ej7` (modos, Routh-Hurwitz, casos especiales, rango de ganancia, región de un PI, espacio de estado, Kharitonov), modelo `crearModelo_LazoPI` y pruebas `verificarCap05`.
- `cap09_retroalimentacion_estado/`: scripts `C9_Ej*`, modelos `crearModelo_RetroEstado` y `crearModelo_Observador`, pruebas `verificarCap09`.
- `cap10_respuesta_frecuencial/`: scripts por clase (`C1_*` … `C4_*`), videos (`C*_Video_*`), modelos de Simulink construidos por código (`crearModelo_*`) y pruebas (`verificarCap10`).

Convenciones: encabezado QUÉ HACE / OBSERVE / ESPERADO / EXPLORE; fragmentos para las notas entre `% [ini:nombre]` y `% [fin:nombre]`; nombres de variables según la notación del curso.

Estado de las pruebas (noviembre de 2026): `verificarCap01` pasa 17/17, `verificarCap02` 18/18, `verificarCap03` 26/26, `verificarCap05` 39/39, `verificarCap09` 30/30 y `verificarCap10` 26/26 en GNU Octave 8.4 con el paquete `control` y las funciones de reemplazo de `herramientas/octave_shims/`; los cálculos de los scripts `C*_Ej*` corren en Octave hasta las funciones exclusivas de MATLAB (`allmargin`, `pidtune`, `VideoWriter`). Los scripts que usan el *Symbolic Math Toolbox* (`syms`, `laplace`, `dsolve`, `jacobian`) y los que usan `tf2ss` no se probaron en Octave. Falta correrlos en MATLAB (en especial los videos y los `crearModelo_*`, que no se pudieron probar sin Simulink).
