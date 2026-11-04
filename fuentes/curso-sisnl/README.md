# Sistemas No Lineales — notas, códigos y sitio web

Curso IELE 4311, Departamento de Ingeniería Eléctrica y Electrónica, Universidad de los Andes. Nicanor Quijano.

Versión **piloto** (noviembre de 2026), con el mismo esquema del repositorio del curso de Control (`curso-control`). Está completo en el formato nuevo el capítulo 11 (*Pasividad y disipatividad*); los demás están listados en el sitio y se migran siguiendo `notas/MIGRACION.md`.

## Qué hay aquí

| Carpeta | Contenido |
|:--|:--|
| `notas/` | Las notas en LaTeX: clase `apuntessisnl.cls` (derivada de `apuntescontrol.cls`), notación `notacion.sty`, `NotasSisNL.tex`, capítulos partidos en secciones, figuras, bibliografía |
| `codigo/` | MATLAB y Simulink: `iniciarCurso.m`, funciones `comun/`, scripts por capítulo (`C11_Ej*`, `C11_Video_*`), modelos de Simulink construidos por código (`crearModelo_*`) y `verificarCap11.m` |
| `sitio/` | Página web (Quarto): una página por parte del curso, notación, códigos, videos y el explorador interactivo de pasividad |
| `herramientas/` | Python para regenerar las figuras y verificar los números (`cap11_figuras.py`, `cap11_numeros.py`), `tikz.sh` para los diagramas y `pdf_por_capitulo.py` para los PDF de cada parte |
| `.github/workflows/` | Compila el PDF y publica el sitio en GitHub Pages en cada *push* |

**Una sola fuente.** Los bloques de código de las notas y del sitio se leen directamente de `codigo/` (marcas `% [ini:nombre]` / `% [fin:nombre]`); la notación vive en `notas/notacion.sty` (y sus macros se repiten para MathJax en `sitio/recursos/macros.html`).

## Compilar en el computador

```bash
# Notas (MacTeX o TeX Live completos)
cd notas && latexmk -pdf NotasSisNL.tex

# Sitio web (https://quarto.org)
quarto preview sitio

# Figuras y verificación de números (Python 3 + numpy, scipy, sympy, matplotlib)
python3 herramientas/cap11_figuras.py
python3 herramientas/cap11_numeros.py      # 72 verificaciones
herramientas/tikz.sh cap11 t_feedback      # recompilar un diagrama TikZ
```

En MATLAB: `run codigo/iniciarCurso.m` y luego `verificarCap11` (39 verificaciones).

## Estado de las pruebas (4 de noviembre de 2026)

- `herramientas/cap11_numeros.py`: 72/72.
- `verificarCap11.m`: 39/39 en GNU Octave 8.4. Los catorce `C11_Ej*` corren en Octave sin errores.
- **Falta correr en MATLAB:** los cinco `C11_Video_*` (VideoWriter) y los tres `crearModelo_*` (Simulink no estaba disponible). Cada `crearModelo_*` simula al final y compara con `ode45`: si algo falla, el mensaje dice qué bloque.
- Las figuras de las notas se generan con Python (`cap11_figuras.py`) con los mismos modelos que los scripts de MATLAB.

## Publicar en GitHub Pages

1. Cree un repositorio (por ejemplo `curso-sisnl`) y suba esta carpeta.
2. Reemplace `USUARIO` por su usuario de GitHub en `notas/NotasSisNL.tex` (`\definirsitio`), `sitio/_quarto.yml` y las páginas de `sitio/`:
   `grep -rl USUARIO . | xargs sed -i '' 's/USUARIO/su-usuario/g'` (macOS).
3. En *Settings → Pages*, elija **GitHub Actions** como fuente. Cada *push* a `main` compila el PDF y publica el sitio.
4. Videos: ejecute los `C11_Video_*.m` y copie los `.mp4` a `sitio/videos/` (o súbalos a YouTube y cambie los enlaces en `sitio/videos.qmd`).
