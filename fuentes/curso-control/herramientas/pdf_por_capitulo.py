"""Separa NotasControl.pdf en un PDF por capítulo (para la página de cada parte).
Uso:  python3 herramientas/pdf_por_capitulo.py notas/NotasControl.pdf sitio/pdf
Lee los marcadores de primer nivel ("2 Modelado I: ...", "10 Respuesta ...") y
corta desde la página de cada capítulo hasta la anterior al siguiente marcador.
"""
import os
import re
import sys
from pypdf import PdfReader, PdfWriter

NOMBRES = {1: 'cap01_introduccion', 2: 'cap02_modelado_primer_orden', 3: 'cap03_modelado_segundo_orden',
           4: 'cap04_espacio_estado', 5: 'cap05_estabilidad', 6: 'cap06_error', 7: 'cap07_pid_nociones', 8: 'cap08_pid_sintonizacion',
           9: 'cap09_retroalimentacion_estado',
           10: 'cap10_respuesta_frecuencial'}

entrada = sys.argv[1] if len(sys.argv) > 1 else 'notas/NotasControl.pdf'
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
