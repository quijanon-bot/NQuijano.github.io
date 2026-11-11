#!/usr/bin/env python3
"""Genera la pestaña de publicaciones de index.html a partir de la hoja de vida.

Lee las listas `publist` de CV_NQS.tex (libros, capítulos, revistas y
congresos) y reemplaza el bloque de index.html que está entre
<!-- PUBLICACIONES:INICIO --> y <!-- PUBLICACIONES:FIN -->.

Uso:
    python3 fuentes/pagina-principal/generar_publicaciones.py RUTA/CV_NQS.tex index.html

Así la lista publicada es siempre la misma de la hoja de vida: se agrega el
artículo en el .tex, se corre este script y se hace commit de index.html.
"""
import html
import re
import sys
import urllib.parse

INICIO = "<!-- PUBLICACIONES:INICIO -->"
FIN = "<!-- PUBLICACIONES:FIN -->"

# Subsección del CV -> (id, título en la página, prefijo de la etiqueta)
SECCIONES = {
    "Books": ("books", "Books", "B"),
    "Book chapters": ("chapters", "Book chapters", "BC"),
    "Journal articles": ("journals", "Journal articles", "J"),
    "Peer-reviewed international conference proceedings":
        ("conferences", "International conference proceedings", "C"),
}

ACENTOS = {
    "'": {"a": "á", "e": "é", "i": "í", "o": "ó", "u": "ú", "A": "Á", "E": "É",
          "I": "Í", "O": "Ó", "U": "Ú", "\\i": "í", "y": "ý", "c": "ć", "n": "ń"},
    "`": {"a": "à", "e": "è", "i": "ì", "o": "ò", "u": "ù"},
    '"': {"a": "ä", "e": "ë", "i": "ï", "o": "ö", "u": "ü", "O": "Ö", "U": "Ü"},
    "~": {"n": "ñ", "N": "Ñ", "a": "ã", "o": "õ"},
    "^": {"a": "â", "e": "ê", "i": "î", "o": "ô", "u": "û"},
    "c": {"c": "ç", "C": "Ç"},
}


def quitar_comentarios(tex):
    salida = []
    for linea in tex.splitlines():
        m = re.search(r"(?<!\\)%", linea)
        salida.append(linea[: m.start()] if m else linea)
    return "\n".join(salida)


def acentos(s):
    def rep(m):
        cmd, letra = m.group(1), m.group(2) or m.group(3)
        return ACENTOS.get(cmd, {}).get(letra, letra)
    s = re.sub(r"\\([\'`\"~^])\s*(?:\{(\\?i|[A-Za-z])\}|(\\i|[A-Za-z]))", rep, s)
    s = re.sub(r"\\(c)\s*(?:\{([A-Za-z])\}|\s([A-Za-z]))", rep, s)
    return s


def tex_a_html(s):
    s = acentos(s)
    s = s.replace("\\&", "&")
    s = html.escape(s, quote=False)
    s = s.replace("\\me", "\u0001")             # se marca para ponerlo en negrita
    s = s.replace("``", "\u201c").replace("''", "\u201d")
    s = s.replace("---", "\u2014").replace("--", "\u2013")
    s = re.sub(r"\\LaTeX\b", "LaTeX", s)
    for _ in range(3):  # comandos anidados
        s = re.sub(r"\\(?:emph|textit)\{([^{}]*)\}", r"<i>\1</i>", s)
        s = re.sub(r"\\textbf\{([^{}]*)\}", r"<b>\1</b>", s)
    s = s.replace("\\,", "\u2009").replace("\\@", "")
    s = re.sub(r"\\[ \t\r\n]", " ", s)          # espacio de control "\ " (tambi\u00e9n al final de l\u00ednea)
    s = s.replace("{,}", ",")
    s = re.sub(r"(?<!\\)~", "\u00a0", s)
    s = re.sub(r"[{}]", "", s)
    s = re.sub(r"[ \t\r\n]+", " ", s).strip()   # no colapsar los espacios no separables
    # Detalles de formato que en la hoja de vida quedaron sin espacio: "A.Cadena", "vol~187", "vol.168"
    s = re.sub(r"\b([A-Z]{1,2})\.(?=[A-Z][^\W\d_])", r"\1. ", s)
    s = re.sub(r"\b(vol|art|pp)\.?\u00a0", "\\1.\u00a0", s)
    s = re.sub(r"\b(vol|art|pp)\.(?=\d)", "\\1.\u00a0", s)
    s = s.replace("\u0001", '<b class="yo">N.\u00a0Quijano</b>')
    return s


def abreviar_autores(item_html):
    """Si la lista de autores es muy larga (p. ej., NeurIPS 2025) la abrevia."""
    corte = item_html.find("\u201c")
    if corte < 0:
        return item_html
    autores, resto = item_html[:corte], item_html[corte:]
    partes = [p.strip() for p in autores.rstrip(", ").split(",") if p.strip()]
    if len(partes) <= 30:
        return item_html
    yo = next((p for p in partes if 'class="yo"' in p), None)
    corto = ", ".join(partes[:3]) + ", \u2026"
    if yo:
        corto += ", " + yo + ", \u2026"
    corto += ", " + partes[-1]
    return (f'<span title="{len(partes)} authors">{corto} '
            f'<span class="nota">({len(partes)} authors)</span></span>, ' + resto)


def anio(item_tex):
    años = re.findall(r"\b(19[89]\d|20[0-4]\d)\b", item_tex)
    return años[-1] if años else ""


def titulo(item_html):
    m = re.search("\u201c(.*?)\u201d", item_html)
    if m:
        return re.sub(r"<[^>]+>", "", m.group(1)).rstrip(",. ")
    m = re.search(r"<i>(.*?)</i>", item_html)
    return re.sub(r"<[^>]+>", "", m.group(1)) if m else ""


def leer_cv(ruta):
    tex = quitar_comentarios(open(ruta, encoding="utf-8").read())
    inicio = tex.index("\\section{Publications}")
    fin = tex.index("\\section{", inicio + 10)
    pubs = tex[inicio:fin]
    nota_nacional = re.search(
        r"\\subsection\{National conference proceedings[^}]*\}\s*\\detail\{(.*?)\}\s*$",
        pubs, re.S)
    bloques = re.findall(
        r"\\subsection\{([^}]*)\}\s*\\begin\{publist\}\{(\w+)\}(.*?)\\end\{publist\}",
        pubs, re.S)
    secciones = []
    for nombre, pref, cuerpo in bloques:
        if nombre not in SECCIONES:
            continue
        items = [i.strip() for i in re.split(r"\\item\b", cuerpo)[1:] if i.strip()]
        secciones.append((nombre, items))
    nota = tex_a_html(nota_nacional.group(1)) if nota_nacional else ""
    return secciones, nota


def generar(secciones, nota):
    total = sum(len(i) for _, i in secciones)
    out = [INICIO]
    out.append('<div class="pub-barra">')
    out.append('  <input type="search" id="pub-filtro" placeholder="Filter by title, co-author, venue or year…" aria-label="Filter publications">')
    out.append('  <div class="pub-saltos">')
    for nombre, items in secciones:
        sid, tit, _ = SECCIONES[nombre]
        out.append(f'    <a href="#pub-{sid}">{tit} <span>{len(items)}</span></a>')
    out.append('  </div>')
    out.append(f'  <p class="pub-conteo" id="pub-conteo" aria-live="polite">{total} publications listed</p>')
    out.append('</div>')
    for nombre, items in secciones:
        sid, tit, pref = SECCIONES[nombre]
        out.append(f'<h3 class="pub-sec" id="pub-{sid}">{tit}</h3>')
        out.append(f'<ol class="pubs" data-prefijo="{pref}">')
        for k, item in enumerate(items, 1):
            h = abreviar_autores(tex_a_html(item))
            t = titulo(h)
            a = anio(item)
            enlace = ""
            if t and "In preparation" not in h:
                q = urllib.parse.quote_plus(t)
                enlace = (f' <a class="scholar" href="https://scholar.google.com/scholar?q={q}" '
                          f'target="_blank" rel="noopener" title="Find on Google Scholar">Scholar ↗</a>')
            out.append(f'  <li data-anio="{a}"><span class="etiqueta">[{pref}{k}]</span> {h}{enlace}</li>')
        out.append('</ol>')
    if nota:
        out.append('<h3 class="pub-sec" id="pub-national">National conference proceedings</h3>')
        out.append(f'<p class="nota-nacional">{nota}</p>')
    out.append(FIN)
    return "\n".join(out), total


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    cv, pagina = sys.argv[1], sys.argv[2]
    secciones, nota = leer_cv(cv)
    bloque, total = generar(secciones, nota)
    texto = open(pagina, encoding="utf-8").read()
    if INICIO not in texto or FIN not in texto:
        sys.exit(f"No encontré los marcadores {INICIO} / {FIN} en {pagina}")
    nuevo = re.sub(re.escape(INICIO) + r".*?" + re.escape(FIN),
                   lambda _: bloque, texto, flags=re.S)
    open(pagina, "w", encoding="utf-8").write(nuevo)
    resumen = ", ".join(f"{SECCIONES[n][1]}: {len(i)}" for n, i in secciones)
    print(f"{total} publicaciones ({resumen})")


if __name__ == "__main__":
    main()
