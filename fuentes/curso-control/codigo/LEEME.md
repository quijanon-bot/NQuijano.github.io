# Códigos del curso

Ejecute una vez por sesión `iniciarCurso` (esta carpeta). Requiere Control System Toolbox; los `crearModelo_*.m` requieren Simulink.

- `comun/`: funciones de todos los capítulos (`bodeAsintotico`, `margenesTabla`, `faseEn`, `pmDeZeta`, `zetaDePM`, `zetaDeOS`, `segundoOrden`, `polosDeseados`, `variablesFase`, `tablaRouth`, `kharitonov`, `constantesError`, `simularPID`, `convertirPID`, `reglasPID`, `identificarFOPDT`, `estiloFigura`, `abrirVideo`).
- `cap01_introduccion/`: scripts `C1_Ej1`–`C1_Ej3` (tanque en lazo abierto y cerrado, ascensor, prealimentación), modelo `crearModelo_TanqueLazos` y pruebas `verificarCap01`.
- `cap02_modelado_primer_orden/` y `cap03_modelado_segundo_orden/`: scripts `C2_Ej*`, `C3_Ej*`, modelos `crearModelo_*` y pruebas `verificarCap02`, `verificarCap03`.
- `cap04_espacio_estado/`: scripts `C4_Ej1`–`C4_Ej7` (masa-resorte en variables de fase, de la función de transferencia al estado, matriz de transición, del estado a la función de transferencia y cancelaciones, ciclo del carbono, Duffing y levitador, bioreactor), modelos `crearModelo_MasaResorte` y `crearModelo_Bioreactor` y pruebas `verificarCap04`.
- `cap05_estabilidad/`: scripts `C5_Ej1`–`C5_Ej8` (modos, Routh-Hurwitz, casos especiales, rango de ganancia, región de un PI, tiempo muerto con Padé, espacio de estado, Kharitonov), modelos `crearModelo_LazoPI` y `crearModelo_Retardo` y pruebas `verificarCap05`.
- `cap06_error/`: scripts `C6_Ej1`–`C6_Ej6` (tipo y constantes, retroalimentación no unitaria, perturbaciones, error en espacio de estado, atraso, sensitividad), modelo `crearModelo_Perturbacion` y pruebas `verificarCap06`. Usa `comun/constantesError`.
- `cap07_pid_nociones/`: scripts `C7_Ej1`–`C7_Ej8` (on/off, acciones P, I y D, formas ideal, paralelo y serie, filtro derivativo, *kicks*, *wind-up*, ponderación de la referencia, algoritmo digital), modelo `crearModelo_AntiWindup` y pruebas `verificarCap07`. Usa `comun/simularPID` y `comun/convertirPID`.
- `cap08_pid_sintonizacion/`: scripts `C8_Ej1`–`C8_Ej6` (identificación FOPDT, reglas de malla abierta y de malla cerrada, síntesis directa, IMC, robustez), modelo `crearModelo_IMC` y pruebas `verificarCap08`. Usa `comun/reglasPID` y `comun/identificarFOPDT`.
- `cap09_retroalimentacion_estado/`: scripts `C9_Ej*`, modelos `crearModelo_RetroEstado` y `crearModelo_Observador`, pruebas `verificarCap09`.
- `cap10_respuesta_frecuencial/`: scripts por clase (`C1_*` … `C4_*`), videos (`C*_Video_*`), modelos de Simulink construidos por código (`crearModelo_*`) y pruebas (`verificarCap10`).

Convenciones: encabezado QUÉ HACE / OBSERVE / ESPERADO / EXPLORE; fragmentos para las notas entre `% [ini:nombre]` y `% [fin:nombre]`; nombres de variables según la notación del curso.

Estado de las pruebas (noviembre de 2026): `verificarCap01` pasa 17/17, `verificarCap02` 18/18, `verificarCap03` 26/26, `verificarCap04` 38/38, `verificarCap05` 46/46, `verificarCap06` 45/45, `verificarCap07` 39/39, `verificarCap08` 67/67, `verificarCap09` 30/30 y `verificarCap10` 26/26 en GNU Octave 8.4 con el paquete `control` y las funciones de reemplazo de `herramientas/octave_shims/`; los cálculos de los scripts `C*_Ej*` corren en Octave hasta las funciones exclusivas de MATLAB (`allmargin`, `pidtune`, `VideoWriter`). Los scripts que usan el *Symbolic Math Toolbox* (`syms`, `laplace`, `dsolve`, `jacobian`) no se probaron en Octave; `tf2ss` y `ss2tf` se probaron con las funciones de reemplazo. Falta correrlos en MATLAB (en especial los videos y los `crearModelo_*`, que no se pudieron probar sin Simulink).
