// Explorador de sistemas unidimensionales (parte 2). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-unidimensional"></div>
//       <script src="../recursos/explorador-unidimensional.js"></script>
// Cuatro pestañas: línea de fase (seis sistemas con un parámetro), diodo túnel e histéresis,
// halcón y paloma, escape en tiempo finito y no unicidad.
// Los modelos son los mismos de codigo/cap02_unidimensionales (C2_Ej1 ... C2_Ej9).
(function () {
  const raiz = document.getElementById('explorador-unidimensional');
  if (!raiz) return;
  const C = {azul: '#1E5AA8', noche: '#14213D', verde: '#2A9D8F', coral: '#D1495B', ambar: '#E09F3E',
             violeta: '#6C4AB6', gris: '#5C677D', rejilla: '#DDE2EA'};
  const f = (x, d = 3) => (+x.toFixed(d)).toString();

  // ---------- dibujo ----------
  function ejes(svg, W, H, m, xr, yr, xl, yl, log) {
    const lx = v => (log ? Math.log10(v) : v);
    const X = x => m.l + (lx(x) - lx(xr[0])) / (lx(xr[1]) - lx(xr[0])) * (W - m.l - m.r);
    const Y = y => H - m.b - (y - yr[0]) / (yr[1] - yr[0]) * (H - m.t - m.b);
    const paso = (a, b) => { const r = (b - a) / 5, p = 10 ** Math.floor(Math.log10(r)), n = r / p;
      return (n < 1.5 ? 1 : n < 3.5 ? 2 : n < 7.5 ? 5 : 10) * p; };
    let s = '';
    if (log) {
      for (let e = Math.ceil(Math.log10(xr[0])); e <= Math.log10(xr[1]); e++) {
        const x = 10 ** e;
        s += `<line x1="${X(x)}" x2="${X(x)}" y1="${m.t}" y2="${H - m.b}" stroke="${C.rejilla}"/>` +
             `<text x="${X(x)}" y="${H - m.b + 14}" font-size="11" text-anchor="middle" fill="${C.gris}">10^${e}</text>`;
      }
    } else {
      const dx = paso(...xr);
      for (let k = Math.ceil(xr[0] / dx); k * dx <= xr[1] + 1e-9; k++) { const x = k * dx;
        s += `<line x1="${X(x)}" x2="${X(x)}" y1="${m.t}" y2="${H - m.b}" stroke="${C.rejilla}"/>` +
             `<text x="${X(x)}" y="${H - m.b + 14}" font-size="11" text-anchor="middle" fill="${C.gris}">${+x.toPrecision(3)}</text>`; }
    }
    const dy = paso(...yr);
    for (let k = Math.ceil(yr[0] / dy); k * dy <= yr[1] + 1e-9; k++) { const y = Math.abs(k * dy) < 1e-12 ? 0 : k * dy;
      s += `<line x1="${m.l}" x2="${W - m.r}" y1="${Y(y)}" y2="${Y(y)}" stroke="${y === 0 ? C.gris : C.rejilla}"/>` +
           `<text x="${m.l - 5}" y="${Y(y) + 4}" font-size="11" text-anchor="end" fill="${C.gris}">${+y.toPrecision(3)}</text>`; }
    s += `<text x="${(W + m.l - m.r) / 2}" y="${H - 3}" font-size="12" text-anchor="middle" fill="${C.noche}">${xl}</text>` +
         `<text x="12" y="${(H - m.b + m.t) / 2}" font-size="12" text-anchor="middle" fill="${C.noche}" transform="rotate(-90 12 ${(H - m.b + m.t) / 2})">${yl}</text>`;
    svg.innerHTML = s;
    return {X, Y};
  }
  function linea(svg, pts, col, ancho = 2.2, guiones = '') {
    // los puntos no finitos (NaN) cortan la curva: así no se dibuja fuera de la ventana
    let d = '', nuevo = true;
    for (const p of pts) {
      if (!isFinite(p[0]) || !isFinite(p[1])) { nuevo = true; continue; }
      d += (nuevo ? 'M' : 'L') + p[0].toFixed(1) + ',' + p[1].toFixed(1); nuevo = false;
    }
    svg.insertAdjacentHTML('beforeend', `<path d="${d}" fill="none" stroke="${col}" stroke-width="${ancho}" stroke-dasharray="${guiones}"/>`);
  }
  const dentro = (v, lo, hi) => (v >= lo && v <= hi ? v : NaN);
  function rk4(F, x0, T, h, t0 = 0) {
    const t = [t0], X = [x0.slice()];
    let x = x0.slice(), tt = t0;
    const n = Math.round(T / h);
    for (let i = 0; i < n; i++) {
      const k1 = F(tt, x), k2 = F(tt + h / 2, x.map((v, j) => v + h / 2 * k1[j]));
      const k3 = F(tt + h / 2, x.map((v, j) => v + h / 2 * k2[j])), k4 = F(tt + h, x.map((v, j) => v + h * k3[j]));
      x = x.map((v, j) => v + h / 6 * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j]));
      tt += h; t.push(tt); X.push(x.slice());
    }
    return {t, X};
  }
  const acum = (t, s) => { const S = [0]; for (let i = 1; i < t.length; i++) S.push(S[i - 1] + 0.5 * (s[i] + s[i - 1]) * (t[i] - t[i - 1])); return S; };
  function controles(cont, lista, e, dib) {
    let html = '<div class="exp-controles">';
    for (const [id, lab, mn, mx, v, paso] of lista) {
      if (e[id] === undefined) e[id] = v;
      html += `<label>${lab}<input type="range" min="${mn}" max="${mx}" step="${paso}" value="${e[id]}" data-id="${id}">
               <input type="number" value="${e[id]}" data-num="${id}" step="${paso}" min="${mn}" max="${mx}"></label>`;
    }
    cont.insertAdjacentHTML('beforeend', html + '</div>');
    cont.querySelectorAll('input[type=range]').forEach(el => el.addEventListener('input', () => {
      e[el.dataset.id] = +el.value; cont.querySelector(`[data-num=${el.dataset.id}]`).value = el.value; dib(); }));
    cont.querySelectorAll('input[type=number]').forEach(el => el.addEventListener('change', () => {
      e[el.dataset.num] = +el.value; cont.querySelector(`[data-id=${el.dataset.num}]`).value = el.value; dib(); }));
  }
  const leyenda = items => `<div class="exp-leyenda">${items.map(([c, t]) => `<span style="color:${c}">━ ${t}</span>`).join('')}</div>`;


  function montarPestanas(pestanas) {
    raiz.innerHTML = `<div class="exp-pestanas">${pestanas.map(([id, t], i) => `<button data-p="${id}" class="${i ? '' : 'activa'}">${t}</button>`).join('')}</div>` +
      pestanas.map(([id], i) => `<div class="exp-panel" data-panel="${id}" style="display:${i ? 'none' : 'block'}"></div>`).join('');
    raiz.querySelectorAll('.exp-pestanas button').forEach(b => b.addEventListener('click', () => {
      raiz.querySelectorAll('.exp-pestanas button').forEach(x => x.classList.toggle('activa', x === b));
      raiz.querySelectorAll('.exp-panel').forEach(p => { p.style.display = p.dataset.panel === b.dataset.p ? 'block' : 'none'; });
    }));
  }
  const panel = id => raiz.querySelector(`[data-panel=${id}]`);
  // un selector (lista desplegable) que guarda su valor en e[id]
  function selector(p, id, lab, opciones, e, dib) {
    if (e[id] === undefined) e[id] = opciones[0][0];
    p.insertAdjacentHTML('beforeend', `<div class="exp-controles"><label>${lab}<select data-sel="${id}" style="width:auto">` +
      opciones.map(([v, t]) => `<option value="${v}">${t}</option>`).join('') + '</select></label></div>');
    p.querySelector(`[data-sel=${id}]`).addEventListener('change', ev => { e[id] = ev.target.value; dib(); });
  }

  // ---------- utilidades propias de la parte 2 ----------
  // Equilibrios de f en [a,b]: cambios de signo (bisección) y mínimos locales de |f| que tocan el cero.
  function equilibrios(F, a, b, n = 4000) {
    const xs = [], ys = [];
    for (let i = 0; i <= n; i++) { const x = a + (b - a) * i / n; xs.push(x); ys.push(F(x)); }
    const r = [];
    for (let i = 0; i < n; i++) {
      if (ys[i] === 0) { r.push(xs[i]); continue; }
      if (ys[i] * ys[i + 1] < 0) { let lo = xs[i], hi = xs[i + 1];
        for (let k = 0; k < 60; k++) { const m = 0.5 * (lo + hi); if (F(lo) * F(m) <= 0) hi = m; else lo = m; }
        r.push(0.5 * (lo + hi)); }
      else if (i > 0 && Math.abs(ys[i]) < Math.abs(ys[i - 1]) && Math.abs(ys[i]) < Math.abs(ys[i + 1]) &&
               Math.abs(ys[i]) < 1e-6 * (1 + Math.max(...ys.map(Math.abs)))) r.push(xs[i]);
    }
    if (Math.abs(ys[n]) < 1e-12) r.push(b);
    return r.filter((x, i) => i === 0 || Math.abs(x - r[i - 1]) > 1e-6 * (b - a));
  }
  function tipo(F, x, d) { const l = F(x - d), r = F(x + d);
    return l > 0 && r < 0 ? 'estable' : l < 0 && r > 0 ? 'inestable' : 'semiestable'; }
  // dibuja f(x) con la convención del curso: lleno estable, vacío inestable, gris semiestable; triángulos = flujo
  function lineaFase(svg, F, xr, W, H, xl, yl, eqs) {
    const xs = Array.from({length: 601}, (_, i) => xr[0] + (xr[1] - xr[0]) * i / 600), ys = xs.map(F);
    let ymax = Math.max(...ys.filter(isFinite).map(Math.abs)); ymax = ymax > 0 ? 1.12 * ymax : 1;
    const {X, Y} = ejes(svg, W, H, {l: 50, r: 12, t: 10, b: 34}, xr, [-ymax, ymax], xl, yl);
    linea(svg, xs.map((x, i) => [X(x), Y(ys[i])]), C.azul, 2.6);
    const d = 1e-4 * (xr[1] - xr[0]);
    eqs = eqs || equilibrios(F, xr[0], xr[1]);
    const b = [xr[0], ...eqs, xr[1]];
    for (let i = 0; i < b.length - 1; i++) {
      if (b[i + 1] - b[i] < 0.04 * (xr[1] - xr[0])) continue;
      const xm = 0.5 * (b[i] + b[i + 1]), s = Math.sign(F(xm)), cx = X(xm), cy = Y(0);
      if (s) svg.insertAdjacentHTML('beforeend', `<path d="M${cx - 7 * s},${cy - 6} L${cx + 7 * s},${cy} L${cx - 7 * s},${cy + 6} Z" fill="${C.azul}"/>`);
    }
    const tipos = eqs.map(x => tipo(F, x, d));
    eqs.forEach((x, i) => svg.insertAdjacentHTML('beforeend', `<circle cx="${X(x)}" cy="${Y(0)}" r="6.5" stroke="${C.noche}" stroke-width="1.6"
      fill="${tipos[i] === 'estable' ? C.noche : tipos[i] === 'inestable' ? '#fff' : '#AAAAAA'}"/>`));
    return {eqs, tipos, X, Y};
  }
  // derivada numérica
  const der = (F, x, h = 1e-6) => (F(x + h) - F(x - h)) / (2 * h);
  // integra x' = F(x) con RK4 escalar; corta si |x| > cota (escape)
  function sim1(F, x0, T, h, cota = 1e3) {
    const t = [0], x = [x0]; let y = x0, tt = 0;
    const n = Math.round(T / h);
    for (let i = 0; i < n; i++) {
      const k1 = F(y), k2 = F(y + h / 2 * k1), k3 = F(y + h / 2 * k2), k4 = F(y + h * k3);
      y = y + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4); tt += h;
      if (!isFinite(y) || Math.abs(y) > cota) return {t, x, escape: tt};
      t.push(tt); x.push(y);
    }
    return {t, x, escape: null};
  }
  const paleta = [C.azul, C.coral, C.violeta, C.ambar, C.verde, C.noche];
  const tablaEq = (eqs, tipos, F) => eqs.length ? eqs.map((x, i) =>
      `x* = ${f(x, 4)} (f′ = ${f(der(F, x), 3)}, ${tipos[i]})`).join(' · ') : 'sin equilibrios en la ventana';

  montarPestanas([['linea', 'Línea de fase'], ['diodo', 'Diodo túnel'], ['halcon', 'Halcón y paloma'], ['escape', 'Escape y unicidad']]);

  // ===== 1. Línea de fase (C2_Ej1, Ej2, Ej4) =====
  (function () {
    const p = panel('linea'), e = {};
    const sis = {
      seno:    [a => x => Math.sin(x) - a, 'sin x − a', [-7, 7], 'a', -1.5, 1.5, 0, 0.01],
      cosecha: [a => x => x * (1 - x) - a, 'x(1 − x) − h', [-0.3, 1.3], 'h', 0, 0.4, 0.2, 0.005],
      sillanodo: [a => x => a + x * x, 'r + x²', [-2.5, 2.5], 'r', -2, 1, -1, 0.01],
      cubico:  [a => x => a * x - x ** 3, 'r x − x³', [-2.5, 2.5], 'r', -2, 3, 1, 0.01],
      nohip:   [a => x => a * x ** 3, 'a x³', [-1.5, 1.5], 'a', -1, 1, -1, 0.01],
      cuad:    [a => x => x * x - a, 'x² − a', [-3, 3], 'a', -1, 4, 1, 0.01]};
    selector(p, 'sis', 'Sistema ẋ = f(x)', [['seno', 'sin x − a'], ['cosecha', 'logística con cosecha x(1−x) − h'], ['sillanodo', 'r + x² (silla-nodo)'],
      ['cubico', 'r x − x³ (horquilla)'], ['nohip', 'a x³ (no hiperbólico)'], ['cuad', 'x² − a (escape)']], e, () => dib());
    controles(p, [['a', 'parámetro', -2, 4, 0, 0.005], ['T', 'tiempo de simulación', 1, 30, 10, 0.5]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.6rem"><svg viewBox="0 0 460 300"></svg><svg viewBox="0 0 460 300"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    let ultimo = '';
    const dib = () => {
      const S = sis[e.sis];
      if (ultimo !== e.sis) { // al cambiar de sistema, ajustar el rango del parámetro
        const r = p.querySelector('[data-id=a]'), n = p.querySelector('[data-num=a]');
        r.min = n.min = S[4]; r.max = n.max = S[5]; r.step = n.step = S[7]; r.value = n.value = e.a = S[6]; ultimo = e.sis; }
      const F = S[0](e.a), xr = S[2];
      const {eqs, tipos} = lineaFase(s1, F, xr, 460, 300, 'x', 'ẋ = ' + S[1]);
      const {X, Y} = ejes(s2, 460, 300, {l: 50, r: 12, t: 10, b: 34}, [0, e.T], xr, 't', 'x(t)');
      eqs.forEach(x => linea(s2, [[X(0), Y(x)], [X(e.T), Y(x)]], C.gris, 1, '5 4'));
      const h = e.T / 1500; let esc = 0;
      for (let i = 0; i < 13; i++) { const x0 = xr[0] + (xr[1] - xr[0]) * (i + 0.5) / 13;
        const r = sim1(F, x0, e.T, h, 1e3);
        if (r.escape) esc++;
        linea(s2, r.t.map((t, j) => [X(t), Y(dentro(r.x[j], xr[0], xr[1]))]), paleta[i % 6], 1.6); }
      res_.innerHTML = `${S[3]} = ${f(e.a, 3)} · ${tablaEq(eqs, tipos, F)}` + (esc ? ` · <b style="color:${C.coral}">${esc} de 13 soluciones escapan en tiempo finito</b>` : '');
    };
    dib();
    p.insertAdjacentHTML('beforeend', leyenda([[C.noche, 'estable (lleno)'], ['#999', 'inestable (vacío) · semiestable (gris)'], [C.azul, 'sentido del flujo (triángulos)']]));
  })();

  // ===== 2. Diodo túnel (C2_Ej5, Ej6) =====
  (function () {
    const p = panel('diodo'), e = {};
    const h = v => 17.76 * v - 103.79 * v ** 2 + 229.62 * v ** 3 - 226.31 * v ** 4 + 83.72 * v ** 5;
    p.insertAdjacentHTML('beforeend', '<p>C v′ = (E − v)/R − h(v), con C = 2 pF (t en ns). Izquierda: característica del diodo y recta de carga. Derecha: la curva de equilibrios E = v + R h(v) y el valor actual de E. Busque el intervalo de E con tres equilibrios, y cambie R para hacerlo desaparecer.</p>');
    controles(p, [['E', 'E [V]', 0, 1.8, 1.2, 0.01], ['R', 'R [kΩ]', 0.3, 2.5, 1.5, 0.01]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.6rem"><svg viewBox="0 0 460 300"></svg><svg viewBox="0 0 460 300"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    const dib = () => {
      const {E, R} = e, F = v => ((E - v) / R - h(v)) / 2, vr = [-0.05, 1.2];
      const vs = Array.from({length: 501}, (_, i) => vr[0] + (vr[1] - vr[0]) * i / 500);
      const {X, Y} = ejes(s1, 460, 300, {l: 50, r: 12, t: 10, b: 34}, vr, [-0.2, 1.4], 'v [V]', 'i [mA]');
      linea(s1, vs.map(v => [X(v), Y(dentro(h(v), -0.2, 1.4))]), C.coral, 2.6);
      linea(s1, vs.map(v => [X(v), Y(dentro((E - v) / R, -0.2, 1.4))]), C.noche, 1.6, '6 4');
      const eqs = equilibrios(F, vr[0], vr[1]), tipos = eqs.map(v => tipo(F, v, 1e-5));
      eqs.forEach((v, i) => s1.insertAdjacentHTML('beforeend', `<circle cx="${X(v)}" cy="${Y(h(v))}" r="6" stroke="${C.noche}" stroke-width="1.6" fill="${tipos[i] === 'estable' ? C.noche : '#fff'}"/>`));
      const g = v => v + R * h(v);
      const B = ejes(s2, 460, 300, {l: 50, r: 12, t: 10, b: 34}, [0, 1.8], vr, 'E [V]', 'v de equilibrio [V]');
      const est = vs.map(v => 1 + R * der(h, v) > 0);
      linea(s2, vs.map((v, i) => [B.X(dentro(g(v), 0, 1.8)), est[i] ? B.Y(v) : NaN]), '#9AA6BA', 5);
      linea(s2, vs.map((v, i) => [B.X(dentro(g(v), 0, 1.8)), est[i] ? NaN : B.Y(v)]), '#9AA6BA', 1.6, '5 4');
      linea(s2, [[B.X(E), B.Y(vr[0])], [B.X(E), B.Y(vr[1])]], C.azul, 1.4);
      eqs.forEach((v, i) => s2.insertAdjacentHTML('beforeend', `<circle cx="${B.X(E)}" cy="${B.Y(v)}" r="6" stroke="${C.noche}" stroke-width="1.6" fill="${tipos[i] === 'estable' ? C.noche : '#fff'}"/>`));
      // extremos locales de g: intervalo de biestabilidad
      const ext = []; for (let i = 1; i < vs.length - 1; i++) { const a = g(vs[i]) - g(vs[i - 1]), b = g(vs[i + 1]) - g(vs[i]); if (a * b < 0) ext.push(g(vs[i])); }
      const biest = ext.length === 2 ? `tres equilibrios para ${f(Math.min(...ext), 3)} < E < ${f(Math.max(...ext), 3)} V` : '<b>sin histéresis con este R</b> (E = v + R h(v) es monótona)';
      res_.innerHTML = eqs.map((v, i) => `v* = ${f(v, 4)} V (f′ = ${f(der(F, v), 3)} ns⁻¹, ${tipos[i]})`).join(' · ') + ' · ' + biest;
    };
    dib();
  })();

  // ===== 3. Halcón y paloma (C2_Ej7) =====
  (function () {
    const p = panel('halcon'), e = {};
    p.insertAdjacentHTML('beforeend', '<p>Dinámica del replicador reducida a p₁′ = ½ p₁(1 − p₁)(v − c p₁). ¿Qué pasa cuando v &gt; c? ¿Dónde queda la raíz v/c?</p>');
    controles(p, [['v', 'valor del recurso v', 0.1, 4, 1, 0.05], ['c', 'costo de pelear c', 0.1, 4, 3, 0.05], ['T', 'tiempo', 5, 80, 40, 1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.6rem"><svg viewBox="0 0 460 300"></svg><svg viewBox="0 0 460 300"></svg></div>');
    const [s1, s2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    const dib = () => {
      const {v, c, T} = e, F = q => 0.5 * q * (1 - q) * (v - c * q);
      const eq = v < c ? [0, v / c, 1] : [0, 1];
      const {tipos} = lineaFase(s1, F, [0, 1], 460, 300, 'p₁', 'ṗ₁', eq);
      const {X, Y} = ejes(s2, 460, 300, {l: 50, r: 12, t: 10, b: 34}, [0, T], [0, 1], 't', 'p₁(t): fracción de halcones');
      [0.01, 0.1, 0.25, 0.5, 0.75, 0.9, 0.99].forEach((q0, i) => { const r = sim1(F, q0, T, T / 1500); linea(s2, r.t.map((t, j) => [X(t), Y(r.x[j])]), paleta[i % 6], 1.8); });
      res_.innerHTML = (v < c ? `v < c: mezcla estable con p₁ = v/c = ${f(v / c, 3)} (f′ = ${f(-v / 2 * (1 - v / c), 3)})` :
        `v ≥ c: la raíz v/c = ${f(v / c, 3)} está fuera de [0, 1]; la población va a “todos halcones”`) + ' · ' + eq.map((x, i) => `${f(x, 3)}: ${tipos[i]}`).join(', ');
    };
    dib();
  })();

  // ===== 4. Escape y unicidad (C2_Ej8, Ej9) =====
  (function () {
    const p = panel('escape'), e = {};
    const sis = {
      x2:   [x => x * x, 'x²', x0 => (x0 > 0 ? 1 / x0 : null)],
      x2m1: [x => x * x - 1, 'x² − 1', x0 => (x0 > 1 ? 0.5 * Math.log((x0 + 1) / (x0 - 1)) : null)],
      x3:   [x => x ** 3, 'x³', x0 => (x0 !== 0 ? 1 / (2 * x0 * x0) : null)],
      menosx3: [x => -(x ** 3), '−x³', () => null],
      raiz: [x => Math.cbrt(x), 'x^(1/3)', () => null],
      menosraiz: [x => -Math.cbrt(x), '−x^(1/3)', () => null]};
    selector(p, 'sis', 'Sistema ẋ = f(x)', [['x2', 'x²'], ['x2m1', 'x² − 1'], ['x3', 'x³'], ['menosx3', '−x³'], ['raiz', 'x^(1/3) (no Lipschitz)'], ['menosraiz', '−x^(1/3) (llega en tiempo finito)']], e, () => dib());
    controles(p, [['x0', 'x(0)', -3, 3, 1, 0.01], ['T', 'tiempo', 0.5, 10, 3, 0.1]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 760 300"></svg>');
    const svg = p.querySelector('svg'), res_ = p.querySelector('.exp-resumen');
    const dib = () => {
      const [F, nom, tesc] = sis[e.sis], r = sim1(F, e.x0, e.T, e.T / 4000, 1e3);
      const ys = r.x.filter(isFinite), lim = Math.min(20, Math.max(3, ...ys.map(Math.abs)) * 1.1);
      const {X, Y} = ejes(svg, 760, 300, {l: 50, r: 12, t: 10, b: 34}, [0, e.T], [-lim, lim], 't', 'x(t)');
      linea(svg, r.t.map((t, j) => [X(t), Y(dentro(r.x[j], -lim, lim))]), C.azul, 2.6);
      const te = tesc(e.x0);
      if (te && te < e.T) linea(svg, [[X(te), Y(-lim)], [X(te), Y(lim)]], C.coral, 1.4, '6 4');
      let txt = `ẋ = ${nom}, x(0) = ${f(e.x0, 2)} · `;
      txt += r.escape ? `<b style="color:${C.coral}">|x| supera 1000 en t = ${f(r.escape, 4)}</b>` : `x(${f(e.T, 1)}) = ${f(r.x[r.x.length - 1], 4)}`;
      if (te) txt += ` · tiempo de escape exacto: ${f(te, 4)}`;
      if (e.sis === 'raiz' && e.x0 === 0) txt += ' · <b>Runge–Kutta devuelve x ≡ 0, pero hay infinitas soluciones</b> (pruebe x(0) = 0.01)';
      if (e.sis === 'menosraiz' && e.x0 > 0) txt += ` · llega a 0 en T = 1.5 x₀^(2/3) = ${f(1.5 * e.x0 ** (2 / 3), 4)}`;
      res_.innerHTML = txt;
    };
    dib();
  })();
})();
