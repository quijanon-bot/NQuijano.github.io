#!/bin/bash
# Compila figuras TikZ (notas/figuras/tikz/<nombre>.tex) -> notas/figuras/<cap>/<nombre>.pdf
# y sitio/figuras/<cap>/<nombre>.svg.   Uso: herramientas/tikz.sh cap03 dos_tanques masa_resorte ...
set -e
RAIZ=$(cd "$(dirname "$0")/.." && pwd)
CAP=$1; shift
cd "$RAIZ/notas/figuras/tikz"
mkdir -p "../$CAP" "$RAIZ/sitio/figuras/$CAP"
for f in "$@"; do
  pdflatex -interaction=nonstopmode -halt-on-error "$f.tex" > /dev/null || { echo "ERROR en $f"; tail -20 "$f.log"; exit 1; }
  mv "$f.pdf" "../$CAP/$f.pdf"
  pdftocairo -svg "../$CAP/$f.pdf" "$RAIZ/sitio/figuras/$CAP/$f.svg"
  rm -f "$f.aux" "$f.log"
  echo "  tikz: $CAP/$f"
done
