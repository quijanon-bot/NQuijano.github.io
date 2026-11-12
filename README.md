# NQuijano.github.io

Página académica de Nicanor Quijano (Universidad de los Andes) y sitios de sus cursos.

| Carpeta | Qué es |
|:--|:--|
| `index.html` | Página principal (en inglés): información general y pestañas *Courses*, *Research*, *Publications* y *Miscellaneous* |
| `assets/` | Foto y demás imágenes de la página principal |
| `curso-sisnl/` | Sitio publicado de **Sistemas No Lineales** (IELE 4311), generado con Quarto. Piloto: Parte 11, pasividad |
| `curso-control/` | Sitio publicado de **Análisis de Sistemas de Control** (IELE 2300), generado con Quarto. Partes 1 a 10 (primera versión completa) |
| `fuentes/curso-control/` | Fuentes del curso de Control: notas en LaTeX, códigos MATLAB/Simulink, herramientas de verificación y sitio Quarto |
| `fuentes/pagina-principal/` | `generar_publicaciones.py`: genera la pestaña *Publications* a partir de `CV_NQS.tex` |
| `fuentes/curso-sisnl/` | Fuentes del curso: notas en LaTeX, códigos MATLAB/Simulink, herramientas de verificación y sitio Quarto |

## Cómo se actualiza un curso

1. Editar las fuentes en `fuentes/curso-sisnl/` (o en la copia local del computador).
2. Compilar el PDF (`cd notas && latexmk -pdf NotasSisNL.tex`) y el sitio (`quarto render sitio`).
3. Reemplazar `curso-sisnl/` con el contenido de `sitio/_site/`.

## Agregar un curso

Crear la carpeta `curso-xxx/` con su sitio publicado y agregar su tarjeta en `index.html`.

## Cómo se actualizan las publicaciones

La pestaña *Publications* se genera desde la hoja de vida, para que las dos listas sean siempre iguales:

1. Agregar el artículo en `CV_NQS.tex` (listas `publist`: libros, capítulos, revistas y congresos).
2. Correr `python3 fuentes/pagina-principal/generar_publicaciones.py RUTA/CV_NQS.tex index.html`.
3. Hacer commit de `index.html`.

### Enlaces y carátulas

`fuentes/pagina-principal/enlaces.json` asocia el título de una publicación con su enlace (DOI, página de la editorial o PDF) y, si se quiere, con una carátula guardada en `assets/`. Las publicaciones que aparecen ahí quedan con el título subrayado y enlazado; las que tienen `"portada"` muestran la carátula al lado. Ejemplo:

```json
{"titulo": "Título exacto como en la hoja de vida", "url": "https://doi.org/10.xxxx/yyyy"}
```

El generador aplica estos enlaces cada vez que corre. Para aplicarlos sin la hoja de vida: `python3 fuentes/pagina-principal/generar_publicaciones.py --enlaces index.html`.

El resto de la página principal (formación, cargos, premios, proyectos, charlas) se edita directamente en `index.html`.
