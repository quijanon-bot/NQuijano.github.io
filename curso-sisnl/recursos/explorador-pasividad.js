// Explorador de pasividad (parte 11). Sin dependencias.
// Uso:  <div class="explorador" id="explorador-pasividad"></div>
//       <script src="../recursos/explorador-pasividad.js"></script>
// Cuatro pestañas: balance de energía, PR/SPR, interconexión y distribución de agua.
// Los modelos son los mismos de codigo/cap11_pasividad (C11_Ej1, Ej8, Ej10, Ej13).
(function () {
  const raiz = document.getElementById('explorador-pasividad');
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

  // ---------- pestañas ----------
  const pestanas = [['balance', 'Balance de energía'], ['pr', 'PR y SPR'], ['lazo', 'Interconexión'], ['agua', 'Distribución de agua']];
  raiz.innerHTML = `<div class="exp-pestanas">${pestanas.map(([id, t], i) => `<button data-p="${id}" class="${i ? '' : 'activa'}">${t}</button>`).join('')}</div>` +
    pestanas.map(([id], i) => `<div class="exp-panel" data-panel="${id}" style="display:${i ? 'none' : 'block'}"></div>`).join('');
  raiz.querySelectorAll('.exp-pestanas button').forEach(b => b.addEventListener('click', () => {
    raiz.querySelectorAll('.exp-pestanas button').forEach(x => x.classList.toggle('activa', x === b));
    raiz.querySelectorAll('.exp-panel').forEach(p => { p.style.display = p.dataset.panel === b.dataset.p ? 'block' : 'none'; });
  }));
  const panel = id => raiz.querySelector(`[data-panel=${id}]`);

  // ===== 1. Balance de energía: masa con resorte duro (C11_Ej1) =====
  (function () {
    const p = panel('balance'), e = {};
    const dib = () => {
      const {delta, A, w, Tu} = e;
      const u = t => (t < Tu ? A * Math.sin(w * t) : 0);
      const {t, X} = rk4((t, x) => [x[1], -(x[0] + x[0] ** 3) - delta * x[1] + u(t)], [0, 0], 30, 0.01);
      const y = X.map(x => x[1]), V = X.map(x => x[0] ** 2 / 2 + x[0] ** 4 / 4 + x[1] ** 2 / 2);
      const S = acum(t, t.map((tt, i) => u(tt) * y[i])), D = acum(t, y.map(v => delta * v * v));
      const res = Math.max(...V.map((v, i) => Math.abs(v - V[0] - S[i] + D[i])));
      const ymax = Math.max(...S, ...V, ...D.map(Math.abs), 0.1) * 1.1, ymin = Math.min(0, ...D, ...S) * 1.1;
      const {X: PX, Y: PY} = ejes(svg, 760, 300, {l: 52, r: 14, t: 12, b: 34}, [0, 30], [ymin, ymax], 't (s)', 'energía');
      svg.insertAdjacentHTML('beforeend', `<rect x="${PX(0)}" y="12" width="${PX(Math.min(Tu, 30)) - PX(0)}" height="254" fill="${C.ambar}" opacity=".08"/>`);
      linea(svg, t.map((tt, i) => [PX(tt), PY(S[i])]), C.verde);
      linea(svg, t.map((tt, i) => [PX(tt), PY(D[i])]), C.violeta);
      linea(svg, t.map((tt, i) => [PX(tt), PY(V[i])]), C.noche, 3);
      const k = Math.min(Math.round(Tu / 0.01), t.length - 1);
      res_.innerHTML = `<b>V̇ = −δy² + u y</b> · en t = ${f(Tu, 1)} s: suministrada ${f(S[k])}, disipada ${f(D[k])}, almacenada ${f(V[k])} ·
        V(30) = ${f(V[V.length - 1], 4)} · residuo máx. del balance ${res.toExponential(1)}` +
        (delta < 0 ? ' · <b style="color:#D1495B">δ &lt; 0: el sistema crea energía (no es pasivo)</b>' : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>Masa con resorte duro, <i>F(x₁) = x₁ + x₁³</i>, fricción δ y fuerza <i>u = A sin(ωt)</i> mientras t &lt; T<sub>u</sub>. Lo almacenado es siempre lo suministrado menos lo disipado. Pruebe δ negativo.</p>');
    controles(p, [['delta', 'Fricción δ', -0.1, 1, 0.3, 0.01], ['A', 'Amplitud A', 0, 2, 0.8, 0.05],
                  ['w', 'Frecuencia ω (rad/s)', 0.2, 4, 1.2, 0.05], ['Tu', 'Fuerza hasta T_u (s)', 0, 30, 12, 0.5]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 760 300"></svg>' +
      leyenda([[C.verde, 'suministrada ∫u y'], [C.violeta, 'disipada ∫δy²'], [C.noche, 'almacenada V']]));
    const svg = p.querySelector('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 2. PR / SPR: familia G_z (C11_Ej8) =====
  (function () {
    const p = panel('pr'), e = {};
    const dib = () => {
      const {z, a, b} = e;
      const G = w => { const nr = z, ni = w, dr = b - w * w, di = a * w, d2 = dr * dr + di * di;
        return [(nr * dr + ni * di) / d2, (ni * dr - nr * di) / d2]; };
      const ws = Array.from({length: 1200}, (_, i) => 10 ** (-3 + 6.5 * i / 1199));
      const g = ws.map(G);
      const minRe = Math.min(...g.map(v => v[0]));
      let ver, col;
      const disc = a * a - 4 * b;
      if (minRe < -1e-9) { ver = 'no PR (Re G(jω) < 0 para algún ω)'; col = C.coral; }
      else if (a - z > 1e-9) { ver = 'SPR'; col = C.verde; }
      else { ver = 'PR, no SPR (ω² Re G → 0)'; col = C.ambar; }
      if (Math.abs(z * z - a * z + b) < 1e-6) ver += ' · ¡ojo! cancelación polo–cero: la prueba supone realización mínima';
      const {X, Y} = ejes(svg1, 370, 300, {l: 48, r: 10, t: 12, b: 34}, [-0.15, 0.4], [-0.3, 0.1], 'Re G(jω)', 'Im G(jω)');
      svg1.insertAdjacentHTML('beforeend', `<rect x="${X(-0.15)}" y="12" width="${X(0) - X(-0.15)}" height="254" fill="${C.coral}" opacity=".06"/>`);
      linea(svg1, g.map(v => [X(dentro(v[0], -0.15, 0.4)), Y(dentro(v[1], -0.3, 0.1))]), col, 2.6);
      const ys = ws.map((w, i) => w * w * g[i][0]);
      const lim = Math.max(3, Math.abs(a - z) * 1.4);
      const {X: X2, Y: Y2} = ejes(svg2, 370, 300, {l: 48, r: 10, t: 12, b: 34}, [1e-3, 10 ** 3.5], [-lim, lim], 'ω (rad/s)', 'ω² Re G(jω)', true);
      linea(svg2, ws.map((w, i) => [X2(w), Y2(dentro(ys[i], -lim, lim))]), col, 2.6);
      linea(svg2, [[X2(1e-3), Y2(a - z)], [X2(10 ** 3.5), Y2(a - z)]], col, 1.2, '4 4');
      res_.innerHTML = `<b>G(s) = (s + ${f(z, 2)})/(s² + ${f(a, 2)}s + ${f(b, 2)})</b> · min Re G(jω) = ${minRe.toExponential(2)} ·
        ω² Re G → a − z = ${f(a - z, 2)} · <b style="color:${col}">${ver}</b>` +
        (disc < 0 ? ' · polos complejos' : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>Familia <i>G<sub>z</sub>(s) = (s+z)/(s²+as+b)</i> del handout (§11.7). Mire <b>por dónde llega</b> la curva de Nyquist al origen y el límite de ω² Re G. Reproduzca la trampa: z = a.</p>');
    controles(p, [['z', 'Cero z', 0.1, 6, 1.5, 0.05], ['a', 'a', 0.2, 6, 3, 0.05], ['b', 'b', 0.2, 6, 2, 0.05]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 370 300"></svg><svg viewBox="0 0 370 300"></svg></div>');
    const [svg1, svg2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 3. Interconexión: dos osciladores (C11_Ej10) =====
  (function () {
    const p = panel('lazo'), e = {signo: -1};
    const dib = () => {
      const {a, k, b, x10} = e, sg = e.signo;
      const {t, X} = rk4((t, x) => { const e1 = sg * x[3], e2 = x[1];
        return [x[1], -a * x[0] ** 3 - k * x[1] + e1, x[3], -b * x[2] - x[3] ** 3 + e2]; }, [x10, 0, 0, 0], 25, 0.005);
      const V1 = X.map(x => a * x[0] ** 4 / 4 + x[1] ** 2 / 2), V2 = X.map(x => b * x[2] ** 2 / 2 + x[3] ** 2 / 2);
      const V = V1.map((v, i) => v + V2[i]);
      const top = Math.min(Math.max(...V) * 1.1, 50);
      const {X: PX, Y: PY} = ejes(svg, 760, 300, {l: 52, r: 14, t: 12, b: 34}, [0, 25], [0, top], 't (s)', 'energía');
      const cl = v => dentro(v, 0, top);
      linea(svg, t.map((tt, i) => [PX(tt), PY(cl(V1[i]))]), C.azul);
      linea(svg, t.map((tt, i) => [PX(tt), PY(cl(V2[i]))]), C.coral);
      linea(svg, t.map((tt, i) => [PX(tt), PY(cl(V[i]))]), C.noche, 3);
      let crece = 0; for (let i = 1; i < V.length; i++) crece = Math.max(crece, V[i] - V[i - 1]);
      res_.innerHTML = `V(0) = ${f(V[0], 4)} · max V₂ = ${f(Math.max(...V2), 4)} · V(25) = ${V[V.length - 1].toExponential(2)} · ` +
        (crece <= 1e-9 ? '<b style="color:#2A9D8F">V nunca crece</b>' : `<b style="color:#D1495B">V crece (hasta ${crece.toExponential(1)} por paso): la potencia ya no se cancela</b>`);
    };
    p.insertAdjacentHTML('beforeend', `<p>H₁: ẋ₁ = x₂, ẋ₂ = −a x₁³ − k x₂ + e₁ · H₂: ẋ₃ = x₄, ẋ₄ = −b x₃ − x₄³ + e₂ · e₂ = y₁ y
      e₁ = ∓ y₂. Toda la energía empieza en H₁. Cambie el signo para ver la trampa.</p>
      <div class="exp-controles"><label>Retroalimentación en e₁ <select data-id="signo" style="width:auto">
      <option value="-1">negativa (e₁ = −y₂)</option><option value="1">positiva (e₁ = +y₂)</option></select></label></div>`);
    controles(p, [['a', 'a (resorte de H₁)', 0.2, 3, 1, 0.05], ['k', 'k (fricción de H₁)', 0, 2, 0.5, 0.05],
                  ['b', 'b (resorte de H₂)', 0.2, 4, 2, 0.05], ['x10', 'x₁(0)', 0.1, 2.5, 1.5, 0.05]], e, () => dib());
    p.querySelector('select').addEventListener('change', ev => { e.signo = +ev.target.value; dib(); });
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><svg viewBox="0 0 760 300"></svg>' +
      leyenda([[C.azul, 'V₁'], [C.coral, 'V₂'], [C.noche, 'V = V₁ + V₂']]));
    const svg = p.querySelector('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();

  // ===== 4. Distribución de agua (C11_Ej13 / Ej14) =====
  (function () {
    const p = panel('agua'), e = {};
    const dib = () => {
      const {Q, r, c3, q30} = e, vm = 2, c = [0.6, 1.0, c3];
      const F = (t, x) => { const v = x.slice(0, 3).map(s => Math.max(s, 0)), q = x.slice(3);
        const Fi = v.map(s => r * (1 - s / vm)), Fb = q.reduce((s, qi, i) => s + qi * Fi[i], 0) / Q;
        return [...q.map((qi, i) => qi - c[i] * Math.sqrt(v[i])), ...q.map((qi, i) => qi * (Fi[i] - Fb))]; };
      const q0 = [(Q - q30) / 2, (Q - q30) / 2, q30];
      const {t, X} = rk4(F, [0.4, 0.4, 0.4, ...q0], 60, 0.01);
      const sc = c.reduce((s, x) => s + x, 0), vs = Q * Q / sc / sc, qs = c.map(ci => ci * Q / sc);
      const Vt = X.map(x => r / (2 * Q * vm) * x.slice(0, 3).reduce((s, v) => s + (v - vs) ** 2, 0) +
        (x[5] > 0 ? qs.reduce((s, qi, i) => s + qi * Math.log(qi / x[3 + i]), 0) / Q : NaN));
      const top = Math.max(1.2, ...X.map(x => Math.max(x[3], x[4], x[5]))) * 1.05;
      const {X: PX, Y: PY} = ejes(svg1, 370, 280, {l: 44, r: 10, t: 12, b: 34}, [0, 60], [0, top], 't (s)', 'v (línea) · q (trazos)');
      [C.azul, C.coral, C.violeta].forEach((col, i) => {
        linea(svg1, t.map((tt, j) => [PX(tt), PY(Math.min(top, Math.max(0, X[j][i])))]), col, 2.2);
        linea(svg1, t.map((tt, j) => [PX(tt), PY(Math.min(top, X[j][3 + i]))]), col, 1.6, '5 3'); });
      linea(svg1, [[PX(0), PY(vs)], [PX(60), PY(vs)]], C.gris, 1, '2 3');
      const lv = Vt.map(v => Math.log10(Math.max(v, 1e-12)));
      const {X: X2, Y: Y2} = ejes(svg2, 370, 280, {l: 44, r: 10, t: 12, b: 34}, [0, 60], [-12, 2], 't (s)', 'log₁₀ V');
      linea(svg2, t.map((tt, j) => [X2(tt), Y2(lv[j])]), C.noche, 2.4);
      res_.innerHTML = `v* = ${f(vs, 4)}${vs >= vm ? ' <b style="color:#D1495B">(≥ v_m: no físico)</b>' : ''} · q* = (${qs.map(x => f(x, 3)).join(', ')}) ·
        v(60) = (${X[X.length - 1].slice(0, 3).map(x => f(x, 3)).join(', ')}) · q(60) = (${X[X.length - 1].slice(3).map(x => f(x, 3)).join(', ')})` +
        (q30 === 0 ? ' · <b style="color:#D1495B">q₃(0) = 0: la cara es invariante, el tanque 3 se vacía (V₂ = ∞)</b>' : '');
    };
    p.insertAdjacentHTML('beforeend', '<p>Tres tanques con descargas c = (0.6, 1, c₃), caudal total Q repartido por el replicador, v(0) = 0.4 en los tres. Ponga q₃(0) = 0 o muy pequeño (trampa de las caras).</p>');
    controles(p, [['Q', 'Caudal total Q', 0.5, 3, 2, 0.05], ['r', 'Pago máximo r', 0.2, 4, 2, 0.1],
                  ['c3', 'Demanda c₃', 0.3, 3, 1.4, 0.05], ['q30', 'q₃(0)', 0, 1, 0.5, 0.0001]], e, () => dib());
    p.insertAdjacentHTML('beforeend', '<div class="exp-resumen"></div><div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem"><svg viewBox="0 0 370 280"></svg><svg viewBox="0 0 370 280"></svg></div>' +
      leyenda([[C.azul, 'tanque 1'], [C.coral, 'tanque 2'], [C.violeta, 'tanque 3'], [C.noche, 'V = V₁ + V₂']]));
    const [svg1, svg2] = p.querySelectorAll('svg'), res_ = p.querySelector('.exp-resumen');
    dib();
  })();
})();
