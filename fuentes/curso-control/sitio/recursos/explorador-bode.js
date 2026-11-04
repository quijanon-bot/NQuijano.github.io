// Explorador de Bode del curso: sin dependencias externas (funciona sin conexión).
// Uso: <div class="explorador" id="explorador-bode"></div> + <script src=".../explorador-bode.js"></script>
(function () {
  const raiz = document.getElementById('explorador-bode');
  if (!raiz) return;
  const C = {azul: '#1E5AA8', noche: '#14213D', verde: '#2A9D8F', coral: '#D1495B', gris: '#5C677D', rejilla: '#DDE2EA'};
  // Controles: [id, etiqueta, min, max, valor, escala log?]
  const ctrls = [
    ['K', 'Ganancia K', 0.01, 1e5, 10000, true],
    ['p1', 'Polo en −p₁ (0 = no hay)', 0, 1000, 1, true],
    ['p2', 'Polo en −p₂ (0 = no hay)', 0, 1000, 10, true],
    ['p3', 'Polo en −p₃ (0 = no hay)', 0, 1000, 100, true],
    ['z1', 'Cero en −z₁ (0 = no hay)', 0, 1000, 0, true]
  ];
  const estado = {N: 0};
  let html = '<div class="exp-controles">';
  for (const [id, lab, mn, mx, v, lg] of ctrls) {
    estado[id] = v;
    const pos = lg ? aSlider(v, mn, mx) : v;
    html += `<label>${lab}<input type="range" min="0" max="1000" step="1" value="${pos}" data-id="${id}">
             <input type="number" value="${v}" data-num="${id}" step="any"></label>`;
  }
  html += `<label>Integradores (polos en 0)
     <select data-id="N"><option>0</option><option>1</option><option>2</option></select></label></div>
     <div class="exp-resumen"></div><svg class="exp-mag" viewBox="0 0 760 250"></svg><svg class="exp-fase" viewBox="0 0 760 220"></svg>
     <div class="exp-leyenda"><span style="color:${C.noche}">━ asintótico (a mano)</span>
     <span style="color:${C.verde}">╍ real</span><span style="color:${C.coral}">● cruce de fase (GM)</span></div>`;
  raiz.innerHTML = html;

  function aSlider(v, mn, mx) { // 0 -> 0; resto en escala logarítmica entre 0.01 y mx
    if (v <= 0) return 0;
    const lo = Math.log10(Math.max(mn, 0.01)), hi = Math.log10(mx);
    return Math.round(1000 * (Math.log10(v) - lo) / (hi - lo));
  }
  function deSlider(p, mn, mx) {
    if (p <= 0 && mn === 0) return 0;
    const lo = Math.log10(Math.max(mn, 0.01)), hi = Math.log10(mx);
    return +(10 ** (lo + (hi - lo) * p / 1000)).toPrecision(3);
  }
  raiz.querySelectorAll('input[type=range]').forEach(el => el.addEventListener('input', () => {
    const c = ctrls.find(x => x[0] === el.dataset.id);
    estado[c[0]] = deSlider(+el.value, c[2], c[3]);
    raiz.querySelector(`[data-num=${c[0]}]`).value = estado[c[0]];
    dibujar();
  }));
  raiz.querySelectorAll('input[type=number]').forEach(el => el.addEventListener('change', () => {
    const c = ctrls.find(x => x[0] === el.dataset.num);
    estado[c[0]] = Math.max(0, +el.value);
    raiz.querySelector(`[data-id=${c[0]}]`).value = aSlider(estado[c[0]], c[2], c[3]);
    dibujar();
  }));
  raiz.querySelector('select').addEventListener('change', e => { estado.N = +e.target.value; dibujar(); });

  const ws = []; for (let e = -2; e <= 4.0001; e += 0.004) ws.push(10 ** e);
  const deg = 180 / Math.PI;

  function calcular() {
    const polos = [estado.p1, estado.p2, estado.p3].filter(p => p > 0);
    const ceros = [estado.z1].filter(z => z > 0);
    const N = estado.N, K = estado.K;
    const real = ws.map(w => {
      let mag = K / w ** N, fase = -90 * N;
      for (const z of ceros) { mag *= Math.hypot(w, z); fase += Math.atan2(w, z) * deg; }
      for (const p of polos) { mag /= Math.hypot(w, p); fase -= Math.atan2(w, p) * deg; }
      return {w, dB: 20 * Math.log10(mag), fase};
    });
    const Kb = K * ceros.reduce((a, z) => a * z, 1) / polos.reduce((a, p) => a * p, 1);
    const q = [...ceros.map(z => [z, 1]), ...polos.map(p => [p, -1])];
    const asint = ws.map(w => {
      let dB = 20 * Math.log10(Kb) - 20 * N * Math.log10(w), fase = -90 * N;
      for (const [wb, o] of q) {
        dB += 20 * o * Math.max(0, Math.log10(w / wb));
        fase += 45 * o * Math.min(2, Math.max(0, Math.log10(w / wb) + 1));
      }
      return {w, dB, fase};
    });
    return {real, asint, Kb, N};
  }
  function cruce(arr, key, nivel) {
    for (let i = 1; i < arr.length; i++) {
      const a = arr[i - 1][key] - nivel, b = arr[i][key] - nivel;
      if (a * b <= 0 && a !== b) {
        const t = a / (a - b);
        return {w: Math.exp(Math.log(arr[i - 1].w) + t * Math.log(arr[i].w / arr[i - 1].w)), i};
      }
    }
    return null;
  }
  const pmDeZeta = z => Math.atan(2 * z / Math.sqrt(-2 * z * z + Math.sqrt(1 + 4 * z ** 4))) * deg;

  function ejes(svg, ymin, ymax, paso, etiqueta) {
    const W = 760, H = +svg.getAttribute('viewBox').split(' ')[3], L = 58, R = 12, T = 10, B = 34;
    const x = w => L + (Math.log10(w) + 2) / 6 * (W - L - R);
    const y = v => T + (ymax - v) / (ymax - ymin) * (H - T - B);
    let s = '';
    for (let e = -2; e <= 4; e++) {
      for (let m = 1; m < 10; m++) {
        const w = m * 10 ** e; if (w > 1e4) break;
        s += `<line x1="${x(w)}" x2="${x(w)}" y1="${T}" y2="${H - B}" stroke="${C.rejilla}" stroke-width="${m === 1 ? 1 : .5}"/>`;
      }
      s += `<text x="${x(10 ** e)}" y="${H - B + 16}" font-size="12" text-anchor="${e === 4 ? 'end' : 'middle'}" fill="${C.gris}">${10 ** e >= 1 ? 10 ** e : (10 ** e).toPrecision(1)}</text>`;
    }
    for (let v = Math.ceil(ymin / paso) * paso; v <= ymax; v += paso) {
      s += `<line x1="${L}" x2="${W - R}" y1="${y(v)}" y2="${y(v)}" stroke="${C.rejilla}"/>`;
      s += `<text x="${L - 6}" y="${y(v) + 4}" font-size="12" text-anchor="end" fill="${C.gris}">${v}</text>`;
    }
    s += `<text x="14" y="${(H - B) / 2 + T}" font-size="12" fill="${C.noche}" transform="rotate(-90 14 ${(H - B) / 2 + T})" text-anchor="middle">${etiqueta}</text>`;
    s += `<text x="${(W + L) / 2}" y="${H - 4}" font-size="12" fill="${C.noche}" text-anchor="middle">ω (rad/s)</text>`;
    return {s, x, y, L, R, T, B, W, H};
  }
  const linea = (arr, key, ax, col, ancho, guion) => {
    const pts = arr.map(r => `${ax.x(r.w).toFixed(1)},${ax.y(Math.max(Math.min(r[key], 1e4), -1e4)).toFixed(1)}`).join(' ');
    return `<polyline points="${pts}" fill="none" stroke="${col}" stroke-width="${ancho}" ${guion ? 'stroke-dasharray="7,5"' : ''}/>`;
  };

  function dibujar() {
    const {real, asint, Kb, N} = calcular();
    const cpm = cruce(real, 'dB', 0), cgm = cruce(real, 'fase', -180);
    const PM = cpm ? 180 + real[cpm.i].fase : null, GM = cgm ? -real[cgm.i].dB : null;
    // rangos
    const todos = real.map(r => r.dB).concat(asint.map(r => r.dB));
    let ymax = Math.min(140, Math.ceil(Math.max(...todos) / 20) * 20 + 10), ymin = Math.max(-140, ymax - 160);
    const fmin = Math.max(-360, Math.floor(Math.min(...real.map(r => r.fase), ...asint.map(r => r.fase)) / 45) * 45 - 10);
    const fmax = Math.min(180, Math.ceil(Math.max(...real.map(r => r.fase), ...asint.map(r => r.fase)) / 45) * 45 + 10);
    const m = raiz.querySelector('.exp-mag'), f = raiz.querySelector('.exp-fase');
    const am = ejes(m, ymin, ymax, 20, 'magnitud (dB)'), af = ejes(f, fmin, fmax, 45, 'fase (°)');
    let sm = am.s + `<line x1="${am.L}" x2="${am.W - am.R}" y1="${am.y(0)}" y2="${am.y(0)}" stroke="${C.gris}" stroke-width="1.4"/>`;
    sm += `<clipPath id="cm"><rect x="${am.L}" y="${am.T}" width="${am.W - am.L - am.R}" height="${am.H - am.T - am.B}"/></clipPath><g clip-path="url(#cm)">`;
    sm += linea(asint, 'dB', am, C.noche, 3) + linea(real, 'dB', am, C.verde, 2.2, true);
    if (cpm) sm += `<circle cx="${am.x(cpm.w)}" cy="${am.y(0)}" r="5" fill="${C.verde}"/>`;
    if (cgm) sm += `<line x1="${am.x(cgm.w)}" x2="${am.x(cgm.w)}" y1="${am.y(0)}" y2="${am.y(-GM)}" stroke="${C.coral}" stroke-width="3"/>`;
    m.innerHTML = sm + '</g>';
    let sf = af.s + `<line x1="${af.L}" x2="${af.W - af.R}" y1="${af.y(-180)}" y2="${af.y(-180)}" stroke="${C.gris}" stroke-width="1.4"/>`;
    sf += `<clipPath id="cf"><rect x="${af.L}" y="${af.T}" width="${af.W - af.L - af.R}" height="${af.H - af.T - af.B}"/></clipPath><g clip-path="url(#cf)">`;
    sf += linea(asint, 'fase', af, C.noche, 3) + linea(real, 'fase', af, C.verde, 2.2, true);
    if (cgm) sf += `<circle cx="${af.x(cgm.w)}" cy="${af.y(-180)}" r="5" fill="${C.coral}"/>`;
    if (cpm) sf += `<line x1="${af.x(cpm.w)}" x2="${af.x(cpm.w)}" y1="${af.y(-180)}" y2="${af.y(-180 + PM)}" stroke="${C.verde}" stroke-width="3"/>`;
    f.innerHTML = sf + '</g>';
    // resumen
    let txt = `<b>Forma de Bode:</b> K<sub>b</sub> = ${Kb.toPrecision(4)} (${(20 * Math.log10(Kb)).toFixed(1)} dB) · <b>tipo</b> ${N} · `;
    txt += `<b>PM</b> = ${PM === null ? '—' : PM.toFixed(1) + '°'}${cpm ? ` (ω<sub>PM</sub> = ${cpm.w.toPrecision(3)} rad/s)` : ''} · `;
    txt += `<b>GM</b> = ${GM === null ? '∞ (la fase no llega a −180°)' : GM.toFixed(1) + ' dB'}${cgm ? ` (ω<sub>GM</sub> = ${cgm.w.toPrecision(3)} rad/s)` : ''}<br>`;
    if ((PM !== null && PM <= 0) || (GM !== null && GM <= 0)) {
      txt += `<span style="color:${C.coral};font-weight:700">Lazo cerrado INESTABLE (fase mínima con márgenes negativos).</span>`;
    } else if (PM !== null && PM > 0 && PM < 76) {
      let z = 0.001; while (pmDeZeta(z) < PM) z += 0.0005;
      const os = 100 * Math.exp(-Math.PI * z / Math.sqrt(1 - z * z));
      txt += `Si dominara un par de polos: ζ ≈ ${z.toFixed(2)} y sobrepico ≈ ${os.toFixed(0)} %.`;
    }
    raiz.querySelector('.exp-resumen').innerHTML = txt;
  }
  dibujar();
})();
