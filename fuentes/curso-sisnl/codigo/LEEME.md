# Códigos del curso

Ejecute una vez por sesión `iniciarCurso` (esta carpeta). Los `C*_Ej*` no requieren toolboxes y corren en GNU Octave; los `crearModelo_*.m` requieren Simulink; los `C*_Video_*` requieren VideoWriter.

- `comun/`: `estiloFigura`, `abrirVideo`, `respFrec` (G(jw) sin toolboxes), `esPR` (prueba PR/SPR del Lema 6.1 de Khalil), `balanceEnergia`.
- `cap01_introduccion/`: `C1_Ej1`…`C1_Ej9`, dos videos `C1_Video_*`, `crearModelo_EstructuraVariable` y `verificarCap01` (34/34 en Octave 8.4).
- `cap02_unidimensionales/`: `C2_Ej1`…`C2_Ej9`, dos videos `C2_Video_*`, `crearModelo_DiodoTunel`, la función `diodoTunel` y `verificarCap02` (37/37 en Octave 8.4). En `comun/`: `lineaFase` (línea de fase con la convención del curso).
- `cap03_preliminares/`: `C3_Ej1`…`C3_Ej10`, dos videos `C3_Video_*` y `verificarCap03` (33/33 en Octave 8.4).
- `cap04_bidimensionales/`: `C4_Ej1`…`C4_Ej12`, tres videos `C4_Video_*`, `crearModelo_DiodoTunel2D`, la función `variedadSilla` y `verificarCap04` (38/38 en Octave 10.3). En `comun/`: `retratoFase` (campo con flechas normalizadas, trayectorias y equilibrios) y `clasificarEquilibrio` (traza y determinante, con el sentido de giro). `C4_Ej10` y el modelo usan `diodoTunel` de `cap02_unidimensionales/`.
- `cap05_orbitas_ciclos/`: `C5_Ej1`…`C5_Ej11`, tres videos `C5_Video_*`, `crearModelo_VanDerPol`, funciones `modeloKuramoto`, `modeloNowak`, `indiceCurva` y `verificarCap05` (34/34 en Octave 8.4).
- `cap06_bifurcaciones/`: `C6_Ej1`…`C6_Ej12`, cuatro videos `C6_Video_*`, `crearModelo_InterruptorGenetico` y `verificarCap06` (42/42 en Octave 8.4). En `comun/`: `primerLyapunov` (coeficiente l1 de una Hopf, con la fórmula de Guckenheimer y Holmes y derivadas numéricas) y `mapaPoincare` (primer retorno a una sección, con un evento de ode45).
- `cap07_lyapunov/`: `C7_Ej1`…`C7_Ej10`, cuatro videos `C7_Video_*`, `crearModelo_PenduloLyapunov` y `verificarCap07` (34/34 en Octave 8.4). En `comun/`: `ecuacionLyapunov` (A'P + PA = -Q, sin toolboxes; la P del curso es `lyap(A',Q)`, no `lyap(A,Q)`).
- `cap11_pasividad/`: `C11_Ej1`…`C11_Ej14`, cinco videos `C11_Video_*`, modelos `crearModelo_LazoPasivo`, `crearModelo_Agua`, `crearModelo_Pendulo`, funciones `modeloOsciladores`, `modeloAgua`, `energiaAgua`, `energiaAguaSL`, y `verificarCap11` (39/39 en Octave 8.4).

Convenciones: encabezado QUÉ HACE / OBSERVE / ESPERADO / EXPLORE; fragmentos para las notas entre `% [ini:nombre]` y `% [fin:nombre]`.
- `cap12_linealizacion/`: `C12_Ej1`…`C12_Ej12`, cuatro videos `C12_Video_*`, `crearModelo_LevitadorFL`, funciones del levitador (`parametrosLevitador`, `modeloLevitador`, `equilibrioLevitador`, `jacobianoLevitador`, `leyExactaLevitador`) y `verificarCap12` (37/37 en Octave 8.4). En `comun/`: `ubicarPolos` (Ackermann, sin toolboxes) y `derivadaLie`.
