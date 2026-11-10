"""Separa NotasSisNL.pdf en un PDF por capítulo (para la página de cada parte).
Uso:  python3 herramientas/pdf_por_capitulo.py notas/NotasSisNL.pdf sitio/pdf
Lee los marcadores de primer nivel ("11 Pasividad ...") y
corta desde la página de cada capítulo hasta la anterior al siguiente marcador.
"""
import os
import re
import sys
from pypdf import PdfReader, PdfWriter

NOMBRES = {3: 'cap03_preliminares', 5: 'cap05_orbitas_ciclos', 11: 'cap11_pasividad', 12: 'cap12_linealizacion'}

entrada = sys.argv[1] if len(sys.argv) > 1 else 'notas/NotasSisNL.pdf'
salida = sys.argv[2] if len(sys.argv) > 2 else 'sitio/pdf'
os.makedirs(salida, exist_ok=True)
r = PdfReader(entrada)
top = [(it.title, r.get_destination_page_number(it)) for it in r.outline if not isinstance(it, list)]
for k, (titulo, p0) in enumerate(top):
    m = re.match(r'\s*(\d+)\s', titulo)
    if not m or int(m.group(1)) not in NOMBRES:
        continue
    p1 = top[k + 1][1] if k + 1 < len(top) else len(r.pages)
    w = PdfWriter()
    for p in range(p0, p1):
        w.add_page(r.pages[p])
    w.add_metadata({'/Title': titulo.strip()})
    nombre = os.path.join(salida, NOMBRES[int(m.group(1))] + '.pdf')
    with open(nombre, 'wb') as f:
        w.write(f)
    print(f'  {nombre}: páginas {p0 + 1}-{p1}')
