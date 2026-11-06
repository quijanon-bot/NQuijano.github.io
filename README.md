# NQuijano.github.io

Sitio de los cursos de Nicanor Quijano (Universidad de los Andes).

| Carpeta | Qué es |
|:--|:--|
| `index.html` | Página principal, con una tarjeta por curso |
| `curso-sisnl/` | Sitio publicado de **Sistemas No Lineales** (IELE 4311), generado con Quarto. Piloto: Parte 11, pasividad |
| `curso-control/` | Sitio publicado de **Análisis de Sistemas de Control** (IELE 2300), generado con Quarto. Partes 1 a 10 (primera versión completa) |
| `fuentes/curso-control/` | Fuentes del curso de Control: notas en LaTeX, códigos MATLAB/Simulink, herramientas de verificación y sitio Quarto |
| `fuentes/curso-sisnl/` | Fuentes del curso: notas en LaTeX, códigos MATLAB/Simulink, herramientas de verificación y sitio Quarto |

## Cómo se actualiza un curso

1. Editar las fuentes en `fuentes/curso-sisnl/` (o en la copia local del computador).
2. Compilar el PDF (`cd notas && latexmk -pdf NotasSisNL.tex`) y el sitio (`quarto render sitio`).
3. Reemplazar `curso-sisnl/` con el contenido de `sitio/_site/`.

## Agregar un curso

Crear la carpeta `curso-xxx/` con su sitio publicado y agregar su tarjeta en `index.html`.
