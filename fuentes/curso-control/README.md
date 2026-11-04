# Análisis de Sistemas de Control — notas, códigos y sitio web

Curso IELE 2300, Departamento de Ingeniería Eléctrica y Electrónica, Universidad de los Andes. Nicanor Quijano.

Versión **piloto** (noviembre de 2026): están completos en el formato nuevo los capítulos 2 (*Modelado I: Laplace, función de transferencia y primer orden*), 3 (*Modelado II: linealización, segundo orden y diagramas de bloques*), 9 (*Retroalimentación de estado y observadores*) y 10 (*Respuesta frecuencial y diagramas de Bode*); los demás están listados en el sitio y se migran siguiendo `notas/MIGRACION.md`.

## Qué hay aquí

| Carpeta | Contenido |
|:--|:--|
| `notas/` | Las notas en LaTeX: clase `apuntescontrol.cls`, notación `notacion.sty`, `NotasControl.tex`, capítulos, figuras, bibliografía |
| `codigo/` | MATLAB y Simulink: `iniciarCurso.m`, funciones `comun/`, scripts por capítulo y `verificarCapNN.m` |
| `sitio/` | Página web (Quarto): una página por parte del curso, notación, códigos, videos, explorador de Bode |
| `herramientas/` | Python para regenerar las figuras y verificar los números (`capNN_figuras.py`, `capNN_numeros.py`), `tikz.sh` para los diagramas y `pdf_por_capitulo.py` para los PDF de cada parte |
| `.github/workflows/` | Compila el PDF y publica el sitio en GitHub Pages en cada *push* |

**Una sola fuente.** Los bloques de código de las notas y del sitio se leen directamente de `codigo/` (marcas `% [ini:nombre]` / `% [fin:nombre]`); la notación vive en `notas/notacion.sty` (y sus macros se repiten para MathJax en `sitio/recursos/macros.html`).

## Compilar en el computador

```bash
# Notas (MacTeX o TeX Live completos)
cd notas && latexmk -pdf NotasControl.tex

# Sitio web (https://quarto.org)
quarto preview sitio

# Figuras y verificación de números (Python 3 + numpy, scipy, sympy, matplotlib, control)
python3 herramientas/cap02_figuras.py   # y cap03_, cap10_
python3 herramientas/cap02_numeros.py   # y cap03_, cap10_
herramientas/tikz.sh cap03 mason_grafo  # recompilar un diagrama TikZ
```

En MATLAB: `run codigo/iniciarCurso.m` y luego `verificarCap02`, `verificarCap03`, `verificarCap09` y `verificarCap10`.

## Publicar

Estas fuentes viven en el repositorio del sitio de cursos ([quijanon-bot/NQuijano.github.io](https://github.com/quijanon-bot/NQuijano.github.io)); el sitio publicado está en `curso-control/` de la raíz y se ve en <https://quijanon-bot.github.io/NQuijano.github.io/curso-control/>.

1. Compile las notas y genere los PDF por capítulo:
   `cd notas && latexmk -pdf NotasControl.tex && cd .. && cp notas/NotasControl.pdf sitio/pdf/ && python3 herramientas/pdf_por_capitulo.py notas/NotasControl.pdf sitio/pdf`
2. Construya el sitio: `quarto render sitio`.
3. Reemplace la carpeta `curso-control/` de la raíz del repositorio con el contenido de `sitio/_site/`.
4. Videos: los `.mp4` van en `sitio/videos/` (están fuera de git en esta carpeta; la copia publicada está en `curso-control/videos/`). Faltan V10, V11 y V12: genérelos con sus scripts.
