// Explorador de Routh-Hurwitz (parte 5). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-routh"></div>
//       <script src="../recursos/explorador-routh.js"></script>
// Lazo con retroalimentación unitaria y malla abierta G'(s) = K N(s)/D(s):
// ecuación característica D(s) + K N(s) = 0.
(function () {
  const raiz = document.getElementById('explorador-routh');
  if (!raiz) return;
  const C = {azul: '#1E5AA8', noche: '#14213D', verde: '#2A9D8F', coral: '#D1495B', ambar: '#E09F3E',
             violeta: '#6C4AB6', gris: '#5C677D', rejilla: '#DDE2EA'};
  const f = (x, d = 3) => (Math.abs(x) >= 1e5 || (Math.abs(x) < 1e-3 && x !== 0) ? x.toExponential(2) : (+x.toFixed(d)).toString());

  const PRESETS = [
    {nom: 'Ejemplo 5.6: Kc·0.8 / [(3s+1)(30s+1)(10s+1)]', N: [0.8], D: [900, 420, 43, 1], K: 10, Kmin: -5, Kmax: 40},
    {nom: 'Ejemplo 5.7: K(s+2)/(s+3) · 1/[(s−1)(s²+2s+2)]', N: [1, 2], D: [1, 4, 3, -2, -6], K: 3.2, Kmin: 0, Kmax: 6},
    {nom: 'Pausa 5.4: K / [s(s+1)(s+2)]', N: [1], D: [1, 3, 2, 0], K: 3, Kmin: -2, Kmax: 10},
    {nom: 'Problema 5.3: K / [(s+1)(s+3)(s+5)]', N: [1], D: [1, 9, 23, 15], K: 50, Kmin: -40, Kmax: 250},
    {nom: 'Propio (escriba N y D)', N: [1], D: [1, 2, 3, 0], K: 1, Kmin: -10, Kmax: 20},
  ];

  // ---------- polinomios ----------
  function sumar(a, b) {
    const n = Math.max(a.length, b.length), r = new Array(n).fill(0);
    a.forEach((v, i) => { r[n - a.length + i] += v; });
    b.forEach((v, i) => { r[n - b.length + i] += v; });
    while (r.length > 1 && Math.abs(r[0]) < 1e-14) r.shift();
    return r;
  }
  function raices(p) {                       // Durand-Kerner
    p = p.slice(); while (p.length > 1 && Math.abs(p[0]) < 1e-14) p.shift();
    const n = p.length - 1; if (n < 1) return [];
    const a = p.map(v => v / p[0]);
    let z = Array.from({length: n}, (_, k) => [0.4 * Math.cos(2 * Math.PI * k / n + 0.4) * (1 + Math.abs(a[n]) ** (1 / n)),
                                              0.9 * Math.sin(2 * Math.PI * k / n + 0.4) * (1 + Math.abs(a[n]) ** (1 / n))]);
    const mul = (x, y) => [x[0] * y[0] - x[1] * y[1], x[0] * y[1] + x[1] * y[0]];
    const div = (x, y) => { const d = y[0] * y[0] + y[1] * y[1] || 1e-300; return [(x[0] * y[0] + x[1] * y[1]) / d, (x[1] * y[0] - x[0] * y[1]) / d]; };
    for (let it = 0; it < 500; it++) {
      let cambio = 0;
      z = z.map((zi, i) => {
        let v = [1, 0]; for (let k = 1; k <= n; k++) v = [mul(v, zi)[0] + a[k], mul(v, zi)[1]];
        let den = [1, 0]; z.forEach((zj, j) => { if (j !== i) den = mul(den, [zi[0] - zj[0], zi[1] - zj[1]]); });
        const d = div(v, den); cambio = Math.max(cambio, Math.hypot(...d));
        return [zi[0] - d[0], zi[1] - d[1]];
      });
      if (cambio < 1e-12) break;
    }
    return z;
  }
  function routh(p, eps = 1e-6) {
    const n = p.length - 1, ancho = Math.ceil((n + 1) / 2), T = [], notas = [];
    const fila = k => { const r = new Array(ancho).fill(0); p.filter((_, i) => i % 2 === k).forEach((v, i) => { r[i] = v; }); return r; };
    T.push(fila(0)); T.push(fila(1));
    const tol = 1e-10 * Math.max(1, ...p.map(Math.abs));
    for (let i = 1; i <= n; i++) {
      if (i > 1) {
        const a = T[i - 2], b = T[i - 1], r = new Array(ancho).fill(0);
        for (let k = 0; k < ancho - 1; k++) r[k] = (b[0] * a[k + 1] - a[0] * b[k + 1]) / b[0];
        T.push(r);
      }
      if (i < n && T[i].every(v => Math.abs(v) < tol)) {
        const orden = n - i + 1;
        T[i] = T[i - 1].map((v, k) => v * (orden - 2 * k));
        notas.push(`fila s^${n - i} de ceros → derivada del auxiliar (grado ${orden})`);
      }
      if (i < n && Math.abs(T[i][0]) < tol) { T[i][0] = eps; notas.push(`cero en la primera columna de s^${n - i} → ε`); }
    }
    let cambios = 0;
    for (let i = 0; i < T.length - 1; i++) if (Math.sign(T[i][0]) * Math.sign(T[i + 1][0]) < 0) cambios++;
    return {T, cambios, notas};
  }
  const texto = p => {
    const n = p.length - 1;
    return p.map((c, i) => {
      if (Math.abs(c) < 1e-12) return '';
      const g = n - i, s = c < 0 ? ' − ' : ' + ', v = Math.abs(c);
      const coef = (v === 1 && g > 0) ? '' : f(v);
      return s + coef + (g > 1 ? `s<sup>${g}</sup>` : g === 1 ? 's' : '');
    }).join('').replace(/^ \+ /, '').replace(/^ − /, '−') || '0';
  };
  const leer = s => s.split(/[ ,;]+/).filter(x => x.length).map(Number).filter(x => !isNaN(x));

  // ---------- interfaz ----------
  const e = {preset: 0, K: PRESETS[0].K};
  raiz.innerHTML = `
    <div class="exp-controles">
      <label>Lazo <select data-id="preset" style="width:auto">${PRESETS.map((p, i) => `<option value="${i}">${p.nom}</option>`).join('')}</select></label>
    </div>
    <div class="exp-controles exp-propio" style="display:none">
      <label>N(s): coeficientes <input type="text" data-txt="N" value="1" style="width:9rem"></label>
      <label>D(s): coeficientes <input type="text" data-txt="D" value="1 2 3 0" style="width:9rem"></label>
    </div>
    <div class="exp-controles"><label>Ganancia K <input type="range" data-id="K" step="any">
      <input type="number" data-num="K" step="any"></label></div>
    <div class="exp-resumen"></div>
    <div style="display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:.8rem;align-items:start">
      <div class="exp-tabla" style="overflow-x:auto;font-family:var(--bs-font-monospace,monospace);font-size:.85rem"></div>
      <svg viewBox="0 0 380 300"></svg>
    </div>
    <div class="exp-leyenda"><span style="color:${C.azul}">× polos del lazo cerrado</span><span style="color:${C.coral}">semiplano derecho</span>
      <span style="color:${C.verde}">rango estable de K (barrido numérico)</span></div>`;
  const sel = raiz.querySelector('select'), rng = raiz.querySelector('input[type=range]'), num = raiz.querySelector('input[type=number]');
  const propio = raiz.querySelector('.exp-propio'), res = raiz.querySelector('.exp-resumen'), tab = raiz.querySelector('.exp-tabla');
  const svg = raiz.querySelector('svg');

  function datos() {
    const P = PRESETS[e.preset];
    if (e.preset === PRESETS.length - 1) {
      const N = leer(raiz.querySelector('[data-txt=N]').value), D = leer(raiz.querySelector('[data-txt=D]').value);
      return {N: N.length ? N : [1], D: D.length ? D : [1, 1], Kmin: P.Kmin, Kmax: P.Kmax};
    }
    return P;
  }
  function rangoEstable(N, D, Kmin, Kmax) {
    const M = 1200, est = [];
    for (let i = 0; i <= M; i++) {
      const K = Kmin + (Kmax - Kmin) * i / M;
      const r = raices(sumar(D, N.map(v => v * K)));
      est.push([K, r.length > 0 && r.every(z => z[0] < -1e-9)]);
    }
    const estable = K => { const r = raices(sumar(D, N.map(v => v * K))); return r.length > 0 && r.every(z => z[0] < -1e-9); };
    const borde = (a, b) => { const sa = estable(a); for (let k = 0; k < 40; k++) { const c = (a + b) / 2; if (estable(c) === sa) a = c; else b = c; } return (a + b) / 2; };
    const tramos = []; let ini = null;
    est.forEach(([K, ok], i) => {
      if (ok && ini === null) ini = i > 0 ? borde(est[i - 1][0], K) : K;
      if ((!ok || i === M) && ini !== null) { tramos.push([ini, ok ? K : borde(est[i - 1][0], K)]); ini = null; }
    });
    return tramos;
  }
  function ajustarDeslizador() {
    const P = datos();
    rng.min = P.Kmin; rng.max = P.Kmax; rng.step = (P.Kmax - P.Kmin) / 1000;
    rng.value = e.K; num.value = e.K;
  }
  function dibujar() {
    const {N, D, Kmin, Kmax} = datos();
    const p = sumar(D, N.map(v => v * e.K));
    const {T, cambios, notas} = routh(p);
    const r = raices(p);
    const tramos = rangoEstable(N, D, Kmin, Kmax);
    const n = p.length - 1;
    const maxRe = r.length ? Math.max(...r.map(z => z[0])) : -1;
    const estado = r.some(z => z[0] > 1e-7) ? `<b style="color:${C.coral}">inestable</b>` :
                   r.some(z => Math.abs(z[0]) <= 1e-7) ? `<b style="color:${C.ambar}">en el límite (polos en el eje)</b>` :
                   `<b style="color:${C.verde}">asintóticamente estable</b>`;
    res.innerHTML = `Ecuación característica: ${texto(p)} = 0 &nbsp;·&nbsp; cambios de signo: <b>${cambios}</b> &nbsp;·&nbsp; ${estado}` +
      `<br><span style="color:${C.verde}">Rango estable en [${f(Kmin)}, ${f(Kmax)}]: ${tramos.length ? tramos.map(t => `${f(t[0])} &lt; K &lt; ${f(t[1])}`).join(' y ') : 'ninguno'}</span>` +
      (notas.length ? `<br><span style="color:${C.violeta}">${notas.join(' · ')}</span>` : '');
    let h = '<table style="border-collapse:collapse">';
    T.forEach((row, i) => {
      const col = Math.sign(row[0]) < 0 ? C.coral : C.noche;
      h += `<tr><td style="padding:2px 8px;border-right:1px solid ${C.gris};color:${C.gris}">s<sup>${n - i}</sup></td>` +
        row.map((v, k) => `<td style="padding:2px 8px;text-align:right;${k === 0 ? `color:${col};font-weight:bold` : ''}">${(k > 0 && v === 0 && i > 1) ? '' : f(v)}</td>`).join('') + '</tr>';
    });
    tab.innerHTML = h + '</table>';
    // plano s
    const W = 380, H = 300, m = 28;
    const R = Math.max(1, ...r.map(z => Math.max(Math.abs(z[0]), Math.abs(z[1])))) * 1.15;
    const X = x => W / 2 + x / R * (W / 2 - m), Y = y => H / 2 - y / R * (H / 2 - m);
    let s = `<rect x="${X(0)}" y="${m / 2}" width="${W - X(0) - m / 2}" height="${H - m}" fill="${C.coral}" opacity="0.08"/>` +
      `<line x1="${m / 2}" x2="${W - m / 2}" y1="${Y(0)}" y2="${Y(0)}" stroke="${C.gris}"/>` +
      `<line x1="${X(0)}" x2="${X(0)}" y1="${m / 2}" y2="${H - m / 2}" stroke="${C.gris}"/>` +
      `<text x="${W - m}" y="${Y(0) - 6}" font-size="12" fill="${C.noche}">σ</text><text x="${X(0) + 6}" y="${m}" font-size="12" fill="${C.noche}">jω</text>` +
      `<text x="${m / 2}" y="${H - 6}" font-size="11" fill="${C.gris}">escala: ±${f(R, 2)}</text>`;
    r.forEach(z => { const x = X(z[0]), y = Y(z[1]), c = z[0] > 1e-7 ? C.coral : C.azul;
      s += `<path d="M${x - 6},${y - 6}L${x + 6},${y + 6}M${x - 6},${y + 6}L${x + 6},${y - 6}" stroke="${c}" stroke-width="2.5"/>`; });
    svg.innerHTML = s;
  }
  sel.addEventListener('change', () => { e.preset = +sel.value; e.K = PRESETS[e.preset].K;
    propio.style.display = e.preset === PRESETS.length - 1 ? '' : 'none'; ajustarDeslizador(); dibujar(); });
  rng.addEventListener('input', () => { e.K = +rng.value; num.value = (+rng.value).toPrecision(4); dibujar(); });
  num.addEventListener('change', () => { e.K = +num.value; rng.value = num.value; dibujar(); });
  raiz.querySelectorAll('[data-txt]').forEach(el => el.addEventListener('change', dibujar));
  ajustarDeslizador(); dibujar();
})();
