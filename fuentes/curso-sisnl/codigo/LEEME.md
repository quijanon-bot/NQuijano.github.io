# Códigos del curso

Ejecute una vez por sesión `iniciarCurso` (esta carpeta). Los `C*_Ej*` no requieren toolboxes y corren en GNU Octave; los `crearModelo_*.m` requieren Simulink; los `C*_Video_*` requieren VideoWriter.

- `comun/`: `estiloFigura`, `abrirVideo`, `respFrec` (G(jw) sin toolboxes), `esPR` (prueba PR/SPR del Lema 6.1 de Khalil), `balanceEnergia`.
- `cap11_pasividad/`: `C11_Ej1`…`C11_Ej14`, cinco videos `C11_Video_*`, modelos `crearModelo_LazoPasivo`, `crearModelo_Agua`, `crearModelo_Pendulo`, funciones `modeloOsciladores`, `modeloAgua`, `energiaAgua`, `energiaAguaSL`, y `verificarCap11` (39/39 en Octave 8.4).

Convenciones: encabezado QUÉ HACE / OBSERVE / ESPERADO / EXPLORE; fragmentos para las notas entre `% [ini:nombre]` y `% [fin:nombre]`.
